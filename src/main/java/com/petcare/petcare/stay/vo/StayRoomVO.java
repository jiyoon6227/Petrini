package com.petcare.petcare.stay.vo;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class StayRoomVO {
    private Long   roomId;
    private Long   stayId;
    private String name;
    private int    pricePerNight;
    private int    capacity;
    private int    petLimit;
    private String statusCd;
    private String rejectReason;    
}
