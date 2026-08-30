/**
 * 역할: MypageOrderService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: MypageOrderService
 * - 사용: MypageOrderMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.mypage.order.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.mypage.order.mapper.MypageOrderMapper;
import com.petcare.petcare.mypage.order.vo.MypageOrderItemVO;
import com.petcare.petcare.mypage.order.vo.MypageOrderVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;

@Service
public class MypageOrderServiceImpl implements MypageOrderService {

    //지윤 26.07.23 추가: 취소신청 시 사업자에게 알림 보내기 위함
    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Autowired
    private MypageOrderMapper mypageOrderMapper;

    //지윤 26.07.20 추가: 리뷰 사진 첨부용 (biz 상품이미지 업로드와 동일한 서비스 재사용)
    @Autowired
    private FileService fileService;

    //지윤 26.07.20 추가: 주문 목록 조회 + 주문마다 상품목록도 같이 채워넣음 (화면에서 카드 하나에 상품 여러 개 보여줘야 해서)
  @Override
    public List<MypageOrderVO> getOrderList(Long memberNo, String statusCd) {
        List<MypageOrderVO> list = mypageOrderMapper.selectOrderList(memberNo, statusCd);
        for (MypageOrderVO o : list) {
            o.setItemList(mypageOrderMapper.selectOrderItems(o.getOrderId()));
            fillStatusBadge(o);
        }
        return list;
    }

   //지윤 26.07.20 수정: 사진 첨부 처리 추가. 리뷰 등록 성공하면 REVIEW_ID 재조회해서 이미지마다 FileService로 저장
    //지윤 26.07.28 수정: 50자 미만이라고 등록 자체를 막던 것 -> 절대 최소치(10자)만 등록 차단하도록 완화.
    //10자 이상~REVIEW_MIN_LENGTH(정책값, 기본 50) 미만이면 등록은 허용하되 포인트는 지급 안 함(0 반환).
    //정상적으로 등록됐는데 포인트가 0인 경우와, 아예 등록 실패(null)를 구분해야 해서 반환값 의미가 달라짐:
    //null = 등록 자체 실패(10자 미만/본인주문아님/중복작성), 0 이상 숫자 = 등록 성공(지급 포인트, 0일 수도 있음)
    @Override
    public Integer writeReview(Long memberNo, Long orderItemId, Double rating, String content,
                                List<MultipartFile> images) throws Exception {
        final int ABSOLUTE_MIN_LENGTH = 10; //지윤 26.07.28 추가: 이 밑으로는 포인트 여부와 무관하게 등록 자체를 차단하는 절대 최소치
        int pointMinLength = Integer.parseInt(mypageOrderMapper.selectPolicyValue("REVIEW_MIN_LENGTH"));
        if (content == null || content.trim().length() < ABSOLUTE_MIN_LENGTH) {
            return null;
        }

        // 2026/08/13 장우철 — INSERT에서 구매확정·환불상태 검증. 미확정/환불건은 0건
        int inserted = mypageOrderMapper.insertProductReview(orderItemId, memberNo, rating, content);
        if (inserted == 0) return null;

        Long reviewId = mypageOrderMapper.selectReviewIdByOrderItem(orderItemId);
        boolean hasImage = false;
        if (images != null && !images.isEmpty()) {
            for (MultipartFile image : images) {
                if (image != null && !image.isEmpty()) {
                    fileService.uploadFile(image, "REVIEW", reviewId);
                    hasImage = true;
                }
            }
        }

        //지윤 26.07.28 추가: 포인트 지급 최소 글자수(정책값)를 못 채웠으면 등록은 되지만 포인트는 0으로 처리
        if (content.trim().length() < pointMinLength) {
            return 0;
        }

        String policyKey = hasImage ? "REVIEW_PHOTO" : "REVIEW_TEXT";
        int earnPoint = Integer.parseInt(mypageOrderMapper.selectPolicyValue(policyKey));
        int currentBalance = mypageOrderMapper.selectMemberPointBalance(memberNo);
        int newBalance = currentBalance + earnPoint;
        mypageOrderMapper.addMemberPoint(memberNo, newBalance);
        mypageOrderMapper.insertPointEarnHistory(memberNo, earnPoint, newBalance, "REVIEW", "REVIEW", reviewId);

        return earnPoint;
    }

    //지윤 26.07.20 추가: 주문상세보기 1건 + 상품목록 (본인 주문 아니면 null 그대로 반환)
    @Override
    public MypageOrderVO getOrderDetail(Long memberNo, Long orderId) {
        MypageOrderVO order = mypageOrderMapper.selectOrderDetail(orderId, memberNo);
        if (order != null) {
            order.setItemList(mypageOrderMapper.selectOrderItems(order.getOrderId()));
            fillStatusBadge(order);
        }
        return order;
    }

    //지윤 26.07.30 추가: 같은 결제(orderGroupId)로 묶인 사업자별 주문을 전부 모아서 반환.
    //클릭한 orderId가 그룹에 속하지 않는(orderGroupId가 없는) 예전 단일주문 데이터면, 그 주문 하나만 담긴 리스트로 대체함
    @Override
    public java.util.List<MypageOrderVO> getOrderGroupDetail(Long memberNo, Long orderId) {
        MypageOrderVO clicked = mypageOrderMapper.selectOrderDetail(orderId, memberNo);
        if (clicked == null) return java.util.Collections.emptyList();

        java.util.List<MypageOrderVO> group;
        if (clicked.getOrderGroupId() != null) {
            group = mypageOrderMapper.selectOrdersByGroupId(clicked.getOrderGroupId(), memberNo);
        } else {
            group = new java.util.ArrayList<>();
            group.add(clicked);
        }

        for (MypageOrderVO o : group) {
            o.setItemList(mypageOrderMapper.selectOrderItems(o.getOrderId()));
            fillStatusBadge(o);
        }
        return group;
    }

    // 2026/08/13 장우철 — #7: 전부환불완료/부분환불/환불진행중 뱃지
    private void fillStatusBadge(MypageOrderVO o) {
        if (o == null) {
            return;
        }
        if ("PENDING".equals(o.getClaimStatus())) {
            o.setStatusBadge("CANCEL_REQUEST");
            return;
        }
        List<MypageOrderItemVO> items = o.getItemList();
        int total = items == null ? 0 : items.size();
        int returnDone = 0;
        int returnActive = 0;
        int returnAny = 0;
        if (items != null) {
            for (MypageOrderItemVO it : items) {
                String r = it.getReturnStatusCd();
                if ("DONE".equals(r)) {
                    returnDone++;
                    returnAny++;
                } else if ("REQUESTED".equals(r) || "RETURNING".equals(r)) {
                    returnActive++;
                    returnAny++;
                }
            }
        }
        if (total > 0 && returnDone == total) {
            o.setStatusBadge("REFUND_DONE");
            return;
        }
        if (returnAny > 0 && returnAny < total) {
            o.setStatusBadge("PARTIAL_REFUND");
            return;
        }
        if (returnActive > 0) {
            o.setStatusBadge("REFUND_PROGRESS");
            return;
        }
        if ("CANCEL".equals(o.getOrderStatus())) {
            o.setStatusBadge("CANCEL");
            return;
        }
        if ("DONE".equals(o.getOrderStatus()) && "Y".equals(o.getConfirmYn())) {
            o.setStatusBadge("CONFIRMED");
            return;
        }
        o.setStatusBadge(o.getOrderStatus());
    }

//지윤 26.07.22 추가: 주문취소 신청 (실제 조건 체크는 매퍼 UPDATE의 WHERE절에서 함, 여기선 결과만 판단)
    //지윤 26.07.23 수정: 성공하면 사업자에게 알림도 같이 전송
    @Override
    public boolean requestCancel(Long memberNo, Long orderId, String reason) {
        int updated = mypageOrderMapper.requestCancel(orderId, memberNo, reason);
        if (updated > 0) {
            Long bizMemberNo = mypageOrderMapper.selectBizMemberNoByOrderId(orderId);
            MypageOrderVO order = mypageOrderMapper.selectOrderDetail(orderId, memberNo);
            mypageNotifyService.sendCancelRequestNotification(bizMemberNo, order.getOrderNo(), reason);
        }
        return updated > 0;
    }

    //지윤 26.07.23 추가: 구매확정 처리 (DONE 상태 주문만, 정책 % 적립)
    // 2026/08/04 장우철 — 부분 확정: 환불중/완료 상품 제외, 확정 대상 TOTAL_PRICE 합계 기준 적립
    @Override
    public Integer confirmPurchase(Long memberNo, Long orderId) {
        int confirmableAmount = mypageOrderMapper.selectConfirmableItemsAmount(orderId);
        if (confirmableAmount <= 0) return null;

        int updated = mypageOrderMapper.confirmPurchaseOrder(orderId, memberNo);
        if (updated == 0) return null;

        mypageOrderMapper.confirmPurchaseItems(orderId);

        int rate = Integer.parseInt(mypageOrderMapper.selectPolicyValue("PURCHASE_RATE"));
        int earnPoint = confirmableAmount * rate / 100;

        int currentBalance = mypageOrderMapper.selectMemberPointBalance(memberNo);
        int newBalance = currentBalance + earnPoint;
        mypageOrderMapper.addMemberPoint(memberNo, newBalance);
        mypageOrderMapper.insertPointEarnHistory(memberNo, earnPoint, newBalance, "PURCHASE_CONFIRM", "ORDER", orderId);

        return earnPoint;
    }

    // 2026/08/04 장우철 — 환불 가능 상품 조회
    @Override
    public MypageOrderItemVO getRefundableItem(Long memberNo, Long orderItemId) {
        return mypageOrderMapper.selectRefundableItem(orderItemId, memberNo);
    }

    // 2026/08/13 장우철 — 반송비 3,000원 기록 (단순변심 USER 선불·환불 미차감 / 상품이상 BIZ 환급)
    private static final int RETURN_FEE_FIXED = 3000;

    @Override
    public String requestRefund(Long memberNo, Long orderItemId, String reasonCd, String content,
                                List<MultipartFile> images) throws Exception {
        if (!"CHANGE_OF_MIND".equals(reasonCd) && !"DEFECT".equals(reasonCd)) {
            return "환불 유형을 선택해 주세요.";
        }
        if (content == null || content.isBlank()) {
            return "신청 내용을 입력해 주세요.";
        }
        if ("DEFECT".equals(reasonCd)) {
            boolean hasPhoto = false;
            if (images != null) {
                for (MultipartFile img : images) {
                    if (img != null && !img.isEmpty()) {
                        hasPhoto = true;
                        break;
                    }
                }
            }
            if (!hasPhoto) {
                return "상품이상 환불은 사진을 1장 이상 첨부해 주세요.";
            }
        }

        MypageOrderItemVO item = mypageOrderMapper.selectRefundableItem(orderItemId, memberNo);
        if (item == null) {
            return "환불 신청할 수 없는 상품입니다. (배송중·배송완료·미확정만 가능)";
        }

        boolean defect = "DEFECT".equals(reasonCd);
        int returnFee = RETURN_FEE_FIXED;
        String feePayer = defect ? "BIZ" : "USER";
        int updated = mypageOrderMapper.requestItemRefund(
                orderItemId, reasonCd, content.trim(), returnFee, feePayer);
        if (updated == 0) {
            return "이미 환불 진행 중이거나 신청할 수 없습니다.";
        }

        if ("DEFECT".equals(reasonCd) && images != null) {
            for (MultipartFile image : images) {
                if (image != null && !image.isEmpty()) {
                    fileService.uploadFile(image, "ORDER_RETURN", orderItemId);
                }
            }
        }

        Long bizMemberNo = mypageOrderMapper.selectBizMemberNoByOrderItemId(orderItemId);
        String orderNo = mypageOrderMapper.selectOrderNoByOrderItemId(orderItemId);
        mypageNotifyService.sendRefundRequestNotification(
                bizMemberNo, orderNo, item.getProductName(), reasonCd);

        return null;
    }
}