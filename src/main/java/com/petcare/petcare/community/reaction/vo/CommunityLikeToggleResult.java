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
