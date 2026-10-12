package com.petcare.petcare.biz.store.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.biz.store.mapper.BizStoreMapper;
import com.petcare.petcare.biz.store.vo.BizDeliveryVO;
import com.petcare.petcare.biz.store.vo.BizOrderItemVO;
import com.petcare.petcare.biz.store.vo.BizOrderVO;
import com.petcare.petcare.biz.store.vo.BizProductVO;
import com.petcare.petcare.biz.store.vo.BizReturnVO;
import com.petcare.petcare.biz.vo.BizCouponVO;
import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.mypage.notify.service.MypageNotifyService;
import com.petcare.petcare.store.vo.CategoryVO;
import com.petcare.petcare.store.vo.OptionVO;
import com.petcare.petcare.common.external.service.TossPaymentService;

@Service
public class BizStoreServiceImpl implements BizStoreService {

    @Autowired
    private BizStoreMapper bizStoreMapper;

    @Autowired
    private FileService fileService;

    // 주문취소 승인 시 토스 결제취소 API 호출용
    @Autowired
    private TossPaymentService tossPaymentService;

    // 취소승인 DB반영 트랜잭션 전용 (self-invocation 문제로 별도 빈 분리)
    @Autowired
    private OrderCancelTxService orderCancelTxService;

    // 환불 처리 알림
    @Autowired
    private MypageNotifyService mypageNotifyService;

    // 페이지당 상품 개수 (10개)
    private static final int PAGE_SIZE = 10;

    // 로그인 ID로 BIZ_NO 조회 (세션에는 로그인 ID만 있어 요청마다 사업자번호 조회)
    @Override
    public Long getBizNo(String bizId) {
        return bizStoreMapper.selectBizNoByBizId(bizId);
    }

    // 상품목록 조회 + 할인율 계산 + 상품별 옵션 목록 채우기 (옵션별 재고 표시용)
    @Override
    public List<BizProductVO> getProductList(Long bizNo, String keyword, String categoryName, String statusCd, int pageNo) {
        int offset = (pageNo - 1) * PAGE_SIZE;
        List<BizProductVO> list = bizStoreMapper.selectProductList(bizNo, keyword, categoryName, statusCd, offset, PAGE_SIZE);
        for (BizProductVO p : list) {
            //정가 대비 판매가 할인율 계산 (store 모듈과 동일 로직)
            if (p.getPrice() != null && p.getSalePrice() != null && p.getPrice() > 0) {
                int rate = (int) Math.round((p.getPrice() - p.getSalePrice()) * 100.0 / p.getPrice());
                p.setDiscountRate(rate);
            } else {
                p.setDiscountRate(0);
            }
            //옵션 있는 상품은 옵션별 재고를 화면에서 나눠서 보여줘야 해서 같이 채워넣음
            p.setOptionList(bizStoreMapper.selectProductOptions(p.getProductId()));
        }
        return list;
    }

    // 상품목록 총 페이지 수 (페이지네이션 버튼 개수 계산용)
    @Override
    public int getTotalPages(Long bizNo, String keyword, String categoryName, String statusCd) {
        int totalCount = bizStoreMapper.selectProductCount(bizNo, keyword, categoryName, statusCd);
        return (int) Math.ceil(totalCount / (double) PAGE_SIZE);
    }

   // 옵션 재고 합계로 STOCK_QTY 자동 계산, 합계 0이면 STATUS_CD 강제 SOLDOUT
   //이미지도 공용 FileService로 등록 (REF_TYPE='PRODUCT')
    @Override
    public void addProduct(BizProductVO product, List<OptionVO> options, MultipartFile image) throws Exception {
        int totalStock = sumStock(options);
        String statusCd = (product.getStatusCd() == null || product.getStatusCd().isBlank()) ? "NORMAL" : product.getStatusCd();
        if (totalStock == 0) statusCd = "SOLDOUT";

        Long newId = bizStoreMapper.selectNextProductId();
        String productCd = "P-" + String.format("%04d", newId);

        bizStoreMapper.insertProduct(newId, productCd, product.getProductName(), product.getBizNo(),
                product.getCategoryId(), product.getPrice(), product.getSalePrice(),
                product.getDescription(), product.getBrandName(), statusCd, product.getTags());

        saveOptions(newId, options);

        if (image != null && !image.isEmpty()) {
            fileService.uploadFile(image, "PRODUCT", newId);
        }
    }

