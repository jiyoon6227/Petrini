/**
 * 역할: 카카오톡 메시지 "나에게 보내기" REST API 연동 (@Service)
 *
 * 구현 내용
 * - 예약 완료 시 사용자 본인의 카카오톡으로 예약 정보 메시지 발송
 * - POST https://kapi.kakao.com/v2/api/talk/memo/default/send
 * - 사용자 Access Token 기반 (Admin Key 아님) → 권한 신청 없이 사용 가능
 *
 * 연결
 * - 호출: StayServiceImpl (결제 확정 후)
 * - 참고: KakaoOAuthService, KakaoMapService 와 동일한 HttpURLConnection 패턴
 *
 * 사전 설정
 * - 카카오디벨로퍼스 > 동의항목 > "카카오톡 메시지 전송" 설정 필요
 * - 카카오 로그인 시 scope에 "talk_message" 포함 필요
 */

package com.petcare.petcare.common.external.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class KakaoMessageService {

    private static final Logger log = LoggerFactory.getLogger(KakaoMessageService.class);

    // 나에게 보내기 API URL
    private static final String MEMO_SEND_URL = "https://kapi.kakao.com/v2/api/talk/memo/default/send";

    /**
     * 숙소 예약 완료 메시지를 사용자 본인의 카카오톡으로 발송
     *
     * @param accessToken  카카오 로그인 시 발급받은 사용자 Access Token (세션에서 가져옴)
     * @param resvNo       예약번호
     * @param stayName     숙소명
     * @param roomName     객실명
     * @param checkinDate  체크인 날짜 (yyyy.MM.dd)
     * @param checkoutDate 체크아웃 날짜 (yyyy.MM.dd)
     * @param nightCnt     숙박일수
     * @param totalAmount  결제 금액
     * @param petName      반려동물 이름
     * @return 발송 성공 여부
     */
    public boolean sendStayReservationMessage(String accessToken,
                                               String resvNo,
                                               String stayName,
                                               String roomName,
                                               String checkinDate,
                                               String checkoutDate,
                                               int nightCnt,
                                               long totalAmount,
                                               String petName) {

        if (accessToken == null || accessToken.isBlank()) {
            log.warn("[KakaoMsg] accessToken 없음 — 카카오 로그인 사용자가 아닙니다");
            return false;
        }

        // 메시지 텍스트 구성
        StringBuilder text = new StringBuilder();
        text.append("🐾 숙소 예약이 확정되었습니다!\n\n");
        text.append("📌 예약번호: ").append(resvNo).append("\n");
        text.append("🏨 숙소: ").append(stayName).append("\n");
        text.append("🛏 객실: ").append(roomName).append("\n");
        text.append("📅 ").append(checkinDate).append(" ~ ").append(checkoutDate);
        text.append(" (").append(nightCnt).append("박)\n");
        if (petName != null && !petName.isBlank()) {
            text.append("🐕 반려동물: ").append(petName).append("\n");
        }
        text.append("💰 결제금액: ").append(String.format("%,d", totalAmount)).append("원");

        // template_object JSON 구성 (text 타입)
        String templateObject = "{"
            + "\"object_type\":\"text\","
            + "\"text\":\"" + escapeJson(text.toString()) + "\","
            + "\"link\":{"
            +   "\"web_url\":\"http://localhost:8080/mypage/reserve\","
            +   "\"mobile_web_url\":\"http://localhost:8080/mypage/reserve\""
            + "},"
            + "\"button_title\":\"예약 내역 보기\""
            + "}";

        return sendMemo(accessToken, templateObject);
    }

    /**
     * 나에게 보내기 API 호출
     */
    private boolean sendMemo(String accessToken, String templateObjectJson) {
        try {
            // 요청 본문 (form-urlencoded)
            String body = "template_object=" + URLEncoder.encode(templateObjectJson, "UTF-8");

            URL url = new URL(MEMO_SEND_URL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded;charset=utf-8");
            conn.setDoOutput(true);

            // 요청 전송
            OutputStream os = conn.getOutputStream();
            os.write(body.getBytes(StandardCharsets.UTF_8));
            os.flush();
            os.close();

            int status = conn.getResponseCode();

            if (status == 200) {
                log.info("[KakaoMsg] 나에게 보내기 성공");
                return true;
            } else {
                // 에러 응답 읽기
                BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8));
                StringBuilder sb = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    sb.append(line);
                }
                br.close();
                log.warn("[KakaoMsg] 나에게 보내기 실패 — status={}, body={}", status, sb.toString());
                return false;
            }
        } catch (Exception e) {
            log.error("[KakaoMsg] 나에게 보내기 예외", e);
            return false;
        }
    }

    /**
     * JSON 문자열 이스케이프
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "")
                  .replace("\t", "\\t");
    }
}
