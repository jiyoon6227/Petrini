/**
 * 2026/07/27 장우철 — 토스 빌링 카드등록 Controller
 *
 * URL
 * - GET  /billing/card/prepare  : Ajax — clientKey·customerKey·콜백 URL 발급
 * - GET  /billing/card/success  : 토스 성공 리다이렉트 → 빌링키 발급·DB(또는 세션) 저장
 * - GET  /billing/card/fail     : 토스 실패 리다이렉트 → 원래 화면 + 알림
 * - GET  /billing/card/list     : Ajax — 활성 카드 목록 (billingKey 제외)
 * - POST /billing/card/delete   : Ajax — 논리삭제
 *
 * 흐름 요약 (공부용)
 * 1) 화면 JS → prepare → TossPayments.requestBillingAuth (토스 카드등록 창)
 * 2) 토스 → success?authKey&customerKey
 * 3) 서버 issueBillingKey → TB_BILLING_CARD (가입 중이면 세션 pending)
 */
package com.petcare.petcare.common.billing.controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.common.billing.service.BillingCardService;
import com.petcare.petcare.common.billing.vo.BillingCardVO;
import com.petcare.petcare.common.billing.vo.BillingIssueResultVO;
import com.petcare.petcare.common.external.service.TossBillingService;
import com.petcare.petcare.member.vo.MemberVO;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/billing/card")
public class BillingCardController {

    /** 2026/07/27 장우철 — 세션 키 */
    public static final String SESSION_RETURN_PATH = "billingReturnPath";
    public static final String SESSION_OWNER_TYPE = "billingOwnerType";
    public static final String SESSION_CUSTOMER_KEY = "billingCustomerKey";
    public static final String SESSION_PENDING_CARD = "pendingBillingCard"; // 가입 중 임시 저장

    private final BillingCardService billingCardService;
    private final TossBillingService tossBillingService;

    public BillingCardController(BillingCardService billingCardService,
                                 TossBillingService tossBillingService) {
        this.billingCardService = billingCardService;
        this.tossBillingService = tossBillingService;
    }

    /**
     * 2026/07/27 장우철 — Ajax: 카드등록 창 열기 전 준비
     * 응답: { ok, clientKey, customerKey, successUrl, failUrl }
     */
    @GetMapping("/prepare")
    @ResponseBody
    public Map<String, Object> prepare(
            @RequestParam String returnPath,
            HttpServletRequest request,
            HttpSession session) {

        Map<String, Object> res = new HashMap<>();
        String safeReturn = sanitizeReturnPath(returnPath);
        if (safeReturn == null) {
            res.put("ok", false);
            res.put("message", "잘못된 복귀 경로입니다.");
            return res;
        }

        OwnerContext owner = resolveOwner(session, safeReturn);
        if (owner == null) {
            res.put("ok", false);
            res.put("message", "로그인이 필요합니다.");
            res.put("loginRequired", true);
            return res;
        }

        // customerKey: 토스 권장 — 추측 어려운 고유값 (단순 memberNo 금지)
        String customerKey = "pc-" + owner.ownerType.toLowerCase() + "-"
                + (owner.ownerNo != null ? owner.ownerNo : "tmp") + "-"
                + UUID.randomUUID().toString().replace("-", "");

        session.setAttribute(SESSION_RETURN_PATH, safeReturn);
        session.setAttribute(SESSION_OWNER_TYPE, owner.ownerType);
        session.setAttribute(SESSION_CUSTOMER_KEY, customerKey);

        String base = buildBaseUrl(request);
        res.put("ok", true);
        res.put("clientKey", tossBillingService.getBillingClientKey());
        res.put("customerKey", customerKey);
        res.put("successUrl", base + "/billing/card/success");
        res.put("failUrl", base + "/billing/card/fail");
        return res;
    }

