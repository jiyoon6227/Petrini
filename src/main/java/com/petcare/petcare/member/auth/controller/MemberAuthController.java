package com.petcare.petcare.member.auth.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.member.auth.exception.MemberLoginBlockedException;
import com.petcare.petcare.member.auth.service.EmailService;
import com.petcare.petcare.member.auth.service.KakaoOAuthService;
import com.petcare.petcare.member.auth.service.MemberAuthService;
import com.petcare.petcare.member.auth.vo.EmailCheckResultVO;
import com.petcare.petcare.member.auth.vo.JoinDraftVO;
import com.petcare.petcare.member.auth.vo.KakaoUserVO;
import com.petcare.petcare.member.auth.vo.MemberRegisterVO;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.common.billing.controller.BillingCardController;
import com.petcare.petcare.common.billing.service.BillingCardService;
import com.petcare.petcare.common.billing.vo.BillingIssueResultVO;
import com.petcare.petcare.common.util.LoginAttemptUtil;

import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.http.HttpSession;

@Controller("memberController")
public class MemberAuthController {

    // 카카오로그인
    @Autowired
    KakaoOAuthService kakaoOAuthService;

    // 이메일 인증
    @Autowired
    EmailService emailService;    

    private final MemberAuthService memberAuthService;

    // 가입 중 등록한 pending 카드를 가입 완료 시 DB 저장
    private final BillingCardService billingCardService;

	// 카카오 로그인
    public MemberAuthController(MemberAuthService memberAuthService,
                                KakaoOAuthService kakaoOAuthService,
                                BillingCardService billingCardService) {
        this.memberAuthService = memberAuthService;
        this.kakaoOAuthService = kakaoOAuthService;
        this.billingCardService = billingCardService;
    }

    // login(로그인)

    /** login — 화면 (GET /login) */
    @GetMapping("/login")
    public String login() {
        return "member/login";
    }

    /** login — 처리 (POST /login) */
    @PostMapping("/login")
    public String loginPost(
            @RequestParam(required = false) String loginId,
            @RequestParam(required = false) String loginPw,
            @RequestParam(required = false) String redirect,
            HttpSession session) {

        if (loginId == null || loginId.isBlank() || loginPw == null || loginPw.isBlank()) {
            return "redirect:/login?error=empty";
        }

        // 잠금 상태 확인 — 5회 실패 후 30분간 차단
        if (LoginAttemptUtil.isLocked(loginId)) {
            long remaining = LoginAttemptUtil.getRemainingLockMinutes(loginId);
            return "redirect:/login?error=locked&minutes=" + remaining;
        }
        
        try {
            MemberVO member = memberAuthService.login(loginId, loginPw);
            if (member == null) {
                // 실패 기록
                LoginAttemptUtil.recordFailure(loginId);
                int remaining = LoginAttemptUtil.getRemainingAttempts(loginId);
                if (remaining == 0) {
                    return "redirect:/login?error=locked&minutes=30";
                }
                return "redirect:/login?error=invalid&remaining=" + remaining;
            }

            // 성공 시 실패 기록 초기화
            LoginAttemptUtil.resetAttempts(loginId);

            // 세션 memberInfo 저장 (header.jsp 로그인 상태 표시용)
            session.setAttribute("memberInfo", member);

            // 정지 회원은 고객센터로
            if("SUSPENDED".equals(member.getStatus())) {
                return "redirect:/member/cs";
            }

            // "//" 로 시작하는 외부 URL 차단 (오픈 리다이렉트 방지)
            if (redirect != null && !redirect.isBlank() && redirect.startsWith("/") && !redirect.startsWith("//")) {
                return "redirect:" + redirect;
            }
            return "redirect:/";
        } catch (MemberLoginBlockedException e) {
            // 정지·탈퇴 회원 전용 메시지
            return "redirect:/login?error=" + mapLoginBlockedError(e.getErrorCode());
        }
    }

   // 카카오 로그인
    // 로그인(/oauth/kakao/login) vs 회원가입(/oauth/kakao/signup) intent 분리

    /** 세션 키 — 카카오 OAuth 진입 경로 (login | signup) */
    public static final String SESSION_KAKAO_INTENT = "kakaoIntent";
    public static final String KAKAO_INTENT_LOGIN = "login";
    public static final String KAKAO_INTENT_SIGNUP = "signup";

