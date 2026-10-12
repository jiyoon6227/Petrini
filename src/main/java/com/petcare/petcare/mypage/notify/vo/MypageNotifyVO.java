package com.petcare.petcare.mypage.notify.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MypageNotifyVO {

    // TB_NOTIFICATION 컬럼 (DATABASE_TABLE.sql 기준)
    private Long   notiId;
    private Long   memberNo;
    private String notiType;   // ORDER / RESERVE / COMMUNITY / SYSTEM
    private String title;
    private String content;
    private String linkUrl;
    private String isRead;     // Y / N
    private Date   regDate;
}
