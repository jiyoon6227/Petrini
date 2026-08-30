/**
 * 역할: 관리자 정산 관리 화면
 * 2026/07/24 장우철 — STORE 탭 UI 더미
 * 2026/07/30 장우철 — STAY 탭 실데이터
 * 2026/08/05 장우철 — STORE 탭 S11 실데이터
 *
 * - GET  /admin/settlement
 * - GET  /admin/settlement/stay/items | /store/items
 * - POST /admin/settlement/stay|store/pay · pay-bulk
 * - POST /admin/settlement/stay|store/request/approve · reject
 */
package com.petcare.petcare.admin.settlement.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.admin.controller.AdminBaseController;
import com.petcare.petcare.admin.settlement.service.AdminSettlementService;
import com.petcare.petcare.admin.settlement.vo.AdminStayRequestVO;
import com.petcare.petcare.admin.settlement.vo.AdminStaySettlementVO;
import com.petcare.petcare.admin.settlement.vo.AdminStoreRequestVO;
import com.petcare.petcare.settlement.vo.StaySettlementItemVO;
import com.petcare.petcare.settlement.vo.StaySettlementVO;
import com.petcare.petcare.settlement.vo.StoreSettlementItemVO;
import com.petcare.petcare.settlement.vo.StoreSettlementVO;

import jakarta.servlet.http.HttpSession;

@Controller("adminSettlementController")
@RequestMapping("/admin/settlement")
public class AdminSettlementController extends AdminBaseController {

    @Autowired
    private AdminSettlementService adminSettlementService;

    @GetMapping
    public String settlement(HttpSession session,
                             @RequestParam(defaultValue = "STORE") String tab,
                             @RequestParam(value = "status", required = false, defaultValue = "all") String status,
                             @RequestParam(value = "reqStatus", required = false, defaultValue = "requested") String reqStatus,
                             Model model) {
        if (getAdmin(session) == null) {
            return redirectToLogin();
        }

        model.addAttribute("tab", tab);
        model.addAttribute("adminSettlementReady", adminSettlementService.isReady());
        model.addAttribute("filterStatus", status);
        model.addAttribute("filterReqStatus", reqStatus);

        if ("STAY".equalsIgnoreCase(tab)) {
            model.addAttribute("staySettlementCount", adminSettlementService.countStaySettlements(null));
            model.addAttribute("staySettlements", adminSettlementService.getStaySettlementList(status));
            model.addAttribute("stayRequests", adminSettlementService.getStayRequestList(reqStatus));
            model.addAttribute("stayRequestPendingCount",
                    adminSettlementService.countStayMidRequestsRequested());
        } else {
            model.addAttribute("storeSettlementCount", adminSettlementService.countStoreSettlements(null));
            model.addAttribute("storeSettlements", adminSettlementService.getStoreSettlementList(status));
            model.addAttribute("storeRequests", adminSettlementService.getStoreRequestList(reqStatus));
            model.addAttribute("storeRequestPendingCount",
                    adminSettlementService.countStoreMidRequestsRequested());
        }

        return "admin/settlement/list";
    }

