/**
 * 역할: 관리자 쇼핑몰 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/admin/store/AdminStoreMapper.xml
 * namespace: com.petcare.petcare.admin.store.mapper.AdminStoreMapper
 *
 * 쿼리 예시
 * - selectProductList
 * - selectProductDetail
 * - insertProduct
 * - updateProduct
 * - selectOrderList
 * - selectOrderDetail
 * - updateOrderStatus
 * - selectCategoryList
 * - insertCategory
 *
 * 참고 테이블
 * - TB_PRODUCT
 * - TB_ORDER
 * - TB_ORDER_ITEM
 * - TB_CATEGORY
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.admin.store.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.admin.store.vo.AdminReviewReportVO;
import com.petcare.petcare.admin.store.vo.AdminStoreOrderVO;
import com.petcare.petcare.admin.store.vo.AdminStoreProductVO;

@Mapper
public interface AdminStoreMapper {

    //지윤 26.07.21 추가: 대기중(PENDING)인 사업자 리뷰 삭제요청 목록
    List<AdminReviewReportVO> selectPendingReviewReports();

   //지윤 26.07.21 추가: 승인 처리 - STATUS_CD='DONE' + REVIEW_ID를 NULL로 비움 (TB_REVIEW 삭제 전에 FK 참조부터 끊어야 함)
   int updateReportApproved(@Param("reportId") Long reportId, @Param("adminNo") Long adminNo);

   //지윤 26.07.22 추가: 이 리뷰를 참조하는 "모든" 신고/삭제요청 행의 REVIEW_ID를 비움
   //(사업자 삭제요청 + 유저 신고가 같은 리뷰에 여러 건 걸려있을 수 있어서, 특정 REPORT_ID 하나만 비우면 나머지 행 때문에 ORA-02292 남)
   int clearAllReportRefsByReviewId(@Param("reviewId") Long reviewId);

   //지윤 26.07.21 추가: 승인 - 원본 리뷰 실제 삭제 (반드시 clearAllReportRefsByReviewId 이후에 호출)
   int deleteReview(@Param("reviewId") Long reviewId);

   //지윤 26.07.21 추가: 반려 처리 완료 표시 (STATUS_CD='DONE' + 처리한 관리자 기록, REVIEW_ID는 그대로 유지)
   int updateReportDone(@Param("reportId") Long reportId, @Param("adminNo") Long adminNo);

    // 2026/08/11 장우철 — 관리자 전 사업자 상품/주문 목록
    List<AdminStoreProductVO> selectAdminProductList(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd,
            @Param("offset") int offset,
            @Param("size") int size);

    int selectAdminProductCount(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd);

    List<AdminStoreOrderVO> selectAdminOrderList(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd,
            @Param("offset") int offset,
            @Param("size") int size);

    int selectAdminOrderCount(
            @Param("keyword") String keyword,
            @Param("statusCd") String statusCd);

    AdminStoreOrderVO selectAdminOrderDetail(@Param("orderId") Long orderId);
}
