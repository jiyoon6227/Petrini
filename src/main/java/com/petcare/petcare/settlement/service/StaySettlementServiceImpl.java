/**
 * 역할: 숙소 정산 계산·저장 구현체
 * 2026/07/30 장우철 — 숙소 정산 구현순서 1-4 / 1-5 / 1-6
 *
 * 규칙
 * - 수수료는 상품(예약) 원금에만 적용
 * - 기본 수수료율 10% (TB_BUSINESS.FEE_RATE 없으면)
 * - 월정산/중간정산 동일 계산식
 * - 저장: SETTLEMENT 1건 후 ITEM 다건 (실패 시 전체 롤백)
 * - 중복 방지: 조회 NOT EXISTS + 저장 직전 RESV_ID 재검사 + UNIQUE INDEX
 *
 * 연결
 * - implements: StaySettlementService
 * - 사용: StaySettlementMapper
 */
package com.petcare.petcare.settlement.service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.settlement.mapper.StaySettlementMapper;
import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StaySettlementRequestVO;
import com.petcare.petcare.settlement.vo.StaySettlementSummaryVO;
import com.petcare.petcare.settlement.vo.StaySettlementVO;

@Service
public class StaySettlementServiceImpl implements StaySettlementService {

    /** 숙소 등록 시 기본 수수료율(%) — 캔버스 잠금 */
    private static final double DEFAULT_STAY_FEE_RATE = 10.0;

    @Autowired
    private StaySettlementMapper staySettlementMapper;

    @Autowired
    private MypageNotifyService mypageNotifyService;

    /**
     * 건별 금액 채우기
     * - resvAmount, feeRate 필요
     * - feeRate 없으면 기본 10
     */
    @Override
    public void fillItemAmounts(StaySettlementItemVO item) {
        if (item == null) {
            return;
        }

        long resvAmount = item.getResvAmount() == null ? 0L : item.getResvAmount();
        double feeRate = item.getFeeRate() == null ? DEFAULT_STAY_FEE_RATE : item.getFeeRate();

        // 수수료 = 원금 * 율 / 100 (원 단위 반올림)
        long feeAmount = Math.round(resvAmount * feeRate / 100.0);
        long settleAmount = resvAmount - feeAmount;

        item.setFeeRate(feeRate);           // 적용한 수수료율 보존
        item.setFeeAmount(feeAmount);       // 건별 수수료
        item.setSettleAmount(settleAmount); // 건별 실정산금

        // 저장 전 초안 상태 — 1-5 저장 시 INCLUDED 로 확정
        if (item.getStatusCd() == null || item.getStatusCd().isBlank()) {
            item.setStatusCd("INCLUDED");
        }
        // 2026/07/31 장우철 — R3-5: STAY / CANCEL_FEE
        if (item.getItemType() == null || item.getItemType().isBlank()) {
            item.setItemType("STAY");
        }
    }

    /**
     * 여러 건 계산 + 마스터 합산
     */
    @Override
    public StaySettlementVO aggregateItems(Long bizNo, List<StaySettlementItemVO> items) {
        StaySettlementVO master = new StaySettlementVO();
        master.setBizNo(bizNo);
        master.setBizType("STAY");

        List<StaySettlementItemVO> safeItems =
                items == null ? new ArrayList<>() : items;

        long totalSales = 0L; // 원금 합
        long totalFee = 0L;   // 수수료 합
        long settleSum = 0L;  // 실정산 합
        Double masterFeeRate = null;

        for (StaySettlementItemVO item : safeItems) {
            fillItemAmounts(item);
            totalSales += item.getResvAmount() == null ? 0L : item.getResvAmount();
            totalFee += item.getFeeAmount() == null ? 0L : item.getFeeAmount();
            settleSum += item.getSettleAmount() == null ? 0L : item.getSettleAmount();
            // 마스터 표시용 수수료율: 첫 건 기준 (사업자 단일율)
            if (masterFeeRate == null && item.getFeeRate() != null) {
                masterFeeRate = item.getFeeRate();
            }
        }

        master.setItems(safeItems);
        master.setTotalSales(totalSales);
        master.setTotalFee(totalFee);
        master.setSettleAmount(settleSum);
        master.setFeeAmount(totalFee);
        master.setFeeRate(masterFeeRate != null ? masterFeeRate : resolveFeeRate(bizNo));
        master.setPayAmount(totalSales); // 호환: 결제 원금 합

        // 초안 상태 (아직 DB 미저장)
        master.setSettleStatus("PENDING");
        master.setPayStatus("WAIT");

        return master;
    }

