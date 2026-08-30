/**
 * 역할: 마이페이지 알림 데이터 객체
 *
 * 참고 테이블: TB_NOTIFICATION
 */

package com.petcare.petcare.mypage.notify.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MypageNotifyVO {

    // 2026-07-09 장우철 — TB_NOTIFICATION 컬럼 (DATABASE_TABLE.sql 기준)
    private Long   notiId;
    private Long   memberNo;
    private String notiType;   // ORDER / RESERVE / COMMUNITY / SYSTEM
    private String title;
    private String content;
    private String linkUrl;
    private String isRead;     // Y / N
    private Date   regDate;
}