    /**
     * 카카오 로그인 — login.jsp 전용 (미가입 시 가입 페이지로 보내지 않음)
     */
    @GetMapping({ "/oauth/kakao", "/oauth/kakao/login" })
    public String kakaoLogin(HttpSession session) {
        session.setAttribute(SESSION_KAKAO_INTENT, KAKAO_INTENT_LOGIN);
        return "redirect:" + kakaoOAuthService.buildAuthorizeUrl(KAKAO_INTENT_LOGIN);
    }

    /**
     * 카카오 연동 회원가입 — join.jsp 전용 (미가입 시 kakaoUserInfo 담아 /join)
     * 가입 진입 시에만 memberInfo 제거 (이전 로그인 잔존으로 가입 폼이 가려지지 않게)
     */
    @GetMapping("/oauth/kakao/signup")
    public String kakaoSignup(HttpSession session) {
        session.removeAttribute("memberInfo");
        session.setAttribute(SESSION_KAKAO_INTENT, KAKAO_INTENT_SIGNUP);
        return "redirect:" + kakaoOAuthService.buildAuthorizeUrl(KAKAO_INTENT_SIGNUP);
    }

    /**
     * 카카오 콜백 (intent에 따라 로그인/회원가입 분기)
     * 카카오가 돌려주는 state 를 우선 사용 (세션 intent 유실 시 로그인으로 오인 방지)
     */
    @GetMapping("/oauth/kakao/callback")
    public String kakaoCallback(
            @RequestParam(required = false) String code,
            @RequestParam(required = false) String error,
            @RequestParam(required = false) String state,
            HttpSession session) {

        String sessionIntent = (String) session.getAttribute(SESSION_KAKAO_INTENT);
        session.removeAttribute(SESSION_KAKAO_INTENT);
        String intent = (KAKAO_INTENT_SIGNUP.equals(state) || KAKAO_INTENT_LOGIN.equals(state))
                ? state : sessionIntent;
        boolean signupFlow = KAKAO_INTENT_SIGNUP.equals(intent);

        if (error != null || code == null || code.isBlank()) {
            return signupFlow
                    ? "redirect:/join?error=kakao_cancel"
                    : "redirect:/login?error=kakao_cancel";
        }

        String accessToken = kakaoOAuthService.getAccessToken(code);
        if (accessToken == null) {
            return signupFlow
                    ? "redirect:/join?error=kakao_token"
                    : "redirect:/login?error=kakao_token";
        }

        KakaoUserVO kakaoUser = kakaoOAuthService.getUserInfo(accessToken);
        if (kakaoUser == null) {
            return signupFlow
                    ? "redirect:/join?error=kakao_user"
                    : "redirect:/login?error=kakao_user";
        }

        try {
            MemberVO member = memberAuthService.kakaoLogin(kakaoUser);

            if (member == null) {
                if (signupFlow) {
                    session.setAttribute("kakaoUserInfo", kakaoUser);
                    return "redirect:/join";
                }
                return "redirect:/login?error=kakao_not_member";
            }

            // 회원가입 경로인데 이미 가입된 회원은 로그인 처리 없이 로그인 페이지로 안내
            if (signupFlow) {
                return "redirect:/login?error=kakao_already_member";
            }

            session.setAttribute("memberInfo", member);
            session.setAttribute("kakaoAccessToken", accessToken);

            if ("SUSPENDED".equals(member.getStatus())) {
                return "redirect:/member/cs";
            }
            return "redirect:/";
        } catch (MemberLoginBlockedException e) {
            return "redirect:/login?error=" + mapLoginBlockedError(e.getErrorCode());
        }
    }
    
    /**
     * join — 화면 (GET /join)
     * card=ok|fail(토스 복귀)가 아니면 임시저장·pending 카드 폐기
     * → 다른 페이지 갔다가 다시 들어오면 처음부터
     * card=ok 이면 pending 카드 라벨을 모델에 넣어 JSP가 바로 「등록됨」 표시
     */
    @GetMapping("/join")
    public String join(@RequestParam(required = false) String card,
                       HttpSession session,
                       Model model) {
        boolean fromTossCard = "ok".equals(card) || "fail".equals(card);
        if (!fromTossCard) {
            session.removeAttribute(SESSION_JOIN_DRAFT);
            session.removeAttribute(BillingCardController.SESSION_PENDING_CARD);
        } else if ("ok".equals(card)) {
            // Ajax race 전에 화면에 카드정보 표시
            BillingIssueResultVO pending = (BillingIssueResultVO) session.getAttribute(
                    BillingCardController.SESSION_PENDING_CARD);
            if (pending != null) {
                String company = pending.getCardCompany() != null ? pending.getCardCompany() : "카드";
                String number = pending.getCardNumber() != null ? pending.getCardNumber() : "····";
                model.addAttribute("pendingCardLabel", company + " " + number);
            }
        }
        return "member/join";
    }

