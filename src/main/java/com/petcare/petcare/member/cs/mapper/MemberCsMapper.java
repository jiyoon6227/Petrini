/**
 * 역할: 고객센터 DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/member/cs/MemberCsMapper.xml
 * namespace: com.petcare.petcare.member.cs.mapper.MemberCsMapper
 *
 * 쿼리 예시
 * - selectNoticeList
 * - selectNoticeDetail
 * - selectFaqList
 *
 * 참고 테이블
 * - TB_NOTICE
 * - TB_FAQ
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.member.cs.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.petcare.petcare.admin.cms.vo.FaqVO;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

@Mapper
public interface MemberCsMapper {

    // 2026-08-11 박유정 — 고객센터 노출 FAQ 목록
    List<FaqVO> selectVisibleFaqList();
    
    // 2026-08-11 박유정 — 고객센터 노출 공지 목록
    List<NoticeVO> selectVisibleNoticeList();

    // 2026-08-11 박유정 — 고객센터 공지 상세 (노출 Y만)
    NoticeVO selectVisibleNoticeById(Long noticeId);
    
    // 2026-08-11 박유정 — 공지 조회수 +1
    void incrementNoticeViewCount(Long noticeId);
}
