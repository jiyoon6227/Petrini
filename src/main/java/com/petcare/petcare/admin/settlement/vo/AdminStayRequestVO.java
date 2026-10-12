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
