package com.petcare.petcare.common.util;

import java.util.UUID;

import jakarta.servlet.http.HttpSession;


public class CsrfTokenUtil {
    /** 세션에 토큰을 저장할 때 쓰는 키 이름 */
    public static final String CSRF_TOKEN_KEY = "_csrf";    

    public static String getOrCreateToken(HttpSession session) {
        String token = (String)session.getAttribute(CSRF_TOKEN_KEY);
        if (token == null) { 
            token = UUID.randomUUID().toString();
            session.setAttribute(CSRF_TOKEN_KEY, token);
        }

        return token;
    }

    public static boolean isValid(HttpSession session, String requestToken) {
        String sessionToken = (String)session.getAttribute(CSRF_TOKEN_KEY);
        if (sessionToken == null || requestToken == null) {
            return false;
        }

        return sessionToken.equals(requestToken);
    }
}
