package com.petcare.petcare.mypage.order.controller;

import java.util.List;

import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.order.service.MypageOrderService;
import com.petcare.petcare.mypage.order.vo.MypageOrderVO;
import com.petcare.petcare.common.external.service.SmartTrackerService;

@Controller
@RequestMapping("/mypage")
public class MypageOrderController {

    @Autowired
    private MypageOrderService mypageOrderService;

    // 배송조회(스마트택배 API) 호출용
    @Autowired
    private SmartTrackerService smartTrackerService;

    // 상태 탭 필터
    @GetMapping("/orders")
    public String orders(@RequestParam(required = false) String statusCd, HttpSession session, Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        model.addAttribute("orderList", mypageOrderService.getOrderList(member.getMemberNo(), statusCd));
        model.addAttribute("selectedStatusCd", statusCd);
        return "mypage/orders";
    }

    // 마이페이지 배송조회 (AJAX, 원본 JSON 그대로 화면에 넘김)
    //본인 주문이 맞는지 getOrderDetail(memberNo, orderId)로 먼저 확인 (null이면 남의 주문번호로 조작 시도한 것 -> 거부)
    @GetMapping("/orders/track")
    @ResponseBody
    public String trackDelivery(@RequestParam Long orderId, @RequestParam String courierCode,
                                 @RequestParam String trackingNo, HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "{\"status\":false,\"msg\":\"로그인이 필요합니다.\"}";

        MypageOrderVO order = mypageOrderService.getOrderDetail(member.getMemberNo(), orderId);
        if (order == null) return "{\"status\":false,\"msg\":\"본인 주문만 조회할 수 있습니다.\"}";

        return smartTrackerService.getTrackingInfo(courierCode, trackingNo);
    }

 // 리뷰작성 모달에서 폼 submit + 사진 첨부(최대 5장, 선택). 배송완료 상품만 대상, 중복작성은 서비스에서 막음
 @PostMapping("/orders/review")
 public String writeReview(@RequestParam("orderItemId") Long orderItemId,
                            @RequestParam("rating") Double rating,
                            @RequestParam("content") String content,
                            @RequestParam(value = "images", required = false) List<MultipartFile> images,
                            HttpSession session, RedirectAttributes rttr) throws Exception {
     MemberVO member = (MemberVO) session.getAttribute("memberInfo");
     if (member == null) return "redirect:/login";

     // earnPoint 0(등록 성공, 50자 미만 포인트 미지급)과 null(등록 실패) 구분 안내
     Integer earnPoint = mypageOrderService.writeReview(member.getMemberNo(), orderItemId, rating, content, images);
     if (earnPoint != null && earnPoint > 0) {
         rttr.addFlashAttribute("msg", "리뷰가 등록되었습니다. " + earnPoint + "P가 적립되었습니다.");
         // 세션 포인트 잔액 즉시 갱신 (재로그인 없이 마이홈 반영)
         MemberVO sessionMember = (MemberVO) session.getAttribute("memberInfo");
         if (sessionMember != null) {
             long current = sessionMember.getPointBalance() != null ? sessionMember.getPointBalance() : 0L;
             sessionMember.setPointBalance(current + earnPoint);
             session.setAttribute("memberInfo", sessionMember);
         }
     } else if (earnPoint != null) {
         // earnPoint == 0인 경우 (10자 이상이지만 50자 미만이라 포인트 미지급, 등록 자체는 성공)
         rttr.addFlashAttribute("msg", "리뷰가 등록되었습니다. (50자 미만으로 작성되어 포인트는 지급되지 않았습니다.)");
     } else {
         // 절대 최소치(10자) 기준 안내 문구
         rttr.addFlashAttribute("errorMsg", "리뷰는 최소 10자 이상 작성해야 하며, 이미 작성했거나 본인 주문이 아니면 등록할 수 없습니다.");
     }
     return "redirect:/mypage/orders?statusCd=DONE";
 }

    // 주문상세보기 (결제내역/배송지, 읽기전용 - 리뷰작성은 목록에서 모달로 처리)
    // 같은 결제로 나뉜 사업자별 주문을 하나의 상세페이지로 표시
    @GetMapping("/orders/detail")
    public String orderDetail(@RequestParam("orderId") Long orderId, HttpSession session, Model model) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        java.util.List<MypageOrderVO> group = mypageOrderService.getOrderGroupDetail(member.getMemberNo(), orderId);
        if (group == null || group.isEmpty()) return "redirect:/mypage/orders?error=notfound";

