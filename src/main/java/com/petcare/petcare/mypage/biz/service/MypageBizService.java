package com.petcare.petcare.mypage.biz.service;

import java.util.List;

import com.petcare.petcare.biz.vo.BusinessVO;
import com.petcare.petcare.file.vo.FileVO;

public interface MypageBizService {
    public void applyBusiness(BusinessVO vo, List<FileVO> fileList) throws Exception;
    public BusinessVO getBizAuthStatus(String bizId) throws Exception;
    public boolean checkBizRegNo(String bizRegNo) throws Exception;
}
