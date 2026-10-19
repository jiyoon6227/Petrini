package com.petcare.petcare.admin.review.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.admin.review.mapper.AdminReviewMapper;
import com.petcare.petcare.admin.review.vo.AdminReviewDeleteRequestVO;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.mypage.reserve.service.MypageReserveRatingService;

/**
 * 승인/반려 후 평점·알림 (별도 트랜잭션, 메인 처리와 분리)
 */
@Service
public class AdminReviewSideEffectService {

    private static final Logger log = LoggerFactory.getLogger(AdminReviewSideEffectService.class);

    private final MypageReserveRatingService ratingService;
    private final MypageNotifyService mypageNotifyService;
    private final AdminReviewMapper adminReviewMapper;

    public AdminReviewSideEffectService(MypageReserveRatingService ratingService,
                                        MypageNotifyService mypageNotifyService,
                                        AdminReviewMapper adminReviewMapper) {
        this.ratingService = ratingService;
        this.mypageNotifyService = mypageNotifyService;
        this.adminReviewMapper = adminReviewMapper;
    }

    public void afterApprove(AdminReviewDeleteRequestVO req) {
        refreshRating(req);
        notifyApprove(req);
    }

    public void afterReject(AdminReviewDeleteRequestVO req, String rejectReason) {
        notifyReject(req, rejectReason);
    }

    private void refreshRating(AdminReviewDeleteRequestVO req) {
        if (req == null) {
            return;
        }
        refreshRating(req.getReviewType(), req.getTargetId());
    }

    // 병원·숙소만 평점 컬럼 갱신 (상품 평점은 조회 시 계산)
    public void refreshRating(String reviewType, Long targetId) {
        if (targetId == null) {
            return;
        }
        if ("HOSPITAL".equals(reviewType)) {
            ratingService.refreshHospitalRating(targetId);
        } else if ("STAY".equals(reviewType)) {
            ratingService.refreshStayRating(targetId);
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW, timeout = 10)
    public void notifyApprove(AdminReviewDeleteRequestVO req) {
        if (req == null) {
            return;
        }
        try {
            Long bizMemberNo = adminReviewMapper.selectBizMemberNoByBizNo(req.getBizNo());
            if (bizMemberNo == null) {
                return;
            }
            String linkUrl;
            if ("STAY".equals(req.getReviewType())) {
                linkUrl = "/biz/stay/reviews";
            } else if ("PRODUCT".equals(req.getReviewType())) {
                linkUrl = "/biz/store/reviews";
            } else {
                linkUrl = "/biz/hospital/reviews";
            }
            mypageNotifyService.sendReviewDeleteApproveNotification(
                    bizMemberNo, req.getHospitalName(), req.getReviewId(), linkUrl);
        } catch (Exception e) {
            log.warn("리뷰 삭제 승인 알림 실패 requestId={}", req.getRequestId(), e);
        }
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW, timeout = 10)
    public void notifyReject(AdminReviewDeleteRequestVO req, String rejectReason) {
        if (req == null) {
            return;
        }
        try {
            Long bizMemberNo = adminReviewMapper.selectBizMemberNoByBizNo(req.getBizNo());
            if (bizMemberNo == null) {
                return;
            }
            String linkUrl;
            if ("STAY".equals(req.getReviewType())) {
                linkUrl = "/biz/stay/reviews";
            } else if ("PRODUCT".equals(req.getReviewType())) {
                linkUrl = "/biz/store/reviews";
            } else {
                linkUrl = "/biz/hospital/reviews";
            }
            mypageNotifyService.sendReviewDeleteRejectNotification(
                    bizMemberNo, req.getHospitalName(), rejectReason, linkUrl);
        } catch (Exception e) {
            log.warn("리뷰 삭제 반려 알림 실패 requestId={}", req.getRequestId(), e);
        }
    }
}
