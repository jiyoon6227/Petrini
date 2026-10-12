package com.petcare.petcare.admin.main.service;

import com.petcare.petcare.admin.main.vo.AdminMainVO;

import com.petcare.petcare.admin.main.vo.AdminStatsVO;

import java.io.IOException;
import java.io.OutputStream;

public interface AdminMainService {

    // 대시보드 요약 (승인 대기 사업자 목록 등)
    AdminMainVO getDashboardSummary();

    // 통계 페이지 요약 (admin/stats/index.jsp)
    AdminStatsVO getStatsSummary();

    // 통계 CSV(Excel)보내기 (admin/stats/export)
    void exportStatsCsv(OutputStream out) throws IOException;
}
