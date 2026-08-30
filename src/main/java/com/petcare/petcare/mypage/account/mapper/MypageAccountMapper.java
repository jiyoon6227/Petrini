/**
 * 역할: 마이페이지 회원정보 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/mypage/account/MypageAccountMapper.xml
 * namespace: com.petcare.petcare.mypage.account.mapper.MypageAccountMapper
 *
 * 쿼리 예시
 * - selectMemberProfile
 * - updateMemberProfile
 * - updatePassword
 *
 * 참고 테이블
 * - TB_MEMBER
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.mypage.account.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.mypage.account.vo.MypageAccountVO;

@Mapper
public interface MypageAccountMapper {

    // 2026-07-28 박유정 — 회원정보 수정 화면용 프로필 조회
    MypageAccountVO selectMemberProfile(@Param("memberNo") Long memberNo);

    /** 회원정보 수정 (전화번호, 닉네임, 주소) */
    int updateMemberProfile(MypageAccountVO vo);

    // 2026-08-04 박유정 — 프로필 사진 URL UPDATE (TB_MEMBER.PROFILE_IMG_URL)
    // 2026/08/06 장우철 — yeju updateMemberProfile 과 id 분리
    int updateProfileImageUrl(MypageAccountVO vo);

    /** 비밀번호 변경 */
    int updatePassword(@Param("memberNo") Long memberNo,
                       @Param("newPassword") String newPassword);

    // HYJ 26.07.29 회원 탈퇴

    /** 비밀번호 확인용 — TB_MEMBER.MEMBER_PWD 조회 */
    String selectPasswordByMemberNo(@Param("memberNo") Long memberNo);

    /** STATUS_CD = 'WITHDRAWN' */
    int updateStatusToWithdrawn(@Param("memberNo") Long memberNo);

    /** 회원정보 복사 + WITHDRAW_DATE = SYSDATE */
    int insertMemberWithdraw(@Param("memberNo") Long memberNo);

    // HYJ 26.07.29 7일 경과 탈퇴 회원 개인정보 삭제 (스케줄러용)

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
