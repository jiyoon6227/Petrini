/**
 * 역할: AdminMemberService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-16 (목록·상세), 2026-07-20 (STEP 7·8)
 *
 * [getAdminMemberDetail — 상세]
 * 1. selectAdminMemberDetail → TB_MEMBER 기본정보
 * 2. selectAdminMemberActivityStats → 주문·예약·게시글 등 COUNT (STEP 8)
 * 3. stats 필드를 member VO에 합쳐서 반환
 *
 * [suspendMember / restoreMember / withdrawMember — STEP 7]
 * 1. updateMemberStatus → TB_MEMBER.STATUS_CD 변경
 * 2. updated == 0 이면 MEMBER_NOT_FOUND 예외
 *
 * 연결
 * - implements: AdminMemberService
 * - 사용: AdminMemberMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

package com.petcare.petcare.admin.member.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.petcare.petcare.admin.member.mapper.AdminMemberMapper;
import com.petcare.petcare.admin.member.vo.AdminMemberVO;

import org.springframework.transaction.annotation.Transactional;
import com.petcare.petcare.admin.member.vo.AdminMemberPointVO;

import com.petcare.petcare.admin.member.vo.AdminMemberOrderVO;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.nio.charset.StandardCharsets;
import java.time.format.DateTimeFormatter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
public class AdminMemberServiceImpl implements AdminMemberService {

    private final AdminMemberMapper adminMemberMapper;

    private static final int PAGE_SIZE = 20; // List.jsp "페이지당 20건"

    public AdminMemberServiceImpl(AdminMemberMapper adminMemberMapper) {
        this.adminMemberMapper = adminMemberMapper;
    }

    // 2026-07-16 박유정 — 관리자 회원 목록 (검색·필터·페이징)
    @Override
    public List<AdminMemberVO> getAdminMemberList(String keyword, String statusCd, String roleType, int page) {
        int safePage = page < 1 ? 1 : page;
        int offset = (safePage - 1) * PAGE_SIZE;
        return adminMemberMapper.selectAdminMemberList(keyword, statusCd, roleType, offset, PAGE_SIZE);
    }
    // 2026-07-16 박유정 — 목록 총 건수
    @Override
    public int getAdminMemberCount(String keyword, String statusCd, String roleType) {
        return adminMemberMapper.selectAdminMemberCount(keyword, statusCd, roleType);
    }
    // 2026-07-16 박유정 — 관리자 회원 상세 (기본정보)
    @Override
    public AdminMemberVO getAdminMemberDetail(long memberNo) {
        AdminMemberVO member = adminMemberMapper.selectAdminMemberDetail(memberNo);
        if (member == null) {
            return null;
        }

        // 2026-07-20 박유정 STEP 8 — 활동 현황 통계 합치기
        AdminMemberVO stats = adminMemberMapper.selectAdminMemberActivityStats(memberNo);
        if (stats != null) {
            member.setOrderCount(stats.getOrderCount());
            member.setTotalPayAmount(stats.getTotalPayAmount());
            member.setCancelCount(stats.getCancelCount());
            member.setHospitalResvCount(stats.getHospitalResvCount());
            member.setPostCount(stats.getPostCount());
            member.setReportCount(stats.getReportCount());
            member.setUsedCouponCount(stats.getUsedCouponCount());
            member.setFavoriteCount(stats.getFavoriteCount());
            member.setPetCount(stats.getPetCount());
            member.setPetNames(stats.getPetNames());
        }

        // 2026-07-21 박유정 STEP 10 — 포인트 요약 합치기
        AdminMemberVO pointSummary = adminMemberMapper.selectAdminMemberPointSummary(memberNo);
        if (pointSummary != null) {
            member.setTotalEarnPoint(pointSummary.getTotalEarnPoint());
            member.setTotalUsePoint(pointSummary.getTotalUsePoint());
        }
        return member;
    }
    // 2026-07-20 박유정 STEP 7 — 계정 정지
    // 2026-07-21 박유정 STEP ② — 기간 정지 (SUSPEND_END_DATE 설정)
    @Override
    public void suspendMember(long memberNo, String suspendType) {
        LocalDateTime endDate = resolveSuspendEndDate(suspendType);
        int updated = adminMemberMapper.updateMemberSuspend(memberNo, endDate);
        if (updated == 0) {
            throw new IllegalArgumentException("MEMBER_NOT_FOUND");
        }
    }
    // 2026-07-20 박유정 STEP 7 — 계정 복구
    @Override
    public void restoreMember(long memberNo) {
        int updated = adminMemberMapper.restoreMemberStatus(memberNo);
        if (updated == 0) {
            throw new IllegalArgumentException("MEMBER_NOT_FOUND");
        }
    }

    // 2026-07-20 박유정 STEP 7 — 강제 탈퇴
    @Override
    public void withdrawMember(long memberNo) {
        int updated = adminMemberMapper.updateMemberStatus(memberNo, "WITHDRAWN");
        if (updated == 0) {
            throw new IllegalArgumentException("MEMBER_NOT_FOUND");
        }
    }

    // 2026-07-21 박유정 STEP 9 — 등급 변경
    @Override
    public void updateMemberGrade(long memberNo, String gradeCd) {
        if (gradeCd == null || gradeCd.isBlank()) {
            throw new IllegalArgumentException("INVALID_GRADE");
        }
        String code = gradeCd.trim().toUpperCase();
        if (!code.equals("BRONZE") && !code.equals("SILVER") && !code.equals("GOLD")) {
            throw new IllegalArgumentException("INVALID_GRADE");
        }
        int updated = adminMemberMapper.updateMemberGrade(memberNo, code);
        if (updated == 0) {
            throw new IllegalArgumentException("MEMBER_NOT_FOUND");
        }
    }

    // 2026-07-21 박유정 STEP 10 — 포인트 이력 목록
    @Override
    public List<AdminMemberPointVO> getAdminMemberPointHistory(long memberNo) {
        return adminMemberMapper.selectAdminMemberPointHistory(memberNo);
    }

    // 2026-07-21 박유정 STEP 10 — 포인트 지급·차감
    @Override
    @Transactional
    public void adjustMemberPoint(long memberNo, String adjustType, int amount, String reason) {
        if (amount <= 0) {
            throw new IllegalArgumentException("INVALID_AMOUNT");
        }
        if (adjustType == null || adjustType.isBlank()) {
            throw new IllegalArgumentException("INVALID_TYPE");
        }

        AdminMemberVO member = adminMemberMapper.selectAdminMemberDetail(memberNo);
        if (member == null) {
            throw new IllegalArgumentException("MEMBER_NOT_FOUND");
        }

        int current = member.getPointBalance() != null ? member.getPointBalance() : 0;
        String detail = (reason != null && !reason.isBlank()) ? reason.trim() : "관리자 처리";
        String type = adjustType.trim().toLowerCase();
        int balanceAfter;

        if ("add".equals(type)) {
            adminMemberMapper.addMemberPointBalance(memberNo, amount);
            balanceAfter = current + amount;
            adminMemberMapper.insertMemberPointHistory(
                    memberNo, "EARN", amount, balanceAfter, "ADMIN_GRANT", detail);
        } else if ("sub".equals(type)) {
            if (current < amount) {
                throw new IllegalArgumentException("INSUFFICIENT_POINT");
            }
            int updated = adminMemberMapper.subtractMemberPointBalance(memberNo, amount);
            if (updated == 0) {
                throw new IllegalArgumentException("INSUFFICIENT_POINT");
            }
            balanceAfter = current - amount;
            adminMemberMapper.insertMemberPointHistory(
                    memberNo, "USE", amount, balanceAfter, "ADMIN_DEDUCT", detail);
        } else {
            throw new IllegalArgumentException("INVALID_TYPE");
        }
    }

    // 2026-07-21 박유정 STEP 11 — 회원 최근 주문 목록
    @Override
    public List<AdminMemberOrderVO> getAdminMemberRecentOrders(long memberNo) {
        return adminMemberMapper.selectAdminMemberRecentOrders(memberNo);
    }

    // 2026-07-21 박유정 STEP 12 — 선택 회원 일괄 정지
    // 2026-07-21 박유정 STEP ② — 일괄 기간 정지 (suspendType)
    @Override
    @Transactional
    public int bulkSuspendMembers(List<Long> memberNos, String suspendType) {
        if (memberNos == null || memberNos.isEmpty()) {
            throw new IllegalArgumentException("EMPTY_SELECTION");
        }
        LocalDateTime endDate = resolveSuspendEndDate(suspendType);
        return adminMemberMapper.updateMemberSuspendBulk(memberNos, endDate);
    }

    // 2026-07-21 박유정 STEP 12 — 선택 회원 일괄 탈퇴
    @Override
    @Transactional
    public int bulkWithdrawMembers(List<Long> memberNos) {
        if (memberNos == null || memberNos.isEmpty()) {
            throw new IllegalArgumentException("EMPTY_SELECTION");
        }
        return adminMemberMapper.updateMemberStatusBulk(memberNos, "WITHDRAWN");
    }

    // 2026-07-22 박유정 — 선택 회원 일괄 복구 (SUSPENDED → NORMAL)
    @Override
    @Transactional
    public int bulkRestoreMembers(List<Long> memberNos) {
        if (memberNos == null || memberNos.isEmpty()) {
            throw new IllegalArgumentException("EMPTY_SELECTION");
        }
        return adminMemberMapper.restoreMemberStatusBulk(memberNos);
    }

    private static final DateTimeFormatter EXPORT_DATE =
            DateTimeFormatter.ofPattern("yyyy.MM.dd");

    // 2026-07-21 박유정 — 회원 목록 CSV보내기
    @Override
    public void exportMemberCsv(String keyword, String statusCd, String roleType,
                                OutputStream out) throws IOException {
        List<AdminMemberVO> list =
                adminMemberMapper.selectAdminMemberListForExport(keyword, statusCd, roleType);

        try (OutputStreamWriter writer = new OutputStreamWriter(out, StandardCharsets.UTF_8)) {
            writer.write('\uFEFF'); // Excel 한글 BOM
            writer.write("번호,이름,이메일,전화번호,역할,상태,등급,포인트,가입일,최근로그인\n");

            for (AdminMemberVO m : list) {
                writer.write(csvCell(m.getMemberNo()));
                writer.write(",");
                writer.write(csvCell(m.getMemberName()));
                writer.write(",");
                writer.write(csvCell(m.getEmail()));
                writer.write(",");
                writer.write(csvCell(m.getPhone()));
                writer.write(",");
                writer.write(csvCell(roleLabel(m.getRoleType())));
                writer.write(",");
                writer.write(csvCell(statusLabel(m.getStatusCd())));
                writer.write(",");
                writer.write(csvCell(gradeLabel(m.getGradeCd())));
                writer.write(",");
                writer.write(csvCell(m.getPointBalance()));
                writer.write(",");
                writer.write(csvCell(m.getJoinDate() != null
                        ? m.getJoinDate().format(EXPORT_DATE) : ""));
                writer.write(",");
                writer.write(csvCell(m.getLastLoginDate() != null
                        ? m.getLastLoginDate().format(EXPORT_DATE) : ""));
                writer.write("\n");
            }
        }
    }

    private String csvCell(Object value) {
        if (value == null) return "";
        String s = String.valueOf(value);
        if (s.contains(",") || s.contains("\"") || s.contains("\n")) {
            return "\"" + s.replace("\"", "\"\"") + "\"";
        }
        return s;
    }

    private String roleLabel(String roleType) {
        if ("BIZ".equals(roleType)) return "사업자";
        return "일반";
    }

    private String statusLabel(String statusCd) {
        if (statusCd == null) return "";
        return switch (statusCd) {
            case "NORMAL" -> "활성";
            case "SUSPENDED" -> "정지";
            case "WITHDRAWN" -> "탈퇴";
            default -> statusCd;
        };
    }

    private String gradeLabel(String gradeCd) {
        if (gradeCd == null) return "";
        return switch (gradeCd) {
            case "GOLD" -> "골드";
            case "SILVER" -> "실버";
            case "BRONZE" -> "브론즈";
            default -> gradeCd;
        };
    }

    // 2026-07-21 박유정 STEP ② — 정지 기간 → SUSPEND_END_DATE (영구=null, 해제일 00:00)
    private LocalDateTime resolveSuspendEndDate(String suspendType) {
        if (suspendType == null || suspendType.isBlank()) {
            throw new IllegalArgumentException("INVALID_SUSPEND_TYPE");
        }
        String type = suspendType.trim().toUpperCase();
        return switch (type) {
            case "DAY3" -> LocalDate.now().plusDays(3).atStartOfDay();
            case "DAY7" -> LocalDate.now().plusDays(7).atStartOfDay();
            case "PERMANENT" -> null;
            default -> throw new IllegalArgumentException("INVALID_SUSPEND_TYPE");
        };
    }

    // 2026-07-21 박유정 — 기간 정지 만료 자동 복구
    @Override
    public void releaseExpiredSuspensions() {
        adminMemberMapper.releaseExpiredSuspensions();
    }
}
