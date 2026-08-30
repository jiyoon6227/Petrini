/**
 * 2026/07/11 장우철 — 마이페이지 반려동물 관리
 *
 * URL: /mypage/pets
 * 화면: mypage/pets.jsp
 */

package com.petcare.petcare.pet.profile.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.pet.profile.service.PetProfileService;
import com.petcare.petcare.pet.profile.vo.PetProfileVO;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/mypage")
public class PetProfileController {

    @Autowired
    private PetProfileService petProfileService;

    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule())
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

    @GetMapping("/pets")
    public String pets(HttpSession session, Model model) throws Exception {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            return "redirect:/login?redirect=/mypage/pets";
        }
        List<PetProfileVO> petList = petProfileService.getPetList(member.getMemberNo());
        model.addAttribute("petList", petList);
        // 2026/07/11 장우철 — 수정 모달용 JSON (이름 특수문자 안전)
        model.addAttribute("petListJson", objectMapper.writeValueAsString(petList));
        return "mypage/pets";
    }

    // 2026/07/11 장우철 — 등록·수정 (모달 Ajax)
    // 2026/08/11 장우철 — petPhoto(대표사진) Multipart 연동
    @PostMapping("/pets/save")
    @ResponseBody
    public Map<String, Object> savePet(PetProfileVO vo,
                                       @RequestParam(value = "petPhoto", required = false) MultipartFile petPhoto,
                                       HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        boolean isNew = vo.getPetId() == null;
        String err = petProfileService.savePet(vo, member.getMemberNo(), petPhoto);
        if (err != null) {
            result.put("success", false);
            result.put("message", err);
            return result;
        }
        result.put("success", true);
        result.put("message", isNew ? "반려동물이 등록되었습니다." : "반려동물 정보가 수정되었습니다.");
        return result;
    }

    // 2026/07/11 장우철 — 삭제 (모달/카드 Ajax)
    @PostMapping("/pets/delete")
    @ResponseBody
    public Map<String, Object> deletePet(@RequestParam("petId") Long petId, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null || member.getMemberNo() == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }

        String err = petProfileService.deletePet(petId, member.getMemberNo());
        if (err != null) {
            result.put("success", false);
            result.put("message", err);
            return result;
        }
        result.put("success", true);
        result.put("message", "반려동물을 삭제했습니다.");
        return result;
    }
}
