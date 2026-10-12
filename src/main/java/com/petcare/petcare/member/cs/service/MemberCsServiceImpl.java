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

    // 고객센터 노출 FAQ
    @Override
    @Transactional(readOnly = true)
    public List<FaqVO> getVisibleFaqList() {
        return memberCsMapper.selectVisibleFaqList();
    }

    // 고객센터 노출 공지 목록
    @Override
    @Transactional(readOnly = true)
    public List<NoticeVO> getVisibleNoticeList() {
        return memberCsMapper.selectVisibleNoticeList();
    }
    // 공지 상세 조회 + 조회수 증가
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
