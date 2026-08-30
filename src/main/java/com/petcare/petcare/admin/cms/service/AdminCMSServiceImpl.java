/**
 * 역할: AdminCMSService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: AdminCMSService
 * - 사용: AdminCMSMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 *
 * 2026-08-06 박유정 — 배너 관리 확장
 * - 탭(현재광고/광고대기/승인/승인대기/반려) + 대분류(메인/숙소/쇼핑/병원) 필터
 * - 승인·대기(HOLD)·반려 + 사업자 알림
 * - 광고 올리기/내리기, 기간 변경, 종료일 자동 만료 연동
 */

package com.petcare.petcare.admin.cms.service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.cms.mapper.AdminCMSMapper;
import com.petcare.petcare.main.banner.BannerConstants;
import com.petcare.petcare.main.banner.mapper.MainBannerMapper;
import com.petcare.petcare.main.banner.service.BannerExpiryService;
import com.petcare.petcare.main.banner.vo.MainBannerVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;

import org.springframework.web.multipart.MultipartFile;
import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;

import com.petcare.petcare.admin.cms.vo.FaqVO;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

@Service
public class AdminCMSServiceImpl implements AdminCMSService {
    private static volatile boolean testStayBannersCleaned = false;

    @Autowired
    private AdminCMSMapper adminCMSMapper;

    @Autowired
    private MypageNotifyService mypageNotifyService;

    @Autowired
    private MainBannerMapper mainBannerMapper;

    @Autowired
    private BannerExpiryService bannerExpiryService;

    @Autowired
    private FileService fileService;
    
    // ── 2026-08-06 박유정 — 관리자: 탭·대분류별 배너 목록 ──
    @Override
    public List<MainBannerVO> getBannerListByTabAndCategory(String tab, String category) {
        String safeTab = normalizeTab(tab);
        String safeCategory = normalizeCategory(category);
        return loadAllBanners().stream()
                .filter(banner -> BannerConstants.matchesAdminCategory(banner.getPositionCd(), safeCategory))
                .filter(banner -> matchesTab(banner, safeTab))
                .collect(Collectors.toList());
    }

    @Override
    public Map<String, Integer> getBannerTabCounts(String category) {
        String safeCategory = normalizeCategory(category);
        List<MainBannerVO> filtered = loadAllBanners().stream()
                .filter(b -> BannerConstants.matchesAdminCategory(b.getPositionCd(), safeCategory))
                .collect(Collectors.toList());
        Map<String, Integer> counts = new HashMap<>();
        counts.put("live", (int) filtered.stream().filter(b -> matchesTab(b, "live")).count());
        counts.put("scheduled", (int) filtered.stream().filter(b -> matchesTab(b, "scheduled")).count());
        counts.put("approved", (int) filtered.stream().filter(b -> matchesTab(b, "approved")).count());
        counts.put("pending", (int) filtered.stream().filter(b -> matchesTab(b, "pending")).count());
        counts.put("rejected", (int) filtered.stream().filter(b -> matchesTab(b, "rejected")).count());
        return counts;
    }

    @Override
    public Map<String, Integer> getBannerCategoryCounts(String tab) {
        String safeTab = normalizeTab(tab);
        List<MainBannerVO> filtered = loadAllBanners().stream()
                .filter(b -> matchesTab(b, safeTab))
                .collect(Collectors.toList());
        Map<String, Integer> counts = new HashMap<>();
        counts.put("main", (int) filtered.stream()
                .filter(b -> BannerConstants.matchesAdminCategory(b.getPositionCd(), BannerConstants.CATEGORY_MAIN)).count());
        counts.put("stay", (int) filtered.stream()
                .filter(b -> BannerConstants.matchesAdminCategory(b.getPositionCd(), BannerConstants.CATEGORY_STAY)).count());
        counts.put("store", (int) filtered.stream()
                .filter(b -> BannerConstants.matchesAdminCategory(b.getPositionCd(), BannerConstants.CATEGORY_STORE)).count());
        counts.put("hospital", (int) filtered.stream()
                .filter(b -> BannerConstants.matchesAdminCategory(b.getPositionCd(), BannerConstants.CATEGORY_HOSPITAL)).count());
        return counts;
    }