    // 옵션 리스트도 같이 채워서 반환 (수정 모달 프리필용)
    @Override
    public BizProductVO getProductDetail(Long productId, Long bizNo) {
        BizProductVO vo = bizStoreMapper.selectProductDetail(productId, bizNo);
        if (vo != null) {
            vo.setOptionList(bizStoreMapper.selectProductOptions(productId));
        }
        return vo;
    }

    // 옵션 전체 삭제 후 재등록, 재고 합계 0이면 강제 SOLDOUT, 이미지 새로 올렸을 때만 교체
    @Override
    public boolean updateProduct(BizProductVO product, List<OptionVO> options, MultipartFile image) throws Exception {
        int totalStock = sumStock(options);
        String statusCd = product.getStatusCd();
        if (totalStock == 0) statusCd = "SOLDOUT";

        int updated = bizStoreMapper.updateProduct(product.getProductId(), product.getBizNo(),
                product.getProductName(), product.getCategoryId(), product.getPrice(), product.getSalePrice(),
                product.getDescription(), product.getBrandName(), statusCd, product.getTags());
        if (updated == 0) return false;

        // OPTION_ID 기준 upsert (전체삭제 후 재생성 방식 대체)
        //이유: 이미 주문된 적 있는 옵션은 TB_ORDER_ITEM이 참조 중이라 삭제하면 ORA-02292(FK위반) 에러 발생
        saveOptionsForUpdate(product.getProductId(), options);

       // 새 이미지 업로드 시 기존 이미지 먼저 삭제 (옛 이미지가 썸네일로 남는 문제 방지)
        if (image != null && !image.isEmpty()) {
            fileService.deleteFilesByRef("PRODUCT", product.getProductId());
            fileService.uploadFile(image, "PRODUCT", product.getProductId());
        }
        return true;
    }

    // 상품수정 전용 옵션 저장 로직 (OPTION_ID 기준 upsert)
    // optionId 있는 옵션은 OPTION_ID 기준 UPDATE, 새 행은 INSERT
    // 제출에서 빠진 옵션: 주문 이력 있으면 삭제 대신 재고 0 (주문이력 보존)
    private void saveOptionsForUpdate(Long productId, List<OptionVO> options) {
        for (OptionVO opt : options) {
            String color = (opt.getOptionColor() == null || opt.getOptionColor().isBlank()) ? "기본" : opt.getOptionColor();

            if (opt.getOptionId() != null) {
                bizStoreMapper.updateProductOptionById(opt.getOptionId(), color, opt.getOptionSize(), opt.getAddPrice(), opt.getStockQty());
            } else {
                Long optId = bizStoreMapper.selectNextOptionId();
                bizStoreMapper.insertProductOption(optId, productId, color, opt.getOptionSize(), opt.getAddPrice(), opt.getStockQty());
                // INSERT 직후 optionId 세팅 (없으면 아래 정리 루프가 새 옵션을 미제출로 보고 삭제)
                opt.setOptionId(optId);
            }
        }

        List<OptionVO> existing = bizStoreMapper.selectProductOptions(productId);
        for (OptionVO old : existing) {
            boolean stillSubmitted = options.stream().anyMatch(o -> o.getOptionId() != null && old.getOptionId().equals(o.getOptionId()));
            if (!stillSubmitted) {
                int orderCount = bizStoreMapper.selectOrderItemCountByOption(old.getOptionId());
                if (orderCount == 0) {
                    bizStoreMapper.deleteProductOptionById(old.getOptionId());
                } else {
                    //주문 이력 있어서 삭제 못 함 -> 재고 0으로 처리해서 사실상 판매목록에서 숨김
                    bizStoreMapper.updateProductOptionById(old.getOptionId(), old.getOptionColor(), old.getOptionSize(), old.getAddPrice(), 0);
                }
            }
        }
    }

    // 옵션 리스트 저장 공통 처리 (등록/수정 둘 다 사용), 색상 비워두면 "기본"으로 저장
    private void saveOptions(Long productId, List<OptionVO> options) {
        for (OptionVO opt : options) {
            Long optId = bizStoreMapper.selectNextOptionId();
            String color = (opt.getOptionColor() == null || opt.getOptionColor().isBlank()) ? "기본" : opt.getOptionColor();
            bizStoreMapper.insertProductOption(optId, productId, color, opt.getOptionSize(), opt.getAddPrice(), opt.getStockQty());
        }
    }

    // 옵션 재고 합계 계산
    private int sumStock(List<OptionVO> options) {
        int total = 0;
        for (OptionVO opt : options) {
            total += (opt.getStockQty() == null ? 0 : opt.getStockQty());
        }
        return total;
    }

