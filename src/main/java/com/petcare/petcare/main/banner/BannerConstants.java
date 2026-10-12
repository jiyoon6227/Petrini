package com.petcare.petcare.main.banner;

public final class BannerConstants {

    /** 노출 위치(POSITION_CD)별 최대 배너 수 */
    public static final int MAX_PER_POSITION = 5;

    /** 위치별 최대 배너 수 (메인 중간은 1개만) */
    public static int getMaxPerPosition(String positionCd) {
        if ("MAIN_MID".equals(positionCd)) {
            return 1;
        }
        return MAX_PER_POSITION;
    }

    /** 관리자 배너 관리 — 대분류 카테고리 */
    public static final String CATEGORY_MAIN = "main";
    public static final String CATEGORY_STAY = "stay";
    public static final String CATEGORY_STORE = "store";
    public static final String CATEGORY_HOSPITAL = "hospital";

    private BannerConstants() {
    }

    // 관리자 대분류 탭 ↔ POSITION_CD 매핑
    public static boolean matchesAdminCategory(String positionCd, String category) {
        if (positionCd == null || category == null) {
            return false;
        }
        return switch (category) {
            case CATEGORY_MAIN -> "MAIN_HERO".equals(positionCd) || "MAIN_MID".equals(positionCd);
            case CATEGORY_STAY -> "STAY".equals(positionCd);
            case CATEGORY_STORE -> "STORE".equals(positionCd);
            case CATEGORY_HOSPITAL -> "HOSPITAL".equals(positionCd);
            default -> false;
        };
    }
}