    /**
     * 1-3 조회 + 1-4 계산 = 저장 전 정산 초안
     */
    @Override
    public StaySettlementVO buildStaySettlementDraft(
            Long bizNo,
            Date periodStart,
            Date periodEnd,
            Long roomId,
            String requestType,
            String requestScope) {

        // 대상 예약 (DONE + 미정산 + 기간 + 선택 객실) — 조회 단계 중복 제외
        List<StaySettlementItemVO> targets = staySettlementMapper.selectUnsettleStayTargets(
                bizNo, periodStart, periodEnd, roomId);

        StaySettlementVO master = aggregateItems(bizNo, targets);
        master.setPeriodStart(periodStart);
        master.setPeriodEnd(periodEnd);
        master.setRoomId(roomId);
        master.setRequestType(requestType);   // REGULAR / ADHOC
        master.setRequestScope(requestScope); // ALL / ROOM
        master.setSettleMonth(toSettleMonth(periodStart)); // YYYY-MM

        return master;
    }

    /**
     * 1-5 저장 트랜잭션 + 1-6 중복 방지
     * - 저장 직전 RESV_ID 재검사
     * - 마스터 insert → 각 ITEM 에 settleId 넣고 insert
     * - UNIQUE 위반 시 메시지로 변환
     */
    @Override
    @Transactional
    public StaySettlementVO saveStaySettlement(StaySettlementVO draft) {
        if (draft == null) {
            throw new IllegalArgumentException("정산 데이터가 없습니다.");
        }
        if (draft.getBizNo() == null) {
            throw new IllegalArgumentException("사업자번호(bizNo)가 없습니다.");
        }
        if (draft.getItems() == null || draft.getItems().isEmpty()) {
            throw new IllegalArgumentException("정산 대상 예약이 없어 저장할 수 없습니다.");
        }

        // 1-6: 요청 목록 안·DB 이미 정산 건 검사
        assertNoDuplicateResv(draft.getItems());

        // 저장 직전 금액 재계산 (화면/호출부 조작 방지)
        StaySettlementVO master = aggregateItems(draft.getBizNo(), draft.getItems());
        master.setPeriodStart(draft.getPeriodStart());
        master.setPeriodEnd(draft.getPeriodEnd());
        master.setRoomId(draft.getRoomId());
        master.setRequestType(draft.getRequestType());
        master.setRequestScope(draft.getRequestScope());
        master.setRequestId(draft.getRequestId());
        master.setSettleMonth(draft.getSettleMonth() != null
                ? draft.getSettleMonth()
                : toSettleMonth(draft.getPeriodStart()));
        master.setRequestedAt(draft.getRequestedAt());
        master.setApprovedAt(draft.getApprovedAt());

        // 관리자 지급 전이면 PENDING / WAIT 유지
        if (master.getSettleStatus() == null) {
            master.setSettleStatus("PENDING");
        }
        if (master.getPayStatus() == null) {
            master.setPayStatus("WAIT");
        }

        try {
            // 1) 마스터 저장 → settleId 발급
            staySettlementMapper.insertSettlement(master);

            // 2) 상세 다건 저장
            for (StaySettlementItemVO item : master.getItems()) {
                item.setSettleId(master.getSettleId());
                fillItemAmounts(item);
                if (item.getStatusCd() == null || item.getStatusCd().isBlank()) {
                    item.setStatusCd("INCLUDED");
                }
                staySettlementMapper.insertSettlementItem(item);
            }
        } catch (DataIntegrityViolationException e) {
            // UX_SETTLE_ITEM_RESV 등 UNIQUE 충돌 (동시 요청 레이스)
            throw new IllegalStateException(
                    "이미 정산된 예약이 포함되어 저장할 수 없습니다. 목록을 다시 조회해 주세요.", e);
        }

        return master;
    }

    /** 초안 생성 후 바로 저장 */
    @Override
    @Transactional
    public StaySettlementVO createAndSaveStaySettlement(
            Long bizNo,
            Date periodStart,
            Date periodEnd,
            Long roomId,
            String requestType,
            String requestScope) {

        StaySettlementVO draft = buildStaySettlementDraft(
                bizNo, periodStart, periodEnd, roomId, requestType, requestScope);
        return saveStaySettlement(draft);
    }

