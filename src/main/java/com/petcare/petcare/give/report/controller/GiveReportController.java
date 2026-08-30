/**
 * 역할: 유기동물 제보 URL 처리 → Service 호출 → JSP 반환
 *
 * - 박유정 / 2026-07-06~07
 *
 * [등록 화면 흐름]
 * 1. GET /give/report/write → 로그인 확인 후 write.jsp
 * 2. POST /give/report/write → giveReportService.insertReport(vo, member, photos)
 * 3. TB_POST INSERT + 사진 로컬 저장(C:/upload/) + TB_FILE INSERT
 * 4. 상세 페이지로 redirect
 *
 * [목록 화면 흐름]
 * 1. GET /give/report/list → giveReportService.getReportList()
 * 2. TB_POST 조회 + TB_FILE 첫 사진을 thumbUrl 로 세팅
 * 3. list.jsp 에 표시
 *
 * [상세 화면 흐름]
 * 1. GET /give/report/detail?id=번호 → giveReportService.getReportDetail()
 * 2. TB_POST + TB_FILE photoUrls 조회
 * 3. detail.jsp 에 표시
 * 
 * 4. POST /give/report/status → 상태 변경
 *
 * [댓글]
 * 1. GET detail → comments 목록 조회 (대댓글 포함)
 * 2. POST /give/report/comment → TB_POST_COMMENT INSERT (parentId → 대댓글)
 * 3. POST /give/report/comment/delete → IS_DELETED='Y' (작성자 본인)
 * 4. POST /give/report/comment/update → BODY 수정 (작성자 본인)
 *
 * - 박유정 / 2026-07-29 — 발견 위치 카카오맵 (write·detail, KakaoMapService)
 *
 * 연결
 * - Service: GiveReportService
 * - 상속: GiveBaseController
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 */

package com.petcare.petcare.give.report.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Collections;
import com.petcare.petcare.community.comment.service.CommunityCommentService;
import com.petcare.petcare.community.comment.vo.CommunityCommentVO;
import com.petcare.petcare.give.controller.GiveBaseController;
import com.petcare.petcare.give.report.service.GiveReportService;
import com.petcare.petcare.give.report.vo.GiveReportVO;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpSession;

import com.petcare.petcare.common.external.service.KakaoMapService;

@Controller("giveReportController")
@RequestMapping("/give/report")
public class GiveReportController extends GiveBaseController {

    private static final Logger log = LoggerFactory.getLogger(GiveReportController.class);
    // 2026-07-29 박유정 — kakaoJsApiKey·mapLat·mapLng JSP 전달 (common/kakaomap.jsp)
    private final KakaoMapService kakaoMapService;
    private final GiveReportService giveReportService;
    private final CommunityCommentService communityCommentService;

    // 2026-07-29 박유정 — KakaoMapService 생성자 주입 (write·detail 지도)
    public GiveReportController(
            GiveReportService giveReportService,
            CommunityCommentService communityCommentService,
            KakaoMapService kakaoMapService){ 
        this.giveReportService = giveReportService;
        this.communityCommentService = communityCommentService;
        this.kakaoMapService = kakaoMapService;
    }
    //@GetMapping("/write")   // 주소창 / 링크 클릭 → 화면만 보여줌
    @GetMapping("/list")
    public String reportList(
            @RequestParam(defaultValue = "") String status,
            Model model) {
        model.addAttribute("list", giveReportService.getReportList(status));
        model.addAttribute("reportCount", giveReportService.getReportCount());
        model.addAttribute("status", status != null ? status.trim() : "");
        return "give/report/list";
    }