    // join 세션 임시저장 (토스 카드등록 왕복용)

    /** 세션 키 — JoinDraftVO */
    public static final String SESSION_JOIN_DRAFT = "joinDraft";

    /**
     * join — 폼 임시저장 (POST /join/draft)
     * join.jsp 가 토스 창 열기 직전 Ajax 로 호출
     */
    @PostMapping("/join/draft")
    @ResponseBody
    public Map<String, Object> saveJoinDraft(@RequestBody JoinDraftVO draft, HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        if (draft == null) {
            res.put("ok", false);
            res.put("message", "임시저장 데이터가 없습니다.");
            return res;
        }
        if (draft.getStep() == null) {
            draft.setStep(2);
        }
        session.setAttribute(SESSION_JOIN_DRAFT, draft);

        // 이메일 인증 완료 상태도 서버 세션에 맞춰 복원 (가입 검증·재진입용)
        if (Boolean.TRUE.equals(draft.getEmailVerified())
                && draft.getEmail() != null && !draft.getEmail().isBlank()) {
            session.setAttribute("emailVerified", true);
            session.setAttribute("emailVerifiedAddr", draft.getEmail().trim());
        }

        res.put("ok", true);
        return res;
    }

    /**
     * join — 폼 임시저장 조회 (GET /join/draft)
     * 토스 복귀(card=ok|fail)일 때만 draft 반환, 그 외 null
     */
    @GetMapping("/join/draft")
    @ResponseBody
    public Map<String, Object> getJoinDraft(
            @RequestParam(required = false) String card,
            HttpSession session) {
        Map<String, Object> res = new HashMap<>();
        boolean fromTossCard = "ok".equals(card) || "fail".equals(card);
        JoinDraftVO draft = null;
        if (fromTossCard) {
            draft = (JoinDraftVO) session.getAttribute(SESSION_JOIN_DRAFT);
        }
        res.put("ok", true);
        res.put("draft", draft);
        return res;
    }

    // join(회원가입)

    /**
     * join — 이메일 중복 확인 (GET /join/check-email)
     * join.jsp [중복 확인] Ajax → JSON { available, message }
     * SQL·검증은 Service, Controller 는 결과만 반환
     */
    @GetMapping("/join/check-email")
    @ResponseBody
    public EmailCheckResultVO checkEmail(@RequestParam String email) {
        return memberAuthService.checkEmail(email);
    }

    /**
     * join — 아이디 중복 확인 (GET /join/check-id)
     */
    @GetMapping("/join/check-id")
    @ResponseBody
    public EmailCheckResultVO checkMemberId(@RequestParam String id) {
        return memberAuthService.checkMemberId(id);
    }

       // 이메일 인증

    /**
     * join — 인증번호 발송 (POST /join/send-code)
     * 이메일 중복 확인 통과 후 인증번호 메일 발송
     * 인증번호와 만료시간을 세션에 저장
     */
    @PostMapping("/join/send-code")
    @ResponseBody
    public EmailCheckResultVO sendCode(@RequestParam String email, HttpSession session) {

        // 이메일 형식 검증
        if (email == null || !email.trim().matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return new EmailCheckResultVO(false, "올바른 이메일 형식이 아닙니다.");
        }

        try {
            String code = emailService.generateCode();
            emailService.sendVerificationEmail(email.trim(), code);

            // 세션에 인증번호 + 만료시간(5분) 저장
            session.setAttribute("emailVerifyCode", code);
            session.setAttribute("emailVerifyEmail", email.trim());
            session.setAttribute("emailVerifyExpire", System.currentTimeMillis() + (5 * 60 * 1000));

            return new EmailCheckResultVO(true, "인증번호가 발송되었습니다.");
        } catch (Exception e) {
            System.out.println("오류" + e);
            return new EmailCheckResultVO(false, "메일 발송 실패: " + e.getMessage());
        }
    }