    /**
     * 2026/07/27 장우철 — 토스 성공 콜백
     * 쿼리: authKey, customerKey → 빌링키 발급 API → DB/세션 저장 → returnPath 복귀
     */
    @GetMapping("/success")
    public String success(
            @RequestParam String authKey,
            @RequestParam String customerKey,
            HttpSession session) {

        String returnPath = (String) session.getAttribute(SESSION_RETURN_PATH);
        String ownerType = (String) session.getAttribute(SESSION_OWNER_TYPE);
        String expectedKey = (String) session.getAttribute(SESSION_CUSTOMER_KEY);

        if (returnPath == null) {
            returnPath = "/";
        }

        // 세션에 넣어둔 customerKey 와 토스가 돌려준 값 일치 확인 (위조 방지)
        if (expectedKey == null || !expectedKey.equals(customerKey)) {
            clearBillingSession(session);
            return "redirect:" + returnPath + appendQuery(returnPath, "card=fail&msg=")
                    + urlEncode("고객키가 일치하지 않습니다.");
        }

        StringBuilder err = new StringBuilder();
        BillingIssueResultVO issued = tossBillingService.issueBillingKey(authKey, customerKey, err);
        if (issued == null) {
            clearBillingSession(session);
            return "redirect:" + returnPath + appendQuery(returnPath, "card=fail&msg=")
                    + urlEncode(err.length() > 0 ? err.toString() : "빌링키 발급 실패");
        }

        try {
            if ("JOIN".equals(ownerType)) {
                // 가입 전: MEMBER_NO 없음 → 세션에만 보관 (가입 완료 시 DB 저장)
                session.setAttribute(SESSION_PENDING_CARD, issued);
            } else {
                OwnerContext owner = resolveOwnerForSave(session, ownerType);
                if (owner == null || owner.ownerNo == null) {
                    clearBillingSession(session);
                    return "redirect:" + returnPath + appendQuery(returnPath, "card=fail&msg=")
                            + urlEncode("로그인 정보가 없습니다.");
                }
                billingCardService.registerCard(owner.ownerType, owner.ownerNo, issued);
            }
        } catch (Exception e) {
            clearBillingSession(session);
            return "redirect:" + returnPath + appendQuery(returnPath, "card=fail&msg=")
                    + urlEncode("카드 저장 중 오류: " + e.getMessage());
        }

        // 발급용 세션만 정리 (pending 카드는 JOIN 시 유지)
        session.removeAttribute(SESSION_RETURN_PATH);
        session.removeAttribute(SESSION_OWNER_TYPE);
        session.removeAttribute(SESSION_CUSTOMER_KEY);

        return "redirect:" + returnPath + appendQuery(returnPath, "card=ok");
    }

    /**
     * 2026/07/27 장우철 — 토스 실패 콜백
     */
    @GetMapping("/fail")
    public String fail(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String message,
            HttpSession session) {

        String returnPath = (String) session.getAttribute(SESSION_RETURN_PATH);
        if (returnPath == null) {
            returnPath = "/";
        }
        clearBillingSession(session);

        String msg = (message != null && !message.isBlank()) ? message : "카드 등록이 취소되었거나 실패했습니다.";
        if (code != null && !code.isBlank()) {
            msg = "[" + code + "] " + msg;
        }
        return "redirect:" + returnPath + appendQuery(returnPath, "card=fail&msg=") + urlEncode(msg);
    }

    /**
     * 2026/07/27 장우철 — Ajax: 활성 카드 목록 (billingKey 미포함)
     */
    @GetMapping("/list")
    @ResponseBody
    public Map<String, Object> list(HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        OwnerContext owner = resolveLoggedInOwner(session);

        // 2026/07/27 장우철 — 가입 중 pending 카드는 로그인 여부와 무관하게 우선 노출
        BillingIssueResultVO pending = (BillingIssueResultVO) session.getAttribute(SESSION_PENDING_CARD);
        if (pending != null) {
            res.put("ok", true);
            res.put("pending", true);
            List<Map<String, Object>> cards = new ArrayList<>();
            cards.add(toSafeCardMap(null, pending.getCardCompany(), pending.getCardNumber()));
            res.put("cards", cards);
            return res;
        }

        if (owner == null) {
            res.put("ok", false);
            res.put("loginRequired", true);
            res.put("message", "로그인이 필요합니다.");
            return res;
        }

        List<BillingCardVO> list = billingCardService.getCardList(owner.ownerType, owner.ownerNo);
        List<Map<String, Object>> cards = new ArrayList<>();
        for (BillingCardVO c : list) {
            cards.add(toSafeCardMap(c.getBillingCardId(), c.getCardCompany(), c.getCardNumber()));
        }
        res.put("ok", true);
        res.put("pending", false);
        res.put("cards", cards);
        return res;
    }