        int groupTotalAmount = 0, groupDeliveryFee = 0, groupDiscountAmount = 0, groupPointUsed = 0, groupPayAmount = 0;
        for (MypageOrderVO o : group) {
            groupTotalAmount += o.getTotalAmount() != null ? o.getTotalAmount() : 0;
            groupDeliveryFee += o.getDeliveryFee() != null ? o.getDeliveryFee() : 0;
            groupDiscountAmount += o.getDiscountAmount() != null ? o.getDiscountAmount() : 0;
            groupPointUsed += o.getPointUsed() != null ? o.getPointUsed() : 0;
            groupPayAmount += o.getPayAmount() != null ? o.getPayAmount() : 0;
        }

        model.addAttribute("orderGroup", group);
        model.addAttribute("order", group.get(0)); //대표 1건 (주문일/받는사람/배송지/주문자 등 공통정보 표시용)
        model.addAttribute("groupTotalAmount", groupTotalAmount);
        model.addAttribute("groupDeliveryFee", groupDeliveryFee);
        model.addAttribute("groupDiscountAmount", groupDiscountAmount);
        model.addAttribute("groupPointUsed", groupPointUsed);
        model.addAttribute("groupPayAmount", groupPayAmount);
        return "mypage/orders-detail";
    }

    // 주문취소 신청 (사유 입력 모달 → 폼 submit, 처리 후 상세페이지로 리다이렉트)
    @PostMapping("/orders/cancel")
    public String cancelOrder(@RequestParam("orderId") Long orderId,
                               @RequestParam("reason") String reason,
                               HttpSession session, RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        boolean ok = mypageOrderService.requestCancel(member.getMemberNo(), orderId, reason);
        rttr.addFlashAttribute(ok ? "msg" : "errorMsg",
                ok ? "취소 신청이 접수되었습니다. 사업자 확인 후 처리됩니다."
                   : "취소 신청에 실패했습니다. 배송중이거나 이미 신청·환불 진행 중인 주문입니다.");
        return "redirect:/mypage/orders/detail?orderId=" + orderId;
    }
    
    // 구매확정 처리 (배송완료 상태 주문에서 버튼 누르면 결제금액의 % 만큼 적립)
    @PostMapping("/orders/confirm")
    public String confirmPurchase(@RequestParam("orderId") Long orderId, HttpSession session, RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        Integer earnPoint = mypageOrderService.confirmPurchase(member.getMemberNo(), orderId);
        if (earnPoint != null) {
            rttr.addFlashAttribute("msg", "구매확정 되었습니다. " + earnPoint + "P가 적립되었습니다.");
            MemberVO sessionMember = (MemberVO) session.getAttribute("memberInfo");
            if (sessionMember != null) {
                long current = sessionMember.getPointBalance() != null ? sessionMember.getPointBalance() : 0L;
                sessionMember.setPointBalance(current + earnPoint);
                session.setAttribute("memberInfo", sessionMember);
            }
        } else {
            rttr.addFlashAttribute("errorMsg", "확정할 상품이 없거나 배송완료 상태가 아닙니다. (환불 진행·완료 상품은 제외됩니다.)");
        }
        return "redirect:/mypage/orders";
    }

    // 환불 신청 폼
    @GetMapping("/orders/refund")
    public String refundForm(@RequestParam("orderItemId") Long orderItemId,
                             HttpSession session, Model model, RedirectAttributes rttr) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        var item = mypageOrderService.getRefundableItem(member.getMemberNo(), orderItemId);
        if (item == null) {
            rttr.addFlashAttribute("errorMsg", "환불 신청할 수 없는 상품입니다.");
            return "redirect:/mypage/orders";
        }
        model.addAttribute("item", item);
        return "mypage/orders-refund";
    }

    // 환불 신청 제출
    @PostMapping("/orders/refund")
    public String refundSubmit(@RequestParam("orderItemId") Long orderItemId,
                               @RequestParam("reasonCd") String reasonCd,
                               @RequestParam("content") String content,
                               @RequestParam(value = "images", required = false) List<MultipartFile> images,
                               HttpSession session, RedirectAttributes rttr) throws Exception {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "redirect:/login";

        String error = mypageOrderService.requestRefund(
                member.getMemberNo(), orderItemId, reasonCd, content, images);
        if (error != null) {
            rttr.addFlashAttribute("errorMsg", error);
            return "redirect:/mypage/orders/refund?orderItemId=" + orderItemId;
        }
        rttr.addFlashAttribute("msg", "환불 신청이 접수되었습니다. 사업자 확인 후 처리됩니다.");
        return "redirect:/mypage/orders";
    }
}