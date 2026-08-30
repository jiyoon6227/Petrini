/**
 * 역할: 관리자 CMS DB 접근 (MyBatis interface)
 *
 * XML: resources/mybatis/mapper/admin/cms/AdminCMSMapper.xml
 * namespace: com.petcare.petcare.admin.cms.mapper.AdminCMSMapper
 *
 * 쿼리 예시
 * - selectBannerList
 * - insertBanner
 * - updateBanner
 * - deleteBanner
 * - selectNoticeList
 * - insertNotice
 * - updateNotice
 * - deleteNotice
 * - selectFaqList
 * - insertFaq
 * - updateFaq
 * - deleteFaq
 *
 * 참고 테이블
 * - TB_BANNER
 * - TB_NOTICE
 * - TB_FAQ
 *
 * SQL은 XML에만 작성 (@Select 등 어노테이션 사용 X)
 * 메서드명은 Service에서 호출하는 이름과 동일하게
 */

package com.petcare.petcare.admin.cms.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import com.petcare.petcare.main.banner.vo.MainBannerVO;

import com.petcare.petcare.admin.cms.vo.FaqVO;

import com.petcare.petcare.admin.cms.vo.NoticeVO;

@Mapper
public interface AdminCMSMapper {
    // ── 관리자: 전체 배너 목록 (PENDING 우선 정렬) ──
    List<MainBannerVO> selectAllBannerList();

    // ── 관리자: PENDING 건수 ──
    int selectPendingBannerCount();

    // ── 관리자: 배너 상태 변경 (승인/반려) ──
    void updateBannerStatus(MainBannerVO banner);

    // ── 관리자: 배너 1건 (승인 알림용) ──
    MainBannerVO selectBannerById(Long bannerId);

    // ── 관리자: 배너 상세 (FILE_ID 포함) ──
    // 2026-08-07 박유정 — fileId 조회 (이미지 교체 시 구 FILE 삭제용)
    MainBannerVO selectBannerDetail(Long bannerId);

    // ── 관리자: 노출 기간 변경 ──
    void updateBannerPeriod(MainBannerVO banner);

    // 2026-08-07 박유정 — 관리자 배너 정보 변경 (제목·링크·이미지 FILE_ID)
    void updateBannerInfo(MainBannerVO banner);

    // ── 관리자: 배너 삭제 ──
    void deleteBanner(Long bannerId);

    // ── 관리자: 테스트 숙소 배너 일괄 삭제 ──
    int deleteTestStayBanners();

    Long selectMemberNoByBizNo(Long bizNo);

    // 2026-08-11 박유정 — FAQ CMS
    List<FaqVO> selectFaqList();

    FaqVO selectFaqById(Long faqId);

    void insertFaq(FaqVO faq);

    void updateFaq(FaqVO faq);

    void deleteFaq(Long faqId);

    // 2026-08-11 박유정 — 공지사항 CMS
    List<NoticeVO> selectNoticeList();
    NoticeVO selectNoticeById(Long noticeId);
    void insertNotice(NoticeVO notice);
    void updateNotice(NoticeVO notice);
    void deleteNotice(Long noticeId);
}
