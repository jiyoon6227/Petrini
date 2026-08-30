/**
 * 역할: 마이페이지 주문 내역 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - mypage/orders.jsp         주문 내역
 *
 * 구현할 기능 예시
 * - 주문 목록·상세 조회
 * - 주문 취소 요청
 *
 * 연결
 * - 구현: MypageOrderServiceImpl
 * - 호출: MypageOrderController
 * - DB: MypageOrderMapper
 *
 * 참고 테이블
 * - TB_ORDER
 * - TB_ORDER_ITEM
 */

package com.petcare.petcare.mypage.order.service;

import java.util.List;

import com.petcare.petcare.mypage.order.vo.MypageOrderVO;

public interface MypageOrderService {

    //지윤 26.07.20 추가: 회원 본인 주문 목록 조회 (상태 필터, 상품목록까지 채워서 반환)
    List<MypageOrderVO> getOrderList(Long memberNo, String statusCd);

    //지윤 26.07.20 수정: 사진 첨부(images) 파라미터 추가. 본인 주문 아니거나 이미 작성했으면 false
    //지윤 26.07.23 수정: 반환타입 boolean -> Integer (null=실패, 아니면 적립된 포인트)
    Integer writeReview(Long memberNo, Long orderItemId, Double rating, String content,
                         java.util.List<org.springframework.web.multipart.MultipartFile> images) throws Exception;

    //지윤 26.07.20 추가: 주문상세보기 1건 조회 (상품목록 포함, 본인 주문 아니면 null)
    MypageOrderVO getOrderDetail(Long memberNo, Long orderId);

    //지윤 26.07.30 추가: 같은 결제(orderGroupId)로 묶인 사업자별 주문을 전부 모아서 반환 (상세보기 결제그룹 단위 표시용)
    java.util.List<MypageOrderVO> getOrderGroupDetail(Long memberNo, Long orderId);

    //지윤 26.07.22 추가: 주문취소 신청 (성공하면 true, 조건 안 맞으면 false)
    boolean requestCancel(Long memberNo, Long orderId, String reason);

    //지윤 26.07.23 추가: 구매확정 처리. 반환값: null=실패, 아니면 적립된 포인트
    Integer confirmPurchase(Long memberNo, Long orderId);

    // 2026/08/04 장우철 — 상품단위 환불 신청
    /** 신청 폼용 상품 조회 (불가하면 null) */
    com.petcare.petcare.mypage.order.vo.MypageOrderItemVO getRefundableItem(Long memberNo, Long orderItemId);

    /**
     * 환불 신청. null=성공, 아니면 에러 메시지.
     * reasonCd: CHANGE_OF_MIND | DEFECT
     */
    String requestRefund(Long memberNo, Long orderItemId, String reasonCd, String content,
                         java.util.List<org.springframework.web.multipart.MultipartFile> images) throws Exception;
}