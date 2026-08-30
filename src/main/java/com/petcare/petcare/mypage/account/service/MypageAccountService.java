/**
 * 역할: 마이페이지 회원정보 수정 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - mypage/edit.jsp           회원정보 수정
 *
 * 구현할 기능 예시
 * - 회원 정보 조회·수정
 * - 비밀번호 변경
 *
 * 연결
 * - 구현: MypageAccountServiceImpl
 * - 호출: MypageAccountController
 * - DB: MypageAccountMapper
 *
 * 참고 테이블
 * - TB_MEMBER
 */

package com.petcare.petcare.mypage.account.service;

import com.petcare.petcare.mypage.account.vo.MypageAccountVO;

import org.springframework.web.multipart.MultipartFile;

public interface MypageAccountService {

    // 2026-07-28 박유정 — 회원정보 수정 화면용 프로필 조회
    MypageAccountVO getMemberProfile(Long memberNo);

    // 2026-08-04 박유정 — 프로필 사진 로컬 저장 + TB_MEMBER.PROFILE_IMG_URL UPDATE, 저장 URL 반환
    String updateProfileImage(Long memberNo, MultipartFile file);

    /**
     * 회원정보 수정 (닉네임, 전화번호, 주소)
     * @return null 이면 성공, 문자열이면 오류 메시지
     */
    String updateProfile(MypageAccountVO vo);

    /**
     * 비밀번호 변경 (현재 비밀번호 확인 → 새 비밀번호 저장)
     * @return null 이면 성공, 문자열이면 오류 메시지
     */
    String changePassword(Long memberNo, String currentPassword, String newPassword);

    /**
     * HYJ 26.07.29 회원 탈퇴 — 비밀번호 확인 후 STATUS_CD = 'WITHDRAWN'
     * @return null 이면 성공, 문자열이면 오류 메시지
     */
    String withdraw(Long memberNo, String password);

    /**
     * HYJ 26.07.29 7일 경과 탈퇴 회원 개인정보 삭제 (스케줄러에서 호출)
     * @return 처리된 회원 수
     */
    int purgeExpiredWithdrawnMembers();
}
