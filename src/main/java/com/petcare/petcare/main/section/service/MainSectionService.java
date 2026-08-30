package com.petcare.petcare.main.section.service;

import java.util.List;

import com.petcare.petcare.main.section.vo.MainCommunityPreviewVO;
import com.petcare.petcare.main.section.vo.MainPopularProductVO;

/*
 *  2026/07/06 장우철
 *  메인 섹션 인터페이스 
 */

public interface MainSectionService {

    List<MainPopularProductVO> getPopularProducts(int limit);
    // 인기상품 TOP N

    List<MainCommunityPreviewVO> getLatestPosts(int limit);
    // 커뮤니티 최신 N건 노출
}
