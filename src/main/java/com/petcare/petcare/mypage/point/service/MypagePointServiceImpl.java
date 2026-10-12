package com.petcare.petcare.mypage.point.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.petcare.petcare.mypage.point.mapper.MypagePointMapper;
import com.petcare.petcare.mypage.point.vo.MypagePointVO;

@Service
public class MypagePointServiceImpl implements MypagePointService {

    @Autowired
    private MypagePointMapper mypagePointMapper;

    @Override
    public int getPointBalance(Long memberNo) {
        return mypagePointMapper.selectPointBalance(memberNo);
    }

    @Override
    public int getThisMonthEarnedPoint(Long memberNo) {
        return mypagePointMapper.selectThisMonthEarnedPoint(memberNo);
    }

    @Override
    public List<MypagePointVO> getPointHistory(Long memberNo) {
        return mypagePointMapper.selectPointHistory(memberNo);
    }
}