    /**
     * 2026/07/27 장우철 — Ajax: 카드 논리삭제
     */
    @PostMapping("/delete")
    @ResponseBody
    public Map<String, Object> delete(
            @RequestParam(required = false) Long billingCardId,
            @RequestParam(required = false, defaultValue = "false") boolean pending,
            HttpSession session) {

        Map<String, Object> res = new HashMap<>();

        // 가입 중 임시 카드 해제
        if (pending) {
            session.removeAttribute(SESSION_PENDING_CARD);
            res.put("ok", true);
            return res;
        }

        OwnerContext owner = resolveLoggedInOwner(session);
        if (owner == null) {
            res.put("ok", false);
            res.put("message", "로그인이 필요합니다.");
            return res;
        }
        if (billingCardId == null) {
            res.put("ok", false);
            res.put("message", "카드 ID가 없습니다.");
            return res;
        }

        boolean removed = billingCardService.removeCard(billingCardId, owner.ownerType, owner.ownerNo);
        res.put("ok", removed);
        if (!removed) {
            res.put("message", "카드를 삭제할 수 없습니다.");
        }
        return res;
    }

    // ── helpers ──

    private OwnerContext resolveOwner(HttpSession session, String returnPath) {
        OwnerContext loggedIn = resolveLoggedInOwner(session);
        if (loggedIn != null) {
            return loggedIn;
        }
        // 가입 화면만 비로그인 허용
        if (returnPath.startsWith("/join")) {
            return new OwnerContext("JOIN", null);
        }
        return null;
    }

    private OwnerContext resolveLoggedInOwner(HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return null;
        }
        if ("ADMIN".equals(member.getRole()) && member.getAdminNo() != null) {
            return new OwnerContext("ADMIN", member.getAdminNo());
        }
        if (member.getMemberNo() != null) {
            return new OwnerContext("MEMBER", member.getMemberNo());
        }
        return null;
    }

    private OwnerContext resolveOwnerForSave(HttpSession session, String ownerType) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            return null;
        }
        if ("ADMIN".equals(ownerType)) {
            return new OwnerContext("ADMIN", member.getAdminNo());
        }
        if ("MEMBER".equals(ownerType)) {
            return new OwnerContext("MEMBER", member.getMemberNo());
        }
        return null;
    }

    private Map<String, Object> toSafeCardMap(Long id, String company, String number) {
        Map<String, Object> m = new HashMap<>();
        m.put("billingCardId", id);
        m.put("cardCompany", company);
        m.put("cardNumber", number);
        m.put("label", formatLabel(company, number));
        return m;
    }

    private static String formatLabel(String company, String number) {
        String c = (company != null && !company.isBlank()) ? company : "카드";
        String n = (number != null && !number.isBlank()) ? number : "····";
        return c + " " + n;
    }

    /** open redirect 방지: 상대경로 + 허용 prefix 만 */
    private String sanitizeReturnPath(String returnPath) {
        if (returnPath == null || returnPath.isBlank()) {
            return null;
        }
        String p = returnPath.trim();
        if (!p.startsWith("/") || p.startsWith("//") || p.contains("://")) {
            return null;
        }
        if (p.startsWith("/join") || p.startsWith("/mypage/edit") || p.startsWith("/admin")) {
            // 쿼리 제거 (우리가 card= 붙임)
            int q = p.indexOf('?');
            return q >= 0 ? p.substring(0, q) : p;
        }
        return null;
    }

    private String buildBaseUrl(HttpServletRequest request) {
        String ctx = request.getContextPath() == null ? "" : request.getContextPath();
        return request.getScheme() + "://" + request.getServerName()
                + (request.getServerPort() == 80 || request.getServerPort() == 443
                ? "" : ":" + request.getServerPort())
                + ctx;
    }

    private static String appendQuery(String path, String query) {
        return path.contains("?") ? ("&" + query) : ("?" + query);
    }

    private static String urlEncode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }

    private void clearBillingSession(HttpSession session) {
        session.removeAttribute(SESSION_RETURN_PATH);
        session.removeAttribute(SESSION_OWNER_TYPE);
        session.removeAttribute(SESSION_CUSTOMER_KEY);
    }

    private static class OwnerContext {
        final String ownerType;
        final Long ownerNo;

        OwnerContext(String ownerType, Long ownerNo) {
            this.ownerType = ownerType;
            this.ownerNo = ownerNo;
        }
    }
}