    // 상품 등록/수정 폼 카테고리 드롭다운 목록
    @Override
    public List<CategoryVO> getLeafCategories() {
        return bizStoreMapper.selectLeafCategories();
    }

    // 상품목록 필터용 카테고리명(중복 제거)
    @Override
    public List<String> getFilterCategoryNames() {
        return bizStoreMapper.selectFilterCategoryNames();
    }

    // 상품목록 총 개수 (화면에 "총 N개" 표시용)
    @Override
    public int getTotalCount(Long bizNo, String keyword, String categoryName, String statusCd) {
        return bizStoreMapper.selectProductCount(bizNo, keyword, categoryName, statusCd);
    }

    // 사업자 주문 목록 조회
    // 유저와 같은 환불완료/부분환불/환불진행중 뱃지
    @Override
    public List<BizOrderVO> getOrderList(Long bizNo, String statusCd) {
        List<BizOrderVO> list = bizStoreMapper.selectOrderList(bizNo, statusCd);
        if (list != null) {
            for (BizOrderVO o : list) {
                fillOrderStatusBadge(o);
            }
        }
        return list;
    }

    private void fillOrderStatusBadge(BizOrderVO o) {
        if (o == null) {
            return;
        }
        if ("PENDING".equals(o.getClaimStatus())) {
            o.setStatusBadge("CANCEL_REQUEST");
            return;
        }
        int total = o.getItemCount() == null ? 0 : o.getItemCount();
        int done = o.getDoneReturnCount() == null ? 0 : o.getDoneReturnCount();
        int active = o.getActiveReturnCount() == null ? 0 : o.getActiveReturnCount();
        int any = done + active;
        if (total > 0 && done == total) {
            o.setStatusBadge("REFUND_DONE");
            return;
        }
        if (any > 0 && any < total) {
            o.setStatusBadge("PARTIAL_REFUND");
            return;
        }
        if (active > 0) {
            o.setStatusBadge("REFUND_PROGRESS");
            return;
        }
        o.setStatusBadge(o.getOrderStatus());
    }

    // 상태별 주문 개수를 Map으로 가공 (화면에서 statusCounts.PAID 형태로 사용)
    @Override
    public java.util.Map<String, Integer> getOrderStatusCounts(Long bizNo) {
        java.util.Map<String, Integer> result = new java.util.HashMap<>();
        for (java.util.Map<String, Object> row : bizStoreMapper.selectOrderStatusCounts(bizNo)) {
            String status = (String) row.get("STATUS");
            Number cnt = (Number) row.get("CNT");
            result.put(status, cnt.intValue());
        }
        // 취소신청 대기 건수도 같은 Map에 저장 (화면에서 statusCounts.CLAIM_PENDING으로 사용)
        result.put("CLAIM_PENDING", bizStoreMapper.selectClaimPendingCount(bizNo));
        return result;
    }

    // 주문 상세 조회 (상품목록까지 같이 채워서 반환)
    @Override
    public BizOrderVO getOrderDetail(Long orderId, Long bizNo) {
        BizOrderVO vo = bizStoreMapper.selectOrderDetail(orderId, bizNo);
        if (vo != null) {
            vo.setItemList(bizStoreMapper.selectOrderItems(orderId));
        }
        return vo;
    }

    // 취소신청 승인
    //순서 중요: 토스 API를 먼저 부르고, 성공했을 때만 DB를 건드림
    @Override
    public String approveOrderCancel(Long orderId, Long bizNo) {
        BizOrderVO order = bizStoreMapper.selectOrderDetail(orderId, bizNo);
        if (order == null || !"PENDING".equals(order.getClaimStatus())) {
            return "취소신청 대기중인 주문이 아닙니다.";
        }
        if (order.getTossPaymentKey() == null) {
            return "결제 정보를 찾을 수 없습니다.";
        }

        // PAY_METHOD(빌링/토스)에 맞는 시크릿 + 주문분 부분취소
        // (과거 BILLING인데 TOSS로 저장된 건은 cancelPaymentSmart 가 반대 시크릿 재시도)
        Long cancelAmt = order.getPayAmount() != null ? order.getPayAmount().longValue() : null;
        String reason = order.getCancelReason() != null && !order.getCancelReason().isBlank()
                ? order.getCancelReason() : "주문 취소 승인";
        String tossError = tossPaymentService.cancelPaymentSmart(
                order.getTossPaymentKey(), reason, cancelAmt, order.getPayMethod());
        if (tossError != null) {
            return tossError;
        }

        orderCancelTxService.applyCancelToDb(order, bizNo);
        // 취소 승인 → 구매자 알림
        try {
            mypageNotifyService.sendCancelApproveToBuyerNotification(order.getMemberNo(), order.getOrderNo());
        } catch (Exception ignored) {
        }
        return null;
    }

