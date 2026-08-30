/**
 * 역할: MypageBizService 구현체 (@Service)
 */

package com.petcare.petcare.mypage.biz.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.biz.vo.BusinessVO;
import com.petcare.petcare.file.mapper.FileMapper;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.mypage.biz.mapper.MypageBizMapper;

@Service
public class MypageBizServiceImpl implements MypageBizService {

    @Autowired
    private MypageBizMapper mypageBizMapper;

    @Autowired
    private FileMapper fileMapper;

    // 2026-07-09 장우철 — [변경 후] 최초 INSERT / 반려 후 재신청 UPDATE 분기
    // 이유: UK(BIZ_ID, BIZ_REG_NO) — 재신청은 TB_BUSINESS UPDATE + TB_BUSINESS_AUTH INSERT
    @Override
    @Transactional
    public void applyBusiness(BusinessVO vo, List<FileVO> fileList) throws Exception {

        if (mypageBizMapper.countActiveBizRegNo(vo.getBizRegNo(), vo.getBizId()) > 0) {
            throw new IllegalStateException("BIZ_REG_NO_DUPLICATE");
        }

        BusinessVO existing = mypageBizMapper.selectBusinessByBizId(vo.getBizId());

        if (existing == null) {
            mypageBizMapper.insertBusiness(vo);
            mypageBizMapper.insertBusinessAuth(vo);
        } else if ("REJECTED".equals(existing.getStatusCd())) {
            vo.setBizNo(existing.getBizNo());
            int updated = mypageBizMapper.updateBusinessForReapply(vo);
            if (updated != 1) {
                throw new IllegalStateException("BIZ_REAPPLY_FAILED");
            }
            mypageBizMapper.insertBusinessAuth(vo);
            replaceBizFiles(vo.getBizNo(), fileList);
            return;
        } else if ("PENDING".equals(existing.getStatusCd())) {
            throw new IllegalStateException("BIZ_ALREADY_PENDING");
        } else {
            throw new IllegalStateException("BIZ_ALREADY_APPROVED");
        }

        for (FileVO fv : fileList) {
            fv.setRefId(vo.getBizNo());
            fileMapper.insertFile(fv);
        }

        /* [변경 전] 2026-07-09 장우철 — 항상 INSERT 만 수행 (재신청 시 UK 위반)
        mypageBizMapper.insertBusiness(vo);
        mypageBizMapper.insertBusinessAuth(vo);
        for (FileVO fv : fileList) { ... }
        */
    }

    // 2026-07-09 장우철 — 재신청 시 기존 제출 서류 교체
  private void replaceBizFiles(Long bizNo, List<FileVO> fileList) throws Exception {
        FileVO delAuth = new FileVO();
        delAuth.setRefType("BIZ_AUTH");
        delAuth.setRefId(bizNo);
        fileMapper.deleteFilesByRefId(delAuth);

        FileVO delLicense = new FileVO();
        delLicense.setRefType("BIZ_LICENSE");
        delLicense.setRefId(bizNo);
        fileMapper.deleteFilesByRefId(delLicense);

        for (FileVO fv : fileList) {
            fv.setRefId(bizNo);
            fileMapper.insertFile(fv);
        }
    }

    @Override
    public BusinessVO getBizAuthStatus(String bizId) throws Exception {
        return mypageBizMapper.selectBizAuthStatus(bizId);
    }

    @Override
    public boolean checkBizRegNo(String bizRegNo) throws Exception {
        if (mypageBizMapper.countBizRegNo(bizRegNo) <= 0) {
            return true;
        }
        return false;
    }
}