    @GetMapping("/stay/items")
    @ResponseBody
    public Map<String, Object> stayItems(HttpSession session,
                                         @RequestParam("settleId") Long settleId) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        List<StaySettlementItemVO> items = adminSettlementService.getStaySettlementItems(settleId);
        result.put("ok", true);
        result.put("items", items);
        return result;
    }

    @PostMapping("/stay/pay")
    @ResponseBody
    public Map<String, Object> stayPay(HttpSession session,
                                       @RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        Long settleId = toLong(body.get("settleId"));
        try {
            int updated = adminSettlementService.payStaySettlement(settleId);
            result.put("ok", updated > 0);
            result.put("updated", updated);
            result.put("message", updated > 0
                    ? "정산(더미 지급) 완료 처리되었습니다."
                    : "이미 완료되었거나 대상이 없습니다.");
        } catch (IllegalArgumentException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @PostMapping("/stay/pay-bulk")
    @ResponseBody
    public Map<String, Object> stayPayBulk(HttpSession session,
                                           @RequestBody Map<String, Object> body) {
        return payBulk(session, body, true);
    }

    @PostMapping("/stay/request/approve")
    @ResponseBody
    public Map<String, Object> stayRequestApprove(HttpSession session,
                                                  @RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        Long requestId = toLong(body.get("requestId"));
        try {
            StaySettlementVO saved = adminSettlementService.approveStayMidRequest(requestId);
            result.put("ok", true);
            result.put("settleId", saved.getSettleId());
            result.put("settleAmount", saved.getSettleAmount());
            result.put("itemCount", saved.getItems() == null ? 0 : saved.getItems().size());
            result.put("message", "승인 완료. 정산 마스터 #" + saved.getSettleId()
                    + " 생성 (" + (saved.getItems() == null ? 0 : saved.getItems().size()) + "건)."
                    + " 지급은 정산 목록에서 진행하세요.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @PostMapping("/stay/request/reject")
    @ResponseBody
    public Map<String, Object> stayRequestReject(HttpSession session,
                                                 @RequestBody Map<String, Object> body) {
        return rejectRequest(session, body, true);
    }

    // ===== STORE =====

    @GetMapping("/store/items")
    @ResponseBody
    public Map<String, Object> storeItems(HttpSession session,
                                          @RequestParam("settleId") Long settleId) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        List<StoreSettlementItemVO> items = adminSettlementService.getStoreSettlementItems(settleId);
        result.put("ok", true);
        result.put("items", items);
        return result;
    }

    @PostMapping("/store/pay")
    @ResponseBody
    public Map<String, Object> storePay(HttpSession session,
                                        @RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        Long settleId = toLong(body.get("settleId"));
        try {
            int updated = adminSettlementService.payStoreSettlement(settleId);
            result.put("ok", updated > 0);
            result.put("updated", updated);
            result.put("message", updated > 0
                    ? "정산(더미 지급) 완료 처리되었습니다."
                    : "이미 완료되었거나 대상이 없습니다.");
        } catch (IllegalArgumentException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @PostMapping("/store/pay-bulk")
    @ResponseBody
    public Map<String, Object> storePayBulk(HttpSession session,
                                            @RequestBody Map<String, Object> body) {
        return payBulk(session, body, false);
    }

    @PostMapping("/store/request/approve")
    @ResponseBody
    public Map<String, Object> storeRequestApprove(HttpSession session,
                                                   @RequestBody Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        Long requestId = toLong(body.get("requestId"));
        try {
            StoreSettlementVO saved = adminSettlementService.approveStoreMidRequest(requestId);
            result.put("ok", true);
            result.put("settleId", saved.getSettleId());
            result.put("settleAmount", saved.getSettleAmount());
            result.put("itemCount", saved.getItems() == null ? 0 : saved.getItems().size());
            result.put("message", "승인 완료. 정산 마스터 #" + saved.getSettleId()
                    + " 생성 (" + (saved.getItems() == null ? 0 : saved.getItems().size()) + "건)."
                    + " 지급은 정산 목록에서 진행하세요.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    @PostMapping("/store/request/reject")
    @ResponseBody
    public Map<String, Object> storeRequestReject(HttpSession session,
                                                  @RequestBody Map<String, Object> body) {
        return rejectRequest(session, body, false);
    }

    private Map<String, Object> payBulk(HttpSession session, Map<String, Object> body, boolean stay) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        @SuppressWarnings("unchecked")
        List<Object> rawIds = (List<Object>) body.get("settleIds");
        List<Long> settleIds = new java.util.ArrayList<>();
        if (rawIds != null) {
            for (Object o : rawIds) {
                Long id = toLong(o);
                if (id != null) {
                    settleIds.add(id);
                }
            }
        }
        try {
            int updated = stay
                    ? adminSettlementService.payStaySettlements(settleIds)
                    : adminSettlementService.payStoreSettlements(settleIds);
            result.put("ok", true);
            result.put("updated", updated);
            result.put("message", "선택 " + settleIds.size() + "건 중 " + updated + "건 정산(더미 지급) 완료.");
        } catch (IllegalArgumentException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    private Map<String, Object> rejectRequest(HttpSession session, Map<String, Object> body, boolean stay) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        Long requestId = toLong(body.get("requestId"));
        String rejectReason = body.get("rejectReason") == null
                ? null : String.valueOf(body.get("rejectReason"));
        try {
            if (stay) {
                adminSettlementService.rejectStayMidRequest(requestId, rejectReason);
            } else {
                adminSettlementService.rejectStoreMidRequest(requestId, rejectReason);
            }
            result.put("ok", true);
            result.put("message", "요청이 거절되었습니다.");
        } catch (IllegalArgumentException | IllegalStateException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    // ===== S12 배치 / FAIL (2026/08/05 장우철) =====

    /** 월정산 생성 — body: { settleMonth: "2026-07" } 없으면 전월 */
    @PostMapping("/batch/monthly-create")
    @ResponseBody
    public Map<String, Object> batchMonthlyCreate(HttpSession session,
                                                  @RequestBody(required = false) Map<String, Object> body) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        String settleMonth = null;
        if (body != null && body.get("settleMonth") != null) {
            settleMonth = String.valueOf(body.get("settleMonth")).trim();
            if (settleMonth.isEmpty() || "null".equalsIgnoreCase(settleMonth)) {
                settleMonth = null;
            }
        }
        try {
            var r = adminSettlementService.createMonthlySettlements(settleMonth);
            result.put("ok", true);
            result.put("result", r);
            result.put("message",
                    "월정산 생성 완료 [" + r.getSettleMonth() + "] "
                    + "숙소 +" + r.getStayCreated() + " / 쇼핑 +" + r.getStoreCreated()
                    + " (스킵 숙소 " + r.getStaySkipped() + " · 쇼핑 " + r.getStoreSkipped() + ")");
        } catch (Exception e) {
            result.put("ok", false);
            result.put("message", e.getMessage() != null ? e.getMessage() : "월정산 생성 실패");
        }
        return result;
    }

    /** WAIT 전체 더미 자동지급 */
    @PostMapping("/batch/auto-pay")
    @ResponseBody
    public Map<String, Object> batchAutoPay(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        try {
            var r = adminSettlementService.autoPayWaitingSettlements();
            result.put("ok", true);
            result.put("result", r);
            result.put("message",
                    "자동지급(더미) 완료 — 숙소 " + r.getStayPaid() + "건 · 쇼핑 " + r.getStorePaid() + "건");
        } catch (Exception e) {
            result.put("ok", false);
            result.put("message", e.getMessage() != null ? e.getMessage() : "자동지급 실패");
        }
        return result;
    }

    @PostMapping("/stay/mark-fail")
    @ResponseBody
    public Map<String, Object> stayMarkFail(HttpSession session,
                                            @RequestBody Map<String, Object> body) {
        return markFail(session, body, true);
    }

    @PostMapping("/store/mark-fail")
    @ResponseBody
    public Map<String, Object> storeMarkFail(HttpSession session,
                                             @RequestBody Map<String, Object> body) {
        return markFail(session, body, false);
    }

    private Map<String, Object> markFail(HttpSession session, Map<String, Object> body, boolean stay) {
        Map<String, Object> result = new HashMap<>();
        if (getAdmin(session) == null) {
            result.put("ok", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        Long settleId = toLong(body == null ? null : body.get("settleId"));
        try {
            int updated = stay
                    ? adminSettlementService.markStaySettlementFail(settleId)
                    : adminSettlementService.markStoreSettlementFail(settleId);
            result.put("ok", updated > 0);
            result.put("updated", updated);
            result.put("message", updated > 0
                    ? "지급실패(FAIL)로 표시했습니다. 상세에서 계좌 확인 후 수동입금완료 하세요."
                    : "대기(WAIT) 상태가 아니거나 대상이 없습니다.");
        } catch (IllegalArgumentException e) {
            result.put("ok", false);
            result.put("message", e.getMessage());
        }
        return result;
    }

    private Long toLong(Object v) {
        if (v == null) {
            return null;
        }
        if (v instanceof Number) {
            return ((Number) v).longValue();
        }
        try {
            return Long.parseLong(String.valueOf(v));
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
