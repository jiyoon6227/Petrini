package com.petcare.petcare.give.vo;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.JsonNode;

import lombok.Getter;
import lombok.Setter;

/*
 * 농림축산식품부 유기동물 공공API 응답 VO
 * API: https://apis.data.go.kr/1543061/abandonmentPublicService_v2/abandonmentPublic_v2
 *
 * 2026-07-06 박유정 — API v2 필드(upKindCd·kindNm·kindFullNm) 및 종/품종 파싱
 */

@Component("abandonmentVO")
@Getter @Setter
public class AbandonmentVO {

    private String desertionNo;    // 유기번호 (공고번호)
    private String filename;       // 이미지 URL
    private String happenDt;       // 접수일 (YYYYMMDD)
    private String happenPlace;    // 발견 장소
    private String kindCd;         // 품종 코드 (ex: "000114")
    private String upKindCd;       // 축종 코드 (개:417000, 고양이:422400, 기타:429900)
    private String kindNm;         // 품종명 (ex: "믹스견")
    private String kindFullNm;     // 종+품종 (ex: "[개] 믹스견")
    private String colorCd;        // 색상
    private String age;            // 나이 (ex: "2023(년생)")
    private String weight;         // 체중 (ex: "8.0(Kg)")
    private String noticeNo;       // 공고번호
    private String noticeSdt;      // 공고 시작일
    private String noticeEdt;      // 공고 종료일
    private String popfile1;        // 썸네일 이미지 URL
    private String popfile2;        // 썸네일 이미지 URL
    private String processState;   // 상태 (보호중, 공고중 등)
    private String sexCd;          // 성별 (M:수컷 F:암컷 Q:미상)
    private String neuterYn;       // 중성화 (Y/N/U)
    private String specialMark;    // 특징
    private String careNm;         // 보호소 이름
    private String careTel;        // 보호소 전화번호
    private String careAddr;       // 보호소 주소
    private String orgNm;          // 관할기관 (시도군)
    private String chargeNm;       // 담당자
    private String officetel;      // 담당자 전화
    private int    dday;           // D-day 계산 (컨트롤러에서 세팅)

    /** 성별 한글 변환 */
    public String getSexLabel() {
        if ("M".equals(sexCd)) return "수컷";
        if ("F".equals(sexCd)) return "암컷";
        return "미상";
    }

    /** 중성화 한글 변환 */
    public String getNeuterLabel() {
        if ("Y".equals(neuterYn)) return "완료";
        if ("N".equals(neuterYn)) return "미완료";
        return "미상";
    }

    /** 동물 종류: v2 API는 upKindCd 로 구분 */
    public String getSpecies() {
        if ("417000".equals(upKindCd)) return "개";
        if ("422400".equals(upKindCd)) return "고양이";
        if ("429900".equals(upKindCd)) return "기타";

        String src = (kindFullNm != null && !kindFullNm.isBlank()) ? kindFullNm : kindCd;
        if (src == null || src.isBlank()) return "";
        if (src.contains("[개]"))     return "개";
        if (src.contains("[고양이]")) return "고양이";
        return "기타";
    }

    /** 품종명만 추출 */
    public String getBreedName() {
        if (kindNm != null && !kindNm.isBlank()) return kindNm;

        String src = (kindFullNm != null && !kindFullNm.isBlank()) ? kindFullNm : kindCd;
        if (src == null || src.isBlank()) return "";
        int idx = src.indexOf(']');
        return idx >= 0 ? src.substring(idx + 1).trim() : src;
    }

    /** 공고 종료일 포맷 변환: "20250629" → "2025.06.29" */
    public String getNoticeEdtFormatted() {
        if (noticeEdt == null || noticeEdt.length() < 8) return noticeEdt;
        return noticeEdt.substring(0,4) + "." + noticeEdt.substring(4,6) + "." + noticeEdt.substring(6,8);
    }

    public static AbandonmentVO parseItem(JsonNode item, DateTimeFormatter fmt) {
        AbandonmentVO vo = new AbandonmentVO();
        vo.setDesertionNo (item.path("desertionNo").asText(""));
        vo.setFilename    (item.path("filename").asText(""));
        vo.setPopfile1     (item.path("popfile1").asText(""));
        vo.setPopfile2     (item.path("popfile2").asText(""));
        vo.setHappenDt    (item.path("happenDt").asText(""));
        vo.setHappenPlace (item.path("happenPlace").asText(""));
        vo.setKindCd      (item.path("kindCd").asText(""));
        // 2026-07-06 박유정 — v2 API 축종·품종 필드 매핑
        vo.setUpKindCd    (item.path("upKindCd").asText(""));
        vo.setKindNm      (item.path("kindNm").asText(""));
        vo.setKindFullNm  (item.path("kindFullNm").asText(""));
        vo.setColorCd     (item.path("colorCd").asText(""));
        vo.setAge         (item.path("age").asText(""));
        vo.setWeight      (item.path("weight").asText(""));
        vo.setNoticeNo    (item.path("noticeNo").asText(""));
        vo.setNoticeSdt   (item.path("noticeSdt").asText(""));
        vo.setNoticeEdt   (item.path("noticeEdt").asText(""));
        vo.setProcessState(item.path("processState").asText(""));
        vo.setSexCd       (item.path("sexCd").asText(""));
        vo.setNeuterYn    (item.path("neuterYn").asText(""));
        vo.setSpecialMark (item.path("specialMark").asText(""));
        vo.setCareNm      (item.path("careNm").asText(""));
        vo.setCareTel     (item.path("careTel").asText(""));
        vo.setCareAddr    (item.path("careAddr").asText(""));
        vo.setOrgNm       (item.path("orgNm").asText(""));
        vo.setChargeNm    (item.path("chargeNm").asText(""));
        vo.setOfficetel   (item.path("officetel").asText(""));
        
        // D-day 계산
        String edt = vo.getNoticeEdt();
        if (edt != null && edt.length() == 8) {
            try {
                long days = ChronoUnit.DAYS.between(LocalDate.now(), LocalDate.parse(edt, fmt));
                vo.setDday((int) days);
            } catch (Exception ignore) {}
        }
        return vo;
    }
}
