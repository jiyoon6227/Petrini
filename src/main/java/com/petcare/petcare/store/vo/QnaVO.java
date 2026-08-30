package com.petcare.petcare.store.vo;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;
import lombok.NoArgsConstructor;

//지윤 26.07.07 상품 Q&A(TB_PRODUCT_QNA) 조회용 VO
@Getter @Setter
@ToString
@NoArgsConstructor
public class QnaVO {
    private Long qnaId;
    private Long memberNo;
    private String nickname;
    private String question;
    private String answer;
    private String regDate;
}