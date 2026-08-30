/**
 * 역할: MypagePointService 구현체 (@Service)
 *
 * 구현 내용
 * - Controller에서 넘어온 요청 처리
 * - Mapper 호출하여 DB 조회·수정
 * - 비즈니스 규칙 검증 및 결과 반환
 *
 * 연결
 * - implements: MypagePointService
 * - 사용: MypagePointMapper
 *
 * 비즈니스 로직은 여기에 작성 (Controller, Mapper에 직접 작성 X)
 */

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
