/**
 * 역할: 마이페이지 주문 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/mypage/order/MypageOrderMapper.xml
 * namespace: com.petcare.petcare.mypage.order.mapper.MypageOrderMapper
 *
 * 쿼리 예시
 * - selectOrderList
 * - selectOrderDetail
 *
 * 참고 테이블
 * - TB_ORDER
 * - TB_ORDER_ITEM
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.mypage.order.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.mypage.order.vo.MypageOrderVO;
import com.petcare.petcare.mypage.order.vo.MypageOrderItemVO;

@Mapper
public interface MypageOrderMapper {

    //지윤 26.07.20 추가: 회원 본인 주문 목록 (상태 필터)
    List<MypageOrderVO> selectOrderList(@Param("memberNo") Long memberNo, @Param("statusCd") String statusCd);

    //지윤 26.07.20 추가: 주문 하나의 상품 목록
    List<MypageOrderItemVO> selectOrderItems(@Param("orderId") Long orderId);

    //지윤 26.07.20 추가: 상품 리뷰 작성 (본인 주문/중복작성 여부는 SQL에서 검증, 영향받은 행수 반환)
    int insertProductReview(@Param("orderItemId") Long orderItemId, @Param("memberNo") Long memberNo,
                             @Param("rating") Double rating, @Param("content") String content);

    //지윤 26.07.20 추가: 방금 등록한 리뷰의 REVIEW_ID 재조회 (사진 첨부용)
    Long selectReviewIdByOrderItem(@Param("orderItemId") Long orderItemId);
    
    //지윤 26.07.20 추가: 주문상세보기 1건 (본인 주문 아니면 null)
    MypageOrderVO selectOrderDetail(@Param("orderId") Long orderId, @Param("memberNo") Long memberNo);

    //지윤 26.07.30 추가: 같은 결제(TOSS_ORDER_ID)로 묶인 사업자별 주문 전체 조회
    List<MypageOrderVO> selectOrdersByGroupId(@Param("groupId") String groupId, @Param("memberNo") Long memberNo);

    //지윤 26.07.22 추가: 주문취소 신청 (조건 안 맞으면 0건 UPDATE되어 반환)
    int requestCancel(@Param("orderId") Long orderId, @Param("memberNo") Long memberNo, @Param("reason") String reason);

    //지윤 26.07.23 추가: 취소신청 알림 보낼 대상(사업자 회원번호) 조회
    Long selectBizMemberNoByOrderId(@Param("orderId") Long orderId);

    //지윤 26.07.23 추가: 구매확정/리뷰 적립금 관련
    String selectPolicyValue(@Param("policyKey") String policyKey);
    int confirmPurchaseOrder(@Param("orderId") Long orderId, @Param("memberNo") Long memberNo);
    int selectMemberPointBalance(@Param("memberNo") Long memberNo);
    void addMemberPoint(@Param("memberNo") Long memberNo, @Param("newBalance") Integer newBalance);
    void insertPointEarnHistory(@Param("memberNo") Long memberNo, @Param("pointAmount") Integer pointAmount,
                                 @Param("balanceAfter") Integer balanceAfter, @Param("reasonCd") String reasonCd,
                                 @Param("refType") String refType, @Param("refId") Long refId);

    // 지윤 26.07.30 추가: 자동확정 스케줄러가 순회할 대상 (배송완료 7일 경과 + 미확정)
    List<Map<String, Object>> selectOrdersNeedingAutoConfirm();

    // 2026/08/04 장우철 — 상품단위 환불 신청
    MypageOrderItemVO selectRefundableItem(@Param("orderItemId") Long orderItemId, @Param("memberNo") Long memberNo);
    int requestItemRefund(@Param("orderItemId") Long orderItemId,
                          @Param("returnReasonCd") String returnReasonCd,
                          @Param("claimReason") String claimReason,
                          @Param("returnFeeAmount") Integer returnFeeAmount,
                          @Param("returnFeePayer") String returnFeePayer);
    Long selectBizMemberNoByOrderItemId(@Param("orderItemId") Long orderItemId);
    String selectOrderNoByOrderItemId(@Param("orderItemId") Long orderItemId);
    int confirmPurchaseItems(@Param("orderId") Long orderId);
    // 2026/08/04 장우철 — 부분 확정 시 적립 기준 금액
    int selectConfirmableItemsAmount(@Param("orderId") Long orderId);

    // 2026/08/04 장우철 — 정산 제외 가드 / 정산 후보 조회
    int countActiveReturnByOrderId(@Param("orderId") Long orderId);
    List<MypageOrderItemVO> selectSettlementEligibleItems(@Param("orderId") Long orderId);
}