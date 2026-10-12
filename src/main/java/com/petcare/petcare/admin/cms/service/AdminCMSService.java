package com.petcare.petcare.admin.cms.service;
import com.petcare.petcare.main.banner.vo.MainBannerVO;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.admin.cms.vo.FaqVO;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

public interface AdminCMSService {
    // 관리자 배너 목록·건수 (대분류 + 중분류 탭)
    List<MainBannerVO> getBannerListByTabAndCategory(String tab, String category);
    Map<String, Integer> getBannerTabCounts(String category);
    Map<String, Integer> getBannerCategoryCounts(String tab);
    int getPendingBannerCount();

    // 승인·대기·반려
    String approveBanner(Long bannerId);
    void holdBanner(Long bannerId, String holdReason);
    void rejectBanner(Long bannerId, String rejectReason);

    // 관리자 배너 상세 조회
    MainBannerVO getBannerDetail(Long bannerId);
    void updateBannerPeriod(Long bannerId, String startDate, String endDate);

    // 관리자 배너 정보 수정 (제목·링크·이미지)
    void updateBannerInfo(Long bannerId, String title, String linkUrl,
                 MultipartFile bannerImage) throws Exception;
    void deactivateBanner(Long bannerId);
    String activateBanner(Long bannerId);
    void deleteBanner(Long bannerId);

    // FAQ CMS
    List<FaqVO> getFaqList();

    FaqVO getFaqById(Long faqId);

    void createFaq(FaqVO faq);

    void updateFaq(FaqVO faq);

    void deleteFaq(Long faqId);

    // 공지사항 CMS
    List<NoticeVO> getNoticeList();

    NoticeVO getNoticeById(Long noticeId);

    void createNotice(NoticeVO notice);

    void updateNotice(NoticeVO notice);

    void deleteNotice(Long noticeId);
}
