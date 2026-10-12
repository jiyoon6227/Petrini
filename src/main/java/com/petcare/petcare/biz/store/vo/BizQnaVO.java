package com.petcare.petcare.biz.store.vo;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class BizQnaVO {

    private Long qnaId;
    private Long productId;
    private Long memberNo;
    private String question;
    private String answer;      // 답변 없으면 null
    private String regDate;     // DB에 문자열(YYYY-MM-DD)로 저장되어 String 사용

   // 조회용 조인
   private String nickname;    // 질문자
   private String productName;
   private String thumbnailUrl; // 상품 썸네일 (리뷰관리와 UI 통일)
   private String optionColor;
   private String optionSize;
   private String answerDate;
}