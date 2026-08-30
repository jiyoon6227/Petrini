package com.petcare.petcare.pet.vo;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

import org.springframework.stereotype.Component;

@Getter @Setter
@Component("petVO")
public class PetVO {

    private Long   petId;
    private Long   memberId;        // FK → member
    private String petName;         // 이름
    private String petType;         // DOG / CAT / ETC
    private String breed;           // 품종
    private Integer age;            // 나이
    private Double  weight;         // 몸무게 (kg)
    private String photoUrl;        // S3 URL
    private LocalDateTime createdAt;
}