    @GetMapping("/detail")
    public String reportDetail(@RequestParam long id, Model model, HttpSession session) {
        GiveReportVO report = giveReportService.getReportDetail(id);
        if (report == null) {
            return "redirect:/give/report/list";
        }
        // 2026-07-29 박유정 — 상세 지도: TB_POST LOST_LAT/LNG + 마커 라벨(region)
        kakaoMapService.addMapAttributes(model, Collections.emptyList());
        if (report.getLostLat() != null && report.getLostLng() != null) {
            // 2026-07-29 박유정 — kakaomap.jsp 가 mapLat·mapLng 로 중심·마커 표시
            model.addAttribute("mapLat", report.getLostLat());
            model.addAttribute("mapLng", report.getLostLng());
            String mapLabel = report.getRegion();
            if (mapLabel == null || mapLabel.isBlank()) {
                mapLabel = "발견 위치";
            }
            // 2026-07-29 박유정 — bizName = 마커 위 라벨 (병원 지도와 kakaomap.jsp 공통 속성명)
            model.addAttribute("bizName", mapLabel);
        }
        MemberVO member = getMemberOrNull(session);
        List<CommunityCommentVO> comments = communityCommentService.getCommentList(id);
        model.addAttribute("report", report);
        model.addAttribute("comments", comments);
        model.addAttribute("commentCount", countComments(comments));
        model.addAttribute("isLoggedIn", member != null);
        Long loginMemberNo = null;
        if (member != null) {
            loginMemberNo = communityCommentService.resolveLoginMemberNo(member);
        }
        model.addAttribute("loginMemberNo", loginMemberNo);
        return "give/report/detail";
    }

    // 2026-07-29 박유정 — 글작성 지도: kakaoJsApiKey·mapLat·mapLng JSP 전달
    @GetMapping("/write")
    public String reportWrite(HttpSession session, Model model) {
        if (getMemberOrNull(session) == null) {
            return "redirect:/login?redirect=/give/report/write";
        }
        kakaoMapService.addMapAttributes(model, Collections.emptyList());
        return "give/report/write";
    }

