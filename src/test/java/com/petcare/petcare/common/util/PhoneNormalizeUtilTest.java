package com.petcare.petcare.common.util;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

/** 휴대전화 형식 검사 */
class PhoneNormalizeUtilTest {

    @Test
    void 하이픈_있는_11자리는_통과() {
        assertTrue(PhoneNormalizeUtil.isValidMobile("010-1234-5678"));
    }

    @Test
    void 숫자만_11자리도_통과() {
        assertTrue(PhoneNormalizeUtil.isValidMobile("01012345678"));
    }

    @Test
    void 열자리는_실패() {
        assertFalse(PhoneNormalizeUtil.isValidMobile("010-1234-567"));
        assertFalse(PhoneNormalizeUtil.isValidMobile("0101234567"));
    }

    @Test
    void 휴대전화_아닌_번호는_실패() {
        assertFalse(PhoneNormalizeUtil.isValidMobile("020-1234-5678"));
        assertFalse(PhoneNormalizeUtil.isValidMobile("012-1234-5678"));
    }

    @Test
    void 빈값은_실패() {
        assertFalse(PhoneNormalizeUtil.isValidMobile(null));
        assertFalse(PhoneNormalizeUtil.isValidMobile(" "));
    }
}
