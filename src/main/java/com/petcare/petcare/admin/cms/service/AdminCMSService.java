/**
 * 역할: 관리자 CMS(배너·공지·FAQ) 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - admin/cms/banner.jsp      배너 목록
 * - admin/cms/notice.jsp      공지 목록
 * - admin/cms/faq.jsp         FAQ 목록
 * - admin/cms/banner-form.jsp 배너 등록·수정
 * - admin/cms/notice-form.jsp 공지 등록·수정
 * - admin/cms/faq-form.jsp    FAQ 등록·수정
 * - POST /banner/update           배너 정보 수정 (제목·링크·이미지)
 *
 * 구현할 기능 예시
 * - 배너 목록·등록·수정·삭제
 * - 공지사항 목록·등록·수정·삭제
 * - FAQ 목록·등록·수정·삭제
 *
 * 연결
 * - 구현: AdminCMSServiceImpl
 * - 호출: AdminCMSController
 * - DB: AdminCMSMapper
 *
 * 참고 테이블
 * - TB_BANNER
 * - TB_NOTICE
 * - TB_FAQ
 */

package com.petcare.petcare.admin.cms.service;
import com.petcare.petcare.main.banner.vo.MainBannerVO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.admin.cms.vo.FaqVO;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

public interface AdminCMSService {
    // 2026-08-06 박유정 — 관리자 배너 목록·건수 (대분류 + 중분류 탭)
    List<MainBannerVO> getBannerListByTabAndCategory(String tab, String category);
    Map<String, Integer> getBannerTabCounts(String category);
    Map<String, Integer> getBannerCategoryCounts(String tab);
    int getPendingBannerCount();

    // 2026-08-06 박유정 — 승인·대기·반려
    String approveBanner(Long bannerId);
    void holdBanner(Long bannerId, String holdReason);
    void rejectBanner(Long bannerId, String rejectReason);

    // 2026-08-07 박유정 — 관리자 배너 상세 조회
    MainBannerVO getBannerDetail(Long bannerId);
    void updateBannerPeriod(Long bannerId, String startDate, String endDate);

    // 2026-08-07 박유정 — 관리자 배너 정보 수정 (제목·링크·이미지)
    void updateBannerInfo(Long bannerId, String title, String linkUrl,
                 MultipartFile bannerImage) throws Exception;
    void deactivateBanner(Long bannerId);
    String activateBanner(Long bannerId);
    void deleteBanner(Long bannerId);

    // 2026-08-11 박유정 — FAQ CMS
    List<FaqVO> getFaqList();

    FaqVO getFaqById(Long faqId);

    void createFaq(FaqVO faq);

    void updateFaq(FaqVO faq);

    void deleteFaq(Long faqId);

    // 2026-08-11 박유정 — 공지사항 CMS
    List<NoticeVO> getNoticeList();

    NoticeVO getNoticeById(Long noticeId);

    void createNotice(NoticeVO notice);

    void updateNotice(NoticeVO notice);

    void deleteNotice(Long noticeId);
}