    // 취소신청 반려 (토스 호출 없이 상태만 변경)
    @Override
    public boolean rejectOrderCancel(Long orderId, Long bizNo) {
        BizOrderVO order = bizStoreMapper.selectOrderDetail(orderId, bizNo);
        boolean ok = bizStoreMapper.updateClaimReject(orderId, bizNo) > 0;
        // 취소 거절 → 구매자 알림
        if (ok && order != null) {
            try {
                mypageNotifyService.sendCancelRejectToBuyerNotification(order.getMemberNo(), order.getOrderNo());
            } catch (Exception ignored) {
            }
        }
        return ok;
    }

    // 주문 상태 변경 + 배송정보(택배사/송장번호) 저장
    //송장번호가 입력되면 배송상태를 자동으로 SHIPPING으로, 이미 배송정보 있으면 UPDATE 없으면 INSERT
    @Override
    public boolean updateOrderStatus(Long orderId, Long bizNo, String orderStatus, String courierName, String courierCode, String trackingNo) {
        // 송장번호가 입력됐는데 드롭다운에서 주문상태를 "배송중"으로 안 바꾸고 저장하면
        //TB_ORDER.ORDER_STATUS(=READY)와 TB_ORDER_DELIVERY.DELIVERY_STATUS(=SHIPPING)가 서로 어긋나는 문제가 있었음.
        //송장번호가 있으면, 사람이 드롭다운을 안 바꿔도 PAID/READY인 경우엔 자동으로 SHIPPING으로 승격시켜서 두 값이 항상 일치하도록 보정
        if (trackingNo != null && !trackingNo.isBlank()
                && ("PAID".equals(orderStatus) || "READY".equals(orderStatus))) {
            orderStatus = "SHIPPING";
        }
    
        int updated = bizStoreMapper.updateOrderStatus(orderId, bizNo, orderStatus);
        if (updated == 0) return false;

        String tsColumn = switch (orderStatus) {
            case "READY" -> "READY_AT";
            case "SHIPPING" -> "SHIPPING_AT";
            case "DONE" -> "DELIVERED_AT";
            default -> null;
        };
        if (tsColumn != null) {
            bizStoreMapper.updateDeliveryTimestamp(orderId, bizNo, tsColumn);
        }

        if ((courierName != null && !courierName.isBlank()) || (trackingNo != null && !trackingNo.isBlank())) {
            String deliveryStatus = (trackingNo != null && !trackingNo.isBlank()) ? "SHIPPING" : "READY";
            int exists = bizStoreMapper.selectDeliveryExists(orderId);
            if (exists > 0) {
                bizStoreMapper.updateOrderDelivery(orderId, courierName, courierCode, trackingNo, deliveryStatus);
            } else {
                bizStoreMapper.insertOrderDelivery(orderId, bizNo, courierName, courierCode, trackingNo, deliveryStatus);
            }
        }
        // 배송중/배송완료 → 구매자 알림
        notifyBuyerDeliveryStatus(orderId, bizNo, orderStatus);
        return true;
    }

    // 배송조회 API 호출 시점에만 동기화 (스마트택배 무료플랜 월 100건 제한으로 스케줄러 폴링 대신)
    //autoCompleteOrderStatus가 이미 DONE인 건은 0건 UPDATE하므로 그 경우 false 반환 -> DELIVERED_AT 중복갱신 안 됨
    @Override
    public boolean autoCompleteDeliveryIfDone(Long orderId, Long bizNo) {
        int updated = bizStoreMapper.autoCompleteOrderStatus(orderId, bizNo);
        if (updated == 0) return false;
        bizStoreMapper.updateDeliveryTimestamp(orderId, bizNo, "DELIVERED_AT");
        bizStoreMapper.updateDeliveryStatusOnly(orderId, "DELIVERED");
        notifyBuyerDeliveryStatus(orderId, bizNo, "DONE");
        return true;
    }

    // 배송조회 시 level 2~5(이동중) 확인되면 PAID/READY인 주문을 SHIPPING으로 자동승격
    //autoElevateToShipping이 이미 SHIPPING 이상인 건은 0건 UPDATE하므로 그 경우 false 반환 (역행 방지)
    @Override
    public boolean autoElevateToShippingIfNeeded(Long orderId, Long bizNo) {
        int updated = bizStoreMapper.autoElevateToShipping(orderId, bizNo);
        if (updated == 0) return false;
        bizStoreMapper.updateDeliveryTimestamp(orderId, bizNo, "SHIPPING_AT");
        bizStoreMapper.updateDeliveryStatusOnly(orderId, "SHIPPING");
        notifyBuyerDeliveryStatus(orderId, bizNo, "SHIPPING");
        return true;
    }

