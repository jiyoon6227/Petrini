/**
 * 역할: GiveTalentService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-13~14
 * - 2026-08-10 박유정 — STEP 3: 일반 회원 참여 신청·모집마감·병원 확인·취소·이미지
 *
 * 연결
 * - DB: GiveTalentMapper, GiveTalentApplyMapper
 */

package com.petcare.petcare.give.talent.service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.give.talent.mapper.GiveTalentApplyMapper;
import com.petcare.petcare.give.talent.mapper.GiveTalentMapper;
import com.petcare.petcare.give.talent.vo.GiveTalentApplyVO;
import com.petcare.petcare.give.talent.vo.GiveTalentVO;

import com.petcare.petcare.mypage.notify.service.MypageNotifyService;

@Service
public class GiveTalentServiceImpl implements GiveTalentService {

    private final GiveTalentMapper giveTalentMapper;
    private final GiveTalentApplyMapper giveTalentApplyMapper;
    private final MypageNotifyService mypageNotifyService;
    private final FileService fileService;

    public GiveTalentServiceImpl(GiveTalentMapper giveTalentMapper,
                                 GiveTalentApplyMapper giveTalentApplyMapper,
                                 MypageNotifyService mypageNotifyService,
                                 FileService fileService) {
        this.giveTalentMapper = giveTalentMapper;
        this.giveTalentApplyMapper = giveTalentApplyMapper;
        this.mypageNotifyService = mypageNotifyService;
        this.fileService = fileService;
    }

    // ── 사용자 목록·상세 (2026-07-13) ─────────────────────────────

    @Override
    public List<GiveTalentVO> getApprovedTalentList(String talentType) {
        return giveTalentMapper.selectApprovedTalentList(talentType);
    }

    @Override
    public GiveTalentVO getTalentDetail(long talentId) {
        return giveTalentMapper.selectTalentDetail(talentId);
    }

    // ── 관리자 승인 화면 (2026-07-13) ─────────────────────────────

    @Override
    public List<GiveTalentVO> getTalentListByStatus(String statusCd) {
        return giveTalentMapper.selectTalentListByStatus(statusCd);
    }

    @Override
    public Map<String, Integer> getTalentStatusCounts() {
        Map<String, Integer> counts = new LinkedHashMap<>();
        counts.put("PENDING", giveTalentMapper.countTalentByStatus("PENDING"));
        counts.put("APPROVED", giveTalentMapper.countTalentByStatus("APPROVED"));
        counts.put("REJECTED", giveTalentMapper.countTalentByStatus("REJECTED"));
        counts.put("DONE", giveTalentMapper.countTalentByStatus("DONE"));
        return counts;
    }

    @Override
    public void approveTalent(long talentId, long adminNo) {
        updateStatus(talentId, "APPROVED", null, adminNo);
    }

    @Override
    public void rejectTalent(long talentId, String rejectReason, long adminNo) {
        updateStatus(talentId, "REJECTED", rejectReason, adminNo);
    }

    @Override
    public void completeTalent(long talentId, long adminNo) {
        updateStatus(talentId, "DONE", null, adminNo);
    }

    private void updateStatus(long talentId, String statusCd, String rejectReason, Long adminNo) {
        GiveTalentVO vo = new GiveTalentVO();
        vo.setTalentId(talentId);
        vo.setStatusCd(statusCd);
        vo.setRejectReason(rejectReason);
        vo.setAdminNo(adminNo);
        giveTalentMapper.updateTalentStatus(vo);
    }

    // ── 사업자 신청 (2026-07-14 STEP 4 — 병원) ───────────────────

    @Override
    public List<GiveTalentVO> getTalentListByBizId(String bizId) {
        return giveTalentMapper.selectTalentListByBizId(bizId);
    }

