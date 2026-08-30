/**
 * 역할: 유기동물 제보 DB 접근 (MyBatis interface)
 *
 * - 박유정 / 2026-07-06~07
 *
 * XML: resources/mybatis/mapper/give/report/GiveReportMapper.xml
 * namespace: com.petcare.petcare.give.report.mapper.GiveReportMapper
 *
 * 쿼리
 * - insertReport / selectReportList / selectReportDetail / selectReportCount
 * - insertFile / selectFileUrlsByPostId (사진)
 *
 * 참고 테이블
 * - TB_POST (BOARD_TYPE = 'LOST')
 * - TB_FILE (REF_TYPE = 'POST')
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 */

package com.petcare.petcare.give.report.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.petcare.petcare.give.report.vo.GiveReportFileVO;
import com.petcare.petcare.give.report.vo.GiveReportVO;

@Mapper
public interface GiveReportMapper {

    int insertReport(GiveReportVO vo);

    int updateReportTags(GiveReportVO vo);

    Long selectMemberNoByMemberId(String memberId);

    Long selectMemberNoByEmail(String email);

    GiveReportVO selectReportDetail(long postId);

    List<GiveReportVO> selectReportList(@Param("status") String status);

    int selectReportCount();

    // TB_FILE INSERT — 사진 등록
    int insertFile(GiveReportFileVO file);

    // 게시글에 연결된 사진 URL 목록 (상세·목록 썸네일용)
    java.util.List<String> selectFileUrlsByPostId(long postId);
}
