/**
 * 역할: 커뮤니티 게시글 데이터 객체
 *
 * - 박유정 / 2026-07-08~10
 * - give/report 의 GiveReportVO 에서 LOST 전용 필드 제외하고 참고
 *
 * 참고 테이블
 * - TB_POST (BOARD_TYPE = TOWN / SHARE / LIFE)
 * - TB_FILE (사진, REF_TYPE = 'POST')
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.community.post.vo;

import java.time.LocalDateTime;
import java.util.List;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

/*
 * HYJ 26.08.06
 * [Bean Validation 이란]
 * VO(데이터 객체) 필드에 @NotBlank, @Size 같은 어노테이션을 붙이면,
 * 컨트롤러에서 @Valid 를 선언하는 것만으로 자동 검증됨
 * → 수동 if 검증 코드가 사라지고, VO 자체가 "이 필드는 이런 규칙" 이라는 문서 역할
 * 
 * ══════════════════════════════════════════════════════════
 * [자주 쓰는 어노테이션 정리]
 * ══════════════════════════════════════════════════════════
 *
 * @NotNull      — null 만 차단 (빈 문자열 "" 은 통과)
 * @NotEmpty     — null + 빈 문자열 "" 차단 (공백 " " 은 통과)
 * @NotBlank     — null + "" + " " 전부 차단 (String 전용, 가장 엄격)
 * @Size(min, max) — 문자열 길이 또는 컬렉션 크기 제한
 * @Min(value)   — 숫자 최솟값
 * @Max(value)   — 숫자 최댓값
 * @Pattern(regexp) — 정규식 매칭 (이메일, 전화번호 등)
 * @Email        — 이메일 형식 검증
 * @Positive     — 양수만 허용
 * @PositiveOrZero — 0 이상
 *
 *
 * [Bean Validation의 장점]
 * → VO 자체가 검증 규칙 문서 역할을 합니다.
 *   컨트롤러에 if 문이 흩어져 있으면 어떤 필드에 어떤 규칙인지 파악이 어렵지만,
 *   VO 어노테이션을 보면 한눈에 알 수 있습니다.
 *
 * [BindingResult 는 왜 @Valid 바로 뒤에 와야 하나요?]
 * → Spring 이 파라미터 순서로 "이 BindingResult 는 어떤 @Valid 의 결과인지" 를 매칭합니다.
 *   @Valid 와 BindingResult 사이에 다른 파라미터가 끼면 매칭이 안 돼서
 *   검증 실패 시 400 에러가 바로 발생합니다.
 *
 * [@RequestParam 에는 왜 @Valid 가 안 되나요?]
 * → @Valid 는 객체(VO) 단위 검증입니다. @RequestParam 은 개별 파라미터라서
 *   Bean Validation 대상이 아닙니다. 개별 파라미터에 검증을 걸려면
 *   컨트롤러 클래스에 @Validated 를 붙이고 @RequestParam 앞에 @NotBlank 등을
 *   직접 붙이는 방법이 있지만, VO 로 묶는 게 더 깔끔합니다.
 */
@Getter
@Setter
public class CommunityPostVO {

    // ── TB_POST 컬럼 ──────────────────────────────────────────

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
    private String tags;           // TAGS — LIFE: WAITING/ANSWERED (2026-07-10)
    private String region;         // REGION — 지역
    private String lostSpecies;    // LOST_SPECIES — LIFE: 동물 종 (DOG/CAT/ETC)
    private String lostFeature;    // LOST_FEATURE — LIFE: 품종|나이

    // ── write.jsp / vet-ask-form 전용 (DB 컬럼 없음 → Service에서 조합) ──

    private String petType;        // (폼) — 반려동물 종, LOST_SPECIES 조합용 (DOG/CAT/ETC)
    private String breed;          // (폼) — 품종, LOST_FEATURE 조합용
    private String petAge;         // (폼) — 나이, LOST_FEATURE 조합용

    // ── 조회 전용 (DB 컬럼 아님, Service·JOIN 으로 채움) ──

    private String authorName;         // NICKNAME — 작성자 닉네임 (TB_MEMBER JOIN)
    private String thumbUrl;           // FILE_URL — 목록 썸네일, TB_FILE 첫 사진
    private List<String> photoUrls;    // FILE_URL — 상세 사진 URL 목록 (TB_FILE, REF_TYPE='POST')

    // ── 관리자 상세 전용 / 2026-07-15 (신고 제외) ──

    private String authorMemberName;   // MEMBER_NAME — 작성자 실명 (TB_MEMBER JOIN)
    private String authorEmail;        // EMAIL — 작성자 이메일 (TB_MEMBER JOIN)
    private Integer commentCount;      // 서브쿼리 — TB_POST_COMMENT 댓글 건수

    // LIFE 답변 미리보기 — 첫 일반댓글 (목록 vet-answer 용) / 2026-07-10 STEP 4
    private String answerBody;         // BODY — 답변 본문 (TB_POST_COMMENT)
    private String answerAuthor;       // NICKNAME — 답변 작성자 (TB_MEMBER JOIN)
    private LocalDateTime answerDate;  // REG_DATE — 답변 등록일 (TB_POST_COMMENT)

    // ── 관리자 목록 전용 (JOIN·서브쿼리로 채움) / 2026-07-15 ──
    private Integer reportCount;        // 서브쿼리 — TB_POST_REPORT 신고 총 건수
    private Integer pendingReportCount; // 서브쿼리 — TB_POST_REPORT, STATUS_CD='PENDING' 건수
    //2026/08/06 장우철 — 신고 기각 건수 (관리자 뱃지용)
    private Integer dismissedReportCount;


}
