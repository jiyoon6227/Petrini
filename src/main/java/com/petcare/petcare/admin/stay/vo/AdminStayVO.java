/**
 * 역할: 관리자 숙소 관리 목록·상세 VO
 * 2026/08/13 장우철
 */
package com.petcare.petcare.admin.stay.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AdminStayVO {
    private Long stayId;
    private Long bizNo;
    private String bizName;
    private String name;
    private String phone;
    private String addr;
    private String addrDetail;
    private String region;
    private String statusCd;
    private String approveDate;
    private String checkIn;
    private String checkOut;
    private String thumbPath;
    private Integer minPrice;
    private Integer roomCount;
    private Integer approveRoomCount;
    private Integer holdRoomCount;
    private Integer closedRoomCount;
}
