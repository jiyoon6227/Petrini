package com.petcare.petcare.common.filter;

import java.util.regex.Pattern;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;

import com.nhncorp.lucy.security.xss.XssPreventer;

public class XssRequestWrapper extends HttpServletRequestWrapper {
//#region
    // ── 사전 컴파일된 정규식 패턴 (성능 최적화) ──
    // Pattern.CASE_INSENSITIVE: 대소문자 무시 (<SCRIPT>, <Script> 등 모두 매칭)
    // Pattern.DOTALL: . 이 개행문자도 포함 (여러 줄에 걸친 스크립트 태그 대응)

    // [1] <script>...</script> 및 <script src="..."/> 제거
    private static final Pattern SCRIPT_TAG_PATTERN = Pattern.compile("<script[^>]*>.*?</script>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern SCRIPT_SELF_CLOSE_PATTERN = Pattern.compile("<script[^>]*/>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern SCRIPT_OPEN_PATTERN = Pattern.compile("<script[^>]*>", Pattern.CASE_INSENSITIVE);

    // [2] <iframe>, <object>, <embed>, <form>, <input> 제거 — 클릭재킹, 피싱 방지
    private static final Pattern IFRAME_PATTERN = Pattern.compile("<iframe[^>]*>.*?</iframe>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern IFRAME_SELF_PATTERN = Pattern.compile("<iframe[^>]*/>", Pattern.CASE_INSENSITIVE);
    private static final Pattern OBJECT_PATTERN = Pattern.compile("<object[^>]*>.*?</object>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern EMBED_PATTERN = Pattern.compile("<embed[^>]*>.*?</embed>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern EMBED_SELF_PATTERN = Pattern.compile("<embed[^>]*/>", Pattern.CASE_INSENSITIVE);
    private static final Pattern FORM_PATTERN = Pattern.compile("<form[^>]*>.*?</form>", Pattern.CASE_INSENSITIVE | Pattern.DOTALL);
    private static final Pattern INPUT_PATTERN = Pattern.compile("<input[^>]*>", Pattern.CASE_INSENSITIVE);

    // [3] javascript: 프로토콜 제거 — <a href="javascript:alert()"> 방지
    private static final Pattern JAVASCRIPT_PROTOCOL_PATTERN = Pattern.compile("javascript\\s*:", Pattern.CASE_INSENSITIVE);

    // [4] vbscript: 프로토콜 제거 (IE 대응)
    private static final Pattern VBSCRIPT_PROTOCOL_PATTERN = Pattern.compile("vbscript\\s*:", Pattern.CASE_INSENSITIVE);

    // [5] on이벤트 속성 제거 — onclick="...", onerror="...", onload="..." 등
    //     \\s+ : 공백 뒤에 on으로 시작하는 속성만 매칭 (button 같은 단어의 on은 제외)
    private static final Pattern ON_EVENT_PATTERN = Pattern.compile("\\s+on\\w+\\s*=\\s*(?:\"[^\"]*\"|'[^']*'|[^\\s>]+)", Pattern.CASE_INSENSITIVE);

    // [6] expression() CSS 함수 제거 (IE expression XSS)
    private static final Pattern EXPRESSION_PATTERN = Pattern.compile("expression\\s*\\(", Pattern.CASE_INSENSITIVE);
//#endregion   

    public XssRequestWrapper(HttpServletRequest request) {
        super(request);
    }

    /**
     * @RequestParam 으로 받는 단일 파라미터 값 필터
     * 예: @RequestParam String question → cleanXss() 거쳐서 전달
     */
    @Override
    public String getParameter(String name) {
        String value = super.getParameter(name);
        if (value == null) {
            return null;
        }
        // return cleanXss(value);
        return XssPreventer.escape(value);
    }

    /**
     * 같은 이름의 파라미터가 여러 개일 때 (체크박스 등)
     * 예: brand=A&brand=B → 각각 정화
     */
    @Override
    public String[] getParameterValues(String name) {
        String[] values = super.getParameterValues(name);
        if (values == null) {
            return null;
        }
        String[] cleanValues = new String[values.length];
        for (int i = 0; i < values.length; i++) {
            cleanValues[i] = XssPreventer.escape(values[i]);//cleanXss(values[i]);
        }
        return cleanValues;
    }

    /**
     * HTTP 헤더 값도 정화 (Referer, User-Agent 등을 통한 XSS 방지)
     */
    @Override
    public String getHeader(String name) {
        String value = super.getHeader(name);
        if (value == null) {
            return null;
        }
        //return cleanXss(value);
        return XssPreventer.escape(value);
    }

    //#region
    /**
     * XSS 위험 패턴 제거 메서드 (2중 방어)
     *
     * [처리 순서]
     * 1단계 (직접 구현): 위험한 HTML 태그·속성·프로토콜 제거
     *   → <script>, <iframe>, onclick=, javascript: 등 구조적 공격 패턴을 정규식으로 제거
     *   → 태그 자체를 없애므로, 변형 공격(<scr<script>ipt>) 에도 태그가 남지 않음
     *
     * 2단계 (lucy-xss): 남은 특수문자를 HTML 엔티티로 변환
     *   → XssPreventer.escape() 가 < > " ' & 등을 &lt; &gt; &quot; 등으로 변환
     *   → 1단계를 빠져나온 잔여 특수문자까지 안전하게 처리
     *
     * [왜 2단계를 마지막에 하는가]
     * - 먼저 엔티티 변환하면 &lt;script&gt; 가 되어 1단계 정규식에 매칭 안 됨
     * - 위험 태그를 먼저 제거한 뒤 남은 특수문자만 변환하는 게 안전
     */
    public static String cleanXss(String value) {
        if (value == null || value.isEmpty()) {
            return value;
        }

        String clean = value;

        // ── 1단계 (직접 구현): 위험한 태그 제거 ──
        clean = SCRIPT_TAG_PATTERN.matcher(clean).replaceAll("");
        clean = SCRIPT_SELF_CLOSE_PATTERN.matcher(clean).replaceAll("");
        clean = SCRIPT_OPEN_PATTERN.matcher(clean).replaceAll("");
        clean = IFRAME_PATTERN.matcher(clean).replaceAll("");
        clean = IFRAME_SELF_PATTERN.matcher(clean).replaceAll("");
        clean = OBJECT_PATTERN.matcher(clean).replaceAll("");
        clean = EMBED_PATTERN.matcher(clean).replaceAll("");
        clean = EMBED_SELF_PATTERN.matcher(clean).replaceAll("");
        clean = FORM_PATTERN.matcher(clean).replaceAll("");
        clean = INPUT_PATTERN.matcher(clean).replaceAll("");

        // ── 1단계 (직접 구현): 위험한 프로토콜/속성 제거 ──
        clean = JAVASCRIPT_PROTOCOL_PATTERN.matcher(clean).replaceAll("");
        clean = VBSCRIPT_PROTOCOL_PATTERN.matcher(clean).replaceAll("");
        clean = ON_EVENT_PATTERN.matcher(clean).replaceAll("");
        clean = EXPRESSION_PATTERN.matcher(clean).replaceAll("(");

        // ── 2단계 (lucy-xss): 남은 특수문자 엔티티 변환 ──
        // XssPreventer.escape() → < > " ' & 를 &lt; &gt; &quot; &#39; &amp; 로 변환
        // 네이버 실서비스에서 검증된 변환 로직 사용
        clean = XssPreventer.escape(clean);

        return clean;
    }
    //#endregion
}