    /**
     * 2-1 상단 요약
     * - 조회 실패/bizNo null 이면 0으로 채운 VO 반환 (화면 NPE 방지)
     */
    @Override
    public StaySettlementSummaryVO getStaySettlementSummary(Long bizNo) {
        StaySettlementSummaryVO empty = new StaySettlementSummaryVO();
        empty.setPendingAmount(0L);
        empty.setPaidAmount(0L);
        empty.setTotalFeeAmount(0L);

        if (bizNo == null) {
            return empty;
        }

        StaySettlementSummaryVO summary = staySettlementMapper.selectStaySettlementSummary(bizNo);
        if (summary == null) {
            return empty;
        }
        if (summary.getPendingAmount() == null) {
            summary.setPendingAmount(0L);
        }
        if (summary.getPaidAmount() == null) {
            summary.setPaidAmount(0L);
        }
        if (summary.getTotalFeeAmount() == null) {
            summary.setTotalFeeAmount(0L);
        }
        return summary;
    }

    /**
     * 2-2 정산 목록
     */
    @Override
    public List<StaySettlementVO> getStaySettlementList(Long bizNo, String settleMonth, String statusCd) {
        if (bizNo == null) {
            return new ArrayList<>();
        }
        String month = (settleMonth == null || settleMonth.isBlank() || "all".equalsIgnoreCase(settleMonth))
                ? null : settleMonth;
        String status = (statusCd == null || statusCd.isBlank() || "all".equalsIgnoreCase(statusCd))
                ? null : statusCd.toLowerCase();
        List<StaySettlementVO> list = staySettlementMapper.selectStaySettlementList(bizNo, month, status);
        return list == null ? new ArrayList<>() : list;
    }

    /** 2-2 필터용 월 목록 */
    @Override
    public List<String> getStaySettlementMonths(Long bizNo) {
        if (bizNo == null) {
            return new ArrayList<>();
        }
        List<String> months = staySettlementMapper.selectStaySettlementMonths(bizNo);
        return months == null ? new ArrayList<>() : months;
    }

    /**
     * 2-4 정산 상세 ITEM
     */
    @Override
    public List<StaySettlementItemVO> getStaySettlementItems(Long bizNo, Long settleId) {
        if (bizNo == null || settleId == null) {
            return new ArrayList<>();
        }
        List<StaySettlementItemVO> items =
                staySettlementMapper.selectStaySettlementItems(bizNo, settleId);
        return items == null ? new ArrayList<>() : items;
    }

    /**
     * 1-6 중복 방지 1차
     * - 같은 요청 안에 RESV_ID 중복
     * - DB에 이미 ITEM 으로 들어간 예약
     */
    private void assertNoDuplicateResv(List<StaySettlementItemVO> items) {
        List<Long> resvIds = items.stream()
                .map(StaySettlementItemVO::getResvId)
                .filter(id -> id != null)
                .collect(Collectors.toList());

        if (resvIds.isEmpty()) {
            throw new IllegalArgumentException("정산 상세에 예약 ID(resvId)가 없습니다.");
        }

        // 요청 목록 내부 중복
        Set<Long> unique = new HashSet<>();
        for (Long resvId : resvIds) {
            if (!unique.add(resvId)) {
                throw new IllegalStateException("같은 예약을 한 정산에 두 번 넣을 수 없습니다. resvId=" + resvId);
            }
        }

        // DB 이미 정산된 예약
        List<Long> already = staySettlementMapper.selectAlreadySettledResvIds(resvIds);
        if (already != null && !already.isEmpty()) {
            throw new IllegalStateException(
                    "이미 정산된 예약이 포함되어 있습니다. resvId=" + already);
        }
    }

    /** DB 수수료율 조회, 없으면 기본 10 */
    private double resolveFeeRate(Long bizNo) {
        Double rate = staySettlementMapper.selectStayFeeRate(bizNo);
        return rate == null ? DEFAULT_STAY_FEE_RATE : rate;
    }

    /** 정산월 문자열 (예: 2026-07) */
    private String toSettleMonth(Date periodStart) {
        if (periodStart == null) {
            return null;
        }
        return new SimpleDateFormat("yyyy-MM").format(periodStart);
    }

