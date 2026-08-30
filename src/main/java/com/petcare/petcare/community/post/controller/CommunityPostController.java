/**
 * 역할: 커뮤니티 게시글 URL 처리 → Service 호출 → JSP 반환
 *
 * - 박유정 / 2026-07-08~10
 *
 * [목록 화면 흐름]
 * 1. GET /community?boardType=...&keyword=...&page=...
 * 2. communityPostService.getPostList() → TB_POST + 썸네일
 * 3. list.jsp 에 ${list} 전달
 *
 * [상세 화면 흐름]
 * 1. GET /community/detail?id=번호
 * 2. getPostDetail() → 조회수 +1, 사진 URL 조회
 * 3. comments 목록 + liked(좋아요 여부) model 추가
 * 4. detail.jsp 반환
 *
 * [작성 화면 흐름]
 * 1. GET /community/write → 로그인 확인 후 write.jsp
 * 2. POST /community/write → insertPost() → 상세 redirect + flash 메시지
 *
 * [댓글]
 * 1. GET detail → communityCommentService.getCommentList()
 * 2. POST /community/comment → TB_POST_COMMENT INSERT
 * 3. LIFE + 일반댓글 성공 시 markLifeAnswered() → TAGS=ANSWERED (2026-07-10 STEP 4)
 * 4. POST /community/comment/delete → IS_DELETED='Y' (작성자 본인)
 * 5. POST /community/comment/update → BODY 수정 (작성자 본인)
 * 6. POST /community/report → TB_POST_REPORT INSERT
 *
 * [탭 ↔ boardType]
 * - 전체     → "" (빈값, 기본 진입)
 * - 집사생활 → TOWN
 * - 무료나눔 → SHARE
 * - 수의사 상담 → LIFE
 *
 * 연결
 * - Service: CommunityPostService, CommunityReactionService, CommunityCommentService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 */

package com.petcare.petcare.community.post.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.petcare.petcare.community.comment.service.CommunityCommentService;
import com.petcare.petcare.community.comment.vo.CommunityCommentVO;
import com.petcare.petcare.community.post.service.CommunityPostService;
import com.petcare.petcare.community.post.vo.CommunityPostVO;
import com.petcare.petcare.community.reaction.service.CommunityReactionService;
import com.petcare.petcare.community.report.service.CommunityReportService;
import com.petcare.petcare.member.vo.MemberVO;

import java.util.List;

import jakarta.servlet.http.HttpSession;
import jakarta.validation.Valid;

import org.springframework.web.multipart.MultipartFile;

@Controller("communityController")
@RequestMapping("/community")
public class CommunityPostController {

    private static final Logger log = LoggerFactory.getLogger(CommunityPostController.class);

    private final CommunityPostService communityPostService;
    private final CommunityReactionService communityReactionService;
    private final CommunityCommentService communityCommentService;
    private final CommunityReportService communityReportService;

    public CommunityPostController(
            CommunityPostService communityPostService,
            CommunityReactionService communityReactionService,
            CommunityCommentService communityCommentService,
            CommunityReportService communityReportService) {
        this.communityPostService = communityPostService;
        this.communityReactionService = communityReactionService;
        this.communityCommentService = communityCommentService;
        this.communityReportService = communityReportService;
    }

    /** 게시글 목록 — boardType 으로 탭별 필터, list.jsp 에 ${list} 전달 */
    @GetMapping({"", "/"})
    public String list(
            @RequestParam(defaultValue = "") String boardType,
            @RequestParam(defaultValue = "") String keyword,
            @RequestParam(defaultValue = "") String petSpecies,
            @RequestParam(defaultValue = "") String vetStatus,
            @RequestParam(defaultValue = "1") int page,
            Model model) {
        if (page < 1) {
            page = 1;
        }
        int totalPages = communityPostService.getTotalPages(boardType, keyword, petSpecies, vetStatus);
        if (page > totalPages) {
            page = totalPages;
        }
        model.addAttribute("list",
                communityPostService.getPostList(boardType, keyword, page, petSpecies, vetStatus));
        model.addAttribute("boardType", boardType);
        model.addAttribute("keyword", keyword != null ? keyword.trim() : "");
        model.addAttribute("petSpecies", petSpecies != null ? petSpecies.trim() : "");
        model.addAttribute("vetStatus", vetStatus != null ? vetStatus.trim() : "");
        model.addAttribute("page", page);
        model.addAttribute("totalCount",
                communityPostService.getPostCount(boardType, keyword, petSpecies, vetStatus));
        model.addAttribute("totalPages", totalPages);
        return "community/list";
    }
    