    private List<MainBannerVO> loadAllBanners() {
        cleanupTestStayBannersOnce();
        bannerExpiryService.expirePastEndDateBanners();
        return adminCMSMapper.selectAllBannerList();
    }

    private String normalizeCategory(String category) {
        return switch (category) {
            case BannerConstants.CATEGORY_MAIN, BannerConstants.CATEGORY_STAY,
                 BannerConstants.CATEGORY_STORE, BannerConstants.CATEGORY_HOSPITAL -> category;
            default -> BannerConstants.CATEGORY_MAIN;
        };
    }

    private String normalizeTab(String tab) {
        return switch (tab) {
            case "live", "scheduled", "approved", "pending", "rejected" -> tab;
            default -> "pending";
        };
    }

    private String todayString() {
        return LocalDate.now().format(DateTimeFormatter.ISO_LOCAL_DATE);
    }

    private boolean isLiveBanner(MainBannerVO banner) {
        if (!"ACTIVE".equals(banner.getStatusCd())) {
            return false;
        }
        String today = todayString();
        return banner.getStartDate() != null && banner.getEndDate() != null
                && banner.getStartDate().compareTo(today) <= 0
                && banner.getEndDate().compareTo(today) >= 0;
    }

    private boolean isScheduledBanner(MainBannerVO banner) {
        if ("HOLD".equals(banner.getStatusCd())) {
            return true;
        }
        if ("ACTIVE".equals(banner.getStatusCd()) && banner.getStartDate() != null) {
            return banner.getStartDate().compareTo(todayString()) > 0;
        }
        return false;
    }

    private boolean isApprovedEndedBanner(MainBannerVO banner) {
        if ("EXPIRED".equals(banner.getStatusCd())) {
            return true;
        }
        if ("ACTIVE".equals(banner.getStatusCd()) && banner.getEndDate() != null) {
            return banner.getEndDate().compareTo(todayString()) < 0;
        }
        return false;
    }

    // 2026-08-06 박유정 — 중분류 탭: live/scheduled/approved/pending/rejected
    private boolean matchesTab(MainBannerVO banner, String tab) {
        if (banner == null || banner.getStatusCd() == null) {
            return false;
        }
        return switch (tab) {
            case "live" -> isLiveBanner(banner);
            case "scheduled" -> isScheduledBanner(banner);
            case "approved" -> isApprovedEndedBanner(banner);
            case "pending" -> "PENDING".equals(banner.getStatusCd());
            case "rejected" -> "REJECTED".equals(banner.getStatusCd());
            default -> false;
        };
    }

    private void cleanupTestStayBannersOnce() {
        if (testStayBannersCleaned) {
            return;
        }
        synchronized (AdminCMSServiceImpl.class) {
            if (testStayBannersCleaned) {
                return;
            }
            try {
                adminCMSMapper.deleteTestStayBanners();
            } catch (Exception ignored) {
                // DB 미연결·권한 오류 시 목록 조회는 계속
            }
            testStayBannersCleaned = true;
        }
    }
    // 2026-08-07 박유정 — 관리자 배너 상세 1건 (만료 동기화 후 조회)
    @Override
    public MainBannerVO getBannerDetail(Long bannerId) {
        bannerExpiryService.expirePastEndDateBanners();
        MainBannerVO banner = adminCMSMapper.selectBannerDetail(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }
        return banner;
    }

