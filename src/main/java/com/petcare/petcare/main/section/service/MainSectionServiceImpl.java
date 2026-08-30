package com.petcare.petcare.main.section.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.petcare.petcare.community.post.mapper.CommunityPostMapper;
import com.petcare.petcare.main.section.mapper.MainSectionMapper;
import com.petcare.petcare.main.section.vo.MainCommunityPreviewVO;
import com.petcare.petcare.main.section.vo.MainPopularProductVO;

/*
 *  2026/07/06 장우철
 *  @Service 서비스 구현체
 *  구현 내용 : 인기상품 목록 조회 , 할인율 계산 , 커뮤니티 최신글 미리보기 조회
 */

@Service
public class MainSectionServiceImpl implements MainSectionService {

    private final MainSectionMapper mainSectionMapper;
    private final CommunityPostMapper communityPostMapper;

    public MainSectionServiceImpl(MainSectionMapper mainSectionMapper,
                                  CommunityPostMapper communityPostMapper) {
        this.mainSectionMapper = mainSectionMapper;
        this.communityPostMapper = communityPostMapper;
    }

    // DB 조회 -> 각 상품마다 할인율 계산 -> 리스트 반환
    @Override
    public List<MainPopularProductVO> getPopularProducts(int limit) {
        List<MainPopularProductVO> products = mainSectionMapper.selectPopularProducts(limit);
        for (MainPopularProductVO product : products) {
            product.setDiscountRate(calcDiscountRate(product.getPrice(), product.getSalePrice()));
        }
        return products;
    }

    // Mapper 결과 반환
    @Override
    public List<MainCommunityPreviewVO> getLatestPosts(int limit) {
        List<MainCommunityPreviewVO> list = mainSectionMapper.selectCommunityPreview(limit);
        //HYJ 26.08.04 메인 커뮤니티 썸네일
        for (MainCommunityPreviewVO item : list) {
            List<String> urls = communityPostMapper.selectFileUrlsByPostId(item.getPostId());
            if (urls != null && !urls.isEmpty()) {
                item.setThumbUrl(urls.get(0));
            }
        }        
        return list;
    }

    // 할인율 계산 
    private int calcDiscountRate(Long price, Long salePrice) {
        if (price == null || salePrice == null || price <= 0 || salePrice >= price) {
            return 0;
        }
        return (int) Math.round((1.0 - (double) salePrice / price) * 100);
    }
}
