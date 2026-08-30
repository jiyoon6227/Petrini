/**
 * 역할: 마이페이지 배송지록 URL 처리 (AJAX 전용, JSON 응답)
 * 지윤 26.07.29 추가: 주문서(order.jsp)의 "배송지 목록" 모달에서 호출
 */
package com.petcare.petcare.mypage.address.controller;

import java.util.List;

import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.petcare.petcare.member.vo.MemberVO;
import com.petcare.petcare.mypage.address.service.MypageAddressService;
import com.petcare.petcare.mypage.address.vo.MypageAddressVO;

@Controller
@RequestMapping("/mypage/address")
public class MypageAddressController {

    @Autowired
    private MypageAddressService mypageAddressService;

    //지윤 26.07.29 추가: 배송지 목록 조회 (AJAX)
    @GetMapping("/list")
    @ResponseBody
    public List<MypageAddressVO> list(HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return java.util.List.of();
        return mypageAddressService.getAddressList(member.getMemberNo());
    }

    //지윤 26.07.29 추가: 배송지 신규 등록 (AJAX)
    @PostMapping("/add")
    @ResponseBody
    public String add(@RequestParam String recvName, @RequestParam String recvPhone,
                       @RequestParam String zipCode, @RequestParam String addr1,
                       @RequestParam(required = false) String addr2,
                       @RequestParam(defaultValue = "false") boolean setDefault,
                       HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "LOGIN_REQUIRED";
        mypageAddressService.addAddress(member.getMemberNo(), recvName, recvPhone, zipCode, addr1, addr2, setDefault);
        return "OK";
    }

    //지윤 26.07.29 추가: 배송지를 기본배송지로 선택 (AJAX)
    @PostMapping("/select")
    @ResponseBody
    public String select(@RequestParam Long addrId, HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "LOGIN_REQUIRED";
        boolean ok = mypageAddressService.selectAsDefault(addrId, member.getMemberNo());
        return ok ? "OK" : "FAILED";
    }

    //지윤 26.07.29 추가: 배송지 수정 (AJAX)
    @PostMapping("/update")
    @ResponseBody
    public String update(@RequestParam Long addrId, @RequestParam String recvName, @RequestParam String recvPhone,
                          @RequestParam String zipCode, @RequestParam String addr1,
                          @RequestParam(required = false) String addr2, HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "LOGIN_REQUIRED";
        boolean ok = mypageAddressService.updateAddress(addrId, member.getMemberNo(), recvName, recvPhone, zipCode, addr1, addr2);
        return ok ? "OK" : "FAILED";
    }

    //지윤 26.07.29 추가: 배송지 삭제 (AJAX)
    @PostMapping("/delete")
    @ResponseBody
    public String delete(@RequestParam Long addrId, HttpSession session) {
        MemberVO member = (MemberVO) session.getAttribute("memberInfo");
        if (member == null) return "LOGIN_REQUIRED";
        boolean ok = mypageAddressService.deleteAddress(addrId, member.getMemberNo());
        return ok ? "OK" : "FAILED";
    }
}