    /** 배송 상태 변경 시 구매자 알림 */
    private void notifyBuyerDeliveryStatus(Long orderId, Long bizNo, String orderStatus) {
        try {
            if (!"SHIPPING".equals(orderStatus) && !"DONE".equals(orderStatus)) {
                return;
            }
            BizOrderVO order = bizStoreMapper.selectOrderDetail(orderId, bizNo);
            if (order == null || order.getMemberNo() == null) {
                return;
            }
            if ("SHIPPING".equals(orderStatus)) {
                mypageNotifyService.sendOrderShippingToBuyerNotification(order.getMemberNo(), order.getOrderNo());
            } else {
                mypageNotifyService.sendOrderDeliveredToBuyerNotification(order.getMemberNo(), order.getOrderNo());
            }
        } catch (Exception ignored) {
        }
    }

    // 배송관리 목록 조회 + 지연여부(3일 이상 SHIPPING) 자바에서 계산
    @Override
    public List<BizDeliveryVO> getDeliveryList(Long bizNo, String carrier, String statusCd, String keyword) {
        List<BizDeliveryVO> list = bizStoreMapper.selectDeliveryList(bizNo, carrier, statusCd, keyword);
        for (BizDeliveryVO d : list) {
            d.setDelayed(isDelayed(d));
        }
        return list;
    }

    // 상단 요약카드: 필터 없이 전체 기준 상태별 개수 집계
    @Override
    public java.util.Map<String, Integer> getDeliverySummary(Long bizNo) {
        List<BizDeliveryVO> all = bizStoreMapper.selectDeliveryList(bizNo, null, null, null);
        java.util.Map<String, Integer> result = new java.util.HashMap<>();
        int ready = 0, shipping = 0, done = 0, delay = 0;
        for (BizDeliveryVO d : all) {
            if ("READY".equals(d.getOrderStatus())) ready++;
            else if ("SHIPPING".equals(d.getOrderStatus())) shipping++;
            else if ("DONE".equals(d.getOrderStatus())) done++;
            if (isDelayed(d)) delay++;
        }
        result.put("READY", ready);
        result.put("SHIPPING", shipping);
        result.put("DONE", done);
        result.put("DELAY", delay);
        return result;
    }

    // 지연 판단: SHIPPING 상태이고, 송장 등록일(shipDate)로부터 3일 이상 지난 경우
    private boolean isDelayed(BizDeliveryVO d) {
        if (!"SHIPPING".equals(d.getOrderStatus()) || d.getShipDate() == null) return false;
        try {
            java.time.LocalDate shipped = java.time.LocalDate.parse(d.getShipDate());
            long diffDays = java.time.temporal.ChronoUnit.DAYS.between(shipped, java.time.LocalDate.now());
            return diffDays >= 3;
        } catch (Exception e) {
            return false;
        }
    }

    // 송장 일괄등록 (줄 단위 파싱, updateOrderStatus 재사용)
    @Override
    public java.util.Map<String, Object> bulkRegisterDelivery(Long bizNo, String bulkText) {
        java.util.List<String> validCarriers = java.util.List.of("cj", "hanjin", "lotte", "post");
        int okCount = 0;
        java.util.List<String> failLines = new java.util.ArrayList<>();

        String[] lines = bulkText.split("\\r?\\n");
        for (String rawLine : lines) {
            String line = rawLine.trim();
            if (line.isEmpty()) continue;

            String[] parts = line.split(",");
            if (parts.length != 3) { failLines.add(line); continue; }

            String orderNo = parts[0].trim();
            String carrier = parts[1].trim();
            String trackingNo = parts[2].trim();

            if (!validCarriers.contains(carrier)) { failLines.add(line); continue; }

            Long orderId = bizStoreMapper.selectOrderIdByOrderNo(orderNo, bizNo);
            if (orderId == null) { failLines.add(line); continue; }

            // 주문관리(orders.jsp)용 updateOrderStatus 재사용
            //(택배사/송장번호 넣으면 자동으로 SHIPPING 상태 + 배송정보 upsert 처리됨)
            // courierCode는 null (일괄등록은 API 코드 없이 텍스트만 사용)
            boolean ok = updateOrderStatus(orderId, bizNo, "SHIPPING", carrier, null, trackingNo);
            if (ok) okCount++; else failLines.add(line);
        }

        java.util.Map<String, Object> result = new java.util.HashMap<>();
        result.put("okCount", okCount);
        result.put("failLines", failLines);
        return result;
    }

