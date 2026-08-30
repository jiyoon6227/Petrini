/**
 * 역할: 쇼핑 정산 계산·저장 구현체
 * 2026/08/04 장우철 — 쇼핑 정산 S8 (1-3~1-6)
 *
 * 규칙
 * - 수수료는 상품매출에만 적용, 택배비는 패스스루
 * - 기본 수수료율 5% (TB_BUSINESS.FEE_RATE 없으면)
 * - 월정산/중간정산 동일 계산식
 * - 저장: SETTLEMENT 1건 후 ITEM 다건 (실패 시 전체 롤백)
 * - 중복 방지: 조회 NOT EXISTS + 저장 직전 ORDER_ITEM_ID 재검사 + UNIQUE INDEX
 * 2026/08/05 장우철 — S9 사업자 요약/목록/상세
 */
package com.petcare.petcare.settlement.service;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.Date;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.biz.store.vo.BizProductVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.settlement.mapper.StoreSettlementMapper;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementRequestVO;
import com.petcare.petcare.settlement.vo.StoreSettlementSummaryVO;
import com.petcare.petcare.settlement.vo.StoreSettlementVO;

@Service
public class StoreSettlementServiceImpl implements StoreSettlementService {

    /** 쇼핑 등록 시 기본 수수료율(%) — 캔버스 잠금 */
    private static final double DEFAULT_STORE_FEE_RATE = 5.0;

    @Autowired
    private StoreSettlementMapper storeSettlementMapper;

    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Override
    public void fillItemAmounts(StoreSettlementItemVO item) {
        if (item == null) {
            return;
        }

        long itemSales = item.getItemSalesAmount() == null ? 0L : item.getItemSalesAmount();
        long deliveryFee = item.getDeliveryFeeAmount() == null ? 0L : item.getDeliveryFeeAmount();
        double feeRate = item.getFeeRate() == null ? DEFAULT_STORE_FEE_RATE : item.getFeeRate();

        long feeAmount = Math.round(itemSales * feeRate / 100.0);
        // (상품매출 − 수수료) + 택배비
        long settleAmount = (itemSales - feeAmount) + deliveryFee;

        item.setFeeRate(feeRate);
        item.setFeeAmount(feeAmount);
        item.setSettleAmount(settleAmount);
        item.setDeliveryFeeAmount(deliveryFee);
        item.setItemSalesAmount(itemSales);

        if (item.getStatusCd() == null || item.getStatusCd().isBlank()) {
            item.setStatusCd("INCLUDED");
        }
        if (item.getItemType() == null || item.getItemType().isBlank()) {
            item.setItemType("ORDER_ITEM");
        }
    }

    @Override
    public StoreSettlementVO aggregateItems(Long bizNo, List<StoreSettlementItemVO> items) {
        StoreSettlementVO master = new StoreSettlementVO();
        master.setBizNo(bizNo);
        master.setBizType("STORE");

        List<StoreSettlementItemVO> safeItems =
                items == null ? new ArrayList<>() : items;

        long productSales = 0L;
        long deliverySum = 0L;
        long totalFee = 0L;
        long settleSum = 0L;
        Double masterFeeRate = null;

        for (StoreSettlementItemVO item : safeItems) {
            fillItemAmounts(item);
            productSales += item.getItemSalesAmount() == null ? 0L : item.getItemSalesAmount();
            deliverySum += item.getDeliveryFeeAmount() == null ? 0L : item.getDeliveryFeeAmount();
            totalFee += item.getFeeAmount() == null ? 0L : item.getFeeAmount();
            settleSum += item.getSettleAmount() == null ? 0L : item.getSettleAmount();
            if (masterFeeRate == null && item.getFeeRate() != null) {
                masterFeeRate = item.getFeeRate();
            }
        }

        master.setItems(safeItems);
        master.setProductSalesAmount(productSales);
        master.setDeliveryFeeAmount(deliverySum);
        master.setReturnFeeAmount(0L);
        master.setTotalSales(productSales + deliverySum);
        master.setTotalFee(totalFee);
        master.setSettleAmount(settleSum);
        master.setFeeAmount(totalFee);
        master.setFeeRate(masterFeeRate != null ? masterFeeRate : resolveFeeRate(bizNo));
        master.setPayAmount(productSales + deliverySum);

        master.setSettleStatus("PENDING");
        master.setPayStatus("WAIT");

        return master;
    }

