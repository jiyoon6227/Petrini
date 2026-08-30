/**
 * 역할: 좋아요 Ajax 토글 응답 DTO
 *
 * - 박유정 / 2026-07-09
 *
 * [응답 흐름]
 * 1. POST /community/like/toggle 처리 후 JSON 반환
 * 2. detail.jsp 가 liked, likeCnt 로 버튼·숫자 갱신
 *
 * JSON 필드
 * - liked   : 토글 후 좋아요 상태 (true/false)
 * - likeCnt : TB_POST.LIKE_CNT 현재값
 */

package com.petcare.petcare.community.reaction.vo;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class CommunityLikeToggleResult {

    @JsonProperty("liked")
    private final boolean liked;

    @JsonProperty("likeCnt")
    private final int likeCnt;
}
