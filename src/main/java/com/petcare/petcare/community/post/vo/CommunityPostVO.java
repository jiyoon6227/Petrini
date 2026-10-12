package com.petcare.petcare.community.post.vo;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/* 입력 검증은 Bean Validation(@NotBlank·@Size) — Controller에서 @Valid 바로 뒤에 BindingResult를 둘 것 */
@Getter
@Setter
public class CommunityPostVO {

    // TB_POST 컬럼

    private Long postId;           // POST_ID — 게시글 ID
    private Long memberNo;         // MEMBER_NO — 작성자 회원번호
    @NotBlank(message= "게시판 유형은 필수입니다")      //when null
    private String boardType;      // BOARD_TYPE — TOWN(집사생활) / SHARE(무료나눔) / LIFE(수의사상담)
    @NotBlank(message = "제목을 입력해주세요")
    @Size(min = 2, max = 100, message = "제목은 2~100자로 입력해주세요")
    private String title;          // TITLE — 제목
    @NotBlank(message = "내용을 입력해주세요")
    @Size(min = 5, max = 5000, message = "내용은 5~5000자로 입력해주세요")
    private String body;           // BODY — 본문
    private Integer viewCount;     // VIEW_COUNT — 조회수
    private Integer likeCnt;       // LIKE_CNT — 좋아요 수
    private String statusCd;       // STATUS_CD — 게시 상태 (ACTIVE/HIDDEN/DELETED)
    private LocalDateTime regDate; // REG_DATE — 등록일
    private String tags;           // TAGS — LIFE: WAITING/ANSWERED
    private String region;         // REGION — 지역
    private String lostSpecies;    // LOST_SPECIES — LIFE: 동물 종 (DOG/CAT/ETC)
    private String lostFeature;    // LOST_FEATURE — LIFE: 품종|나이

    // write.jsp / vet-ask-form 전용 (DB 컬럼 없음 → Service에서 조합)

    private String petType;        // (폼) — 반려동물 종, LOST_SPECIES 조합용 (DOG/CAT/ETC)
    private String breed;          // (폼) — 품종, LOST_FEATURE 조합용
    private String petAge;         // (폼) — 나이, LOST_FEATURE 조합용

    // 조회 전용 (DB 컬럼 아님, Service·JOIN 으로 채움)

    private String authorName;         // NICKNAME — 작성자 닉네임 (TB_MEMBER JOIN)
    private String thumbUrl;           // FILE_URL — 목록 썸네일, TB_FILE 첫 사진
    private List<String> photoUrls;    // FILE_URL — 상세 사진 URL 목록 (TB_FILE, REF_TYPE='POST')

    // 관리자 상세 전용 (신고 제외)

    private String authorMemberName;   // MEMBER_NAME — 작성자 실명 (TB_MEMBER JOIN)
    private String authorEmail;        // EMAIL — 작성자 이메일 (TB_MEMBER JOIN)
    private Integer commentCount;      // 서브쿼리 — TB_POST_COMMENT 댓글 건수

    // LIFE 답변 미리보기 — 첫 일반댓글 (목록 vet-answer 용)
    private String answerBody;         // BODY — 답변 본문 (TB_POST_COMMENT)
    private String answerAuthor;       // NICKNAME — 답변 작성자 (TB_MEMBER JOIN)
    private LocalDateTime answerDate;  // REG_DATE — 답변 등록일 (TB_POST_COMMENT)

    // 관리자 목록 전용 (JOIN·서브쿼리로 채움)
    private Integer reportCount;        // 서브쿼리 — TB_POST_REPORT 신고 총 건수
    private Integer pendingReportCount; // 서브쿼리 — TB_POST_REPORT, STATUS_CD='PENDING' 건수
    // 신고 기각 건수 (관리자 뱃지용)
    private Integer dismissedReportCount;


}
