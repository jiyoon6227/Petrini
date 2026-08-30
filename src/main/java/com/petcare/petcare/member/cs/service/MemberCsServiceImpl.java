/**
 * 역할: MemberCsService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: MemberCsService
 * - 사용: MemberCsMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.member.cs.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.cms.vo.FaqVO;
import com.petcare.petcare.member.cs.mapper.MemberCsMapper;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

@Service
public class MemberCsServiceImpl implements MemberCsService {

    @Autowired
    private MemberCsMapper memberCsMapper;

    // 2026-08-11 박유정 — 고객센터 노출 FAQ
    @Override
    @Transactional(readOnly = true)
    public List<FaqVO> getVisibleFaqList() {
        return memberCsMapper.selectVisibleFaqList();
    }

    // 2026-08-11 박유정 — 고객센터 노출 공지 목록
    @Override
    @Transactional(readOnly = true)
    public List<NoticeVO> getVisibleNoticeList() {
        return memberCsMapper.selectVisibleNoticeList();
    }
    // 2026-08-11 박유정 — 공지 상세 조회 + 조회수 증가
    @Override
    @Transactional
    public NoticeVO getVisibleNoticeDetail(Long noticeId) {
        if (noticeId == null) {
            return null;
        }
        NoticeVO notice = memberCsMapper.selectVisibleNoticeById(noticeId);
        if (notice == null) {
            return null;
        }
        memberCsMapper.incrementNoticeViewCount(noticeId);
        if (notice.getViewCount() == null) {
            notice.setViewCount(1);
        } else {
            notice.setViewCount(notice.getViewCount() + 1);
        }
        return notice;
    }
}