    @Override
    public StoreSettlementVO buildStoreSettlementDraft(
            Long bizNo,
            Date periodStart,
            Date periodEnd,
            Long productId,
            String requestType,
            String requestScope) {

        List<StoreSettlementItemVO> targets = storeSettlementMapper.selectUnsettleStoreTargets(
                bizNo, periodStart, periodEnd, productId);

        // 조회에 feeRate 없으면 사업자율로 보정
        Double bizRate = resolveFeeRate(bizNo);
        for (StoreSettlementItemVO item : targets) {
            if (item.getFeeRate() == null) {
                item.setFeeRate(bizRate);
            }
        }

        StoreSettlementVO master = aggregateItems(bizNo, targets);
        master.setPeriodStart(periodStart);
        master.setPeriodEnd(periodEnd);
        master.setProductId(productId);
        master.setRequestType(requestType);
        master.setRequestScope(requestScope);
        master.setSettleMonth(toSettleMonth(periodStart));

        return master;
    }

    @Override
    @Transactional
    public StoreSettlementVO saveStoreSettlement(StoreSettlementVO draft) {
        if (draft == null) {
            throw new IllegalArgumentException("정산 데이터가 없습니다.");
        }
        if (draft.getBizNo() == null) {
            throw new IllegalArgumentException("사업자번호(bizNo)가 없습니다.");
        }
        if (draft.getItems() == null || draft.getItems().isEmpty()) {
            throw new IllegalArgumentException("정산 대상 상품이 없어 저장할 수 없습니다.");
        }

        assertNoDuplicateOrderItems(draft.getItems());

        StoreSettlementVO master = aggregateItems(draft.getBizNo(), draft.getItems());
        master.setPeriodStart(draft.getPeriodStart());
        master.setPeriodEnd(draft.getPeriodEnd());
        master.setProductId(draft.getProductId());
        master.setRequestType(draft.getRequestType());
        master.setRequestScope(draft.getRequestScope());
        master.setRequestId(draft.getRequestId());
        master.setSettleMonth(draft.getSettleMonth() != null
                ? draft.getSettleMonth()
                : toSettleMonth(draft.getPeriodStart()));
        master.setRequestedAt(draft.getRequestedAt());
        master.setApprovedAt(draft.getApprovedAt());

        if (master.getSettleStatus() == null) {
            master.setSettleStatus("PENDING");
        }
        if (master.getPayStatus() == null) {
            master.setPayStatus("WAIT");
        }

        try {
            storeSettlementMapper.insertSettlement(master);

            for (StoreSettlementItemVO item : master.getItems()) {
                item.setSettleId(master.getSettleId());
                fillItemAmounts(item);
                if (item.getStatusCd() == null || item.getStatusCd().isBlank()) {
                    item.setStatusCd("INCLUDED");
                }
                storeSettlementMapper.insertSettlementItem(item);
            }
        } catch (DataIntegrityViolationException e) {
            throw new IllegalStateException(
                    "이미 정산된 주문상품이 포함되어 저장할 수 없습니다. 목록을 다시 조회해 주세요.", e);
        }

        return master;
    }