    /**
     * join — 인증번호 확인 (POST /join/verify-code)
     * 사용자가 입력한 인증번호와 세션 값 비교
     */
    @PostMapping("/join/verify-code")
    @ResponseBody
    public EmailCheckResultVO verifyCode(@RequestParam String email,
                                         @RequestParam String code,
                                         HttpSession session) {

        String savedCode  = (String) session.getAttribute("emailVerifyCode");
        String savedEmail = (String) session.getAttribute("emailVerifyEmail");
        Long   expireTime = (Long)   session.getAttribute("emailVerifyExpire");

        // 세션에 인증 정보가 없음
        if (savedCode == null || savedEmail == null || expireTime == null) {
            return new EmailCheckResultVO(false, "인증번호를 먼저 발송해 주세요.");
        }

        // 만료 확인
        if (System.currentTimeMillis() > expireTime) {
            session.removeAttribute("emailVerifyCode");
            session.removeAttribute("emailVerifyEmail");
            session.removeAttribute("emailVerifyExpire");
            return new EmailCheckResultVO(false, "인증번호가 만료되었습니다. 다시 발송해 주세요.");
        }

        // 이메일 일치 확인
        if (!savedEmail.equals(email.trim())) {
            return new EmailCheckResultVO(false, "인증 요청한 이메일과 다릅니다.");
        }

        // 인증번호 비교
        if (!savedCode.equals(code.trim())) {
            return new EmailCheckResultVO(false, "인증번호가 일치하지 않습니다.");
        }

        // 인증 성공 → 세션에 인증 완료 표시
        session.setAttribute("emailVerified", true);
        session.setAttribute("emailVerifiedAddr", email.trim());
        return new EmailCheckResultVO(true, "이메일 인증이 완료되었습니다.");
    }

    /**
     * join — 가입 처리 (POST /join)
     * join.jsp [가입 완료] FormData → MemberRegisterVO 자동 매핑
     * 성공: "OK" / 실패: "ERROR:코드" (join.jsp 에서 분기 — JSP 수정은 직접 적용)
     * 카카오 → 회원가입 흐름: 가입 성공 후 세션의 kakaoUserInfo 로 SOCIAL_ID 연동
     */
    @PostMapping("/join")
    @ResponseBody
    public String joinPost(MemberRegisterVO vo,
                           @RequestParam(value = "petPhoto", required = false) MultipartFile petPhoto,
                           HttpSession session) {

        // 카카오 → 회원가입 흐름이면 socialId 를 VO 에 담아서 register() 에서 함께 처리
        KakaoUserVO kakaoUser = (KakaoUserVO) session.getAttribute("kakaoUserInfo");
        if (kakaoUser != null) {
            vo.setSocialId(kakaoUser.getKakaoId());
        }
        // Step3 펫 성별(petGender)·대표사진(petPhoto) 저장
        String error = memberAuthService.register(vo, petPhoto);
        if (error != null) {
            return "ERROR:" + error;
        }
        BillingIssueResultVO pending = (BillingIssueResultVO) session.getAttribute(
                BillingCardController.SESSION_PENDING_CARD);
        if (pending != null && vo.getMemberNo() != null) {
            try {
                billingCardService.registerCard("MEMBER", vo.getMemberNo(), pending);
            } catch (Exception e) {
                // 가입 자체는 성공 — 카드만 실패 시 마이페이지에서 재등록 가능
                e.printStackTrace();
            }
            session.removeAttribute(BillingCardController.SESSION_PENDING_CARD);
        }
        // 가입 성공 시 임시저장·이메일인증 세션 정리
        session.removeAttribute(SESSION_JOIN_DRAFT);
        session.removeAttribute("emailVerified");
        session.removeAttribute("emailVerifiedAddr");
        // 세션 정리
        if (kakaoUser != null) {
            session.removeAttribute("kakaoUserInfo");
        }

        return "OK";
    }

    // login(로그아웃)

    // 로그아웃
    // 서버 세션만 제거 (브라우저 자동로그인용 sessionStorage는 login.jsp에서 별도 처리 예정)
    @GetMapping("/member/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }

    // STATUS_CD → login.jsp error 파라미터
    private String mapLoginBlockedError(String statusCd) {
        if ("SUSPENDED".equals(statusCd)) {
            return "suspended";
        }
        if ("WITHDRAWN".equals(statusCd)) {
            return "withdrawn";
        }
        return "invalid";
    }
}