    /** 게시글 상세 — post + comments + liked → detail.jsp */
    @GetMapping("/detail")
    public String detail(@RequestParam long id, Model model, HttpSession session) {
        CommunityPostVO post = communityPostService.getPostDetail(id);
        if (post == null) {
            return "redirect:/community?error=notfound";
        }
        MemberVO member = getMemberOrNull(session);

        List<CommunityCommentVO> comments = List.of();
        try {
            comments = communityCommentService.getCommentList(id);
        } catch (Exception e) {
            log.warn("community comment load failed: postId={}", id, e);
        }

        boolean liked = false;
        try {
            liked = communityReactionService.isLiked(id, member, session);
        } catch (Exception e) {
            log.warn("community like check failed: postId={}", id, e);
        }

        model.addAttribute("post", post);
        model.addAttribute("comments", comments);
        model.addAttribute("commentCount", countComments(comments));
        model.addAttribute("liked", liked);
        model.addAttribute("isLoggedIn", member != null);

        Long loginMemberNo = null;
        if (member != null) {
            loginMemberNo = communityCommentService.resolveLoginMemberNo(member);

            //HYJ 26.07.28 관리자권한 확인
            model.addAttribute("loginMemberRole", member.getRole());
        }

        model.addAttribute("loginMemberNo", loginMemberNo);

        // 2026/07/11 장우철 — LIFE 댓글 UI 권한 플래그 (서버 검증과 동일 규칙)
        // canWriteTopComment: 최상위 댓글 폼 / canWriteReply: 대댓글(답글) 폼
        boolean canWriteTopComment = false;
        boolean canWriteReply = false;
        if (member != null) {
            boolean isLife = post.getBoardType() != null
                    && "LIFE".equalsIgnoreCase(post.getBoardType().trim());
            if (!isLife) {
                canWriteTopComment = true;
                canWriteReply = true;
            } else {
                boolean hospitalBiz = member.getRole() != null
                        && member.getBizType() != null
                        && "BIZ".equalsIgnoreCase(member.getRole().trim())
                        && "HOSPITAL".equalsIgnoreCase(member.getBizType().trim());
                boolean isAuthor = loginMemberNo != null
                        && post.getMemberNo() != null
                        && loginMemberNo.equals(post.getMemberNo());
                canWriteTopComment = hospitalBiz;
                canWriteReply = hospitalBiz || isAuthor;
            }
        }
        model.addAttribute("canWriteTopComment", canWriteTopComment);
        model.addAttribute("canWriteReply", canWriteReply);
        return "community/detail";
    }