    @Override
    @Transactional
    // 2026-08-10 박유정 — 사업자 재능나눔 등록 + 대표 이미지 업로드(선택)
    public void applyTalent(String bizId, GiveTalentVO vo, MultipartFile thumbImage) {
        if (!"APPROVED".equals(giveTalentMapper.selectBusinessStatusByBizId(bizId))) {
            throw new IllegalStateException("BIZ_NOT_APPROVED");
        }

        Long bizNo = giveTalentMapper.selectBizNoByBizId(bizId);
        if (bizNo == null) {
            throw new IllegalStateException("BIZ_NOT_FOUND");
        }

        vo.setBizNo(bizNo);
        vo.setStatusCd("PENDING");
        vo.setCurrentCnt(0);
        giveTalentMapper.insertTalent(vo);

        if (thumbImage != null && !thumbImage.isEmpty()) {
            validateTalentImageFile(thumbImage);
            try {
                FileVO file = fileService.uploadFile(thumbImage, "TALENT", vo.getTalentId());
                GiveTalentVO thumb = new GiveTalentVO();
                thumb.setTalentId(vo.getTalentId());
                thumb.setThumbUrl("/upload/" + file.getFileUrl());
                giveTalentMapper.updateTalentThumbUrl(thumb);
            } catch (Exception e) {
                throw new IllegalArgumentException("대표 이미지 업로드에 실패했습니다.");
            }
        }
    }

    // 2026-08-10 박유정 — 대표 이미지 형식·용량 검증
    private void validateTalentImageFile(MultipartFile image) {
        if (image.getSize() > 10L * 1024 * 1024) {
            throw new IllegalArgumentException("대표 이미지는 10MB 이하만 등록할 수 있습니다.");
        }
        String originalName = image.getOriginalFilename();
        if (originalName != null) {
            String lower = originalName.toLowerCase();
            if (lower.endsWith(".pdf") || lower.endsWith(".doc") || lower.endsWith(".docx")
                    || lower.endsWith(".hwp") || lower.endsWith(".ppt") || lower.endsWith(".pptx")) {
                throw new IllegalArgumentException("JPG, PNG, WebP 이미지 파일만 등록할 수 있습니다.");
            }
        }
        String contentType = image.getContentType();
        if (contentType != null && !contentType.isBlank() && !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("JPG, PNG, WebP 이미지 파일만 등록할 수 있습니다.");
        }
    }

    // ── 일반 회원 참여 신청 (2026-08-10 STEP 3) ───────────────────

    // 2026-08-10 박유정 — 모집 중 조건: 관리자 승인(APPROVED) + 인원 여유 + DONE 아님
    @Override
    public boolean isRecruitmentOpen(GiveTalentVO talent) {
        if (talent == null || talent.getStatusCd() == null) {
            return false;
        }
        if (!"APPROVED".equalsIgnoreCase(talent.getStatusCd().trim())) {
            return false;
        }
        int capacity = talent.getCapacity() != null ? talent.getCapacity() : 0;
        int current = talent.getCurrentCnt() != null ? talent.getCurrentCnt() : 0;
        return capacity > 0 && current < capacity;
    }

    @Override
    public String getRecruitmentStatusLabel(GiveTalentVO talent) {
        return isRecruitmentOpen(talent) ? "모집중" : "모집마감";
    }

    // 2026-08-10 박유정 — 일반 회원 [신청]: INSERT + CURRENT_CNT+1 + 정원 차면 DONE
    @Override
    @Transactional
    public void applyForTalent(long memberNo, long talentId, String message) {
        GiveTalentVO talent = giveTalentMapper.selectTalentDetail(talentId);
        if (talent == null) {
            throw new IllegalStateException("TALENT_NOT_FOUND");
        }
        if (!isRecruitmentOpen(talent)) {
            throw new IllegalStateException("TALENT_NOT_OPEN");
        }
        if (giveTalentApplyMapper.countByTalentAndMember(talentId, memberNo) > 0) {
            throw new IllegalStateException("ALREADY_APPLIED");
        }

        GiveTalentApplyVO apply = new GiveTalentApplyVO();
        apply.setTalentId(talentId);
        apply.setMemberNo(memberNo);
        apply.setMessage(trimToNull(message));
        apply.setStatusCd("PENDING");
        giveTalentApplyMapper.insertApply(apply);

        giveTalentApplyMapper.incrementTalentCurrentCnt(talentId);

        int capacity = talent.getCapacity() != null ? talent.getCapacity() : 0;
        int currentAfter = (talent.getCurrentCnt() != null ? talent.getCurrentCnt() : 0) + 1;
        if (capacity > 0 && currentAfter >= capacity) {
            updateStatus(talentId, "DONE", null, null);
        }
        // 2026-08-10 박유정 — 병원 사업자 알림
        Long bizMemberNo = giveTalentMapper.selectMemberNoByBizId(talent.getBizId());
        GiveTalentApplyVO saved = giveTalentApplyMapper.selectApplyById(apply.getApplyId());
        mypageNotifyService.sendTalentApplyToBizNotification(
                bizMemberNo,
                talent.getTitle(),
                saved != null ? saved.getNickname() : null,
                "/biz/hospital/talent");
    }

