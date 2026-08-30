/**
 * 역할: TB_MEDICAL_RECORD.MEMO 보조 태그 파싱
 *
 * 2026-07-28 박유정 — 사업자 저장 형식 [유형:...] [체중:...] 등을 VO 필드로 분리
 */

package com.petcare.petcare.hospital.util;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.petcare.petcare.hospital.vo.MedicalRecordVO;

public final class MedicalRecordMemoParser {

    private static final Pattern TAG_TREAT = Pattern.compile("\\[유형:([^\\]]+)\\]");
    private static final Pattern TAG_WEIGHT = Pattern.compile("\\[체중:([^\\]]+?)kg\\]");
    private static final Pattern TAG_TEMP = Pattern.compile("\\[체온:([^\\]]+?)℃\\]");
    private static final Pattern TAG_HR = Pattern.compile("\\[심박:([^\\]]+?)bpm\\]");
    private static final Pattern TAG_BR = Pattern.compile("\\[호흡:([^\\]]+?)회/분\\]");
    private static final Pattern TAG_EXAM = Pattern.compile("\\[검사:([^\\]]+)\\]");
    private static final Pattern TAG_NEXT = Pattern.compile("\\[다음방문:([^\\]]+)\\]");
    private static final Pattern ALL_TAGS = Pattern.compile(
            "\\[(?:유형|체중|체온|심박|호흡|검사|다음방문):[^\\]]*\\]\\s*");

    private MedicalRecordMemoParser() {
    }

    /** MEMO 앞쪽 보조 태그를 VO 필드로 분리하고, 순수 수의사 메모만 남김 */
    public static void parse(MedicalRecordVO record) {
        if (record == null) {
            return;
        }
        String raw = record.getMemo();
        if (raw == null || raw.isBlank()) {
            return;
        }
        record.setTreatType(firstGroup(TAG_TREAT, raw));
        record.setWeight(firstGroup(TAG_WEIGHT, raw));
        record.setTemperature(firstGroup(TAG_TEMP, raw));
        record.setHeartRate(firstGroup(TAG_HR, raw));
        record.setBreathRate(firstGroup(TAG_BR, raw));
        record.setExamItems(firstGroup(TAG_EXAM, raw));
        record.setNextVisit(firstGroup(TAG_NEXT, raw));

        String free = ALL_TAGS.matcher(raw).replaceAll("").trim();
        record.setMemo(free.isEmpty() ? null : free);
    }

    private static String firstGroup(Pattern p, String text) {
        Matcher m = p.matcher(text);
        return m.find() ? m.group(1).trim() : null;
    }
}
