/**
 * 역할: 회원 인증 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/member/auth/MemberAuthMapper.xml
 * namespace: com.petcare.petcare.member.auth.mapper.MemberAuthMapper
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 */

package com.petcare.petcare.member.auth.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.member.auth.vo.AdminAuthVO;
import com.petcare.petcare.member.auth.vo.MemberAuthBizVO;
import com.petcare.petcare.member.auth.vo.MemberAuthVO;
import com.petcare.petcare.member.auth.vo.MemberRegisterVO;

@Mapper
public interface MemberAuthMapper {

    // 2026/07/06 장우철 — login(로그인)

    /** 로그인 ID(이메일)로 TB_MEMBER 1건 조회 — 없으면 null */
    MemberAuthVO selectMemberByLoginId(
            @Param("loginId") String loginId);

    // 2026/07/07 장우철 — 관리자 로그인 확장
    /** 로그인 ID(admin 등)로 TB_ADMIN 1건 조회 — 없으면 null */
    AdminAuthVO selectAdminByLoginId(
            @Param("loginId") String loginId);

    /** 로그인 성공 시 최종 로그인 일시(LAST_LOGIN_DATE) 갱신 */
    int updateLastLoginDate(
            @Param("memberNo") Long memberNo);

    // 2026-07-09 장우철 — 사업자 승인 완료 조회 (로그인 세션 role=BIZ 세팅용)
    // 이유: TB_BUSINESS.STATUS_CD=APPROVED 이면 신청 시 저장된 BIZ_TYPE 으로 사업자 화면 분기
    MemberAuthBizVO selectApprovedBusinessByBizId(
            @Param("bizId") String bizId);

    // 2026/07/07 장우철 — join(회원가입)

    /* 이메일 중복 확인 */
    int countMemberByEmail(@Param("email") String email);

    /* 아이디 중복 확인 */
    int countMemberById(@Param("memberId") String memberId);

    /* 회원 1건 INSERT */
    int insertMember(MemberRegisterVO vo);

    /* 약관 동의 1건 INSERT */
    int insertMemberAgreement(
            @Param("memberNo") Long memberNo,
            @Param("termsType") String termsType,
            @Param("termsVer") String termsVer,
            @Param("agreeYn") String agreeYn);

    /* 반려동물 1건 INSERT */
    int insertPet(MemberRegisterVO vo);

    // 2026/08/11 장우철 — 가입 시 펫 사진 PHOTO_URL 갱신
    int updatePetPhotoUrl(
            @Param("petId") Long petId,
            @Param("memberNo") Long memberNo,
            @Param("photoUrl") String photoUrl);

    // 2026/07/15 — 카카오 로그인

    /** 카카오 PROVIDER_UID 로 TB_MEMBER_SOCIAL → TB_MEMBER 조인 조회 — 없으면 null */
    MemberAuthVO selectMemberBySocialId(
            @Param("socialId") String socialId);

    /** TB_MEMBER_SOCIAL 에 카카오 연동 INSERT */
    int insertSocialLink(
            @Param("memberNo") Long memberNo,
            @Param("providerUid") String providerUid);

    // 2026-07-21 박유정 STEP ② — 기간 정지 만료 시 STATUS_CD=NORMAL 복구
    int releaseExpiredSuspensions();

    // 2026-07-22 박유정 — 탈퇴 회원 이메일 재가입 차단
    int countWithdrawnMemberByEmail(@Param("email")String email);
}
