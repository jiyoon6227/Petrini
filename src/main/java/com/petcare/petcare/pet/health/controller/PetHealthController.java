/**
 * 역할: 마이페이지 건강수첩 URL 처리
 *
 * URL: /mypage/health
 * 화면: mypage/health.jsp
 *
 * 2026/07/14 장우철 — TB_MEDICAL_RECORD 연동 (목업 제거)
 */

package com.petcare.petcare.pet.health.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.petcare.petcare.hospital.vo.MedicalRecordVO;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.pet.health.service.PetHealthService;
import com.petcare.petcare.pet.profile.service.PetProfileService;
import com.petcare.petcare.pet.profile.vo.PetProfileVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/mypage")
public class PetHealthController {

    @Autowired
    private PetHealthService petHealthService;

    @Autowired
    private PetProfileService petProfileService;

    // 2026/07/14 장우철 — 건강수첩: 반려견 탭 + 진료 타임라인
    @GetMapping("/health")
    public String health(@RequestParam(value = "petId", required = false) Long petId,
                         HttpSession session,
                         Model model) throws Exception {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login?redirect=/mypage/health";
        }

        Long memberNo = member.getMemberNo();
        List<PetProfileVO> petList = petProfileService.getPetList(memberNo);
        model.addAttribute("petList", petList);

        PetProfileVO selected = null;
        if (petList != null && !petList.isEmpty()) {
            if (petId != null) {
                for (PetProfileVO p : petList) {
                    if (petId.equals(p.getPetId())) {
                        selected = p;
                        break;
                    }
                }
            }
            if (selected == null) {
                // 대표견 우선, 없으면 첫 번째
                for (PetProfileVO p : petList) {
                    if ("Y".equalsIgnoreCase(p.getIsRepresent())) {
                        selected = p;
                        break;
                    }
                }
                if (selected == null) {
                    selected = petList.get(0);
                }
            }
        }
        model.addAttribute("selectedPet", selected);

        List<MedicalRecordVO> recordList = List.of();
        if (selected != null) {
            recordList = petHealthService.getHealthRecords(memberNo, selected.getPetId());
        }
        model.addAttribute("recordList", recordList);
        model.addAttribute("visitCount", recordList.size());

        // 최근 체중·체온: 파싱된 최신 기록(또는 펫 프로필 체중)
        String latestWeight = null;
        String latestTemp = null;
        for (MedicalRecordVO r : recordList) {
            if (latestWeight == null && r.getWeight() != null && !r.getWeight().isBlank()) {
                latestWeight = r.getWeight();
            }
            if (latestTemp == null && r.getTemperature() != null && !r.getTemperature().isBlank()) {
                latestTemp = r.getTemperature();
            }
            if (latestWeight != null && latestTemp != null) {
                break;
            }
        }
        if (latestWeight == null && selected != null && selected.getWeight() != null) {
            latestWeight = String.valueOf(selected.getWeight());
        }
        model.addAttribute("latestWeight", latestWeight);
        model.addAttribute("latestTemp", latestTemp);

        return "mypage/health";
    }
}
