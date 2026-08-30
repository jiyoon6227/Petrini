/**
 * 역할: 마이페이지 회원정보 데이터 객체
 *
 * - 박유정 / 2026-07-28 — 회원정보 수정 화면 DB 조회용
 * - 박유정 / 2026-08-04 — 프로필 사진 URL
 *
 * 참고 테이블
 * - TB_MEMBER
 */

package com.petcare.petcare.mypage.account.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MypageAccountVO {

    // ── TB_MEMBER 컬럼 ─────────────────────────────────────────

    private Long memberNo;          // MEMBER_NO — 회원번호 (PK)
    private String memberId;        // MEMBER_ID — 아이디
    private String memberName;      // MEMBER_NAME — 이름
    private String nickname;        // NICKNAME — 닉네임 (HEAD)
    private String email;           // EMAIL — 이메일
    private String phone;           // PHONE — 전화번호
    private String zipcode;         // ZIP_CODE — 우편번호
    private String addr1;           // ADDR1 — 기본 주소
    private String addr2;           // ADDR2 — 상세 주소
    private String birthDate;       // BIRTH_DATE — 생년월일 (yyyy-MM-dd)
    private String gender;          // GENDER — 성별 (M/F)
    private String profileImgUrl;   // PROFILE_IMG_URL — 프로필 사진 URL
}
