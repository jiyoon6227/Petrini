package com.petcare.petcare.give.report.service;

import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.give.report.vo.GiveReportVO;
import com.petcare.petcare.member.vo.MemberVO;

import java.util.List;

public interface GiveReportService {

    // 유기견/실종동물 신고 글쓰기 (등록 + 사진 로컬 저장)
    void insertReport(GiveReportVO vo, MemberVO loginMember, MultipartFile[] photos);

    // 상세 페이지 조회
    GiveReportVO getReportDetail(long postId);

    // 목록 조회 (status: 빈값=전체, FINDING/OWNER_FOUND/RESCUED)
    List<GiveReportVO> getReportList(String status);

    // 게시글 수 (탭 배지용)
    int getReportCount();

    // 진행 상태 변경 (FINDING / RESCUED / OWNER_FOUND)
    void updateFindingStatus(long postId, String findingStatus, MemberVO loginMember);

    // 제보 사진 물리 삭제(로컬/GCS) + TB_FILE 삭제
    void deletePhotosByPostId(long postId);
}