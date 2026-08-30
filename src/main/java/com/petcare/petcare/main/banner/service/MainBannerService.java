/**
 * 역할: 메인 배너 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - main/main.jsp             히어로 배너 (메인 내)
 *
 * 구현할 기능 예시
 * - 활성 배너 목록 조회
 *
 * 연결
 * - 구현: MainBannerServiceImpl
 * - 호출: MainBannerController
 * - DB: MainBannerMapper
 *
 * 참고 테이블
 * - TB_BANNER
 */

package com.petcare.petcare.main.banner.service;

import java.util.List;


import com.petcare.petcare.main.banner.vo.MainBannerVO;

public interface MainBannerService {
    // ── 사용자: 위치별 조회 ──
    List<MainBannerVO> getBannersByPosition(String positionCd);
}
