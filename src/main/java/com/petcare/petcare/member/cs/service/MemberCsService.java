/**
 * 역할: 고객센터(공지) 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - member/cs.jsp             고객센터
 * - member/cs-notice.jsp      공지 상세
 *
 * 구현할 기능 예시
 * - 고객센터 공지 목록·상세 조회
 * - FAQ 조회
 *
 * 연결
 * - 구현: MemberCsServiceImpl
 * - 호출: MemberCsController
 * - DB: MemberCsMapper
 *
 * 참고 테이블
 * - TB_NOTICE
 * - TB_FAQ
 */

package com.petcare.petcare.member.cs.service;

import java.util.List;

import com.petcare.petcare.admin.cms.vo.FaqVO;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

public interface MemberCsService {

    // 2026-08-11 박유정 — 고객센터 FAQ 목록
    List<FaqVO> getVisibleFaqList();

    // 2026-08-11 박유정 — 고객센터 공지 목록
    List<NoticeVO> getVisibleNoticeList();
    
    // 2026-08-11 박유정 — 공지 상세 (조회수 +1)
    NoticeVO getVisibleNoticeDetail(Long noticeId);
}