    // 2026-08-07 박유정 — 관리자 배너 정보 수정 (제목·링크·이미지)
    @Override
    @Transactional
    public void updateBannerInfo(Long bannerId, String title, String linkUrl,
                                 MultipartFile bannerImage) throws Exception {
        if (title == null || title.isBlank()) {
            throw new IllegalArgumentException("배너 제목을 입력해 주세요.");
        }
        MainBannerVO banner = adminCMSMapper.selectBannerDetail(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }

        MainBannerVO vo = new MainBannerVO();
        vo.setBannerId(bannerId);
        vo.setTitle(title.trim());
        vo.setLinkUrl(linkUrl != null && !linkUrl.isBlank() ? linkUrl.trim() : null);

        Long oldFileId = banner.getFileId();

        if (bannerImage != null && !bannerImage.isEmpty()) {
            // 2026-08-07 박유정 — PDF·문서 업로드 차단 후 BANNER 파일 교체
            String name = bannerImage.getOriginalFilename();
            if (name != null) {
                String lower = name.toLowerCase();
                if (lower.endsWith(".pdf") || lower.endsWith(".doc") || lower.endsWith(".docx")) {
                    throw new IllegalArgumentException("배너는 JPG, PNG 이미지 파일만 등록할 수 있습니다.");
                }
            }
            FileVO file = fileService.uploadFile(bannerImage, "BANNER", banner.getBizNo());
            vo.setFileId(file.getFileId());
            adminCMSMapper.updateBannerInfo(vo);
            if (oldFileId != null) {
                fileService.deleteFile(oldFileId);
            }
        } else {
            adminCMSMapper.updateBannerInfo(vo);
        }
    }

    @Override
    @Transactional
    public void updateBannerPeriod(Long bannerId, String startDate, String endDate) {
        if (startDate == null || endDate == null || startDate.isBlank() || endDate.isBlank()) {
            throw new IllegalArgumentException("시작일과 종료일을 모두 입력해 주세요.");
        }
        if (startDate.compareTo(endDate) > 0) {
            throw new IllegalArgumentException("종료일은 시작일 이후여야 합니다.");
        }
        MainBannerVO banner = adminCMSMapper.selectBannerById(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }
        MainBannerVO vo = new MainBannerVO();
        vo.setBannerId(bannerId);
        vo.setStartDate(startDate);
        vo.setEndDate(endDate);
        adminCMSMapper.updateBannerPeriod(vo);
    }

    @Override
    @Transactional
    public void deactivateBanner(Long bannerId) {
        // 2026-08-06 박유정 — 광고 내리기 (ACTIVE → EXPIRED)
        MainBannerVO banner = adminCMSMapper.selectBannerById(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }
        if (!"ACTIVE".equals(banner.getStatusCd())) {
            throw new IllegalArgumentException("노출 중인 배너만 내릴 수 있습니다.");
        }
        MainBannerVO vo = new MainBannerVO();
        vo.setBannerId(bannerId);
        vo.setStatusCd("EXPIRED");
        adminCMSMapper.updateBannerStatus(vo);
    }

    // 2026-08-06 박유정 — 광고 올리기 (EXPIRED → ACTIVE)
    @Override
    @Transactional
    public String activateBanner(Long bannerId) {
        MainBannerVO banner = adminCMSMapper.selectBannerById(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }
        if (!"EXPIRED".equals(banner.getStatusCd())) {
            throw new IllegalArgumentException("미노출 상태의 배너만 올릴 수 있습니다.");
        }
        ensureActiveSlotAvailable(banner.getPositionCd());

        MainBannerVO vo = new MainBannerVO();
        vo.setBannerId(bannerId);
        vo.setStatusCd("ACTIVE");
        adminCMSMapper.updateBannerStatus(vo);

        return "광고 상태가 '노출중'으로 변경되었습니다.";
    }

    @Override
    @Transactional
    public void deleteBanner(Long bannerId) {
        MainBannerVO banner = adminCMSMapper.selectBannerById(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }
        adminCMSMapper.deleteBanner(bannerId);
    }

    // ── 관리자: PENDING 건수 (사이드바 배지용) ──
    @Override
    public int getPendingBannerCount() {
        return adminCMSMapper.selectPendingBannerCount();
    }

