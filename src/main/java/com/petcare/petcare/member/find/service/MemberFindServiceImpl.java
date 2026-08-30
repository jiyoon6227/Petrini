/**
 * 역할: MemberFindService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: MemberFindService
 * - 사용: MemberFindMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.member.find.service;

import java.util.Random;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.member.auth.service.EmailService;
import com.petcare.petcare.member.find.mapper.MemberFindMapper;
import com.petcare.petcare.member.find.vo.MemberFindVO;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class MemberFindServiceImpl implements MemberFindService {
    private final MemberFindMapper memberFindMapper;
    private final PasswordEncoder passwordEncoder;
    private final EmailService emailService;

        /**
     * 아이디 찾기
     * 이름 + 전화번호로 회원을 찾아서 MEMBER_ID(로그인 아이디) 원문 반환
     * 2026/08/11 장우철 — EMAIL 대신 MEMBER_ID / 마스킹 제거(찾기 목적상 원문 표시)
     */
    @Override
    @Transactional(readOnly = true)
    public String findMemberId(String memberName, String phone) {
        if (memberName == null || memberName.isBlank()) return null;
        if (phone == null || phone.isBlank()) return null;

        // JSP 입력이 하이픈 포함(010-0000-0000)이고 DB PHONE 도 동일 형식이라 phone 그대로 조회
        MemberFindVO member = memberFindMapper.selectByNameAndPhone(memberName.trim(), phone);
        if (member == null) return null;

        String id = member.getMemberId();
        if (id == null || id.isBlank()) {
            return null;
        }
        return id.trim();
    }

    /**
     * 비밀번호 찾기
     * [1] 이메일 + 이름으로 회원 확인
     * [2] 임시 비밀번호 생성 (영문+숫자+특수문자 10자리)
     * [3] BCrypt 암호화 후 DB 저장
     * [4] 임시 비밀번호를 이메일로 발송
     */
    @Override
    @Transactional
    public String resetPassword(String email, String memberName) {
        if (email == null || email.isBlank()) return "이메일을 입력해 주세요.";
        if (memberName == null || memberName.isBlank()) return "이름을 입력해 주세요.";

        MemberFindVO member = memberFindMapper.selectByEmailAndName(email.trim(), memberName.trim());
        if (member == null) {
            return "일치하는 회원 정보가 없습니다.";
        }

        // 임시 비밀번호 생성
        String tempPw = generateTempPassword();

        // 암호화 후 DB 저장
        String encoded = passwordEncoder.encode(tempPw);
        memberFindMapper.updatePassword(member.getMemberNo(), encoded);

        // 이메일 발송
        String toEmail = member.getEmail();
        if (toEmail == null || toEmail.isBlank()) {
            toEmail = email; // 이메일 컬럼이 비었으면 입력한 이메일 사용
        }

        try {
            String subject = "[PetCare] 임시 비밀번호 안내";
            String body = ""
                + "<div style='max-width:480px; margin:0 auto; padding:32px; "
                + "font-family:Pretendard,Apple SD Gothic Neo,sans-serif;'>"
                + "  <h2 style='color:#2BAB82; margin-bottom:8px;'>임시 비밀번호 안내</h2>"
                + "  <p style='color:#555; font-size:15px;'>"
                + member.getMemberName() + "님, 임시 비밀번호가 발급되었습니다.</p>"
                + "  <div style='background:#EAF7F2; border:2px solid #2BAB82; border-radius:12px; "
                + "  padding:24px; text-align:center; margin:24px 0;'>"
                + "    <span style='font-size:24px; font-weight:700; letter-spacing:4px; color:#333;'>"
                + tempPw
                + "    </span>"
                + "  </div>"
                + "  <p style='color:#999; font-size:13px;'>"
                + "로그인 후 반드시 비밀번호를 변경해 주세요.</p>"
                + "</div>";
            emailService.send(toEmail, subject, body);
        } catch (Exception e) {
            // 이메일 발송 실패해도 비밀번호는 이미 변경됨
            System.out.println("[find/pw] 이메일 발송 실패: " + e.getMessage());
            return "임시 비밀번호가 설정되었으나 이메일 발송에 실패했습니다. 고객센터에 문의해 주세요.";
        }

        return null; // 성공
    }

    // ── 내부 메서드 ──

    /**
     * 임시 비밀번호 생성 (영문+숫자+특수문자 10자리)
     * 최소 영문 1개, 숫자 1개, 특수문자 1개 포함 보장
     */
    private String generateTempPassword() {
        String upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        String lower = "abcdefghijklmnopqrstuvwxyz";
        String digits = "0123456789";
        String specials = "!@#$%&*";
        String all = upper + lower + digits + specials;
        Random rand = new Random();

        StringBuilder sb = new StringBuilder();
        // 필수 1자씩
        sb.append(upper.charAt(rand.nextInt(upper.length())));
        sb.append(lower.charAt(rand.nextInt(lower.length())));
        sb.append(digits.charAt(rand.nextInt(digits.length())));
        sb.append(specials.charAt(rand.nextInt(specials.length())));
        // 나머지 6자 랜덤
        for (int i = 0; i < 6; i++) {
            sb.append(all.charAt(rand.nextInt(all.length())));
        }

        // 셔플
        char[] arr = sb.toString().toCharArray();
        for (int i = arr.length - 1; i > 0; i--) {
            int j = rand.nextInt(i + 1);
            char tmp = arr[i];
            arr[i] = arr[j];
            arr[j] = tmp;
        }
        return new String(arr);
    }
}