    // 리뷰관리 목록
    @Override
    public List<com.petcare.petcare.biz.store.vo.BizReviewVO> getBizReviewList(Long bizNo) {
        return bizStoreMapper.selectBizReviewList(bizNo);
    }

    // 답글 작성/수정 (UPDATE 조건에 BIZ_NO 포함, 본인 상품 리뷰만 반영)
    @Override
    public boolean saveReviewBizReply(Long bizNo, Long reviewId, String bizReply) {
        int updated = bizStoreMapper.updateReviewBizReply(reviewId, bizNo, bizReply);
        return updated > 0;
    }

    // 리뷰 삭제요청: 즉시 삭제 없이 TB_REVIEW_REPORT에 PENDING 등록 (관리자 승인 후 삭제)
    @Override
    public void requestReviewDelete(Long bizNo, Long reviewId, String reason) {
        if (bizStoreMapper.selectReviewOwnedByBiz(reviewId, bizNo) == 0) {
            throw new IllegalArgumentException("본인 상품의 리뷰가 아닙니다.");
        }
        if (bizStoreMapper.selectPendingReportExists(reviewId) > 0) {
            throw new IllegalStateException("이미 삭제 요청이 접수되어 관리자 승인을 기다리고 있습니다.");
        }
        bizStoreMapper.insertReviewDeleteRequest(reviewId, bizNo, reason);
    }

   // 사이드바 "주문관리" 뱃지용 - 결제완료(PAID) 상태 주문 개수
   @Override
   public int getPaidOrderCount(Long bizNo) {
       return bizStoreMapper.selectPaidOrderCount(bizNo);
   }

   // 오늘 신규 주문 건수
   @Override
   public int getTodayNewOrderCount(Long bizNo) {
       return bizStoreMapper.selectTodayNewOrderCount(bizNo);
   }

   // Q&A관리 목록
   @Override
   public List<com.petcare.petcare.biz.store.vo.BizQnaVO> getBizQnaList(Long bizNo) {
       return bizStoreMapper.selectBizQnaList(bizNo);
   }

   // Q&A 답변 등록/수정 (UPDATE 조건에 BIZ_NO 포함, 본인 상품 질문만 반영)
   @Override
   public boolean saveQnaAnswer(Long bizNo, Long qnaId, String answer) {
       int updated = bizStoreMapper.updateQnaAnswer(qnaId, bizNo, answer);
       return updated > 0;
   }

   // 사업자 정보 조회
   @Override
   public com.petcare.petcare.biz.store.vo.BizInfoVO getBusinessInfo(Long bizNo) {
       return bizStoreMapper.selectBusinessInfo(bizNo);
   }

   // 사업자 정보 수정 (등록증 새로 올리면 기존 것 삭제 후 교체)
   @Override
   public void updateBusinessInfo(Long bizNo, com.petcare.petcare.biz.store.vo.BizInfoVO info,
                                   org.springframework.web.multipart.MultipartFile certFile) throws Exception {
                                    bizStoreMapper.updateBusinessInfo(bizNo, info.getShopName(), info.getCeoName(), info.getBizRegNo(), info.getBizType(),
                                    info.getAddr(), info.getAddrDetail(), info.getPhone());

       if (certFile != null && !certFile.isEmpty()) {
           fileService.deleteFilesByRef("BIZ_AUTH", bizNo);
           fileService.uploadFile(certFile, "BIZ_AUTH", bizNo);
       }
   }

   // 정산 계좌 조회
   @Override
   public com.petcare.petcare.biz.store.vo.BizInfoVO getSettleAccount(Long bizNo) {
       return bizStoreMapper.selectSettleAccount(bizNo);
   }

   // 정산 계좌 변경
   @Override
   public boolean updateSettleAccount(Long bizNo, String settleBank, String settleBankCode,
                                      String settleAccount, String settleHolder) {
       if (bizNo == null || settleBank == null || settleBank.isBlank()
               || settleBankCode == null || settleBankCode.isBlank()
               || settleAccount == null || settleAccount.isBlank()
               || settleHolder == null || settleHolder.isBlank()) {
           return false;
       }
       return bizStoreMapper.updateSettleAccount(bizNo, settleBank.trim(), settleBankCode.trim(),
               settleAccount.replaceAll("[^0-9]", ""), settleHolder.trim()) > 0;
   }

