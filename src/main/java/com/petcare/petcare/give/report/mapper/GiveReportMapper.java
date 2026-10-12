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
