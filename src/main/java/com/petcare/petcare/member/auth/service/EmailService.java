/**
 * 2026/07/15 — 회원가입 이메일 인증
 *
 * 역할: Google SMTP 로 인증번호 발송 (@Service)
 *
 * 흐름
 * 1. Controller 가 이메일 주소 전달
 * 2. 6자리 인증번호 생성 → 메일 발송
 * 3. 인증번호를 반환 → Controller 가 세션에 저장
 * 4. 사용자가 입력한 인증번호와 세션 값 비교 → 일치하면 인증 완료
 *
 * 연결
 * - 호출: MemberAuthController (POST /join/send-code, POST /join/verify-code)
 * - 설정: application.properties (spring.mail.*)
 */
package com.petcare.petcare.member.auth.service;

import java.util.Properties;
import java.util.Random;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender mailSender;

    // 2026/08/01 장우철 — mail.smtp-from 미설정 시 spring.mail.username 사용 (클린패키지/기동 실패 방지)
    @Value("${mail.smtp-from:${spring.mail.username}}")
    private String from;

    /**
     * HYJ 26.07.28 공통 메일 발송
     */
    public void send(String to, String subject, String htmlBody) throws MessagingException {
        if (mailSender instanceof JavaMailSenderImpl) {
            Properties props = ((JavaMailSenderImpl) mailSender).getJavaMailProperties();
            props.put("mail.smtp.localhost", "127.0.0.1");
        }

        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, false, "UTF-8");
        helper.setFrom(from);
        helper.setTo(to);
        helper.setSubject(subject);
        helper.setText(htmlBody, true);

        mailSender.send(message);
    }

    /**
     * 인증번호 메일 발송
     * @param toEmail 수신자 이메일
     * @param code    6자리 인증번호
     */
    public void sendVerificationEmail(String to, String code) throws MessagingException {
        String subject = "[PetCare] 이메일 인증번호 안내";
        String body = ""
            + "<div style='max-width:480px; margin:0 auto; padding:32px; "
            + "font-family:\"Pretendard\",\"Apple SD Gothic Neo\",sans-serif;'>"
            + "  <h2 style='color:#FD8B00; margin-bottom:8px;'>PetCare 이메일 인증</h2>"
            + "  <p style='color:#555; font-size:15px;'>아래 인증번호를 입력해 주세요.</p>"
            + "  <div style='background:#FFF8EE; border:2px solid #FD8B00; border-radius:12px; "
            + "  padding:24px; text-align:center; margin:24px 0;'>"
            + "    <span style='font-size:32px; font-weight:700; letter-spacing:8px; color:#333;'>"
            + code
            + "    </span>"
            + "  </div>"
            + "  <p style='color:#999; font-size:13px;'>인증번호는 5분간 유효합니다.</p>"
            + "</div>";

        send(to, subject, body);  // 공통 메서드 호출
    }

    /**
     * HYJ 26.07.28 사업자 승인 알림
     */
    public void sendApproveNotice(String to, String bizName) throws MessagingException {

        String subject = "[PetCare] 사업자 승인 완료";
        String body = ""
            + "<div style='max-width:480px; margin:0 auto; padding:32px;'>"
            + "  <h2 style='color:#2BAB82;'>사업자 승인 완료</h2>"
            + "  <p>" + bizName + " 업체가 승인되었습니다.</p>"
            + "  <p>지금부터 사업자 페이지에서 업체를 관리할 수 있습니다.</p>"
            + "</div>";

        send(to, subject, body);
    }

    /**
     * HYJ 26.07.28 사업자 반려 알림
     */
    public void sendRejectNotice(String to, String bizName, String reason) throws MessagingException {
        String subject = "[PetCare] 사업자 등록 반려 안내";
        String body = ""
            + "<div style='max-width:480px; margin:0 auto; padding:32px;'>"
            + "  <h2 style='color:#DC2626;'>사업자 등록 반려</h2>"
            + "  <p><b>" + bizName + "</b> 업체 등록이 반려되었습니다.</p>"
            + "  <div style='background:#FEF2F2; border:1px solid #FECACA; border-radius:8px;"
            + "  padding:16px; margin:16px 0;'>"
            + "    <p style='color:#DC2626; font-weight:600; margin:0 0 4px;'>반려 사유</p>"
            + "    <p style='color:#555; margin:0;'>" + reason + "</p>"
            + "  </div>"
            + "  <p style='color:#999; font-size:13px;'>수정 후 다시 신청하실 수 있습니다.</p>"
            + "</div>";

        send(to, subject, body);
    }

    /**
     * HYJ 26.07.28 예약 확인 알림
     */
    public void sendReservationConfirm(String to, String bizName, String date) throws MessagingException {
        String subject = "[PetCare] 예약이 확인되었습니다";
        String body = ""
            + "<div style='max-width:480px; margin:0 auto; padding:32px;'>"
            + "  <h2 style='color:#2BAB82;'>예약 확인</h2>"
            + "  <p>" + bizName + " 예약이 확정되었습니다.</p>"
            + "  <p>날짜: " + date + "</p>"
            + "</div>";

        send(to, subject, body);
    }

    /**
     * 6자리 인증번호 생성
     */
    public String generateCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);  // 100000 ~ 999999
        return String.valueOf(code);
    }

    //지윤 26.08.05 추가: 상품 품절 알림 (기존 sendApproveNotice 패턴과 동일)
    //지윤 26.08.05 수정: 사업자명까지 넣어서 인사말 추가 (3개 파라미터)
    public void sendSoldoutNotice(String to, String bizName, String productName) throws MessagingException {
    String subject = "[PetCare] 상품 품절 알림";
    String body = ""
        + "<div style='max-width:480px; margin:0 auto; padding:32px;'>"
        + "  <h2 style='color:#DC2626;'>상품 품절 안내</h2>"
        + "  <p><b>" + bizName + "</b> 사업자님, 아래 상품의 재고가 모두 소진되었습니다.</p>"
        + "  <div style='background:#FEF2F2; border:1px solid #FECACA; border-radius:8px;"
        + "  padding:16px; margin:16px 0;'>"
        + "    <p style='color:#DC2626; font-weight:600; margin:0;'>" + productName + "</p>"
        + "  </div>"
        + "  <p style='color:#999; font-size:13px;'>사업자센터에서 재고를 보충해주세요.</p>"
        + "</div>";

    send(to, subject, body);
 }
}