    @Override
    @Transactional
    public StoreSettlementVO createAndSaveStoreSettlement(
            Long bizNo,
            Date periodStart,
            Date periodEnd,
            Long productId,
            String requestType,
            String requestScope) {

        StoreSettlementVO draft = buildStoreSettlementDraft(
                bizNo, periodStart, periodEnd, productId, requestType, requestScope);
        return saveStoreSettlement(draft);
    }

    
    @Override
    public StoreSettlementSummaryVO getStoreSettlementSummary(Long bizNo) {
        StoreSettlementSummaryVO empty = new StoreSettlementSummaryVO();
        empty.setPendingAmount(0L);
        empty.setPaidAmount(0L);
        empty.setTotalFeeAmount(0L);

        if (bizNo == null) {
            return empty;
        }

        StoreSettlementSummaryVO summary = storeSettlementMapper.selectStoreSettlementSummary(bizNo);
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

    /** 2-2 정산 목록 */
    @Override
    public List<StoreSettlementVO> getStoreSettlementList(Long bizNo, String settleMonth, String statusCd) {
        if (bizNo == null) {
            return new ArrayList<>();
        }
        String month = (settleMonth == null || settleMonth.isBlank() || "all".equalsIgnoreCase(settleMonth))
                ? null : settleMonth;
        String status = (statusCd == null || statusCd.isBlank() || "all".equalsIgnoreCase(statusCd))
                ? null : statusCd.toLowerCase();
        List<StoreSettlementVO> list = storeSettlementMapper.selectStoreSettlementList(bizNo, month, status);
        return list == null ? new ArrayList<>() : list;
    }

    /** 2-2 필터용 월 목록 */
    @Override
    public List<String> getStoreSettlementMonths(Long bizNo) {
        if (bizNo == null) {
            return new ArrayList<>();
        }
        List<String> months = storeSettlementMapper.selectStoreSettlementMonths(bizNo);
        return months == null ? new ArrayList<>() : months;
    }

    /** 2-3 정산 상세 ITEM */
    @Override
    public List<StoreSettlementItemVO> getStoreSettlementItems(Long bizNo, Long settleId) {
        if (bizNo == null || settleId == null) {
            return new ArrayList<>();
        }
        List<StoreSettlementItemVO> items =
                storeSettlementMapper.selectStoreSettlementItems(bizNo, settleId);
        return items == null ? new ArrayList<>() : items;
    }

    @Override
    public List<BizProductVO> getProductsForSettlement(Long bizNo) {
        if (bizNo == null) {
            return new ArrayList<>();
        }
        List<BizProductVO> list = storeSettlementMapper.selectProductsByBiz(bizNo);
        return list == null ? new ArrayList<>() : list;
    }

    /**
     * S10 중간정산 요청 등록
     * 시작일 = 컷오프가 속한 달 1일 고정
     */
    @Override
    @Transactional
    public StoreSettlementRequestVO createMidSettlementRequest(
            Long bizNo,
            String requestScope,
            Long productId,
            Date targetEnd,
            String requestMemo) {

        if (bizNo == null) {
            throw new IllegalArgumentException("사업자번호가 없습니다.");
        }
        if (targetEnd == null) {
            throw new IllegalArgumentException("대상 종료일(컷오프)을 입력하세요.");
        }

        String scope = requestScope == null ? "" : requestScope.trim().toUpperCase();
        if (!"ALL".equals(scope) && !"PRODUCT".equals(scope)) {
            throw new IllegalArgumentException("정산 범위는 ALL 또는 PRODUCT 만 가능합니다.");
        }

        Long resolvedProductId = null;
        if ("PRODUCT".equals(scope)) {
            if (productId == null) {
                throw new IllegalArgumentException("특정 상품 범위일 때 상품을 선택하세요.");
            }
            if (storeSettlementMapper.countProductOwnedByBiz(bizNo, productId) <= 0) {
                throw new IllegalArgumentException("해당 상품이 이 쇼핑몰에 없습니다.");
            }
            resolvedProductId = productId;
        }

        Date targetStart = firstDayOfMonth(targetEnd);
        Date endDay = truncateDate(targetEnd);
        if (endDay.before(targetStart)) {
            throw new IllegalArgumentException("종료일이 시작일보다 빠를 수 없습니다.");
        }

        if (storeSettlementMapper.countRequestedByBiz(bizNo) > 0) {
            throw new IllegalStateException("이미 요청대기(REQUESTED) 중인 중간정산이 있습니다. 승인/거절 후 다시 요청하세요.");
        }

        if (storeSettlementMapper.countSamePeriodScopeRequest(
                bizNo, scope, resolvedProductId, targetStart, endDay) > 0) {
            throw new IllegalStateException(
                    "동일 기간·상품 범위의 중간정산 요청이 이미 있습니다. (요청대기 또는 승인완료)");
        }

        List<StoreSettlementItemVO> targets = storeSettlementMapper.selectUnsettleStoreTargets(
                bizNo, targetStart, endDay, resolvedProductId);
        if (targets == null || targets.isEmpty()) {
            throw new IllegalArgumentException(
                    "정산 대상 주문상품이 없어 요청할 수 없습니다. (구매확정·미정산 건 없음 / 환불중·완료 제외)");
        }

        StoreSettlementRequestVO req = new StoreSettlementRequestVO();
        req.setBizNo(bizNo);
        req.setRequestScope(scope);
        req.setProductId(resolvedProductId);
        req.setTargetStart(targetStart);
        req.setTargetEnd(endDay);
        req.setStatusCd("REQUESTED");
        req.setRequestMemo(trimToNull(requestMemo));

        storeSettlementMapper.insertSettlementRequest(req);
        return storeSettlementMapper.selectSettlementRequestById(req.getRequestId());
    }

    @Override
    public StoreSettlementRequestVO getSettlementRequest(Long requestId) {
        if (requestId == null) {
            return null;
        }
        return storeSettlementMapper.selectSettlementRequestById(requestId);
    }

    @Override
    @Transactional
    public StoreSettlementVO approveMidSettlementRequest(Long requestId) {
        StoreSettlementRequestVO req = storeSettlementMapper.selectSettlementRequestById(requestId);
        if (req == null) {
            throw new IllegalArgumentException("중간정산 요청을 찾을 수 없습니다.");
        }
        if (!"REQUESTED".equals(req.getStatusCd())) {
            throw new IllegalStateException("요청대기(REQUESTED) 상태의 건만 승인할 수 있습니다. 현재=" + req.getStatusCd());
        }

        Long productId = "PRODUCT".equalsIgnoreCase(req.getRequestScope()) ? req.getProductId() : null;
        String scope = req.getRequestScope() == null ? "ALL" : req.getRequestScope().toUpperCase();

        StoreSettlementVO draft = buildStoreSettlementDraft(
                req.getBizNo(),
                req.getTargetStart(),
                req.getTargetEnd(),
                productId,
                "ADHOC",
                scope);
        draft.setRequestId(req.getRequestId());
        draft.setRequestedAt(req.getRequestedAt());
        draft.setApprovedAt(new Date());
        draft.setSettleStatus("PENDING");
        draft.setPayStatus("WAIT");

        StoreSettlementVO saved = saveStoreSettlement(draft);

        int updated = storeSettlementMapper.updateSettlementRequestApproved(requestId);
        if (updated <= 0) {
            throw new IllegalStateException("요청 승인 상태 변경에 실패했습니다. (동시 처리 가능)");
        }

        notifyMidSettleApproved(req, saved);
        return saved;
    }

    @Override
    @Transactional
    public void rejectMidSettlementRequest(Long requestId, String rejectReason) {
        StoreSettlementRequestVO req = storeSettlementMapper.selectSettlementRequestById(requestId);
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
        int updated = storeSettlementMapper.updateSettlementRequestRejected(requestId, reason);
        if (updated <= 0) {
            throw new IllegalStateException("요청 거절 처리에 실패했습니다.");
        }

        notifyMidSettleRejected(req, reason);
    }

    private void notifyMidSettleApproved(StoreSettlementRequestVO req, StoreSettlementVO saved) {
        try {
            Long memberNo = storeSettlementMapper.selectMemberNoByBizNo(req.getBizNo());
            String bizName = storeSettlementMapper.selectBizNameByBizNo(req.getBizNo());
            mypageNotifyService.sendStoreMidSettleApproveNotification(
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

    private void notifyMidSettleRejected(StoreSettlementRequestVO req, String reason) {
        try {
            Long memberNo = storeSettlementMapper.selectMemberNoByBizNo(req.getBizNo());
            String bizName = storeSettlementMapper.selectBizNameByBizNo(req.getBizNo());
            mypageNotifyService.sendStoreMidSettleRejectNotification(
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

    private double resolveFeeRate(Long bizNo) {
        if (bizNo == null) {
            return DEFAULT_STORE_FEE_RATE;
        }
        Double rate = storeSettlementMapper.selectStoreFeeRate(bizNo);
        return rate != null ? rate : DEFAULT_STORE_FEE_RATE;
    }

    private void assertNoDuplicateOrderItems(List<StoreSettlementItemVO> items) {
        Set<Long> seen = new HashSet<>();
        List<Long> ids = new ArrayList<>();
        for (StoreSettlementItemVO item : items) {
            Long id = item.getOrderItemId();
            if (id == null) {
                throw new IllegalArgumentException("주문상품 ID가 없는 정산 대상이 있습니다.");
            }
            if (!seen.add(id)) {
                throw new IllegalStateException("같은 주문상품이 정산 목록에 중복되어 있습니다: " + id);
            }
            ids.add(id);
        }

        List<Long> already = storeSettlementMapper.selectAlreadySettledOrderItemIds(ids);
        if (already != null && !already.isEmpty()) {
            String joined = already.stream().map(String::valueOf).collect(Collectors.joining(", "));
            throw new IllegalStateException("이미 정산된 주문상품이 포함되어 있습니다: " + joined);
        }
    }

    private String toSettleMonth(Date periodStart) {
        if (periodStart == null) {
            return null;
        }
        return new SimpleDateFormat("yyyy-MM").format(periodStart);
    }
}
