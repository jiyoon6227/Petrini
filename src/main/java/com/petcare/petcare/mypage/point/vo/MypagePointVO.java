/**
 * 역할: 마이페이지 포인트 데이터 객체
 *
 * 필드 예시
 * - memberId, balance, pointAmount, pointType, createdAt
 *
 * 참고 테이블
 * - TB_POINT
 * - TB_POINT_HISTORY
 *
 * DB 컬럼명은 팀 VO 규칙(camelCase)에 맞게 작성
 */

package com.petcare.petcare.mypage.point.vo;

public class MypagePointVO {

    private Long pointId;
    private String regDate;      //지윤 26.07.29: 화면 "날짜" 컬럼 (YYYY-MM-DD)
    private String content;      //지윤 26.07.29: 화면 "내용" 컬럼 - REASON_CD를 사람이 읽을 문구로 변환한 것
    private String pointType;    //지윤 26.07.29: EARN(적립) / REFUND(차감 아님, 환불복구) - 화면 "구분" 뱃지용
    private Integer pointAmount;

    public Long getPointId() { return pointId; }
    public void setPointId(Long pointId) { this.pointId = pointId; }
    public String getRegDate() { return regDate; }
    public void setRegDate(String regDate) { this.regDate = regDate; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getPointType() { return pointType; }
    public void setPointType(String pointType) { this.pointType = pointType; }
    public Integer getPointAmount() { return pointAmount; }
    public void setPointAmount(Integer pointAmount) { this.pointAmount = pointAmount; }
}
