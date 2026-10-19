package com.petcare.petcare.admin.store.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.store.mapper.AdminStoreMapper;
import com.petcare.petcare.admin.store.vo.AdminStoreOrderVO;
import com.petcare.petcare.admin.store.vo.AdminStoreProductVO;

@Service
public class AdminStoreServiceImpl implements AdminStoreService {

    @Autowired
    private AdminStoreMapper adminStoreMapper;

    // 전 사업자 상품 목록
    @Override
    @Transactional(readOnly = true)
    public List<AdminStoreProductVO> getProductList(String keyword, String statusCd, int page, int size) {
        int safePage = page < 1 ? 1 : page;
        int safeSize = size < 1 ? 20 : size;
        int offset = (safePage - 1) * safeSize;
        return adminStoreMapper.selectAdminProductList(blankToNull(keyword), blankToNull(statusCd), offset, safeSize);
    }

    @Override
    @Transactional(readOnly = true)
    public int getProductCount(String keyword, String statusCd) {
        return adminStoreMapper.selectAdminProductCount(blankToNull(keyword), blankToNull(statusCd));
    }

    @Override
    @Transactional(readOnly = true)
    public List<AdminStoreOrderVO> getOrderList(String keyword, String statusCd, int page, int size) {
        int safePage = page < 1 ? 1 : page;
        int safeSize = size < 1 ? 20 : size;
        int offset = (safePage - 1) * safeSize;
        return adminStoreMapper.selectAdminOrderList(blankToNull(keyword), blankToNull(statusCd), offset, safeSize);
    }

    @Override
    @Transactional(readOnly = true)
    public int getOrderCount(String keyword, String statusCd) {
        return adminStoreMapper.selectAdminOrderCount(blankToNull(keyword), blankToNull(statusCd));
    }

    @Override
    @Transactional(readOnly = true)
    public AdminStoreOrderVO getOrderDetail(Long orderId) {
        if (orderId == null) {
            return null;
        }
        return adminStoreMapper.selectAdminOrderDetail(orderId);
    }

    private String blankToNull(String s) {
        return (s == null || s.isBlank()) ? null : s.trim();
    }
}
