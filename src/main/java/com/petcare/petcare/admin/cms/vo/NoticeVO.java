/**
 * NOTICE_TYPE_CD: NOTICE 공지 / INFO 안내
 * PIN_YN: Y 상단 고정 / N 일반, VISIBLE_YN: Y 노출 / N 숨김
 */

package com.petcare.petcare.admin.cms.vo;

import java.util.Date;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class NoticeVO {

    // TB_NOTICE 컬럼

    private Long noticeId;        // NOTICE_ID — 공지 번호 (PK)
    private String noticeTypeCd;  // NOTICE_TYPE_CD — 유형 (NOTICE/INFO)
    private String title;         // TITLE — 제목
    private String body;          // BODY — 본문
    private String writerName;    // WRITER_NAME — 작성자 표시명
    private String pinYn;         // PIN_YN — 상단 고정 여부 (Y/N)
    private String visibleYn;     // VISIBLE_YN — 노출 여부 (Y/N)
    private Integer viewCount;    // VIEW_COUNT — 조회수
    private Date regDate;         // REG_DATE — 등록일
    private Date modDate;         // MOD_DATE — 수정일
}
