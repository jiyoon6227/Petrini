package com.petcare.petcare.member.cs.service;

import java.util.List;

import com.petcare.petcare.admin.cms.vo.FaqVO;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

public interface MemberCsService {

    // 고객센터 FAQ 목록
    List<FaqVO> getVisibleFaqList();

    // 고객센터 공지 목록
    List<NoticeVO> getVisibleNoticeList();
    
    // 공지 상세 (조회수 +1)
    NoticeVO getVisibleNoticeDetail(Long noticeId);
}
