/**
 * 역할: 마이페이지 알림 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/mypage/notify/MypageNotifyMapper.xml
 * namespace: com.petcare.petcare.mypage.notify.mapper.MypageNotifyMapper
 *
 * 쿼리 예시
 * - selectNotificationList
 * - selectNotificationDetail
 * - updateReadStatus
 *
 * 참고 테이블
 * - TB_NOTIFICATION
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.mypage.notify.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.mypage.notify.vo.MypageNotifyVO;

@Mapper
public interface MypageNotifyMapper {

    // 2026-07-09 장우철 — 사업자 반려 알림 INSERT
    int insertNotification(MypageNotifyVO vo);

    // 2026-07-09 장우철 — 회원 알림 목록 (알림함 UI DB 연동)
    java.util.List<MypageNotifyVO> selectNotificationList(@Param("memberNo") Long memberNo);

    // 2026-07-09 장우철 — 알림 상세 1건 (본인 것만)
    MypageNotifyVO selectNotificationDetail(@Param("notiId") Long notiId,
                                            @Param("memberNo") Long memberNo);

    // 2026-07-09 장우철 — 상세 열람 시 읽음 처리
    int updateNotificationRead(@Param("notiId") Long notiId,
                               @Param("memberNo") Long memberNo);

    // 2026-07-10 장우철 — 알림함 전체 읽음
    int updateAllNotificationRead(@Param("memberNo") Long memberNo);

    // 2026-07-10 장우철 — 알림함 전체 삭제 (본인 알림만)
    int deleteAllNotificationsByMemberNo(@Param("memberNo") Long memberNo);

    // 2026/07/11 장우철 — 헤더 배지용 미읽음 건수
    int countUnreadNotifications(@Param("memberNo") Long memberNo);
}
