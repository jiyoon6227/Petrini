package com.petcare.petcare.mypage.order.service;

import java.util.List;

import com.petcare.petcare.mypage.order.vo.MypageOrderVO;

public interface MypageOrderService {

    // 회원 본인 주문 목록 조회 (상태 필터, 상품목록까지 채워서 반환)
    List<MypageOrderVO> getOrderList(Long memberNo, String statusCd);

    // 사진 첨부(images) 포함. 본인 주문 아니거나 이미 작성했으면 false
    // 반환: null=실패, 아니면 적립된 포인트
    Integer writeReview(Long memberNo, Long orderItemId, Double rating, String content,
                         java.util.List<org.springframework.web.multipart.MultipartFile> images) throws Exception;

    // 주문상세보기 1건 조회 (상품목록 포함, 본인 주문 아니면 null)
    MypageOrderVO getOrderDetail(Long memberNo, Long orderId);

    // 같은 결제(orderGroupId)로 묶인 사업자별 주문을 전부 모아서 반환 (상세보기 결제그룹 단위 표시용)
    java.util.List<MypageOrderVO> getOrderGroupDetail(Long memberNo, Long orderId);

    // 주문취소 신청 (성공하면 true, 조건 안 맞으면 false)
    boolean requestCancel(Long memberNo, Long orderId, String reason);

    // 구매확정 처리. 반환값: null=실패, 아니면 적립된 포인트
    Integer confirmPurchase(Long memberNo, Long orderId);

    // 상품단위 환불 신청
    /** 신청 폼용 상품 조회 (불가하면 null) */
    com.petcare.petcare.mypage.order.vo.MypageOrderItemVO getRefundableItem(Long memberNo, Long orderItemId);

    /**
     * 환불 신청. null=성공, 아니면 에러 메시지.
     * reasonCd: CHANGE_OF_MIND | DEFECT
     */
    String requestRefund(Long memberNo, Long orderItemId, String reasonCd, String content,
                         java.util.List<org.springframework.web.multipart.MultipartFile> images) throws Exception;
}