    // 2026-08-06 박유정 — 배너 승인 (PENDING/HOLD → ACTIVE, 시작일 유지·예약 노출)
    @Override
    @Transactional
    public String approveBanner(Long bannerId) {
        MainBannerVO banner = adminCMSMapper.selectBannerById(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }
        if (!"PENDING".equals(banner.getStatusCd()) && !"HOLD".equals(banner.getStatusCd())) {
            throw new IllegalArgumentException("심사중·노출예정 배너만 승인할 수 있습니다.");
        }

        ensureActiveSlotAvailable(banner.getPositionCd());

        MainBannerVO vo = new MainBannerVO();
        vo.setBannerId(bannerId);
        vo.setStatusCd("ACTIVE");
        adminCMSMapper.updateBannerStatus(vo);

        notifyBannerApproved(banner);

        return "배너 승인이 완료되었습니다.";
    }

    // 2026-08-06 박유정 — 배너 대기 (PENDING → HOLD 노출예정, 사유 알림)
    @Override
    @Transactional
    public void holdBanner(Long bannerId, String holdReason) {
        if (holdReason == null || holdReason.isBlank()) {
            throw new IllegalArgumentException("대기 사유를 입력해 주세요.");
        }
        MainBannerVO banner = adminCMSMapper.selectBannerById(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }
        if (!"PENDING".equals(banner.getStatusCd())) {
            throw new IllegalArgumentException("심사중인 배너만 대기 처리할 수 있습니다.");
        }

        MainBannerVO vo = new MainBannerVO();
        vo.setBannerId(bannerId);
        vo.setStatusCd("HOLD");
        vo.setRejectReason(holdReason.trim());
        adminCMSMapper.updateBannerStatus(vo);

        notifyBannerHold(banner, holdReason.trim());
    }

    // 2026-08-06 박유정 — 위치별 노출 슬롯 제한 (기간 만료 전 ACTIVE 기준)
    private void ensureActiveSlotAvailable(String positionCd) {
        // 2026-08-07 박유정 — MAIN_MID 1개, 그 외 MAX_PER_POSITION
        int maxSlots = BannerConstants.getMaxPerPosition(positionCd);
        int activeCount = mainBannerMapper.countLiveSlotsByPosition(positionCd);
        if (activeCount >= maxSlots) {
            throw new IllegalArgumentException(
                    "해당 노출 위치에 이미 노출 중인 배너가 " + maxSlots + "개입니다.");
        }
    }

    // 2026-08-06 박유정 — 배너 반려 (사유 저장 + 사업자 알림)
    @Override
    @Transactional
    public void rejectBanner(Long bannerId, String rejectReason) {
        if (rejectReason == null || rejectReason.isBlank()) {
            throw new IllegalArgumentException("반려 사유를 입력해 주세요.");
        }
        MainBannerVO banner = adminCMSMapper.selectBannerById(bannerId);
        if (banner == null) {
            throw new IllegalArgumentException("배너를 찾을 수 없습니다.");
        }
        if (!"PENDING".equals(banner.getStatusCd()) && !"HOLD".equals(banner.getStatusCd())) {
            throw new IllegalArgumentException("심사중·노출예정 배너만 반려할 수 있습니다.");
        }

        MainBannerVO vo = new MainBannerVO();
        vo.setBannerId(bannerId);
        vo.setStatusCd("REJECTED");
        vo.setRejectReason(rejectReason.trim());
        adminCMSMapper.updateBannerStatus(vo);

        notifyBannerRejected(banner, rejectReason.trim());
    }

    private void notifyBannerHold(MainBannerVO banner, String holdReason) {
        // 2026-08-06 박유정 — 대기 사유 사업자 알림 (실패해도 트랜잭션 유지)
        if (banner == null || banner.getBizNo() == null) {
            return;
        }
        try {
            Long memberNo = adminCMSMapper.selectMemberNoByBizNo(banner.getBizNo());
            mypageNotifyService.sendBannerHoldNotification(
                    memberNo,
                    banner.getTitle(),
                    banner.getPositionLabel(),
                    holdReason,
                    resolveBannerManageUrl(banner.getBizType()));
        } catch (Exception e) {
            // 알림 실패해도 대기 트랜잭션은 유지
        }
    }

