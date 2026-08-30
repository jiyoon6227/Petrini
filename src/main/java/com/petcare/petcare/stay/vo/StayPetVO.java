package com.petcare.petcare.stay.vo;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter

public class StayPetVO {
    private Long    petId;
    private String  petName;
    private String  species;
    private String  breed;
    private Integer age;    
}