    @Override
    public GiveTalentApplyVO getMyApply(long talentId, long memberNo) {
        if (memberNo <= 0) {
            return null;
        }
        return giveTalentApplyMapper.selectByTalentAndMember(talentId, memberNo);
    }

    // ── 병원 사업자 신청자 확인 (2026-08-10 STEP 3) ─────────────

    @Override
    public List<GiveTalentApplyVO> getAppliesByBizId(String bizId) {
        return giveTalentApplyMapper.selectAppliesByBizId(bizId);
    }

    @Override
    public List<GiveTalentApplyVO> getAppliesByTalentId(long talentId) {
        return giveTalentApplyMapper.selectAppliesByTalentId(talentId);
    }

    // 2026-08-10 박유정 — 병원 [확인]: 내 글인지 검사 후 PENDING → CONFIRMED
    @Override
    @Transactional
    public void confirmApply(long applyId, String bizId) {
        if (giveTalentApplyMapper.countApplyOwnedByBiz(applyId, bizId) == 0) {
            throw new IllegalStateException("NOT_OWNER");
        }
        int updated = giveTalentApplyMapper.updateApplyConfirmed(applyId);
        if (updated == 0) {
            throw new IllegalStateException("APPLY_NOT_PENDING");
        }
        GiveTalentApplyVO apply = giveTalentApplyMapper.selectApplyById(applyId);
        if (apply != null) {
           GiveTalentVO talent = giveTalentMapper.selectTalentDetail(apply.getTalentId());
          mypageNotifyService.sendTalentApplyConfirmNotification(
                 apply.getMemberNo(),
                 apply.getTalentTitle(),
                 talent != null ? talent.getBizName() : null,
                   "/give/talent/detail?id=" + apply.getTalentId());
        }
    }

    private String trimToNull(String value) {
        if (value == null) {
            return null;
        }
        String trimmed = value.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    // 2026-08-10 박유정 — 사업자 사이드바 확인 대기 건수
    @Override
    public int countPendingAppliesByBizId(String bizId) {
        if (bizId == null || bizId.isBlank()) {
            return 0;
        }
        return giveTalentApplyMapper.countPendingAppliesByBizId(bizId);
    }

    // 2026-08-10 박유정 — 회원 참여 신청 취소 (PENDING → CANCELLED, 인원 복구)
    @Override
    @Transactional
    public void cancelMyApply(long applyId, long memberNo) {
        GiveTalentApplyVO apply = giveTalentApplyMapper.selectApplyById(applyId);
        if (apply == null || apply.getMemberNo() == null || apply.getMemberNo() != memberNo) {
            throw new IllegalStateException("NOT_OWNER");
        }
        if (!"PENDING".equalsIgnoreCase(apply.getStatusCd())) {
            throw new IllegalStateException("NOT_CANCELABLE");
        }
        int updated = giveTalentApplyMapper.updateApplyCancelled(applyId, memberNo);
        if (updated == 0) {
            throw new IllegalStateException("NOT_CANCELABLE");
        }

        long talentId = apply.getTalentId();
        giveTalentApplyMapper.decrementTalentCurrentCnt(talentId);

        GiveTalentVO talent = giveTalentMapper.selectTalentDetail(talentId);
        if (talent != null && "DONE".equalsIgnoreCase(talent.getStatusCd())) {
            int capacity = talent.getCapacity() != null ? talent.getCapacity() : 0;
            int current = talent.getCurrentCnt() != null ? talent.getCurrentCnt() : 0;
            if (capacity > 0 && current < capacity) {
                updateStatus(talentId, "APPROVED", null, null);
            }
        }
    }

    // 2026-08-10 박유정 — 병원 수동 모집 마감
    @Override
    @Transactional
    public void closeRecruitment(long talentId, String bizId) {
     if (giveTalentMapper.countTalentOwnedByBiz(talentId, bizId) == 0) {
         throw new IllegalStateException("NOT_OWNER_OR_NOT_OPEN");
      }
      updateStatus(talentId, "DONE", null, null);
    }   
}
