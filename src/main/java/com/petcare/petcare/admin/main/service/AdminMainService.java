/**
 * 역할: 관리자 대시보드·통계 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - admin/dashboard.jsp       관리자 대시보드
 * - admin/stats/index.jsp     통계
 *
 * 구현할 기능 예시
 * - 대시보드 요약 지표 조회
 * - 회원·주문·예약 통계 조회
 *
 * 연결
 * - 구현: AdminMainServiceImpl
 * - 호출: AdminMainController
 * - DB: AdminMainMapper
 *
 * 참고 테이블
 * - TB_MEMBER
 * - TB_ORDER
 * - TB_RESERVATION
 *
 * - 박유정 / 2026-07-29 — Phase 1: getDashboardSummary()
 * - 박유정 / 2026-07-30 — ADMIN-04: getStatsSummary() Phase 1
 * - 박유정 / 2026-07-31 — ADMIN-04: getStatsSummary() Phase 2~5-A / exportStatsCsv()
 */

package com.petcare.petcare.admin.main.service;

import com.petcare.petcare.admin.main.vo.AdminMainVO;

import com.petcare.petcare.admin.main.vo.AdminStatsVO;

import java.io.IOException;
import java.io.OutputStream;

public interface AdminMainService {

    // 2026-07-29 박유정 — 대시보드 요약 (승인 대기 사업자 목록 등)
    AdminMainVO getDashboardSummary();

    // 2026-07-30 박유정 — ADMIN-04: 통계 페이지 요약 (admin/stats/index.jsp)
    AdminStatsVO getStatsSummary();

    // 2026-07-31 박유정 — Phase 5-C: 통계 CSV(Excel)보내기 (admin/stats/export)
    void exportStatsCsv(OutputStream out) throws IOException;
}