    // 환불 목록
    @Override
    public List<BizReturnVO> getReturnList(Long bizNo, String statusCd) {
        if (statusCd == null || statusCd.isBlank()) {
            statusCd = "REQUESTED";
        }
        return bizStoreMapper.selectReturnList(bizNo, statusCd);
    }

    @Override
    public int getReturnRequestedCount(Long bizNo) {
        return bizStoreMapper.selectReturnRequestedCount(bizNo);
    }

    @Override
    public BizReturnVO getReturnDetail(Long orderItemId, Long bizNo) {
        BizReturnVO vo = bizStoreMapper.selectReturnDetail(orderItemId, bizNo);
        if (vo != null) {
            vo.setPhotoUrls(bizStoreMapper.selectReturnPhotoUrls(orderItemId));
            fillRefundCalc(vo);
        }
        return vo;
    }

    private void fillRefundCalc(BizReturnVO vo) {
        List<BizOrderItemVO> items = bizStoreMapper.selectOrderItems(vo.getOrderId());
        StoreItemRefundCalculator.fill(vo, items);
    }

    @Override
    public String approveReturn(Long orderItemId, Long bizNo) {
        BizReturnVO detail = bizStoreMapper.selectReturnDetail(orderItemId, bizNo);
        if (detail == null || !"REQUESTED".equals(detail.getReturnStatusCd())) {
            return "환불 신청 대기 건이 아닙니다.";
        }
        int updated = bizStoreMapper.approveReturn(orderItemId, bizNo);
        if (updated == 0) {
            return "승인 처리에 실패했습니다.";
        }
        mypageNotifyService.sendRefundApproveToBuyerNotification(
                detail.getMemberNo(), detail.getOrderNo(), detail.getProductName(),
                detail.getReturnReasonCd());
        return null;
    }

    @Override
    public String rejectReturn(Long orderItemId, Long bizNo, String rejectReason) {
        if (rejectReason == null || rejectReason.isBlank()) {
            return "거절 사유를 입력해 주세요.";
        }
        BizReturnVO detail = bizStoreMapper.selectReturnDetail(orderItemId, bizNo);
        if (detail == null || !"REQUESTED".equals(detail.getReturnStatusCd())) {
            return "환불 신청 대기 건이 아닙니다.";
        }
        int updated = bizStoreMapper.rejectReturn(orderItemId, bizNo, rejectReason.trim());
        if (updated == 0) {
            return "거절 처리에 실패했습니다.";
        }
        mypageNotifyService.sendRefundRejectToBuyerNotification(
                detail.getMemberNo(), detail.getOrderNo(), detail.getProductName(), rejectReason.trim());
        return null;
    }

    /**
     * 회수완료 처리 (토스 부분환불 후 DONE·재고복구)
     * 환불액 = 이 상품 실결제 (+ 상품이상이면 반송 3,000, 카드 잔액 한도)
     */
    @Override
    @org.springframework.transaction.annotation.Transactional
    public String completeReturn(Long orderItemId, Long bizNo) {
        BizReturnVO detail = bizStoreMapper.selectReturnDetail(orderItemId, bizNo);
        if (detail == null || !"RETURNING".equals(detail.getReturnStatusCd())) {
            return "환불 진행 중인 건이 아닙니다.";
        }
        fillRefundCalc(detail);

        int refundAmount = detail.getExpectCardRefund() != null ? detail.getExpectCardRefund() : 0;
        int pointRestore = detail.getItemPointAmount() != null ? detail.getItemPointAmount() : 0;
        boolean lastItem = Boolean.TRUE.equals(detail.getLastItemRefund());

        if (refundAmount > 0) {
            if (detail.getTossPaymentKey() == null || detail.getTossPaymentKey().isBlank()) {
                return "결제 정보를 찾을 수 없습니다.";
            }
            // 결제수단(빌링/토스위젯)에 맞는 시크릿으로 부분환불
            String tossError = tossPaymentService.cancelPaymentSmart(
                    detail.getTossPaymentKey(),
                    "상품 환불(회수완료)",
                    (long) refundAmount,
                    detail.getPayMethod());
            if (tossError != null) {
                return tossError;
            }
        }

        int updated = bizStoreMapper.completeReturn(orderItemId, bizNo, refundAmount);
        if (updated == 0) {
            return "환불 완료 DB 반영에 실패했습니다. 토스 환불은 이미 되었을 수 있으니 확인해 주세요.";
        }

        if (refundAmount > 0) {
            bizStoreMapper.addPaymentRefundAmt(detail.getOrderId(), refundAmount);
        }

        if (detail.getOptionId() != null && detail.getQty() != null) {
            bizStoreMapper.restoreStock(detail.getOptionId(), detail.getQty());
            bizStoreMapper.restoreProductStatusIfNeeded(detail.getProductId());
        }

        if (pointRestore > 0 && detail.getMemberNo() != null) {
            int currentBalance = bizStoreMapper.selectMemberPointBalance(detail.getMemberNo());
            int newBalance = currentBalance + pointRestore;
            bizStoreMapper.restoreMemberPoint(detail.getMemberNo(), newBalance);
            bizStoreMapper.insertPointRefundHistory(
                    detail.getMemberNo(), pointRestore, newBalance, detail.getOrderId());
        }
        // 주문 상품이 모두 환불(DONE)될 때만 쿠폰 복구
        if (lastItem && detail.getMemberCouponId() != null) {
            bizStoreMapper.restoreCoupon(detail.getMemberCouponId());
        }

        mypageNotifyService.sendRefundDoneToBuyerNotification(
                detail.getMemberNo(), detail.getOrderNo(), detail.getProductName(), refundAmount);
        return null;
    }

