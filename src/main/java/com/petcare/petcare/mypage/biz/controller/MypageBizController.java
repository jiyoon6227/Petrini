/**
 * 역할: 마이페이지 사업자 URL 처리 → Service 호출 → JSP/리다이렉트 반환
 *
 * 연결
 * - Service: MypageBizService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.mypage.biz.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.petcare.petcare.biz.vo.BusinessVO;
import com.petcare.petcare.common.config.controller.CommonConfigController;
import com.petcare.petcare.common.external.service.KftcOpenBankingService;
import com.petcare.petcare.common.external.vo.KftcRealNameResultVO;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.member.auth.service.MemberAuthService;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.biz.service.MypageBizService;

import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;

@Controller
@RequestMapping("/mypage/biz")
public class MypageBizController extends CommonConfigController {
    @Value("${file.upload-dir}")
    private String uploadDir;

    @Value("${gcs.enabled:false}")
    private boolean gcsEnabled;

    @Value("${gcs.bucket-name:}")
    private String gcsBucket;

    @Autowired(required = false)
    private Storage storage;

    @Autowired
    private MypageBizService mypageBizService;

    // 2026-07-09 장우철 — 승인 완료 사업자 세션(role=BIZ) 동기화
    // 이유: 관리자 승인 후 재로그인 없이 /mypage/biz ↔ /apply 무한 리다이렉트 방지
    @Autowired
    private MemberAuthService memberAuthService;

    // 2026/07/28 장우철 — 정산 계좌 실명조회 (mock/실연동)
    @Autowired
    private KftcOpenBankingService kftcOpenBankingService;
    
    @GetMapping({"", "/"})
    public String biz(HttpSession session) {
        MemberVO memberInfo = (MemberVO) session.getAttribute("memberInfo");
        if (memberInfo == null)
            return "redirect:/login";

        // 2026-07-09 장우철 — [변경 후] DB 승인 상태를 세션에 반영 후 업종별 사업자 화면으로 이동
        memberAuthService.enrichSessionWithApprovedBiz(memberInfo);
        session.setAttribute("memberInfo", memberInfo);

        /* [변경 전] 2026-07-09 장우철 — 세션 role 만 확인, APPROVED 인데 USER 이면 /apply 로 루프
        if (!"BIZ".equals(memberInfo.getRole())) {
            return "redirect:/mypage/biz/apply";
        }
        */

        if (!"BIZ".equals(memberInfo.getRole())) {
            return "redirect:/mypage/biz/apply";
        }

        return switch (memberInfo.getBizType()) {
            case "HOSPITAL" -> "redirect:/biz/hospital";
            case "STAY" -> "redirect:/biz/stay";
            case "RESTAURANT" -> "redirect:/biz/restaurant";
            case "GROOMING" -> "redirect:/biz/grooming";
            case "STUDIO" -> "redirect:/biz/studio";
            case "STORE" -> "redirect:/biz/store";
            default -> "mypage/biz";
        };
    }

    /* 사업자 등록 신청 — 폼 페이지 */
    @GetMapping("/apply")
    public String bizApply(HttpSession session,
                            @RequestParam(required = false) String reapply,
                            Model model,
                            RedirectAttributes redirectAttr) throws Exception {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null)
            return "redirect:/login";

        // 기존 신청 이력 확인
        BusinessVO apply = mypageBizService.getBizAuthStatus(member.getMemberId());
        if (apply != null) {
        if ("APPROVED".equals(apply.getStatusCd())) {
            // 2026-07-09 장우철 — [변경 후] 승인 완료 시 세션에 BIZ 권한 반영 후 이동
            memberAuthService.enrichSessionWithApprovedBiz(member);
            session.setAttribute("memberInfo", member);
            return "redirect:/mypage/biz";
        }
        // 2026-07-09 장우철 — [변경 후] 반려 → 반려 안내 화면, reapply=Y 일 때만 신청 폼
        // 이유: PENDING 과 동일하게 complete 로내면 「심사중」으로만 보이는 문제 해결
        if ("REJECTED".equals(apply.getStatusCd())) {
            if ("Y".equalsIgnoreCase(reapply)) {
                model.addAttribute("reapply", true);
                model.addAttribute("rejectReason", apply.getRejectReason());
                return "mypage/biz/apply";
            }
            return "redirect:/mypage/biz/rejected";
        }
        // PENDING — 심사중
        redirectAttr.addFlashAttribute("bizName", apply.getBizName());
        redirectAttr.addFlashAttribute("bizType", apply.getBizType());
        redirectAttr.addFlashAttribute("bizRegNo", apply.getBizRegNo());
        return "redirect:/mypage/biz/complete";

        /* [변경 전] 2026-07-09 장우철 — REJECTED 도 PENDING 과 같이 complete(심사중) 로 이동
        redirectAttr.addFlashAttribute("bizName", apply.getBizName());
        return "redirect:/mypage/biz/complete";
        */
    }

        return "mypage/biz/apply";
    }

    // 2026-07-09 장우철 — 반려 안내 화면 (재신청 버튼 → /apply?reapply=Y)
    @GetMapping("/rejected")
    public String bizRejected(HttpSession session, Model model) throws Exception {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null)
            return "redirect:/login";

            BusinessVO apply = mypageBizService.getBizAuthStatus(member.getMemberId());
        if (apply == null || !"REJECTED".equals(apply.getStatusCd())) {
            return "redirect:/mypage/biz/apply";
        }
        model.addAttribute("apply", apply);
        return "mypage/biz/rejected";
    }

    /* 사업자등록번호 확인 — 폼 제출 처리 */
    @PostMapping("/checkBizNo")
    @ResponseBody
    public Map<String, Object> checkBizNo(HttpSession session,
                                          @RequestParam String bizRegNo) throws Exception {

        Map<String, Object> result = new HashMap<>();

        try {
            //HYJ 26.08.04
            if (!mypageBizService.checkBizRegNo(bizRegNo)) {
                result.put("success", false);
                result.put("message", "이미 등록된 사업자 번호 입니다.");
                return result;
            }

            result.put("success", true);
            result.put("message", "이미 등록된 사업자 번호 입니다.");

            // String baseUrl = "https://api.odcloud.kr/api/nts-businessman/v1/status";
            // StringBuilder sb = new StringBuilder(baseUrl);
            // sb.append("?serviceKey=").append(URLEncoder.encode(apiService.publicServiceApiKey, "UTF-8"));
            
            // String body = "{\"b_no\":[\"" + bizRegNo.replace("-", "") + "\"]}";
            // String json = apiService.callApi(sb.toString(), body);

            // ObjectMapper mapper = new ObjectMapper();
            // JsonNode root = mapper.readTree(json);
            // JsonNode data = root.path("data");

            // if (data.isArray() && data.size() > 0) {
            //     String status = data.get(0).path("b_stt").asText("");
            //     // "계속사업자" = 정상 / "휴업자" = 휴업 / "폐업자" = 폐업
            //     if ("계속사업자".equals(status)) {
            //         result.put("success", true);
            //         result.put("message", "인증 완료 (계속사업자)");
            //     } else if (status.isEmpty()) {
            //         result.put("success", false);
            //         result.put("message", "등록되지 않은 사업자등록번호입니다.");
            //     } else {
            //         result.put("success", false);
            //         result.put("message", "사업 상태: " + status);
            //     }
            // } 
            // else {
            //     result.put("success", false);
            //     result.put("message", "조회 결과가 없습니다.");
            // }
        } 
        catch (Exception e) {
            result.put("success", false);
            result.put("message", "API 호출 오류: " + e.getMessage());
        }
        return result;
    }

    /**
     * 2026/07/28 장우철 — Ajax: 정산 계좌 실명조회 (mock / 금결원)
     * 요청: bankCodeStd, bankName, accountNum, accountHolder, bizRegNo
     */
    @PostMapping("/account/verify")
    @ResponseBody
    public Map<String, Object> verifySettleAccount(HttpSession session,
                                                   @RequestParam String bankCodeStd,
                                                   @RequestParam String bankName,
                                                   @RequestParam String accountNum,
                                                   @RequestParam String accountHolder,
                                                   @RequestParam(required = false) String bizRegNo) {
        Map<String, Object> result = new HashMap<>();
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        StringBuilder err = new StringBuilder();
        String holderInfo = bizRegNo != null ? bizRegNo.replaceAll("[^0-9]", "") : "";
        String holderType = holderInfo.length() >= 10 ? "1" : " ";

        KftcRealNameResultVO vo = kftcOpenBankingService.inquireRealName(
                bankCodeStd, bankName, accountNum, holderType, holderInfo, accountHolder, err);

        result.put("success", vo.isSuccess());
        result.put("mock", vo.isMock());
        result.put("message", vo.isSuccess() ? vo.getMessage() : (err.length() > 0 ? err.toString() : vo.getMessage()));
        if (vo.isSuccess()) {
            result.put("bankCodeStd", vo.getBankCodeStd());
            result.put("bankName", vo.getBankName());
            result.put("accountNum", vo.getAccountNum());
            result.put("accountHolderName", vo.getAccountHolderName());
        }
        return result;
    }

    /* 사업자 등록 신청 — 폼 제출 처리 */
    @PostMapping("/apply")
    public String bizApplySubmit(@RequestParam(required = true) MultipartFile docFile,
                                 @RequestParam(required = false) MultipartFile licenseFile,
                                 BusinessVO vo,
                                 RedirectAttributes redirectAttr,
                                 HttpSession session) throws Exception {

        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null)
            return "redirect:/login";

        vo.setBizId(member.getMemberId());
        vo.setStatusCd("PENDING");

        // 2026/07/28 장우철 — 숙소·쇼핑은 정산 계좌 인증값 필수
        if ("STAY".equals(vo.getBizType()) || "STORE".equals(vo.getBizType())) {
            if (!"Y".equalsIgnoreCase(vo.getSettleVerifyYn())
                    || vo.getSettleAccount() == null || vo.getSettleAccount().isBlank()
                    || vo.getSettleHolder() == null || vo.getSettleHolder().isBlank()
                    || vo.getSettleBank() == null || vo.getSettleBank().isBlank()) {
                redirectAttr.addFlashAttribute("errorMsg", "정산 계좌 인증을 완료해 주세요.");
                return "redirect:/mypage/biz/apply";
            }
        } else {
            vo.setSettleBank(null);
            vo.setSettleBankCode(null);
            vo.setSettleAccount(null);
            vo.setSettleHolder(null);
            vo.setSettleVerifyYn(null);
        }

        try {
            // 1) 파일을 로컬 또는 GCS에 저장 + FileVO 목록 준비 — 2026/07/22 장우철
            String subDir = "biz/" + vo.getBizId();
            List<FileVO> fileList = new ArrayList<>();

            if (docFile != null && !docFile.isEmpty()) {
                String objectPath = subDir + "/" + docFile.getOriginalFilename();
                storeBizUploadFile(docFile, objectPath);
                FileVO fv = new FileVO();
                fv.setRefType("BIZ_AUTH");
                fv.setFileUrl(objectPath);
                fv.setDriveFileId(gcsEnabled ? "GCS" : ("biz_auth" + System.currentTimeMillis()));
                fv.setOriginName(docFile.getOriginalFilename());
                fileList.add(fv);
            }

            if (licenseFile != null && !licenseFile.isEmpty()) {
                String objectPath = subDir + "/" + licenseFile.getOriginalFilename();
                storeBizUploadFile(licenseFile, objectPath);
                FileVO fv = new FileVO();
                fv.setRefType("BIZ_LICENSE");
                fv.setFileUrl(objectPath);
                fv.setDriveFileId(gcsEnabled ? "GCS" : ("biz_license" + System.currentTimeMillis()));
                fv.setOriginName(licenseFile.getOriginalFilename());
                fileList.add(fv);
            }

            // 2) DB 작업은 Service에서 한 트랜잭션으로 처리
            mypageBizService.applyBusiness(vo, fileList);
           
            redirectAttr.addFlashAttribute("bizName", vo.getBizName());
            redirectAttr.addFlashAttribute("bizType", vo.getBizType());
            redirectAttr.addFlashAttribute("bizRegNo", vo.getBizRegNo());
            return "redirect:/mypage/biz/complete";
        } catch (IllegalStateException e) {
            String code = e.getMessage();
            String msg = "신청 처리 중 오류가 발생했습니다.";
            if ("BIZ_REG_NO_DUPLICATE".equals(code)) {
                msg = "이미 다른 사업자가 사용 중인 사업자등록번호입니다.";
            } else if ("BIZ_ALREADY_PENDING".equals(code)) {
                msg = "이미 심사 중인 신청이 있습니다.";
            } else if ("BIZ_ALREADY_APPROVED".equals(code)) {
                msg = "이미 승인된 사업자 계정입니다.";
            } else if ("BIZ_REAPPLY_FAILED".equals(code)) {
                msg = "재신청 처리에 실패했습니다. 잠시 후 다시 시도해 주세요.";
            }
            redirectAttr.addFlashAttribute("errorMsg", msg);
            BusinessVO cur = mypageBizService.getBizAuthStatus(member.getMemberId());
            if (cur != null && "REJECTED".equals(cur.getStatusCd())) {
                return "redirect:/mypage/biz/apply?reapply=Y";
            }
            return "redirect:/mypage/biz/apply";
        }
        catch (Exception e) {
            e.printStackTrace();
            redirectAttr.addFlashAttribute("errorMsg", "신청 처리 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/mypage/biz/apply";
        }
    }

    /* 신청 완료 페이지 — PENDING(심사중) 전용 */
    @GetMapping("/complete")
    public String bizComplete(HttpSession session, Model model) throws Exception {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null)
            return "redirect:/login";

        // 2026-07-09 장우철 — [변경 후] DB 상태로 분기 (flash 만 믿지 않음)
        // 이유: 반려 후에도 complete 북마크 시 심사중으로 보이던 문제 방지
        BusinessVO apply = mypageBizService.getBizAuthStatus(member.getMemberId());
        if (apply == null) {
            return "redirect:/mypage/biz/apply";
        }
        if ("REJECTED".equals(apply.getStatusCd())) {
            return "redirect:/mypage/biz/rejected";
        }
        if ("APPROVED".equals(apply.getStatusCd())) {
            memberAuthService.enrichSessionWithApprovedBiz(member);
            session.setAttribute("memberInfo", member);
            return "redirect:/mypage/biz";
        }
        model.addAttribute("biz", apply);
        return "mypage/biz/complete";

        /* [변경 전] 2026-07-09 장우철 — 상태 확인 없이 complete.jsp 만 반환
        return "mypage/biz/complete";
        */
    }

    /**
     * 사업자 신청 서류 저장 — gcs.enabled 분기
     * 2026/07/22 장우철
     */
    private void storeBizUploadFile(MultipartFile file, String objectPath) throws Exception {
        if (gcsEnabled) {
            // [GCS 업로드 — gcs.enabled=true] 2026/07/22 장우철
            //#region구글 스토리지 GCS 전환코드 START
            if (storage == null) {
                throw new IllegalStateException("GCS enabled but Storage bean is missing");
            }
            String contentType = file.getContentType();
            if (contentType == null || contentType.isBlank()) {
                contentType = "application/octet-stream";
            }
            BlobInfo blobInfo = BlobInfo.newBuilder(BlobId.of(gcsBucket, objectPath))
                    .setContentType(contentType)
                    .build();
            storage.create(blobInfo, file.getBytes());
            //#endregion GCS 전환코드 END
        } else {
            // [로컬 저장 — gcs.enabled=false] 2026/07/22 장우철
            //#region로컬 파일관리
            File dest = new File(uploadDir + objectPath);
            File parent = dest.getParentFile();
            if (parent != null && !parent.exists()) {
                parent.mkdirs();
            }
            file.transferTo(dest);
            //#endregion
        }
    }
}
