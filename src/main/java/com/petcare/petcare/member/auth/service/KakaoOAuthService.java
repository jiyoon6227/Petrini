/**
 * 2026/07/15 — 카카오 로그인
 *
 * 역할: 카카오 OAuth2 인증 처리 (@Service)
 *
 * 흐름
 * 1. 인가 코드(code) → 액세스 토큰 교환  (POST kauth.kakao.com/oauth/token)
 * 2. 액세스 토큰 → 사용자 정보 조회       (GET kapi.kakao.com/v2/user/me)
 * 3. KakaoUserVO 로 반환 → Controller 에서 로그인/가입 처리
 *
 * 연결
 * - 호출: MemberAuthController (GET /oauth/kakao/callback)
 * - 참고: 기존 KakaoMapService 와 동일한 HttpURLConnection 패턴 사용
 */
package com.petcare.petcare.member.auth.service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.member.auth.vo.KakaoUserVO;

@Service
public class KakaoOAuthService {

    @Value("${kakao.rest-api-key}")
    private String clientId;

    @Value("${kakao.client-secret}")
    private String clientSecret;

    @Value("${kakao.redirect-uri}")
    private String redirectUri;

    private final ObjectMapper objectMapper = new ObjectMapper();

    // ── [1단계] 카카오 로그인 페이지 URL 생성 ──
    // 2026/08/18 장우철 — state 로 로그인/회원가입 구분 (카카오 왕복 시 세션 intent 유실 대비)
    public String buildAuthorizeUrl() {
        return buildAuthorizeUrl(null);
    }

    public String buildAuthorizeUrl(String state) {
        String url = "https://kauth.kakao.com/oauth/authorize"
                + "?client_id=" + clientId
                + "&redirect_uri=" + redirectUri
                + "&response_type=code"
                + "&scope=talk_message";
        if (state != null && !state.isBlank()) {
            url += "&state=" + URLEncoder.encode(state, StandardCharsets.UTF_8);
        }
        return url;
    }

    // ── [2단계] 인가 코드 → 액세스 토큰 교환 ──
    // 카카오가 callback URL 로 보내준 code 를 토큰으로 바꿈
    public String getAccessToken(String code) {

        String tokenUrl = "https://kauth.kakao.com/oauth/token";
        String params = "grant_type=authorization_code"
                + "&client_id=" + clientId
                + "&client_secret=" + clientSecret
                + "&redirect_uri=" + redirectUri
                + "&code=" + code;

        try {
            // POST 요청
            URL url = new URL(tokenUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type",
                    "application/x-www-form-urlencoded;charset=UTF-8");
            conn.setDoOutput(true);

            // 파라미터 전송
            OutputStream os = conn.getOutputStream();
            os.write(params.getBytes("UTF-8"));
            os.flush();
            os.close();

            int responseCode = conn.getResponseCode();

            // 에러 응답이면 에러 스트림 읽어서 로그 출력
            if (responseCode != 200) {
                BufferedReader errBr = new BufferedReader(
                        new InputStreamReader(conn.getErrorStream(), "UTF-8"));
                StringBuilder errSb = new StringBuilder();
                String errLine;
                while ((errLine = errBr.readLine()) != null) {
                    errSb.append(errLine);
                }
                errBr.close();
                System.out.println("▶ [카카오 토큰 오류] HTTP " + responseCode);
                System.out.println("▶ [카카오 토큰 오류] 응답: " + errSb.toString());
                System.out.println("▶ [카카오 토큰 오류] client_id: " + clientId);
                System.out.println("▶ [카카오 토큰 오류] redirect_uri: " + redirectUri);
                return null;
            }

            // 응답 읽기
            BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), "UTF-8"));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            br.close();

            // JSON → access_token 추출
            JsonNode root = objectMapper.readTree(sb.toString());
            return root.path("access_token").asText(null);

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    // ── [3단계] 액세스 토큰 → 카카오 사용자 정보 조회 ──
    public KakaoUserVO getUserInfo(String accessToken) {

        String userInfoUrl = "https://kapi.kakao.com/v2/user/me";

        try {
            // GET 요청 + Authorization 헤더
            URL url = new URL(userInfoUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);

            // 응답 읽기
            BufferedReader br = new BufferedReader(
                    new InputStreamReader(conn.getInputStream(), "UTF-8"));
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            br.close();

            // JSON 파싱
            JsonNode root = objectMapper.readTree(sb.toString());

            KakaoUserVO user = new KakaoUserVO();
            // 카카오 고유 ID (숫자)
            user.setKakaoId(String.valueOf(root.path("id").asLong()));

            // kakao_account → profile → nickname
            JsonNode account = root.path("kakao_account");
            JsonNode profile = account.path("profile");
            user.setNickname(profile.path("nickname").asText("카카오회원"));
            user.setProfileImage(
                    profile.path("profile_image_url").asText(null));

            // 이메일 (동의 항목에 포함된 경우에만)
            if (account.path("has_email").asBoolean(false)
                    && account.path("is_email_valid").asBoolean(false)) {
                user.setEmail(account.path("email").asText(null));
            }

            return user;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
