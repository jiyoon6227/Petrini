package com.petcare.petcare.admin.store.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.admin.store.vo.AdminStoreOrderVO;
import com.petcare.petcare.admin.store.vo.AdminStoreProductVO;

@Mapper
public interface AdminStoreMapper {

    // 관리자 전 사업자 상품/주문 목록
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
