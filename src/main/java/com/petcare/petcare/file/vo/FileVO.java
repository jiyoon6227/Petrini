package com.petcare.petcare.file.vo;

import lombok.Getter;
import lombok.Setter;
import java.util.Date;

@Getter @Setter
public class FileVO {
    private Long   fileId;
    private String refType;    // HOSPITAL / MEMBER / GROOMING 등
    private Long   refId;      // 각 도메인 PK
    private String driveFileId;   // 
    private String fileUrl;   // 저장 경로 (upload/hospital/1/main.jpg)
    private String originName;   
    //private int    fileOrder;  // 0 = 대표이미지
    private Date   regDate;        
}
