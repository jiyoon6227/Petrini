/**
 * 역할: 마이페이지 사업자 신청·관리 비즈니스 로직 (interface)
 *
 * 담당 화면
 * - mypage/biz.jsp            사업자 관리
 * - mypage/biz/apply.jsp      사업자 신청
 *
 * 구현할 기능 예시
 * - 사업자 신청 등록
 * - 사업자 유형별 대시보드 리다이렉트
 *
 * 연결
 * - 구현: MypageBizServiceImpl
 * - 호출: MypageBizController
 * - DB: MypageBizMapper
 *
 * 참고 테이블
 * - TB_BUSINESS
 */

package com.petcare.petcare.mypage.biz.service;

import java.util.List;

import com.petcare.petcare.biz.vo.BusinessVO;
import com.petcare.petcare.file.vo.FileVO;

public interface MypageBizService {
    public void applyBusiness(BusinessVO vo, List<FileVO> fileList) throws Exception;
    public BusinessVO getBizAuthStatus(String bizId) throws Exception;
    public boolean checkBizRegNo(String bizRegNo) throws Exception;
}
