package com.petcare.petcare.common.review;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.hospital.vo.ReviewDeleteRequestVO;

/**
 * 사업자 리뷰관리(병원·숙소·쇼핑) 화면에 내려줄 JSON 행 만들기
 * resources/js/biz-review.js가 읽는 키 이름과 맞춰야 함
 */
public final class BizReviewRows {

    private BizReviewRows() {
    }

    // 리뷰 카드 공통 필드 (target: 상품명/병원명/숙소명, latest: 이 리뷰의 가장 최근 삭제요청)
    public static Map<String, Object> reviewRow(Long reviewId, String target, String nickname, Date regDate,
                                                Double rating, String content, String reply,
                                                ReviewDeleteRequestVO latest) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("id", reviewId);
        row.put("target", target);
        row.put("author", (nickname != null && !nickname.isBlank()) ? nickname : "회원");
        row.put("date", format(regDate));
        row.put("rating", rating != null ? rating : 0);
        row.put("content", content != null ? content : "");
        row.put("reply", reply);
        String status = latest != null ? latest.getStatusCd() : null;
        row.put("deleteReqStatus", status);
        row.put("rejectReason", "REJECTED".equals(status) ? latest.getRejectReason() : null);
        return row;
    }

    // 삭제요청 이력 행. 승인·작성자 삭제 건은 리뷰가 없으므로 author/rating/content가 null
    public static List<Map<String, Object>> deleteRequestRows(List<ReviewDeleteRequestVO> requests,
                                                              String defaultTarget) {
        List<Map<String, Object>> rows = new ArrayList<>();
        for (ReviewDeleteRequestVO dr : requests) {
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("requestId", dr.getRequestId());
            row.put("reviewId", dr.getReviewId());
            row.put("target", dr.getTargetName() != null ? dr.getTargetName() : defaultTarget);
            row.put("thumbnail", dr.getThumbnailUrl());
            row.put("author", dr.getReviewerNickname());
            row.put("rating", dr.getReviewRating());
            row.put("content", dr.getReviewContent());
            row.put("requestReason", dr.getRequestReason() != null ? dr.getRequestReason() : "");
            row.put("rejectReason", dr.getRejectReason());
            row.put("statusCd", dr.getStatusCd());
            row.put("reqDate", format(dr.getReqDate()));
            row.put("processDate", format(dr.getProcessDate()));
            rows.add(row);
        }
        return rows;
    }

    // 리뷰별 가장 최근 삭제요청 (REQUEST_ID가 가장 큰 건)
    public static Map<Long, ReviewDeleteRequestVO> latestByReview(List<ReviewDeleteRequestVO> requests) {
        Map<Long, ReviewDeleteRequestVO> latest = new HashMap<>();
        for (ReviewDeleteRequestVO dr : requests) {
            if (dr.getReviewId() == null || dr.getRequestId() == null) {
                continue;
            }
            ReviewDeleteRequestVO prev = latest.get(dr.getReviewId());
            if (prev == null || dr.getRequestId() > prev.getRequestId()) {
                latest.put(dr.getReviewId(), dr);
            }
        }
        return latest;
    }

    // JSP <script> 안에 그대로 넣을 JSON. 리뷰 내용에 </script> 같은 글자가 있어도 스크립트가 끊기지 않게 < > & 를 유니코드로 바꿈
    public static String toScriptJson(ObjectMapper objectMapper, Object value) throws JsonProcessingException {
        return objectMapper.writeValueAsString(value)
                .replace("<", "\\u003c")
                .replace(">", "\\u003e")
                .replace("&", "\\u0026");
    }

    private static String format(Date date) {
        return date != null ? new SimpleDateFormat("yyyy-MM-dd").format(date) : "";
    }
}
