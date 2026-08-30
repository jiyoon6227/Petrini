/**
 * 역할: 관리자 숙소 중간정산 요청 목록용 VO
 * 2026/07/30 장우철 — 숙소 정산 구현순서 4-3
 *
 * TB_SETTLEMENT_REQUEST + TB_BUSINESS(+객실명) JOIN
 */
package com.petcare.petcare.admin.settlement.vo;

import java.util.Date;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class AdminStayRequestVO {

    private Long requestId;
    private Long bizNo;
    private String bizName;
    private String requestScope;   // ALL / ROOM
    private Long roomId;
    private String roomName;
    private Date targetStart;
    private Date targetEnd;
    private String statusCd;       // REQUESTED / APPROVED / REJECTED / CANCELED
    private String requestMemo;
    private String rejectReason;
    private Date requestedAt;
    private Date approvedAt;
    private Date rejectedAt;
}
