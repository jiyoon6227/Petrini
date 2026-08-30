/**
 * 2026/08/11 장우철 — 휴대전화 숫자만/하이픈 혼용 → 010-1234-5678 정규화
 */
package com.petcare.petcare.common.util;

public final class PhoneNormalizeUtil {

    private PhoneNormalizeUtil() {
    }

    /** 숫자만 추출 후 3-4-나머지 하이픈. 형식이 아니면 원문 반환 */
    public static String toHyphenPhone(String phone) {
        if (phone == null || phone.isBlank()) {
            return phone;
        }
        String digits = phone.replaceAll("[^0-9]", "");
        if (digits.length() >= 10 && digits.length() <= 11) {
            return digits.substring(0, 3) + "-"
                    + digits.substring(3, 7) + "-"
                    + digits.substring(7);
        }
        return phone.trim();
    }
}
