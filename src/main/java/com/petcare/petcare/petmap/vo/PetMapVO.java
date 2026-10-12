package com.petcare.petcare.petmap.vo;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.JsonNode;
import com.petcare.petcare.common.external.service.Mapperable;

import lombok.Getter;
import lombok.Setter;

@JsonIgnoreProperties(ignoreUnknown = true)
@Component("petMapVO")
@Getter @Setter
public class PetMapVO implements Mapperable {
    private String addr1;
    private String addr2;

    private String contentid;
    private String contenttypeid;

    private String title;

    private String mapx;
    private String mapy;

    private String firstimage;
    private String firstimage2;

    private String tel;

    private String zipcode;

    private String createdtime;
    private String modifiedtime;

    @Override
    public String getMarkerId()   { return contentid; }
    @Override
    public String getMarkerName() { return title; }
    @Override
    public Double getMarkerLat() {
        return (mapy != null && !mapy.isEmpty()) ? Double.parseDouble(mapy) : null;
    }
    @Override
    public Double getMarkerLng() {
        return (mapx != null && !mapx.isEmpty()) ? Double.parseDouble(mapx) : null;
    }

    public static PetMapVO parseItem(JsonNode item) {
        PetMapVO vo = new PetMapVO();
        vo.setAddr1 (item.path("addr1").asText(""));
        vo.setAddr2 (item.path("addr2").asText(""));
        vo.setContentid (item.path("contentid").asText(""));
        vo.setContenttypeid (item.path("contenttypeid").asText(""));
        vo.setTitle (item.path("title").asText(""));
        vo.setMapx (item.path("mapx").asText(""));
        vo.setMapy (item.path("mapy").asText(""));
        vo.setFirstimage (item.path("firstimage").asText(""));
        vo.setFirstimage2 (item.path("firstimage2").asText(""));
        vo.setTel (item.path("tel").asText(""));
        vo.setZipcode (item.path("zipcode").asText(""));
        vo.setCreatedtime (item.path("createdtime").asText(""));
        vo.setModifiedtime (item.path("modifiedtime").asText(""));
        return vo;
    }
}
