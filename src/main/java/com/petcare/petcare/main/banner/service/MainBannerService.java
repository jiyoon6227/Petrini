package com.petcare.petcare.main.banner.service;

import java.util.List;


import com.petcare.petcare.main.banner.vo.MainBannerVO;

public interface MainBannerService {
    // 사용자: 위치별 조회
    List<MainBannerVO> getBannersByPosition(String positionCd);
}
