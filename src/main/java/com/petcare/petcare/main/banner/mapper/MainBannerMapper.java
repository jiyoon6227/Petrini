package com.petcare.petcare.main.banner.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.main.banner.vo.MainBannerVO;


@Mapper
public interface MainBannerMapper {
    // 사용자: 위치별 활성 배너 조회
    // maxCount 바인드 (MAIN_MID 1건, Oracle ROWNUM)
    List<MainBannerVO> selectActiveBannersByPosition(@Param("positionCd") String positionCd,
                                                     @Param("maxCount") int maxCount);

    // 위치·상태별 배너 건수 (신청/승인 제한용)
    int countByPositionAndStatuses(@Param("positionCd") String positionCd,
                                   @Param("statusCds") List<String> statusCds);

    // 승인·신청 제한: PENDING + 기간 만료 전 ACTIVE
    int countReservedSlotsByPosition(@Param("positionCd") String positionCd);

    // 승인·올리기 제한: 기간 만료 전 ACTIVE
    int countLiveSlotsByPosition(@Param("positionCd") String positionCd);

    // 종료일 경과 ACTIVE → EXPIRED 일괄 처리
    int expirePastEndDateBanners();
}