    /**
     * [댓글·대댓글 등록 화면 흐름]
     * 1. POST /community/comment (postId, body, parentId 선택)
     * 2. parentId 없음 → 일반댓글 / 있음 → 대댓글 (PARENT_ID)
     * 3. 성공 시 상세 redirect / 실패 시 ?error=...
     */
    @PostMapping("/comment")
    public String insertComment(
            @RequestParam long postId,
            @RequestParam String body,
            @RequestParam(required = false) Long parentId,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/community/detail?id=" + postId;
        }
        try {
            communityCommentService.insertComment(postId, body, member, parentId);
            // 2026-07-10 박유정 STEP 4 — LIFE 일반댓글 등록 시 답변완료 처리
            if (parentId == null) {
                communityPostService.markLifeAnswered(postId);
            }
            return "redirect:/community/detail?id=" + postId;
        } catch (IllegalStateException e) {
            log.warn("community comment insert state error: {}", e.getMessage());
            if ("MEMBER_NOT_FOUND".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=member";
            }
            if ("LOGIN_REQUIRED".equals(e.getMessage())) {
                return "redirect:/login?redirect=/community/detail?id=" + postId;
            }
            // 2026/07/11 장우철 — LIFE 댓글 권한 거부
            if ("LIFE_COMMENT_FORBIDDEN".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=lifeComment";
            }
            return "redirect:/community/detail?id=" + postId + "&error=comment";
        } catch (IllegalArgumentException e) {
            if ("INVALID_PARENT".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=comment";
            }
            return "redirect:/community/detail?id=" + postId + "&error=empty";
        } catch (Exception e) {
            log.error("community comment insert failed", e);
            if (isSequenceError(e)) {
                return "redirect:/community/detail?id=" + postId + "&error=seq";
            }
            return "redirect:/community/detail?id=" + postId + "&error=comment";
        }
    }
     
    /**
    * [댓글 삭제 화면 흐름]
    * 1. POST /community/comment/delete (commentId, postId)
    * 2. 작성자 본인 확인 → IS_DELETED='Y'
    * 3. 상세 redirect
    */
    @PostMapping("/comment/delete")
    public String deleteComment(
            @RequestParam long commentId,
            @RequestParam long postId,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/community/detail?id=" + postId;
        }
        try {
            communityCommentService.deleteComment(commentId, postId, member);
            return "redirect:/community/detail?id=" + postId;
        } catch (IllegalStateException e) {
            if ("FORBIDDEN".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=forbidden";
            }
            return "redirect:/community/detail?id=" + postId + "&error=comment";
        } catch (Exception e) {
            log.error("community comment delete failed", e);
            return "redirect:/community/detail?id=" + postId + "&error=comment";
        }
    }

    /**
     * [댓글 수정] 2026-07-14 박유정
     * POST /community/comment/update — 작성자 본인만 BODY 수정
     */
    @PostMapping("/comment/update")
    public String updateComment(
            @RequestParam long commentId,
            @RequestParam long postId,
            @RequestParam String body,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/community/detail?id=" + postId;
        }
        try {
            communityCommentService.updateComment(commentId, postId, body, member);
            return "redirect:/community/detail?id=" + postId;
        } catch (IllegalStateException e) {
            if ("FORBIDDEN".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=forbidden";
            }
            return "redirect:/community/detail?id=" + postId + "&error=comment";
        } catch (IllegalArgumentException e) {
            if ("EMPTY_BODY".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=empty";
            }
            return "redirect:/community/detail?id=" + postId + "&error=comment";
        } catch (Exception e) {
            log.error("community comment update failed", e);
            return "redirect:/community/detail?id=" + postId + "&error=comment";
        }
    }

    /**
     * [게시글 신고] 2026-07-14 박유정
     * POST /community/report — TB_POST_REPORT INSERT (PENDING)
     */
    @PostMapping("/report")
    public String reportPost(
            @RequestParam long postId,
            @RequestParam String reasonCd,
            @RequestParam(required = false) String reasonDetail,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/community/detail?id=" + postId;
        }
        try {
            communityReportService.insertPostReport(postId, reasonCd, reasonDetail, member);
            return "redirect:/community/detail?id=" + postId + "&reported=1";
        } catch (IllegalStateException e) {
            if ("SELF_REPORT".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=selfReport";
            }
            if ("DUPLICATE_REPORT".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=duplicateReport";
            }
            if ("MEMBER_NOT_FOUND".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=member";
            }
            return "redirect:/community/detail?id=" + postId + "&error=report";
        } catch (IllegalArgumentException e) {
            if ("EMPTY_REASON".equals(e.getMessage()) || "INVALID_REASON".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=reportReason";
            }
            if ("POST_NOT_FOUND".equals(e.getMessage())) {
                return "redirect:/community?error=notfound";
            }
            return "redirect:/community/detail?id=" + postId + "&error=report";
        } catch (Exception e) {
            log.error("community post report failed", e);
            if (isReportSequenceError(e)) {
                return "redirect:/community/detail?id=" + postId + "&error=reportSeq";
            }
            return "redirect:/community/detail?id=" + postId + "&error=report";
        }
    }

    private boolean isSequenceError(Throwable e) {
        Throwable cur = e;
        while (cur != null) {
            String msg = cur.getMessage();
            if (msg != null && (msg.contains("ORA-02289")
                    || msg.contains("SEQ_TB_POST_COMMENT")
                    || msg.contains("sequence does not exist"))) {
                return true;
            }
            cur = cur.getCause();
        }
        return false;
    }

    private boolean isReportSequenceError(Throwable e) {
        Throwable cur = e;
        while (cur != null) {
            String msg = cur.getMessage();
            if (msg != null && (msg.contains("ORA-02289")
                    || msg.contains("SEQ_TB_POST_REPORT")
                    || msg.contains("sequence does not exist"))) {
                return true;
            }
            cur = cur.getCause();
        }
        return false;
    }


    /**
     * [게시글 수정 화면] 2026-07-23 HYJ
     * GET /community/edit?id=번호 → 본인 글만 edit.jsp
     */
    @GetMapping("/edit")
    public String editForm(@RequestParam long id, Model model, HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/community/edit?id=" + id;
        }
        CommunityPostVO post = communityPostService.getPostDetailForEdit(id);
        if (post == null) {
            return "redirect:/community?error=notfound";
        }
        Long loginMemberNo = null;
        if (member.getMemberNo() != null) {
            loginMemberNo = member.getMemberNo();
        } else {
            loginMemberNo = communityCommentService.resolveLoginMemberNo(member);
        }
        if (loginMemberNo == null || !loginMemberNo.equals(post.getMemberNo())) {
            return "redirect:/community/detail?id=" + id + "&error=forbidden";
        }
        model.addAttribute("post", post);
        return "community/edit";
    }

    /**
     * [게시글 수정 처리] 2026-07-23 HYJ
     * POST /community/edit → updatePost() → 상세 redirect
     * 2026-08-13 박유정 — photos(추가), removePhotoUrls(선택 삭제) multipart 전달
     */
    @PostMapping("/edit")
    public String editSubmit(
            @RequestParam long postId,
            @RequestParam String title,
            @RequestParam String body,
            @RequestParam(value = "photos", required = false) MultipartFile[] photos,
            @RequestParam(value = "removePhotoUrls", required = false) List<String> removePhotoUrls,
            HttpSession session,
            RedirectAttributes redirectAttributes) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/community/edit?id=" + postId;
        }
        try {
            CommunityPostVO vo = new CommunityPostVO();
            vo.setPostId(postId);
            vo.setTitle(title);
            vo.setBody(body);
            communityPostService.updatePost(vo, member, photos, removePhotoUrls);
            redirectAttributes.addFlashAttribute("successMessage", "게시글이 수정되었습니다.");
            return "redirect:/community/detail?id=" + postId;
        } catch (IllegalStateException e) {
            if ("FORBIDDEN".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=forbidden";
            }
            if ("MEMBER_NOT_FOUND".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=member";
            }
            return "redirect:/community/edit?id=" + postId + "&error=save";
        } catch (IllegalArgumentException e) {
            return "redirect:/community?error=notfound";
        } catch (Exception e) {
            log.error("community post update failed", e);
            return "redirect:/community/edit?id=" + postId + "&error=save";
        }
    }

    /**
     * [게시글 삭제] 2026-07-23 HYJ
     * POST /community/delete → deletePost() → 목록 redirect
     */
    @PostMapping("/delete")
    public String deletePost(@RequestParam long postId,
                             HttpSession session,
                             RedirectAttributes redirectAttributes) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/community/detail?id=" + postId;
        }

        // boardType을 미리 조회해서 삭제 후 해당 탭으로 돌아가기
        CommunityPostVO post = communityPostService.getPostDetail(postId);
        String boardType = (post != null) ? post.getBoardType() : "";

        try {
            communityPostService.deletePost(postId, member);
            redirectAttributes.addFlashAttribute("successMessage", "게시글이 삭제되었습니다.");
            if (boardType != null && !boardType.isEmpty()) {
                return "redirect:/community?boardType=" + boardType;
            }
            return "redirect:/community";
        } catch (IllegalStateException e) {
            if ("FORBIDDEN".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=forbidden";
            }
            if ("MEMBER_NOT_FOUND".equals(e.getMessage())) {
                return "redirect:/community/detail?id=" + postId + "&error=member";
            }
            return "redirect:/community/detail?id=" + postId + "&error=delete";
        } catch (IllegalArgumentException e) {
            return "redirect:/community?error=notfound";
        } catch (Exception e) {
            log.error("community post delete failed", e);
            return "redirect:/community/detail?id=" + postId + "&error=delete";
        }
    }

    /** 게시글 작성 화면 — 로그인 확인 후 write.jsp */
    @GetMapping("/write")
    public String write(HttpSession session) {
        if (getMemberOrNull(session) == null) {
            return "redirect:/login?redirect=/community/write";
        }
        return "community/write";
    }

    /** 게시글 등록 — TB_POST + 사진 저장 후 상세 또는 LIFE 목록 redirect */
    @PostMapping("/write")
    public String writeSubmit(
            @Valid @ModelAttribute CommunityPostVO vo,      //HYJ 26.08.06 vo 검증 추가
            BindingResult bindingResult,                   // 2026/08/10 장우철 — @Valid 실패를 ExHandler로 안 보내고 화면에 표시
            @RequestParam(value = "photos", required = false) MultipartFile[] photos,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        boolean isLife = vo.getBoardType() != null && "LIFE".equalsIgnoreCase(vo.getBoardType().trim());
        String lifeListUrl = "/community?boardType=LIFE";
        String loginRedirect = isLife ? lifeListUrl : "/community/write";

        // 2026/08/10 장우철 — 글자수 등 검증 실패 시 write 화면에 메시지 표시
        if (bindingResult.hasErrors()) {
            redirectAttributes.addFlashAttribute("validationMessage", resolveValidationMessage(bindingResult));
            redirectAttributes.addFlashAttribute("communityPostVO", vo);
            return "redirect:/community/write";
        }

        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=" + loginRedirect;
        }
        try {
            communityPostService.insertPost(vo, member, photos);
            if (isLife) {
                redirectAttributes.addFlashAttribute("successMessage", "상담 글이 등록되었습니다.");
                return "redirect:" + lifeListUrl;
            }
            redirectAttributes.addFlashAttribute("successMessage", "게시글이 등록되었습니다.");
            return "redirect:/community/detail?id=" + vo.getPostId();
        } catch (IllegalStateException e) {
            log.warn("community write failed: {}", e.getMessage(), e);
            if ("MEMBER_NOT_FOUND".equals(e.getMessage())) {
                return isLife
                        ? "redirect:" + lifeListUrl + "&error=member"
                        : "redirect:/community/write?error=member";
            }
            if ("LOGIN_REQUIRED".equals(e.getMessage())) {
                return "redirect:/login?redirect=" + loginRedirect;
            }
            return isLife
                    ? "redirect:" + lifeListUrl + "&error=save"
                    : "redirect:/community/write?error=save";
        } catch (Exception e) {
            log.error("community write failed", e);
            return isLife
                    ? "redirect:" + lifeListUrl + "&error=save"
                    : "redirect:/community/write?error=save";
        }
    }

    private MemberVO getMemberOrNull(HttpSession session) {
        Object member = session.getAttribute("memberInfo");
        if (member instanceof MemberVO memberVO) {
            return memberVO;
        }
        return null;
    }

    /** 2026/08/10 장우철 — body/title Size 실패 메시지를 우선 노출 */
    private String resolveValidationMessage(BindingResult bindingResult) {
        FieldError bodyError = bindingResult.getFieldError("body");
        if (bodyError != null && bodyError.getDefaultMessage() != null) {
            return bodyError.getDefaultMessage();
        }
        FieldError titleError = bindingResult.getFieldError("title");
        if (titleError != null && titleError.getDefaultMessage() != null) {
            return titleError.getDefaultMessage();
        }
        FieldError first = bindingResult.getFieldError();
        if (first != null && first.getDefaultMessage() != null) {
            return first.getDefaultMessage();
        }
        return "입력 내용을 확인해 주세요.";
    }

    private int countComments(List<CommunityCommentVO> parents) {
        int count = 0;
        for (CommunityCommentVO parent : parents) {
            count++;
            if (parent.getReplies() != null) {
                count += parent.getReplies().size();
            }
        }
        return count;
    }
}