    // 쇼핑몰 쿠폰기능
    @Override
    public List<BizCouponVO> getCouponList(Long bizNo) {
        return bizStoreMapper.selectCouponListByBizNo(bizNo);
    }

    @Override
    public void applyCoupon(Long bizNo, BizCouponVO vo) {
        // 빈 최소주문금액·정액 쿠폰 maxDiscountAmt 서버 기본값 (Integer 바인딩 보완)
        if (vo.getMinOrderAmt() == null) {
            vo.setMinOrderAmt(0);
        }
        if ("FIXED".equals(vo.getCouponType())) {
            vo.setMaxDiscountAmt(null);
        }
        String code = "CPN-" + java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        vo.setCouponCode(code);
        vo.setBizMemberNo(bizNo);
        vo.setApprovalStatus("PENDING");
        vo.setStatusCd("INACTIVE");
        vo.setIssuedBudget(0);
        vo.setIssuedQty(0);
        bizStoreMapper.insertCoupon(vo);
    }

    @Override
    public void updateCoupon(Long bizNo, BizCouponVO vo) {
        BizCouponVO existing = bizStoreMapper.selectCouponById(vo.getCouponId());
        if (existing == null) throw new IllegalArgumentException("COUPON_NOT_FOUND");
        if (bizNo == null || !bizNo.equals(existing.getBizMemberNo())) throw new IllegalStateException("NOT_OWNER");
        if (!"PENDING".equals(existing.getApprovalStatus())) throw new IllegalStateException("NOT_PENDING");
        vo.setBizMemberNo(bizNo);
        bizStoreMapper.updateCoupon(vo);
    }

    @Override
    public void deleteCoupon(Long bizNo, Long couponId) {
        BizCouponVO existing = bizStoreMapper.selectCouponById(couponId);
        if (existing == null) throw new IllegalArgumentException("COUPON_NOT_FOUND");
        if (bizNo == null || !bizNo.equals(existing.getBizMemberNo())) throw new IllegalStateException("NOT_OWNER");
        if (!"PENDING".equals(existing.getApprovalStatus())) throw new IllegalStateException("NOT_PENDING");
        bizStoreMapper.deleteCoupon(couponId, bizNo);
    }

    /**
     * 쇼핑몰 사업자 쿠폰 조기 마감
     *
     * 관리자 승인을 받은 ACTIVE 쿠폰만 조기 마감 가능
     * 회원이 이미 발급받은 쿠폰은 변경 없음
     */
    @Override
    public void closeCoupon(Long bizNo, Long couponId) {
        BizCouponVO existing = bizStoreMapper.selectCouponById(couponId);

        if (existing == null) {
            throw new IllegalArgumentException("COUPON_NOT_FOUND");
        }

        // 로그인 사업자가 발급한 쿠폰인지 확인
        if (bizNo == null || !bizNo.equals(existing.getBizMemberNo())) {
            throw new IllegalStateException("NOT_OWNER");
        }

        // 관리자 승인을 받은 쿠폰만 조기 마감 가능
        if (!"APPROVED".equals(existing.getApprovalStatus())) {
            throw new IllegalStateException("NOT_APPROVED");
        }

        // 현재 게시 중인 쿠폰만 조기 마감 가능
        if (!"ACTIVE".equals(existing.getStatusCd())) {
            throw new IllegalStateException("NOT_ACTIVE");
        }

        int result = bizStoreMapper.closeCoupon(couponId, bizNo);

        if (result == 0) {
            throw new IllegalStateException("CLOSE_FAILED");
        }
    }
}