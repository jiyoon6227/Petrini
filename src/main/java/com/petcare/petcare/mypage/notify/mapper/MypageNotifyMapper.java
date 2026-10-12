package com.petcare.petcare.mypage.notify.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.mypage.notify.vo.MypageNotifyVO;

@Mapper
public interface MypageNotifyMapper {

    // 사업자 반려 알림 INSERT
    int insertNotification(MypageNotifyVO vo);

    // 회원 알림 목록 (알림함 UI DB 연동)
    java.util.List<MypageNotifyVO> selectNotificationList(@Param("memberNo") Long memberNo);

    // 알림 상세 1건 (본인 것만)
    MypageNotifyVO selectNotificationDetail(@Param("notiId") Long notiId,
                                            @Param("memberNo") Long memberNo);

    // 상세 열람 시 읽음 처리
    int updateNotificationRead(@Param("notiId") Long notiId,
                               @Param("memberNo") Long memberNo);

    // 알림함 전체 읽음
    int updateAllNotificationRead(@Param("memberNo") Long memberNo);

    // 알림함 전체 삭제 (본인 알림만)
    int deleteAllNotificationsByMemberNo(@Param("memberNo") Long memberNo);

    // 헤더 배지용 미읽음 건수
    int countUnreadNotifications(@Param("memberNo") Long memberNo);
}
