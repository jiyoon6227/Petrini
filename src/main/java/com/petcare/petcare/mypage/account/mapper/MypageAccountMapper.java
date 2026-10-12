package com.petcare.petcare.mypage.account.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.mypage.account.vo.MypageAccountVO;

@Mapper
public interface MypageAccountMapper {

    // 회원정보 수정 화면용 프로필 조회
    MypageAccountVO selectMemberProfile(@Param("memberNo") Long memberNo);

    /** 회원정보 수정 (전화번호, 닉네임, 주소) */
    int updateMemberProfile(MypageAccountVO vo);

    // 프로필 사진 URL UPDATE (TB_MEMBER.PROFILE_IMG_URL)
    // updateMemberProfile 과 id 분리
    int updateProfileImageUrl(MypageAccountVO vo);

    /** 비밀번호 변경 */
    int updatePassword(@Param("memberNo") Long memberNo,
                       @Param("newPassword") String newPassword);

    // 회원 탈퇴

    /** 비밀번호 확인용 — TB_MEMBER.MEMBER_PWD 조회 */
    String selectPasswordByMemberNo(@Param("memberNo") Long memberNo);

    /** STATUS_CD = 'WITHDRAWN' */
    int updateStatusToWithdrawn(@Param("memberNo") Long memberNo);

    /** 회원정보 복사 + WITHDRAW_DATE = SYSDATE */
    int insertMemberWithdraw(@Param("memberNo") Long memberNo);

    // 7일 경과 탈퇴 회원 개인정보 삭제 (스케줄러용)

    /** 7일 경과 탈퇴 회원 MEMBER_NO 목록 */
    List<Long> selectExpiredWithdrawnMemberNos();

    /** TB_MEMBER 개인정보 익명화 */
    int anonymizeMember(@Param("memberNo") Long memberNo);

    /** TB_MEMBER_SOCIAL 삭제 */
    int deleteSocialByMemberNo(@Param("memberNo") Long memberNo);

    /** TB_PET 삭제 */
    int deletePetsByMemberNo(@Param("memberNo") Long memberNo);

    /** TB_MEMBER_AGREEMENT 삭제 */
    int deleteAgreementsByMemberNo(@Param("memberNo") Long memberNo);

    /** TB_MEMBER_WITHDRAW 삭제 */
    int deleteMemberWithdrawByMemberNo(@Param("memberNo") Long memberNo);
}