    private void notifyBannerRejected(MainBannerVO banner, String rejectReason) {
        // 2026-08-06 박유정 — 반려 사유 사업자 알림 (실패해도 트랜잭션 유지)
        if (banner == null || banner.getBizNo() == null) {
            return;
        }
        try {
            Long memberNo = adminCMSMapper.selectMemberNoByBizNo(banner.getBizNo());
            mypageNotifyService.sendBannerRejectNotification(
                    memberNo,
                    banner.getTitle(),
                    banner.getPositionLabel(),
                    rejectReason,
                    resolveBannerManageUrl(banner.getBizType()));
        } catch (Exception e) {
            // 알림 실패해도 반려 트랜잭션은 유지
        }
    }

    private void notifyBannerApproved(MainBannerVO banner) {
        if (banner == null || banner.getBizNo() == null) {
            return;
        }
        try {
            Long memberNo = adminCMSMapper.selectMemberNoByBizNo(banner.getBizNo());
            mypageNotifyService.sendBannerApproveNotification(
                    memberNo,
                    banner.getTitle(),
                    banner.getPositionLabel(),
                    resolveBannerManageUrl(banner.getBizType()));
        } catch (Exception e) {
            // 알림 실패해도 승인 트랜잭션은 유지
        }
    }

    private String resolveBannerManageUrl(String bizType) {
        if (bizType == null) {
            return "/mypage/biz";
        }
        return switch (bizType) {
            case "HOSPITAL" -> "/biz/hospital/banner";
            case "STAY" -> "/biz/stay/banner";
            case "STORE", "SHOP" -> "/biz/store/banner";
            default -> "/mypage/biz";
        };
    }

    // 2026-08-11 박유정 — FAQ CMS
    @Override
    @Transactional(readOnly = true)
    public List<FaqVO> getFaqList() {
        return adminCMSMapper.selectFaqList();
    }

    @Override
    @Transactional(readOnly = true)
    public FaqVO getFaqById(Long faqId) {
        if (faqId == null) {
            return null;
        }
        return adminCMSMapper.selectFaqById(faqId);
    }

    @Override
    @Transactional
    public void createFaq(FaqVO faq) {
        validateFaq(faq, false);
        applyFaqDefaults(faq);
        adminCMSMapper.insertFaq(faq);
    }

    @Override
    @Transactional
    public void updateFaq(FaqVO faq) {
        validateFaq(faq, true);
        applyFaqDefaults(faq);
        if (adminCMSMapper.selectFaqById(faq.getFaqId()) == null) {
            throw new IllegalArgumentException("수정할 FAQ를 찾을 수 없습니다.");
        }
        adminCMSMapper.updateFaq(faq);
    }

    @Override
    @Transactional
    public void deleteFaq(Long faqId) {
        if (faqId == null) {
            throw new IllegalArgumentException("FAQ ID가 없습니다.");
        }
        if (adminCMSMapper.selectFaqById(faqId) == null) {
            throw new IllegalArgumentException("삭제할 FAQ를 찾을 수 없습니다.");
        }
        adminCMSMapper.deleteFaq(faqId);
    }

    // 2026-08-11 박유정 — FAQ 입력값 검증
    private void validateFaq(FaqVO faq, boolean isUpdate) {
        if (faq == null) {
            throw new IllegalArgumentException("FAQ 정보가 없습니다.");
        }
        if (isUpdate && faq.getFaqId() == null) {
            throw new IllegalArgumentException("FAQ ID가 없습니다.");
        }
        if (faq.getCategoryCd() == null || faq.getCategoryCd().isBlank()) {
            throw new IllegalArgumentException("카테고리를 선택해 주세요.");
        }
        if (faq.getQuestion() == null || faq.getQuestion().trim().isEmpty()) {
            throw new IllegalArgumentException("질문을 입력해 주세요.");
        }
        if (faq.getAnswer() == null || faq.getAnswer().trim().isEmpty()) {
            throw new IllegalArgumentException("답변을 입력해 주세요.");
        }
        faq.setCategoryCd(faq.getCategoryCd().trim());
        faq.setQuestion(faq.getQuestion().trim());
        faq.setAnswer(faq.getAnswer().trim());
    }