    /**
     * 4-2 중간정산 요청 등록
     * 시작일 = 컷오프가 속한 달 1일 고정
     */
    @Override
    @Transactional
    public StaySettlementRequestVO createMidSettlementRequest(
            Long bizNo,
            String requestScope,
            Long roomId,
            Date targetEnd,
            String requestMemo) {

        if (bizNo == null) {
            throw new IllegalArgumentException("사업자번호가 없습니다.");
        }
        if (targetEnd == null) {
            throw new IllegalArgumentException("대상 종료일(컷오프)을 입력하세요.");
        }

        String scope = requestScope == null ? "" : requestScope.trim().toUpperCase();
        if (!"ALL".equals(scope) && !"ROOM".equals(scope)) {
            throw new IllegalArgumentException("정산 범위는 ALL 또는 ROOM 만 가능합니다.");
        }

        Long resolvedRoomId = null;
        if ("ROOM".equals(scope)) {
            if (roomId == null) {
                throw new IllegalArgumentException("특정 객실 범위일 때 객실을 선택하세요.");
            }
            if (staySettlementMapper.countRoomOwnedByBiz(bizNo, roomId) <= 0) {
                throw new IllegalArgumentException("해당 객실이 이 숙소에 없습니다.");
            }
            resolvedRoomId = roomId;
        }

        // 잠긴 규칙: 시작일 = 해당 월 1일
        Date targetStart = firstDayOfMonth(targetEnd);
        Date endDay = truncateDate(targetEnd);
        if (endDay.before(targetStart)) {
            throw new IllegalArgumentException("종료일이 시작일보다 빠를 수 없습니다.");
        }

        if (staySettlementMapper.countRequestedByBiz(bizNo) > 0) {
            throw new IllegalStateException("이미 요청대기(REQUESTED) 중인 중간정산이 있습니다. 승인/거절 후 다시 요청하세요.");
        }

        // 5-2: 동일 기간·범위(ALL/ROOM+객실) 로 이미 REQUESTED/APPROVED 가 있으면 차단
        if (staySettlementMapper.countSamePeriodScopeRequest(
                bizNo, scope, resolvedRoomId, targetStart, endDay) > 0) {
            throw new IllegalStateException(
                    "동일 기간·객실 범위의 중간정산 요청이 이미 있습니다. (요청대기 또는 승인완료)");
        }

        // 신청 단계: 미정산 대상 0건이면 요청 자체 불가 (승인 시 검사와 이중 방어)
        List<StaySettlementItemVO> targets = staySettlementMapper.selectUnsettleStayTargets(
                bizNo, targetStart, endDay, resolvedRoomId);
        if (targets == null || targets.isEmpty()) {
            throw new IllegalArgumentException(
                    "정산 대상 예약이 없어 요청할 수 없습니다. (체크아웃 완료·미정산 건 없음 / 취소·보류·환불제외)");
        }

        StaySettlementRequestVO req = new StaySettlementRequestVO();
        req.setBizNo(bizNo);
        req.setRequestScope(scope);
        req.setRoomId(resolvedRoomId);
        req.setTargetStart(targetStart);
        req.setTargetEnd(endDay);
        req.setStatusCd("REQUESTED");
        req.setRequestMemo(trimToNull(requestMemo));

        staySettlementMapper.insertSettlementRequest(req);
        return staySettlementMapper.selectSettlementRequestById(req.getRequestId());
    }

    @Override
    public StaySettlementRequestVO getSettlementRequest(Long requestId) {
        if (requestId == null) {
            return null;
        }
        return staySettlementMapper.selectSettlementRequestById(requestId);
    }

