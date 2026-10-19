package com.petcare.petcare.admin.store.service;

import java.util.List;

import com.petcare.petcare.admin.store.vo.AdminStoreOrderVO;
import com.petcare.petcare.admin.store.vo.AdminStoreProductVO;

public interface AdminStoreService {

    // 전 사업자 상품/주문 목록
    List<AdminStoreProductVO> getProductList(String keyword, String statusCd, int page, int size);

    int getProductCount(String keyword, String statusCd);

    List<AdminStoreOrderVO> getOrderList(String keyword, String statusCd, int page, int size);

    int getOrderCount(String keyword, String statusCd);

    AdminStoreOrderVO getOrderDetail(Long orderId);
}