    // 2026-08-11 박유정 — FAQ 기본값
    private void applyFaqDefaults(FaqVO faq) {
        if (faq.getVisibleYn() == null || faq.getVisibleYn().isBlank()) {
            faq.setVisibleYn("Y");
        } else {
            faq.setVisibleYn(faq.getVisibleYn().trim().toUpperCase());
        }
        if (faq.getSortOrder() == null) {
            faq.setSortOrder(0);
        }
    }

    // 2026-08-11 박유정 — 공지사항 CMS
    @Override
    @Transactional(readOnly = true)
    public List<NoticeVO> getNoticeList() {
        return adminCMSMapper.selectNoticeList();
    }

    @Override
    @Transactional(readOnly = true)
    public NoticeVO getNoticeById(Long noticeId) {
        if (noticeId == null) {
            return null;
        }
        return adminCMSMapper.selectNoticeById(noticeId);
    }

    @Override
    @Transactional
    public void createNotice(NoticeVO notice) {
        validateNotice(notice, false);
        applyNoticeDefaults(notice);
        adminCMSMapper.insertNotice(notice);
    }

    @Override
    @Transactional
    public void updateNotice(NoticeVO notice) {
        validateNotice(notice, true);
        applyNoticeDefaults(notice);
        if (adminCMSMapper.selectNoticeById(notice.getNoticeId()) == null) {
            throw new IllegalArgumentException("수정할 공지를 찾을 수 없습니다.");
        }
        adminCMSMapper.updateNotice(notice);
    }

    @Override
    @Transactional
    public void deleteNotice(Long noticeId) {
        if (noticeId == null) {
            throw new IllegalArgumentException("공지 ID가 없습니다.");
        }
        if (adminCMSMapper.selectNoticeById(noticeId) == null) {
            throw new IllegalArgumentException("삭제할 공지를 찾을 수 없습니다.");
        }
        adminCMSMapper.deleteNotice(noticeId);
    }

    // 2026-08-11 박유정 — 공지 입력값 검증
    private void validateNotice(NoticeVO notice, boolean isUpdate) {
        if (notice == null) {
            throw new IllegalArgumentException("공지 정보가 없습니다.");
        }
        if (isUpdate && notice.getNoticeId() == null) {
            throw new IllegalArgumentException("공지 ID가 없습니다.");
        }
        if (notice.getTitle() == null || notice.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("제목을 입력해 주세요.");
        }
        if (notice.getBody() == null || notice.getBody().trim().isEmpty()) {
            throw new IllegalArgumentException("내용을 입력해 주세요.");
        }
        notice.setTitle(notice.getTitle().trim());
        notice.setBody(notice.getBody().trim());
        if (notice.getWriterName() != null) {
            notice.setWriterName(notice.getWriterName().trim());
        }
    }

    // 2026-08-11 박유정 — 공지 기본값
    private void applyNoticeDefaults(NoticeVO notice) {
        if (notice.getNoticeTypeCd() == null || notice.getNoticeTypeCd().isBlank()) {
            notice.setNoticeTypeCd("NOTICE");
        } else {
            notice.setNoticeTypeCd(notice.getNoticeTypeCd().trim().toUpperCase());
        }
        if (notice.getWriterName() == null || notice.getWriterName().isBlank()) {
            notice.setWriterName("펫린이 운영팀");
        }
        if (notice.getPinYn() == null || notice.getPinYn().isBlank()) {
            notice.setPinYn("N");
        } else {
            notice.setPinYn(notice.getPinYn().trim().toUpperCase());
        }
        if (notice.getVisibleYn() == null || notice.getVisibleYn().isBlank()) {
            notice.setVisibleYn("Y");
        } else {
            notice.setVisibleYn(notice.getVisibleYn().trim().toUpperCase());
        }
        if (notice.getViewCount() == null) {
            notice.setViewCount(0);
        }
    }
}
