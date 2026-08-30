/**
 * 역할: 유기동물 제보 비즈니스 로직 (interface)
 *
 * - 박유정 / 2026-07-06~07
 *
 * 담당 화면
 * - give/report/list.jsp      제보 목록
 * - give/report/detail.jsp    제보 상세
 * - give/report/write.jsp     제보 작성 (사진 첨부)
 *
 * 연결
 * - 구현: GiveReportServiceImpl
 * - 호출: GiveReportController
 * - DB: GiveReportMapper
 *
 * 참고 테이블
 * - TB_POST (BOARD_TYPE = 'LOST')
 * - TB_FILE (사진 첨부, 로컬 C:/upload/)
 */

package com.petcare.petcare.give.report.service;

import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.give.report.vo.GiveReportVO;
import com.petcare.petcare.member.vo.MemberVO;

import java.util.List;

public interface GiveReportService {

    // 1. 유기견/실종동물 신고 글쓰기 (등록 + 사진 로컬 저장)
    void insertReport(GiveReportVO vo, MemberVO loginMember, MultipartFile[] photos);

    // 2. 상세 페이지 조회
    GiveReportVO getReportDetail(long postId);

    // 3. 목록 조회 (status: 빈값=전체, FINDING/OWNER_FOUND/RESCUED)
    List<GiveReportVO> getReportList(String status);

    // 4. 게시글 수 (탭 배지용)
    int getReportCount();

    // 5. 진행 상태 변경 (FINDING / RESCUED / OWNER_FOUND)
    void updateFindingStatus(long postId, String findingStatus, MemberVO loginMember);

    // 2026/07/22 장우철 — 제보 사진 물리 삭제(로컬/GCS) + TB_FILE 삭제
    void deletePhotosByPostId(long postId);
}