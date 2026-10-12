package com.petcare.petcare.member.cs.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.petcare.petcare.admin.cms.vo.FaqVO;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

@Mapper
public interface MemberCsMapper {

    // 고객센터 노출 FAQ 목록
    List<FaqVO> selectVisibleFaqList();
    
    // 고객센터 노출 공지 목록
    List<NoticeVO> selectVisibleNoticeList();

    // 고객센터 공지 상세 (노출 Y만)
    NoticeVO selectVisibleNoticeById(Long noticeId);
    
    // 공지 조회수 +1
    void incrementNoticeViewCount(Long noticeId);
}
