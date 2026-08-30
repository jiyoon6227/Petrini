/**
 * 역할: 회원 인증(로그인·회원가입) 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - member/login.jsp          로그인
 * - member/join.jsp           회원가입
 *
 * 연결
 * - 구현: MemberAuthServiceImpl
 * - 호출: MemberAuthController
 * - DB: MemberAuthMapper
 */

package com.petcare.petcare.member.auth.service;

import com.petcare.petcare.member.auth.vo.EmailCheckResultVO;
import com.petcare.petcare.member.auth.vo.KakaoUserVO;
import com.petcare.petcare.member.auth.vo.MemberRegisterVO;
import com.petcare.petcare.member.vo.MemberVO;

public interface MemberAuthService {

    // 2026/07/06 장우철 — login(로그인)

    /**
     * 이메일·아이디 로그인 처리
     * @return 성공 시 세션용 MemberVO, 실패 시 null
     */
    MemberVO login(String loginId, String rawPassword);

    // 2026-07-09 장우철 — 이미 로그인된 세션에 승인 사업자 권한 반영
    // 이유: 관리자 승인 직후 재로그인 없이 /mypage/biz 리다이렉트 루프 방지
    void enrichSessionWithApprovedBiz(MemberVO sessionMember);

    // 2026/07/07 장우철 — join(회원가입)

    /**
     * HYJ 26.07.15 카카오 사용자 정보로 로그인 또는 자동 회원가입
     * @return 세션용 MemberVO (항상 non-null — 신규면 가입 후 반환)
     */
    MemberVO kakaoLogin(KakaoUserVO kakaoUser);

    /**
     * 이메일 중복 확인 — join.jsp [중복 확인] Ajax (GET /join/check-email)
     * @return available=true 이면 가입 가능
     */
    EmailCheckResultVO checkEmail(String email);

    /**
     * 아이디 중복 확인 — join.jsp [중복 확인] Ajax (GET /join/check-id)
     * @return available=true 이면 가입 가능
     */
    EmailCheckResultVO checkMemberId(String memberId);

    /**
     * 회원가입 처리 — join.jsp [가입 완료] POST /join
     * @param petPhoto 선택 — Step3 대표 사진 (없으면 null)
     * @return null 이면 성공, 문자열이면 오류 코드 (join.jsp 에서 메시지 분기)
     */
    // 2026/08/11 장우철 — 펫 성별·대표사진 Multipart 연동
    String register(MemberRegisterVO vo, org.springframework.web.multipart.MultipartFile petPhoto);
}