    /**
     * 4-4 승인 → 부분 정산 생성
     * 4-5: buildStaySettlementDraft → selectUnsettleStayTargets 가
     *      이미 TB_SETTLEMENT_ITEM 에 있는 RESV 제외
     */
    @Override
    @Transactional
    public StaySettlementVO approveMidSettlementRequest(Long requestId) {
        StaySettlementRequestVO req = staySettlementMapper.selectSettlementRequestById(requestId);
        if (req == null) {
            throw new IllegalArgumentException("중간정산 요청을 찾을 수 없습니다.");
        }
        if (!"REQUESTED".equals(req.getStatusCd())) {
            throw new IllegalStateException("요청대기(REQUESTED) 상태의 건만 승인할 수 있습니다. 현재=" + req.getStatusCd());
        }

        Long roomId = "ROOM".equalsIgnoreCase(req.getRequestScope()) ? req.getRoomId() : null;
        String scope = req.getRequestScope() == null ? "ALL" : req.getRequestScope().toUpperCase();

        StaySettlementVO draft = buildStaySettlementDraft(
                req.getBizNo(),
                req.getTargetStart(),
                req.getTargetEnd(),
                roomId,
                "ADHOC",
                scope);
        draft.setRequestId(req.getRequestId());
        draft.setRequestedAt(req.getRequestedAt());
        draft.setApprovedAt(new Date());
        // 5-3: 마스터 SETTLE_STATUS=PENDING(지급 전), PAY_STATUS=WAIT(지급대기)
        draft.setSettleStatus("PENDING");
        draft.setPayStatus("WAIT");

        StaySettlementVO saved = saveStaySettlement(draft);

        int updated = staySettlementMapper.updateSettlementRequestApproved(requestId);
        if (updated <= 0) {
            throw new IllegalStateException("요청 승인 상태 변경에 실패했습니다. (동시 처리 가능)");
        }

        // 5-4 B: 사이트 내 알림 (이메일 아님)
        notifyMidSettleApproved(req, saved);
        return saved;
    }

    /** 4-3 거절 */
    @Override
    @Transactional
    public void rejectMidSettlementRequest(Long requestId, String rejectReason) {
        StaySettlementRequestVO req = staySettlementMapper.selectSettlementRequestById(requestId);
        if (req == null) {
            throw new IllegalArgumentException("중간정산 요청을 찾을 수 없습니다.");
        }
        if (!"REQUESTED".equals(req.getStatusCd())) {
            throw new IllegalStateException("요청대기(REQUESTED) 상태의 건만 거절할 수 있습니다.");
        }
        String reason = trimToNull(rejectReason);
        if (reason == null) {
            throw new IllegalArgumentException("거절 사유를 입력하세요.");
        }
        int updated = staySettlementMapper.updateSettlementRequestRejected(requestId, reason);
        if (updated <= 0) {
            throw new IllegalStateException("요청 거절 처리에 실패했습니다.");
        }

        // 5-4 C: 사이트 내 알림 (거절 사유 포함)
        notifyMidSettleRejected(req, reason);
    }

    private void notifyMidSettleApproved(StaySettlementRequestVO req, StaySettlementVO saved) {
        try {
            Long memberNo = staySettlementMapper.selectMemberNoByBizNo(req.getBizNo());
            String bizName = staySettlementMapper.selectBizNameByBizNo(req.getBizNo());
            mypageNotifyService.sendStayMidSettleApproveNotification(
                    memberNo,
                    bizName,
                    formatDate(req.getTargetStart()),
                    formatDate(req.getTargetEnd()),
                    req.getRequestScope(),
                    saved == null ? null : saved.getSettleAmount());
        } catch (Exception e) {
            // 알림 실패해도 승인 트랜잭션은 유지
        }
    }

    private void notifyMidSettleRejected(StaySettlementRequestVO req, String reason) {
        try {
            Long memberNo = staySettlementMapper.selectMemberNoByBizNo(req.getBizNo());
            String bizName = staySettlementMapper.selectBizNameByBizNo(req.getBizNo());
            mypageNotifyService.sendStayMidSettleRejectNotification(
                    memberNo,
                    bizName,
                    formatDate(req.getTargetStart()),
                    formatDate(req.getTargetEnd()),
                    reason);
        } catch (Exception e) {
            // 알림 실패해도 거절 트랜잭션은 유지
        }
    }

    private String formatDate(Date d) {
        if (d == null) {
            return "-";
        }
        return new SimpleDateFormat("yyyy-MM-dd").format(d);
    }

    /** 컷오프 월의 1일 00:00 */
    private Date firstDayOfMonth(Date day) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(day);
        cal.set(Calendar.DAY_OF_MONTH, 1);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

    private Date truncateDate(Date day) {
        Calendar cal = Calendar.getInstance();
        cal.setTime(day);
        cal.set(Calendar.HOUR_OF_DAY, 0);
        cal.set(Calendar.MINUTE, 0);
        cal.set(Calendar.SECOND, 0);
        cal.set(Calendar.MILLISECOND, 0);
        return cal.getTime();
    }

    private String trimToNull(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