    //@PostMapping("/write") // form submit → 데이터 저장
    @PostMapping("/write")
    public String reportWriteSubmit(
            @ModelAttribute GiveReportVO vo,
            @RequestParam(value = "photos", required = false) MultipartFile[] photos,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/give/report/write";
        }
        try {
            // TB_POST 저장 후 사진 저장 (postId 필요)
            giveReportService.insertReport(vo, member, photos);
            return "redirect:/give/report/detail?id=" + vo.getPostId();
        } catch (IllegalStateException e) {
            if ("MEMBER_NOT_FOUND".equals(e.getMessage())) {
                return "redirect:/give/report/write?error=member";
            }
            if ("LOGIN_REQUIRED".equals(e.getMessage())) {
                return "redirect:/login?redirect=/give/report/write";
            }
            log.error("report write failed", e);
            return "redirect:/give/report/write?error=save";
        } catch (Exception e) {
            log.error("report write failed", e);
            return "redirect:/give/report/write?error=save";
        }
    }

     /**
     * 진행 상태 변경
     * POST /give/report/status
     * 파라미터: postId, findingStatus (FINDING / RESCUED / OWNER_FOUND)
     */
    @PostMapping("/status")
    public String updateStatus(
            @RequestParam long postId,
            @RequestParam String findingStatus,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/give/report/detail?id=" + postId;
        }
        try {
            giveReportService.updateFindingStatus(postId, findingStatus, member);
            return "redirect:/give/report/detail?id=" + postId;
        } catch (IllegalStateException e) {
            if ("FORBIDDEN".equals(e.getMessage())) {
                return "redirect:/give/report/detail?id=" + postId + "&error=forbidden";
            }
            if ("REPORT_NOT_FOUND".equals(e.getMessage())) {
                return "redirect:/give/report/list";
            }
            return "redirect:/give/report/detail?id=" + postId + "&error=status";
        } catch (IllegalArgumentException e) {
            return "redirect:/give/report/detail?id=" + postId + "&error=status";
        } catch (Exception e) {
            log.error("report status update failed", e);
            return "redirect:/give/report/detail?id=" + postId + "&error=status";
        }
    }

    /**
     * 댓글·대댓글 등록
     * POST /give/report/comment
     */
    @PostMapping("/comment")
    public String insertComment(
            @RequestParam long postId,
            @RequestParam String body,
            @RequestParam(required = false) Long parentId,
            HttpSession session) {

        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/give/report/detail?id=" + postId;
        }

        try {
            communityCommentService.insertComment(postId, body, member, parentId);
            return "redirect:/give/report/detail?id=" + postId;

        } catch (IllegalStateException e) {
            log.warn("report comment insert state error: {}", e.getMessage());
            if ("MEMBER_NOT_FOUND".equals(e.getMessage())) {
                return "redirect:/give/report/detail?id=" + postId + "&error=member";
            }
            if ("LOGIN_REQUIRED".equals(e.getMessage())) {
                return "redirect:/login?redirect=/give/report/detail?id=" + postId;
            }
            return "redirect:/give/report/detail?id=" + postId + "&error=comment";

        } catch (IllegalArgumentException e) {
            if ("INVALID_PARENT".equals(e.getMessage())) {
                return "redirect:/give/report/detail?id=" + postId + "&error=comment";
            }
            return "redirect:/give/report/detail?id=" + postId + "&error=empty";

        } catch (Exception e) {
            log.error("report comment insert failed", e);
            if (isSequenceError(e)) {
                return "redirect:/give/report/detail?id=" + postId + "&error=seq";
            }
            return "redirect:/give/report/detail?id=" + postId + "&error=comment";
        }
    }

    /**
     * 댓글 삭제
     * POST /give/report/comment/delete
     */
    @PostMapping("/comment/delete")
    public String deleteComment(
            @RequestParam long commentId,
            @RequestParam long postId,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/give/report/detail?id=" + postId;
        }
        try {
            communityCommentService.deleteComment(commentId, postId, member);
            return "redirect:/give/report/detail?id=" + postId;
        } catch (IllegalStateException e) {
            if ("FORBIDDEN".equals(e.getMessage())) {
                return "redirect:/give/report/detail?id=" + postId + "&error=commentForbidden";
            }
            return "redirect:/give/report/detail?id=" + postId + "&error=comment";
        } catch (Exception e) {
            log.error("report comment delete failed", e);
            return "redirect:/give/report/detail?id=" + postId + "&error=comment";
        }
    }

    /**
     * 댓글 수정
     * POST /give/report/comment/update
     */
    @PostMapping("/comment/update")
    public String updateComment(
            @RequestParam long commentId,
            @RequestParam long postId,
            @RequestParam String body,
            HttpSession session) {
        MemberVO member = getMemberOrNull(session);
        if (member == null) {
            return "redirect:/login?redirect=/give/report/detail?id=" + postId;
        }
        try {
            communityCommentService.updateComment(commentId, postId, body, member);
            return "redirect:/give/report/detail?id=" + postId;
        } catch (IllegalStateException e) {
            if ("FORBIDDEN".equals(e.getMessage())) {
                return "redirect:/give/report/detail?id=" + postId + "&error=commentForbidden";
            }
            return "redirect:/give/report/detail?id=" + postId + "&error=comment";
        } catch (IllegalArgumentException e) {
            if ("EMPTY_BODY".equals(e.getMessage())) {
                return "redirect:/give/report/detail?id=" + postId + "&error=empty";
            }
            return "redirect:/give/report/detail?id=" + postId + "&error=comment";
        } catch (Exception e) {
            log.error("report comment update failed", e);
            return "redirect:/give/report/detail?id=" + postId + "&error=comment";
        }
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

    private MemberVO getMemberOrNull(HttpSession session) {
        Object member = session.getAttribute("memberInfo");
        if (member instanceof MemberVO memberVO) {
            return memberVO;
        }
        return null;
    }
    
}

