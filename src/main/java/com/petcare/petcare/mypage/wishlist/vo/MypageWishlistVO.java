/**
 * 역할: 마이페이지 찜 목록 표시용
 * 2026/08/13 장우철 — TB_FAVORITE (PRODUCT/HOSPITAL/LODGE)
 */
package com.petcare.petcare.mypage.wishlist.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class MypageWishlistVO {
    private Long favId;
    private Long memberNo;
    private String favType;
    private Long targetId;
    private Date regDate;
    private String title;
    private Integer price;
    private String imageUrl;
    private String link;
    private String wishKey;
}
