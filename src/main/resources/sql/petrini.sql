/* =========================================================
   DATABASE_TABLE.sql
   프로젝트: petcare
   ========================================================= */


-- 순서: 1.DROP  2.CREATE  3.FK  4.COMMENT

SET DEFINE OFF;

-- =========================================================
-- 2026/07/21 장우철 — 미사용 테이블 정리 (팀 확인용)
-- 제외 대상 CREATE / FK / COMMENT 는 주석 처리
-- DROP 은 유지 (기존 DB 정리용). 팀 확인 후 DROP 도 주석 예정
-- 제외: PET_HEALTH, STATUS_HIST, SYSTEM_POLICY, AUTH_VERIFY,
--       PRODUCT_APPROVAL, EXPERIENCE_*, PROMOTION, POI*, SHELTER,
--       PUBLIC_DATA_SYNC, DONATION, VOLUNTEER*, WALK_*
-- =========================================================

-- ==================== 1. DROP TABLE ====================

-- 2026/07/13 장우철 — 유저↔사업자 신고 (TB_POST_REPORT 와 별개, 자식 테이블 먼저 DROP)
-- TB_REVIEW_REPORT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_REVIEW_REPORT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 2026/07/13 유정 — 재능나눔 (TB_POST.SHARE 와 별개, TB_BUSINESS FK 자식)
-- TB_TALENT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_TALENT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_REVIEW
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_REVIEW CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_EXPERIENCE_APPLY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_EXPERIENCE_APPLY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_EXPERIENCE_GROUP
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_EXPERIENCE_GROUP CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_POST_COMMENT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_POST_COMMENT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PAYMENT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PAYMENT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_ORDER_DELIVERY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_ORDER_DELIVERY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_ORDER_ITEM
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_ORDER_ITEM CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_ORDER
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_ORDER CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_CART_ITEM
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_CART_ITEM CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PRODUCT_QNA
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PRODUCT_QNA CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PRODUCT_APPROVAL
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PRODUCT_APPROVAL CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PRODUCT_OPTION
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PRODUCT_OPTION CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PRODUCT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PRODUCT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PRODUCT_CATEGORY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PRODUCT_CATEGORY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
-- 2026/07/29 장우철
-- 정산 상세
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_SETTLEMENT_ITEM CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 정산 마스터
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_SETTLEMENT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 중간정산 요청
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_SETTLEMENT_REQUEST CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_MEDICAL_RECORD
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_MEDICAL_RECORD CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_WALK_REWARD_HIST
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_WALK_REWARD_HIST CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 2026/07/16 장우철 고도화작업 — 예약 임시 선점 (RESERVATION보다 먼저 DROP)
-- TB_HOSPITAL_RESV_HOLD
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_HOSPITAL_RESV_HOLD CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_RESERVATION
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_RESERVATION CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 2026/07/15 장우철 고도화작업 — 진료유형·의사 (RESERVATION 뒤, HOSPITAL 앞 DROP)
-- 2026/07/16 장우철 고도화작업 — 예약규칙·예외 (의사보다 먼저 DROP)
-- TB_HOSPITAL_RESV_EXCEPTION
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_HOSPITAL_RESV_EXCEPTION CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 2026/07/16 장우철 고도화작업 — RESV_RULE 폐기(병원 HOURS_JSON·RESV_INTERVAL_MIN 으로 통합)
-- CREATE는 제거됨. 구 DB 정리용 DROP은 유지(나중에 직접 삭제)
-- TB_HOSPITAL_RESV_RULE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_HOSPITAL_RESV_RULE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_HOSPITAL_TREAT_TYPE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_HOSPITAL_TREAT_TYPE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_HOSPITAL_DOCTOR
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_HOSPITAL_DOCTOR CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_VOLUNTEER_APPLY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_VOLUNTEER_APPLY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_POST_REPORT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_POST_REPORT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_POST_LIKE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_POST_LIKE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_INQUIRY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_INQUIRY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_FAQ
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_FAQ CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
-- TB_NOTICE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_NOTICE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_WALK_MATE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_WALK_MATE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_WALK_RECORD
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_WALK_RECORD CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PET_HEALTH
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PET_HEALTH CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_AD
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_AD CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_STATUS_HIST
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_STATUS_HIST CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_CONTENT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_CONTENT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_POI_REQUEST
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_POI_REQUEST CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_ADMIN_LOG
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_ADMIN_LOG CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_BUSINESS_AUTH
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_BUSINESS_AUTH CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_STAY_ROOM (구 TB_LODGE_ROOM)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_STAY_ROOM CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_LODGE_ROOM CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- 2026/07/16 장우철 고도화작업 — 슬롯 폐기(규칙 방식으로 전환). 구 DB 잔여 테이블만 DROP
-- TB_RESERVATION_SLOT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_RESERVATION_SLOT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_VOLUNTEER
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_VOLUNTEER CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_DONATION
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_DONATION CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_POINT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_POINT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_POST
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_POST CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_MEMBER_COUPON
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_MEMBER_COUPON CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_CART
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_CART CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_FCM_TOKEN
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_FCM_TOKEN CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_NOTIFICATION
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_NOTIFICATION CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_FAVORITE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_FAVORITE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PET
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PET CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_MEMBER_ADDRESS
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_MEMBER_ADDRESS CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_MEMBER_AGREEMENT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_MEMBER_AGREEMENT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_MEMBER_SOCIAL
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_MEMBER_SOCIAL CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_BANNER
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_BANNER CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_WALK_COURSE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_WALK_COURSE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_ADMIN
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_ADMIN CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_AD_PAYMENT
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_AD_PAYMENT CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_STAY (구 TB_LODGE)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_STAY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_LODGE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_HOSPITAL
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_HOSPITAL CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_MEMBER
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_MEMBER CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_POLICY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_POLICY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PUBLIC_DATA_SYNC
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PUBLIC_DATA_SYNC CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_FILE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_FILE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_SHELTER
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_SHELTER CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_POI
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_POI CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_COUPON
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_COUPON CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_PROMOTION
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_PROMOTION CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_SYSTEM_POLICY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_SYSTEM_POLICY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_ADMIN_ROLE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_ADMIN_ROLE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_BUSINESS
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_BUSINESS CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_MEMBER_GRADE
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_MEMBER_GRADE CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_MEMBER_WITHDRAW
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_MEMBER_WITHDRAW CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
-- TB_AUTH_VERIFY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_AUTH_VERIFY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- TB_BILLING_CARD
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_BILLING_CARD CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
-- TB_REVIEW_DELETE_REQUEST
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_REVIEW_DELETE_REQUEST CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/
-- TB_TALENT_APPLY
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE TB_TALENT_APPLY CASCADE CONSTRAINTS PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN RAISE; END IF;
END;
/

-- ==================== 2. CREATE TABLE ====================

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_AUTH_VERIFY (인증코드)
-- CREATE TABLE TB_AUTH_VERIFY (
--     VERIFY_ID                        NUMBER                   NOT NULL,  -- 인증 ID
--     TARGET_TYPE                      VARCHAR2(10)             NOT NULL,  -- 대상 유형 (MEMBER/BUSINESS)
--     TARGET_NO                        NUMBER                   NOT NULL,  -- 대상 PK
--     VERIFY_TYPE                      VARCHAR2(10)             NOT NULL,  -- 인증 유형 (EMAIL/KAKAO)
--     TARGET_ADDR                      VARCHAR2(200)            NOT NULL,  -- 이메일 또는 전화
--     VERIFY_CODE                      VARCHAR2(6)              NOT NULL,  -- 인증코드
--     VERIFY_YN                        CHAR(1)                  NULL,  -- 인증완료
--     EXPIRE_DATE                      DATE                     NOT NULL,  -- 만료(5분)
--     REG_DATE                         DATE                     NOT NULL,  -- 발송일
--     CONSTRAINT PK_TB_AUTH_VERIFY PRIMARY KEY (VERIFY_ID)
-- );

-- TB_MEMBER_GRADE (회원등급)
CREATE TABLE TB_MEMBER_GRADE (
    GRADE_CD                         VARCHAR2(10)             NOT NULL,  -- 등급코드
    GRADE_NAME                       VARCHAR2(30)             NOT NULL,  -- 등급명
    MIN_POINT                        NUMBER                   NULL,  -- 최소포인트
    BENEFIT_DESC                     VARCHAR2(500)            NULL,  -- 혜택
    CONSTRAINT PK_TB_MEMBER_GRADE PRIMARY KEY (GRADE_CD)
);

-- TB_BUSINESS (사업자)
CREATE TABLE TB_BUSINESS (
    BIZ_NO                           NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,  -- 사업자번호
    BIZ_ID                           VARCHAR2(50)             NOT NULL,  -- 로그인 ID
    BIZ_TYPE                         VARCHAR2(10)             NOT NULL,  -- 사업자 유형 (HOSPITAL/STORE/STAY)
    BIZ_REG_NO                       VARCHAR2(12)             NOT NULL,  -- 사업자등록번호
    BIZ_NAME                         VARCHAR2(100)            NOT NULL,  -- 상호명
    CEO_NAME                         VARCHAR2(50)             NULL,  -- 대표자
    PHONE                            VARCHAR2(20)             NULL,  -- 연락처
    EMAIL                            VARCHAR2(100)            NULL,  -- 이메일
    ZIP_CODE                         VARCHAR2(10)             NULL,  -- 우편번호 [사업자 신청 주소]
    ADDR                             VARCHAR2(200)            NULL,  -- 기본주소 [사업자 신청 주소]
    ADDR_DETAIL                      VARCHAR2(200)            NULL,  -- 상세주소 [사업자 신청 주소]
    STATUS_CD                        VARCHAR2(10)             NOT NULL,  -- 상태코드 (PENDING/NORMAL/STOP/WITHDRAW)
    JOIN_DATE                        DATE                     NOT NULL,  -- 가입일
    APPROVE_DATE                     DATE                     NULL,  -- 승인일
    FEE_RATE                         NUMBER(5,2)              NULL,  -- 수수료율(%) [계약 정보 흡수]
    SETTLE_ACCOUNT                   VARCHAR2(50)             NULL,  -- 정산계좌 [계약 정보 흡수]
    SETTLE_BANK                      VARCHAR2(20)             NULL,  -- 은행 [계약 정보 흡수]
    -- 2026/07/28 장우철 — 금결원 계좌실명조회(정산계좌 인증)용 컬럼
    SETTLE_BANK_CODE                 VARCHAR2(3)              NULL,  -- 은행 표준코드(금결원 bank_code_std, 예: 088)
    SETTLE_HOLDER                    VARCHAR2(100)            NULL,  -- 예금주명(인증·표시용)
    SETTLE_VERIFY_YN                 CHAR(1)                  DEFAULT 'N' NULL,  -- 계좌실명인증 여부 (Y/N)
    SETTLE_VERIFY_DATE               DATE                     NULL,  -- 계좌실명인증 성공 일시
    ANNUAL_FEE                       NUMBER                   NULL,  -- 연회비(병원) [계약 정보 흡수]
    START_DATE                       DATE                     NULL,  -- 시작 [계약 정보 흡수]
    END_DATE                         DATE                     NULL,  -- 종료 [계약 정보 흡수]
    SHOP_NAME                        VARCHAR2(200)            NULL,  -- 펫샵명 (BIZ_TYPE=SHOP) [펫샵 통합]
    CONSTRAINT PK_TB_BUSINESS PRIMARY KEY (BIZ_NO),
    CONSTRAINT UK_TB_BUSINESS_1 UNIQUE (BIZ_ID),
    CONSTRAINT UK_TB_BUSINESS_2 UNIQUE (BIZ_REG_NO)
);

-- TB_ADMIN_ROLE (관리자권한그룹)
CREATE TABLE TB_ADMIN_ROLE (
    ROLE_ID                          NUMBER                   NOT NULL,  -- 역할ID
    ROLE_NAME                        VARCHAR2(200)            NULL,  -- 역할명
    ROLE_DESC                        VARCHAR2(200)            NULL,  -- 역할DESC
    USE_YN                           VARCHAR2(200)            NULL,  -- 여부
    MENU_PERMS                       CLOB                     NULL,  -- 메뉴 권한 JSON (ROLE_MENU 통합)
    CONSTRAINT PK_TB_ADMIN_ROLE PRIMARY KEY (ROLE_ID)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_SYSTEM_POLICY (운영정책)
-- CREATE TABLE TB_SYSTEM_POLICY (
--     POLICY_ID                        NUMBER                   NOT NULL,  -- 정책 ID
--     POLICY_KEY                       VARCHAR2(200)            NULL,  -- 정책 키
--     POLICY_VALUE                     VARCHAR2(200)            NULL,  -- 정책 값
--     UPD_DATE                         VARCHAR2(200)            NULL,  -- 수정일
--     CONSTRAINT PK_TB_SYSTEM_POLICY PRIMARY KEY (POLICY_ID)
-- );

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_PROMOTION (기획전)
-- CREATE TABLE TB_PROMOTION (
--     PROMO_ID                         NUMBER                   NOT NULL,  -- 기획전 ID
--     PROMO_NAME                       VARCHAR2(200)            NULL,  -- PROMO명
--     START_DATE                       VARCHAR2(200)            NULL,  -- 시작일
--     END_DATE                         VARCHAR2(200)            NULL,  -- 종료일
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     PRODUCT_IDS                      CLOB                     NULL,  -- 기획전 상품 ID JSON
--     CONSTRAINT PK_TB_PROMOTION PRIMARY KEY (PROMO_ID)
-- );

-- TB_COUPON (쿠폰)
CREATE TABLE TB_COUPON (
    COUPON_ID                        NUMBER                   NOT NULL,  -- 쿠폰 ID
    COUPON_CODE                      VARCHAR2(100)            NOT NULL,  -- 쿠폰CODE
    COUPON_NAME                      VARCHAR2(200)            NULL,  -- 쿠폰명
    COUPON_TYPE                      VARCHAR2(200)            NULL,  -- 쿠폰유형
    DISCOUNT_VALUE                   NUMBER                   NULL,  -- 할인값
    MIN_ORDER_AMT                    NUMBER                   NULL,  -- MIN주문AMT
    STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
    TOTAL_BUDGET                     NUMBER         DEFAULT 0,
    ISSUED_BUDGET                    NUMBER         DEFAULT 0,
    TOTAL_QTY                        NUMBER         DEFAULT 0,
    ISSUED_QTY                       NUMBER         DEFAULT 0,
    USE_START_DATE                   VARCHAR2(8),
    USE_END_DATE                     VARCHAR2(8),
    BIZ_MEMBER_NO                    NUMBER,
    APPROVAL_STATUS                  VARCHAR2(20)   DEFAULT 'PENDING',
    REJECT_REASON                    VARCHAR2(500),
    APPROVAL_DATE                    VARCHAR2(8),
    REG_DATE                         VARCHAR2(14),
    MOD_DATE                         VARCHAR2(14),
    BIZ_NO                           NUMBER                   NULL,
    MAX_DISCOUNT_AMT 	NUMBER 		NULL,
    CONSTRAINT PK_TB_COUPON PRIMARY KEY (COUPON_ID),
    CONSTRAINT UK_TB_COUPON_1 UNIQUE (COUPON_CODE)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_POI (POI장소)
-- CREATE TABLE TB_POI (
--     POI_ID                           NUMBER                   NOT NULL,  -- 장소 ID
--     CATEGORY_ID                      NUMBER                   NOT NULL,  -- 카테고리 ID
--     POI_NAME                         VARCHAR2(200)            NULL,  -- 장소명
--     ADDR                             VARCHAR2(200)            NULL,  -- 주소
--     LAT                              VARCHAR2(200)            NULL,  -- 위도
--     LNG                              VARCHAR2(200)            NULL,  -- 경도
--     PET_POLICY                       VARCHAR2(200)            NULL,  -- 반려동물 정책
--     DATA_SOURCE                      VARCHAR2(200)            NULL,  -- 데이터 출처
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
--     CATEGORY_CD                      VARCHAR2(30)             NULL,  -- POI 카테고리 (POI_CATEGORY 통합)
--     CONSTRAINT PK_TB_POI PRIMARY KEY (POI_ID)
-- );

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_SHELTER (보호소)
-- CREATE TABLE TB_SHELTER (
--     SHELTER_ID                       NUMBER                   NOT NULL,  -- 보호소 ID
--     SHELTER_NAME                     VARCHAR2(200)            NULL,  -- 보호소명
--     REGION                           VARCHAR2(200)            NULL,  -- 지역
--     ADDR                             VARCHAR2(200)            NULL,  -- 주소
--     LAT                              VARCHAR2(200)            NULL,  -- 위도
--     LNG                              VARCHAR2(200)            NULL,  -- 경도
--     PUBLIC_DATA_ID                   VARCHAR2(200)            NULL,  -- 공공데이터 키
--     GOAL_AMOUNT                      VARCHAR2(200)            NULL,  -- GOAL금액
--     TOTAL_DONATION                   VARCHAR2(200)            NULL,  -- 합계기부
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     CONSTRAINT PK_TB_SHELTER PRIMARY KEY (SHELTER_ID)
-- );

-- TB_FILE (파일)
CREATE TABLE TB_FILE (
    FILE_ID                          NUMBER                   NOT NULL,  -- 파일 ID
    REF_TYPE                         VARCHAR2(20)             NOT NULL,  -- 참조유형
    REF_ID                           NUMBER                   NOT NULL,  -- 참조 ID
    DRIVE_FILE_ID                    VARCHAR2(200)            NULL,      -- DRIVE파일ID (Google Drive fileId)
    FILE_URL                         VARCHAR2(500)            NOT NULL,  -- 접근 URL
    ORIGIN_NAME                      VARCHAR2(200)            NULL,  -- 원본파일명
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_FILE PRIMARY KEY (FILE_ID)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_PUBLIC_DATA_SYNC (공공데이터동기화)
-- CREATE TABLE TB_PUBLIC_DATA_SYNC (
--     SYNC_ID                          NUMBER                   NOT NULL,  -- 동기화 ID
--     DATA_TYPE                        VARCHAR2(20)             NOT NULL,  -- 데이터유형 (HOSPITAL/SHELTER)
--     SYNC_STATUS                      VARCHAR2(10)             NOT NULL,  -- 동기화상태 (SUCCESS/FAIL)
--     SYNC_CNT                         NUMBER                   NULL,  -- 건수
--     ERROR_MSG                        VARCHAR2(500)            NULL,  -- 오류
--     SYNC_DATE                        DATE                     NOT NULL,  -- 동기화일(@Scheduled)
--     CONSTRAINT PK_TB_PUBLIC_DATA_SYNC PRIMARY KEY (SYNC_ID)
-- );

-- TB_POLICY (POLICY)
CREATE TABLE TB_POLICY (
    POLICY_ID                        NUMBER                   NOT NULL,  -- 정책 ID
    POLICY_TYPE                      VARCHAR2(30)             NOT NULL,  -- POINT/WALK_REWARD 등
    POLICY_KEY                       VARCHAR2(200)            NULL,  -- 정책 키 [포인트정책 통합]
    POLICY_VALUE                     VARCHAR2(200)            NULL,  -- 정책 값 [포인트정책 통합]
    POINT_PER_KM                     VARCHAR2(200)            NULL,  -- km당 포인트 [산책리워드정책 통합]
    DAILY_MAX_POINT                  VARCHAR2(200)            NULL,  -- 일일 최대 포인트 [산책리워드정책 통합]
    APPLY_DATE                       VARCHAR2(200)            NULL,  -- 신청일 [산책리워드정책 통합]
    CONSTRAINT PK_TB_POLICY PRIMARY KEY (POLICY_ID)
);

-- TB_MEMBER (회원)
CREATE TABLE TB_MEMBER (
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
    MEMBER_ID                        VARCHAR2(50)             NOT NULL,  -- 로그인 ID(이메일)
    MEMBER_PWD                       VARCHAR2(200)            NULL,  -- 비밀번호 BCrypt(소셜가입 시 NULL)
    MEMBER_NAME                      VARCHAR2(50)             NOT NULL,  -- 이름
    NICKNAME                         VARCHAR2(30)             NOT NULL,  -- 닉네임
    EMAIL                            VARCHAR2(100)            NOT NULL,  -- 이메일
    PHONE                            VARCHAR2(20)             NULL,  -- 휴대폰
    ZIP_CODE                         VARCHAR2(10)             NULL,  -- 우편번호
    ADDR1                            VARCHAR2(200)            NULL,  -- 주소
    ADDR2                            VARCHAR2(100)            NULL,  -- 상세주소
    GRADE_CD                         VARCHAR2(10)             NULL,  -- 회원등급
    POINT_BALANCE                    NUMBER(10)               NULL,  -- 보유 포인트
    PROFILE_IMG_URL                  VARCHAR2(500)            NULL,  -- 프로필(Google Drive)
    STATUS_CD                        VARCHAR2(10)             NOT NULL,  -- 상태코드 (NORMAL/STOP/WITHDRAW)
    MARKETING_YN                     CHAR(1)                  NULL,  -- 마케팅 수신
    JOIN_DATE                        DATE                     NOT NULL,  -- 가입일
    LAST_LOGIN_DATE                  DATE                     NULL,  -- 최종 로그인
    WITHDRAW_DATE                    DATE                     NULL,  -- 탈퇴일
    SUSPEND_END_DATE                 DATE                     NULL,  -- 정지 종료일 (팀원)
        -- 2026-07-28 박유정 — 회원 생년월일·성별
    BIRTH_DATE                       DATE                     NULL,  -- 회원 생년월일
    GENDER                           CHAR(1)                  NULL,  -- 회원 성별 (M: 남, F: 여)
    POST_COUNT                       NUMBER                   DEFAULT 0 NOT NULL,  -- 게시글 작성 누적
    COMMENT_COUNT                    NUMBER                   DEFAULT 0 NOT NULL,  -- 댓글·대댓글 작성 누적
    ADMIN_POST_DEL_COUNT             NUMBER                   DEFAULT 0 NOT NULL,  -- 관리자 게시글 삭제 누적
    ADMIN_COMMENT_DEL_COUNT          NUMBER                   DEFAULT 0 NOT NULL,  -- 관리자 댓글·대댓글 삭제 누적
    REPORT_COUNT                     NUMBER                   DEFAULT 0 NOT NULL,  -- 받은 신고 누적
    CONSTRAINT PK_TB_MEMBER PRIMARY KEY (MEMBER_NO),
    CONSTRAINT UK_TB_MEMBER_1 UNIQUE (MEMBER_ID),
    CONSTRAINT UK_TB_MEMBER_2 UNIQUE (EMAIL)
);
-- 2026/07/29 하예주
-- TB_MEMBER_WITHDRAW (탈퇴회원)
CREATE TABLE TB_MEMBER_WITHDRAW (
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
    MEMBER_ID                        VARCHAR2(50)             NOT NULL,  -- 로그인 ID
    MEMBER_NAME                      VARCHAR2(50)             NOT NULL,  -- 이름
    EMAIL                            VARCHAR2(100)            NOT NULL,  -- 이메일
    WITHDRAW_DATE           DATE,                                         -- 탈퇴날짜 (YYYY-MM-DD)
    CONSTRAINT PK_TB_MEMBER_WITHDRAW PRIMARY KEY (MEMBER_NO)
);

-- TB_HOSPITAL (병원)
CREATE TABLE TB_HOSPITAL (
    HOSPITAL_ID                      NUMBER                   NOT NULL,  -- 병원 ID
    BIZ_NO                           NUMBER                   NOT NULL,  -- 사업자번호
    MEMBER_NO		                   NUMBER	                 NOT NULL,	 --회원정보(추가)
    NAME                    VARCHAR2(100)            NOT NULL,  -- 병원명
    PHONE                            VARCHAR2(20)             NULL,  -- 전화
    ADDR                             VARCHAR2(300)            NULL,  -- 주소
    ADDR_DETAIL                   VARCHAR2(200)            NULL,  -- 상세주소
    LAT                              NUMBER(10,7)             NULL,  -- 위도
    LNG                              NUMBER(10,7)             NULL,  -- 경도
    AVG_RATING                       NUMBER(2,1)              NULL,  -- 평균평점
    REVIEW_CNT                       NUMBER                   NULL,  -- 리뷰수
    DATA_SOURCE                      VARCHAR2(10)             NULL,  -- 데이터 출처 (PLATFORM/PUBLIC)
    PUBLIC_DATA_ID                   VARCHAR2(50)             NULL,  -- 공공데이터 키
    STATUS_CD                        VARCHAR2(10)             NOT NULL,  -- 승인상태
    APPROVE_DATE                     DATE                     NULL,  -- 승인일
    HOURS_JSON                       CLOB                     NULL,  -- 진료시간 JSON (HOSPITAL_HOURS 통합)
    DESCRIPTION                       VARCHAR2(2000)       NULL,  -- 상세설명
    TAG_LIST                        VARCHAR2(500)            NULL,  -- 운영특성 (HOSPITAL_DEPT 통합)
    -- 2026/07/15 장우철 고도화작업 — 병원 기본 동시예약 정원
    -- 2026/07/16 장우철 고도화작업 — 슬롯 폐기 후에도 규칙·겹침 시 동시 정원 기본값으로 사용
    RESV_CAPACITY                    NUMBER                   NULL,  -- 기본 동시 예약 인원
    -- 2026/07/16 장우철 고도화작업 — RESV_RULE 통합: 예약 시작시각 간격(분). 요일·오픈·점심은 HOURS_JSON
    RESV_INTERVAL_MIN                NUMBER        DEFAULT 15 NULL,  -- 예약 시작 간격(분)
    CONSTRAINT PK_TB_HOSPITAL PRIMARY KEY (HOSPITAL_ID)
);

-- TB_STAY (숙소) — 2026-07-11 LODGE → STAY (앱 StayMapper 기준)
CREATE TABLE TB_STAY (
    STAY_ID                          NUMBER                   NOT NULL,  -- 숙소 ID
    BIZ_NO                           NUMBER                   NOT NULL,  -- 사업자번호
    MEMBER_NO		                 NUMBER                   NULL,  --회원번호
    NAME                             VARCHAR2(200)            NULL,  -- 숙소명
    PHONE		                     VARCHAR2(20) 	       	  NULL,  --전화번호
    ZIP_CODE                         VARCHAR2(10)             NULL,  -- 우편번호
    ADDR                             VARCHAR2(200)            NULL,  -- 주소
    ADDR_DETAIL		                 VARCHAR2(200) 	       	  NULL,  --상세주소
    LAT                              VARCHAR2(200)            NULL,  -- 위도
    LNG                              VARCHAR2(200)            NULL,  -- 경도
    PET_POLICY                       CLOB                     NULL,  -- 반려동물 정책
    REFUND_POLICY                    CLOB                     NULL,  -- 환불 정책
    STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드 (APPROVE 등)
    APPROVE_DATE                     VARCHAR2(200)            NULL,  -- 승인일
    FACILITIES                       VARCHAR2(500)            NULL,  -- 편의시설
    CHECK_IN                         VARCHAR2(20)             NULL,  -- 체크인 시각
    CHECK_OUT                        VARCHAR2(20)             NULL,  -- 체크아웃 시각
    DESCRIPTION                      CLOB                     NULL,  -- 공간 소개
    PET_FEE                          NUMBER                   NULL,  -- 반려동물 추가비용 안내
    REGION		                     VARCHAR2(20) 	          NULL,  --지역 필터링
        -- 2026-07-28 박유정 — 숙소 평점·리뷰수
    AVG_RATING                       NUMBER(3,1)              NULL,  -- 숙소 평균 평점 (소수점 1자리)
    REVIEW_CNT                       NUMBER                   DEFAULT 0 NULL,  -- 등록된 리뷰 총 개수
    CONSTRAINT PK_TB_STAY PRIMARY KEY (STAY_ID)
);

-- TB_AD_PAYMENT (광고결제)
-- CREATE TABLE TB_AD_PAYMENT (
--     PAYMENT_ID                       NUMBER                   NOT NULL,  -- 결제 ID
--     CONTRACT_ID                      NUMBER                   NOT NULL,  -- 계약ID
--     BIZ_NO                           NUMBER                   NOT NULL,  -- 사업자번호
--     PAY_MONTH                        VARCHAR2(200)            NULL,  -- 결제MONTH
--     PAY_AMOUNT                       VARCHAR2(200)            NULL,  -- 실결제금액
--     PAY_STATUS                       VARCHAR2(200)            NULL,  -- 결제상태
--     PAY_DATE                         VARCHAR2(200)            NULL,  -- 결제일
--     CONSTRAINT PK_TB_AD_PAYMENT PRIMARY KEY (PAYMENT_ID)
-- );

-- TB_ADMIN (관리자)
CREATE TABLE TB_ADMIN (
    ADMIN_NO                         NUMBER                   NOT NULL,  -- 관리자번호
    ADMIN_ID                         VARCHAR2(100)            NOT NULL,  -- 관리자 로그인 ID
    ADMIN_PWD                        VARCHAR2(200)            NULL,  -- 관리자 비밀번호
    ADMIN_NAME                       VARCHAR2(200)            NULL,  -- 관리자 이름
    ROLE_ID                          NUMBER                   NOT NULL,  -- 역할ID
    STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
    REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
    CONSTRAINT PK_TB_ADMIN PRIMARY KEY (ADMIN_NO),
    CONSTRAINT UK_TB_ADMIN_1 UNIQUE (ADMIN_ID)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_WALK_COURSE (산책코스)
-- CREATE TABLE TB_WALK_COURSE (
--     COURSE_ID                        NUMBER                   NOT NULL,  -- 코스ID
--     COURSE_NAME                      VARCHAR2(200)            NULL,  -- 코스명
--     POI_ID                           NUMBER                   NOT NULL,  -- 장소 ID
--     DISTANCE_KM                      VARCHAR2(200)            NULL,  -- 거리KM
--     DIFFICULTY                       VARCHAR2(200)            NULL,  -- 난이도
--     ROUTE_DATA                       CLOB                     NULL,  -- ROUTE데이터
--     USE_YN                           VARCHAR2(200)            NULL,  -- 여부
--     CONSTRAINT PK_TB_WALK_COURSE PRIMARY KEY (COURSE_ID)
-- );

-- TB_BANNER (배너)
-- 2026/08/01 장우철 — yeju 팀원 스키마 반영 (BANNER_TYPE/USE_YN 제거, BIZ_NO·TITLE·POSITION_CD·STATUS_CD 등)
CREATE TABLE TB_BANNER (
    BANNER_ID                        NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,  -- 배너 ID
    BIZ_NO                           NUMBER                   NOT NULL,  -- 사업자번호
    TITLE                            VARCHAR2(200)            NOT NULL,  -- 배너 제목
    POSITION_CD                      VARCHAR2(20)   DEFAULT 'MAIN_HERO' NULL,  -- 노출 위치
    FILE_ID                          NUMBER                   NOT NULL,  -- 파일 ID
    LINK_URL                         VARCHAR2(200)            NULL,  -- 클릭 이동 URL
    START_DATE                       DATE                     NULL,  -- 시작일
    END_DATE                         DATE                     NULL,  -- 종료일
    STATUS_CD                        VARCHAR2(20)   DEFAULT 'PENDING' NULL,  -- PENDING/ACTIVE/REJECTED/EXPIRED
    REJECT_REASON                    VARCHAR2(500)            NULL,  -- 반려 사유
    REG_DATE                         DATE           DEFAULT SYSTIMESTAMP NULL,  -- 등록일
    MOD_DATE                         DATE                     NULL,  -- 수정일
    CONSTRAINT PK_TB_BANNER PRIMARY KEY (BANNER_ID)
);

-- TB_MEMBER_SOCIAL (소셜연동)
CREATE TABLE TB_MEMBER_SOCIAL (
    SOCIAL_ID                        NUMBER                   NOT NULL,  -- 소셜연동 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원
    PROVIDER                         VARCHAR2(20)             NOT NULL,  -- 소셜 제공처 (KAKAO/NAVER/GOOGLE)
    PROVIDER_UID                     VARCHAR2(200)            NOT NULL,  -- 소셜 고유 ID
    REG_DATE                         DATE                     NOT NULL,  -- 연동일
    CONSTRAINT PK_TB_MEMBER_SOCIAL PRIMARY KEY (SOCIAL_ID),
    CONSTRAINT UK_TB_MEMBER_SOCIAL_1 UNIQUE (PROVIDER_UID)
);

-- TB_MEMBER_AGREEMENT (회원약관동의)
CREATE TABLE TB_MEMBER_AGREEMENT (
    AGREE_ID                         NUMBER                   NOT NULL,  -- 동의 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원
    TERMS_TYPE                       VARCHAR2(20)             NOT NULL,  -- 약관 유형 (SERVICE/PRIVACY/MARKETING)
    TERMS_VER                        VARCHAR2(10)             NOT NULL,  -- 약관버전
    AGREE_YN                         CHAR(1)                  NOT NULL,  -- 동의여부
    AGREE_DATE                       DATE                     NOT NULL,  -- 동의일
    CONSTRAINT PK_TB_MEMBER_AGREEMENT PRIMARY KEY (AGREE_ID)
);

-- TB_MEMBER_ADDRESS (회원배송지)
CREATE TABLE TB_MEMBER_ADDRESS (
    ADDR_ID                          NUMBER                   NOT NULL,  -- 배송지 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원
    RECV_NAME                        VARCHAR2(50)             NOT NULL,  -- 수령인
    RECV_PHONE                       VARCHAR2(20)             NOT NULL,  -- 연락처
    ZIP_CODE                         VARCHAR2(10)             NULL,  -- 우편번호
    ADDR1                            VARCHAR2(200)            NOT NULL,  -- 주소
    ADDR2                            VARCHAR2(100)            NULL,  -- 상세주소
    IS_DEFAULT                       CHAR(1)                  NULL,  -- 기본배송지 Y/N
    CONSTRAINT PK_TB_MEMBER_ADDRESS PRIMARY KEY (ADDR_ID)
);

-- TB_PET (반려동물)
CREATE TABLE TB_PET (
    PET_ID                           NUMBER                   NOT NULL,  -- 반려동물 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원
    PET_NAME                         VARCHAR2(30)             NOT NULL,  -- 이름
    SPECIES                          VARCHAR2(10)             NOT NULL,  -- 반려동물 종 (DOG/CAT/ETC)
    BREED                            VARCHAR2(50)             NULL,  -- 품종
    GENDER                           CHAR(1)                  NULL,  -- 성별 (M/F)
    BIRTH_DATE                       DATE                     NULL,  -- 생년월일
    AGE                              NUMBER(3)                NULL,  -- 나이
    WEIGHT                           NUMBER(5,1)              NULL,  -- 체중(kg)
    IS_REPRESENT                     CHAR(1)                  NULL,  -- 대표 Y/N
    PHOTO_URL                        VARCHAR2(500)            NULL,  -- 사진(Google Drive)
    DEL_YN                           CHAR(1)    DEFAULT 'N'   NULL,  -- 삭제 Y/N (Y=목록 비표시)
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
        -- 2026-07-28 박유정 — 반려 상세 (털색·중성화·특징·메모)
    FUR_COLOR                        VARCHAR2(50)             NULL,  -- 털 색상
    NEUTER_YN                        CHAR(1)                  NULL,  -- 중성화 (Y/N/U)
    TRAITS                           VARCHAR2(200)            NULL,  -- 성격·특징 (쉼표 구분)
    MEMO                             VARCHAR2(500)            NULL,  -- 기타 메모
    CONSTRAINT PK_TB_PET PRIMARY KEY (PET_ID)
);

-- =========================================================
-- 2026/07/15 장우철 고도화작업 — 병원 진료유형 (소요시간)
-- =========================================================
-- TB_HOSPITAL_TREAT_TYPE (병원 진료유형)
CREATE TABLE TB_HOSPITAL_TREAT_TYPE (
    TREAT_TYPE_ID                    NUMBER                   NOT NULL,  -- 진료유형 ID
    HOSPITAL_ID                      NUMBER                   NOT NULL,  -- 병원 ID
    TYPE_NAME                        VARCHAR2(100)            NOT NULL,  -- 유형명 (일반진료, 접종 등)
    DURATION_MIN                     NUMBER                   NOT NULL,  -- 소요 분 (15, 30 …)
    STATUS_CD                        VARCHAR2(10)  DEFAULT 'Y' NULL,  -- 사용여부 (Y/N)
    SORT_ORDR                        NUMBER                   NULL,  -- 화면 정렬
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_HOSPITAL_TREAT_TYPE PRIMARY KEY (TREAT_TYPE_ID),
    -- 2026/07/15 장우철 고도화작업 — FK 병원
    CONSTRAINT FK_PTN65_0100 FOREIGN KEY (HOSPITAL_ID)
        REFERENCES TB_HOSPITAL (HOSPITAL_ID)
);

-- =========================================================
-- 2026/07/15 장우철 고도화작업 — 병원 의사 (상세에서만 표시, 의사별 캘린더 없음)
-- =========================================================
-- TB_HOSPITAL_DOCTOR (병원 의사)
CREATE TABLE TB_HOSPITAL_DOCTOR (
    DOCTOR_ID                        NUMBER                   NOT NULL,  -- 의사 ID
    HOSPITAL_ID                      NUMBER                   NOT NULL,  -- 병원 ID
    DOCTOR_NAME                      VARCHAR2(50)             NOT NULL,  -- 의사명
    SPECIALTY                        VARCHAR2(100)            NULL,  -- 전문분야 (선택)
    STATUS_CD                        VARCHAR2(10)  DEFAULT 'Y' NULL,  -- 사용여부 (Y/N)
    SORT_ORDR                        NUMBER                   NULL,  -- 화면 정렬
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_HOSPITAL_DOCTOR PRIMARY KEY (DOCTOR_ID),
    -- 2026/07/15 장우철 고도화작업 — FK 병원
    CONSTRAINT FK_PTN65_0103 FOREIGN KEY (HOSPITAL_ID)
        REFERENCES TB_HOSPITAL (HOSPITAL_ID)
);
-- =========================================================
-- 2026/07/16 장우철 고도화작업 — 병원 예약 예외 (미리 설정, 특정일 덮어쓰기)
-- 예: 특정일 CLOSE / 의사 휴가(의사 지정) / REPLACE 단축
-- =========================================================
-- TB_HOSPITAL_RESV_EXCEPTION (병원 예약예외)
CREATE TABLE TB_HOSPITAL_RESV_EXCEPTION (
    EXC_ID                           NUMBER                   NOT NULL,  -- 예외 ID
    HOSPITAL_ID                      NUMBER                   NOT NULL,  -- 병원 ID
    -- 2026/07/16 장우철 고도화작업 — NULL=병원 공통 예외, 값=의사별 예외
    DOCTOR_ID                        NUMBER                   NULL,  -- 의사 ID (선택)
    EXC_DATE                         DATE                     NOT NULL,  -- 예외 적용일
    -- REPLACE=그날 이 구간(들)만 오픈, CLOSE=그날 이 구간 예약 불가
    EXC_TYPE                         VARCHAR2(20)             NOT NULL,  -- REPLACE / CLOSE
    START_TIME                       VARCHAR2(10)             NULL,  -- 시작 (예: 13:00)
    END_TIME                         VARCHAR2(10)             NULL,  -- 종료 (예: 15:00)
    INTERVAL_MIN                     NUMBER                   NULL,  -- 시작 간격(분), NULL이면 병원 RESV_INTERVAL_MIN
    MEMO                             VARCHAR2(200)            NULL,  -- 메모 (휴진·단축 등)
    STATUS_CD                        VARCHAR2(10)  DEFAULT 'Y' NULL,  -- 사용여부 Y/N
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_HOSPITAL_RESV_EXCEPTION PRIMARY KEY (EXC_ID),
    -- 2026/07/16 장우철 고도화작업 — FK 병원
    CONSTRAINT FK_PTN65_0108 FOREIGN KEY (HOSPITAL_ID)
        REFERENCES TB_HOSPITAL (HOSPITAL_ID),
    -- 2026/07/16 장우철 고도화작업 — FK 의사 (NULL 허용)
    CONSTRAINT FK_PTN65_0109 FOREIGN KEY (DOCTOR_ID)
        REFERENCES TB_HOSPITAL_DOCTOR (DOCTOR_ID)
);

-- =========================================================
-- 2026/07/16 장우철 고도화작업 — 병원 예약 임시 선점
-- 유저가 시간 선택 후 펫·증상 단계로 넘어갈 때 구간 점유 (만료 EXPIRE_DATE)
-- =========================================================
-- TB_HOSPITAL_RESV_HOLD (병원 예약 임시 선점)
CREATE TABLE TB_HOSPITAL_RESV_HOLD (
    HOLD_ID                          NUMBER                   NOT NULL,  -- 선점 ID
    HOSPITAL_ID                      NUMBER                   NOT NULL,  -- 병원 ID
    DOCTOR_ID                        NUMBER                   NOT NULL,  -- 의사 ID
    TREAT_TYPE_ID                    NUMBER                   NOT NULL,  -- 진료유형 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 선점 회원
    RESV_DATE                        DATE                     NOT NULL,  -- 예약일
    RESV_TIME                        VARCHAR2(10)             NOT NULL,  -- 시작 시각 (예: 09:00)
    DURATION_MIN                     NUMBER                   NOT NULL,  -- 소요 분
    END_TIME                         VARCHAR2(10)             NOT NULL,  -- 종료 시각 (예: 09:20)
    EXPIRE_DATE                      DATE                     NOT NULL,  -- 선점 만료 시각
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_HOSPITAL_RESV_HOLD PRIMARY KEY (HOLD_ID)
);

-- TB_FAVORITE (즐겨찾기)
CREATE TABLE TB_FAVORITE (
    FAV_ID                           NUMBER                   NOT NULL,  -- 즐겨찾기 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원
    FAV_TYPE                         VARCHAR2(10)             NOT NULL,  -- 즐겨찾기 유형 (PRODUCT/HOSPITAL/STAY/POI)
    TARGET_ID                        NUMBER                   NOT NULL,  -- 대상 PK
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_FAVORITE PRIMARY KEY (FAV_ID)
);

-- TB_NOTIFICATION (알림함)
CREATE TABLE TB_NOTIFICATION (
    NOTI_ID                          NUMBER                   NOT NULL,  -- 알림 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원
    NOTI_TYPE                        VARCHAR2(30)             NOT NULL,  -- 알림 유형 (ORDER/RESERVE/COMMUNITY/SYSTEM)
    TITLE                            VARCHAR2(200)            NOT NULL,  -- 제목
    CONTENT                          VARCHAR2(500)            NULL,  -- 내용
    LINK_URL                         VARCHAR2(300)            NULL,  -- 이동 URL
    IS_READ                          CHAR(1)                  NULL,  -- 읽음 Y/N
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_NOTIFICATION PRIMARY KEY (NOTI_ID)
);
-- 2026-08-11 박유정 — 공지사항 테이블
CREATE TABLE TB_NOTICE (
    NOTICE_ID      NUMBER         NOT NULL,
    NOTICE_TYPE_CD VARCHAR2(20)   NOT NULL,   -- NOTICE / INFO
    TITLE          VARCHAR2(500)  NOT NULL,
    BODY           CLOB           NOT NULL,
    WRITER_NAME    VARCHAR2(100),
    PIN_YN         CHAR(1)        DEFAULT 'N' NOT NULL,
    VISIBLE_YN     CHAR(1)        DEFAULT 'Y' NOT NULL,
    VIEW_COUNT     NUMBER         DEFAULT 0,
    REG_DATE       DATE           DEFAULT SYSDATE NOT NULL,
    MOD_DATE       DATE,
    CONSTRAINT PK_TB_NOTICE PRIMARY KEY (NOTICE_ID)
);

-- TB_FCM_TOKEN (FCM토큰)
-- CREATE TABLE TB_FCM_TOKEN (
--     TOKEN_ID                         NUMBER                   NOT NULL,  -- 토큰 ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원
--     DEVICE_TOKEN                     VARCHAR2(500)            NOT NULL,  -- FCM 토큰
--     DEVICE_TYPE                      VARCHAR2(10)             NULL,  -- 기기 유형 (WEB/ANDROID/IOS)
--     REG_DATE                         DATE                     NOT NULL,  -- 등록일
--     CONSTRAINT PK_TB_FCM_TOKEN PRIMARY KEY (TOKEN_ID)
-- );

-- TB_CART (장바구니)
CREATE TABLE TB_CART (
    CART_ID                          NUMBER                   NOT NULL,  -- 장바구니 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
    REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
    CONSTRAINT PK_TB_CART PRIMARY KEY (CART_ID)
);

-- TB_MEMBER_COUPON (회원쿠폰)
CREATE TABLE TB_MEMBER_COUPON (
    MEMBER_COUPON_ID                 NUMBER                   NOT NULL,  -- 회원쿠폰ID
    COUPON_ID                        NUMBER                   NOT NULL,  -- 쿠폰 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
    EXPIRE_DATE                      VARCHAR2(200)            NULL,  -- 만료일
    USE_END_DATE                     VARCHAR2(14)             NULL,
    REG_DATE                         VARCHAR2(14)             NULL,
    STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드 (UNUSED/USED/EXPIRED)
    CONSTRAINT PK_TB_MEMBER_COUPON PRIMARY KEY (MEMBER_COUPON_ID)
);

-- TB_POST (게시글)
CREATE TABLE TB_POST (
    POST_ID                          NUMBER                   NOT NULL,  -- 게시글 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 작성자
    BOARD_TYPE                       VARCHAR2(20)             NOT NULL,  -- 게시판 유형 (TOWN/LOST/SHARE/LIFE)
    TITLE                            VARCHAR2(200)            NOT NULL,  -- 제목
    BODY                             CLOB                     NULL,  -- 본문
    VIEW_COUNT                       NUMBER                   NULL,  -- 조회수
    LIKE_CNT                         NUMBER                   NULL,  -- 좋아요
    LOST_SPECIES                     VARCHAR2(20)             NULL,  -- 분실:동물종류
    LOST_FEATURE                     VARCHAR2(500)            NULL,  -- 분실:특징
    LOST_LAT                         NUMBER(10,7)             NULL,  -- 분실:위도
    LOST_LNG                         NUMBER(10,7)             NULL,  -- 분실:경도
    LOST_CONTACT                     VARCHAR2(50)             NULL,  -- 분실:연락처
    REGION                           VARCHAR2(50)             NULL,  -- 지역
    STATUS_CD                        VARCHAR2(10)             NOT NULL,  -- 상태코드 (ACTIVE/HIDDEN/DELETED)
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    TAGS                             VARCHAR2(500)            NULL,  -- 해시태그 (HASHTAG 통합)
    DELETE_DATE                      DATE                     NULL,
    CONSTRAINT PK_TB_POST PRIMARY KEY (POST_ID)
);

-- TB_POINT (포인트이력)
CREATE TABLE TB_POINT (
    POINT_ID                         NUMBER                   NOT NULL,  -- 포인트ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
    POINT_TYPE                       VARCHAR2(200)            NULL,  -- 포인트유형
    POINT_AMOUNT                     VARCHAR2(200)            NULL,  -- 포인트금액
    BALANCE_AFTER                    VARCHAR2(200)            NULL,  -- 잔액이후
    REASON_CD                        VARCHAR2(200)            NULL,  -- 사유코드
    REF_TYPE                         VARCHAR2(200)            NULL,  -- 참조 유형
    REF_ID                           VARCHAR2(200)            NULL,  -- 참조 대상 ID
    REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
    CONSTRAINT PK_TB_POINT PRIMARY KEY (POINT_ID)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_DONATION (기부내역)
-- CREATE TABLE TB_DONATION (
--     DONATION_ID                      NUMBER                   NOT NULL,  -- 기부 ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
--     SHELTER_ID                       NUMBER                   NOT NULL,  -- 보호소 ID
--     DONATION_TYPE                    VARCHAR2(200)            NULL,  -- 기부유형
--     AMOUNT                           VARCHAR2(200)            NULL,  -- 금액
--     DONATION_DATE                    VARCHAR2(200)            NULL,  -- 기부일
--     CERT_NO                          VARCHAR2(50)             NULL,  -- 기부증서 번호 [증서 통합]
--     CERT_FILE_ID                     NUMBER                   NULL,  -- 증서 파일 ID
--     CERT_ISSUE_DATE                  DATE                     NULL,  -- 증서 발급일 [증서 통합]
--     CONSTRAINT PK_TB_DONATION PRIMARY KEY (DONATION_ID)
-- );

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_VOLUNTEER (봉사모집)
-- CREATE TABLE TB_VOLUNTEER (
--     VOLUNTEER_ID                     NUMBER                   NOT NULL,  -- 봉사 ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
--     VOL_TYPE                         VARCHAR2(200)            NULL,  -- VOL유형
--     TITLE                            VARCHAR2(200)            NULL,  -- 제목
--     BODY                             CLOB                     NULL,  -- 본문
--     LOCATION                         VARCHAR2(200)            NULL,  -- 장소
--     VOL_DATE                         VARCHAR2(200)            NULL,  -- VOL일
--     MAX_COUNT                        VARCHAR2(200)            NULL,  -- 최대 인원
--     CURRENT_COUNT                    VARCHAR2(200)            NULL,  -- 현재 신청 인원
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
--     CONSTRAINT PK_TB_VOLUNTEER PRIMARY KEY (VOLUNTEER_ID)
-- );

-- 2026/07/16 장우철 고도화작업 — TB_RESERVATION_SLOT CREATE 제거 (규칙·예외 테이블로 대체)
-- (구 DB 잔여분은 상단 DROP TABLE TB_RESERVATION_SLOT 로 정리)

-- TB_STAY_ROOM (숙소객실) — 2026-07-11 LODGE_ROOM → STAY_ROOM
CREATE TABLE TB_STAY_ROOM (
    ROOM_ID                          NUMBER                   NOT NULL,  -- 객실 ID
    STAY_ID                          NUMBER                   NOT NULL,  -- 숙소
    NAME                             VARCHAR2(100)            NOT NULL,  -- 객실명
    PRICE_PER_NIGHT                  NUMBER                   NOT NULL,  -- 1박 요금
    CAPACITY                         NUMBER                   NULL,  -- 정원
    PET_LIMIT                        NUMBER                   NULL,  -- 반려동물 수 제한
    STATUS_CD                        VARCHAR2(10)             NOT NULL,  -- 상태코드 (PENDING/APPROVE/REJECT)
    REJECT_REASON                    VARCHAR2(500)            NULL,  -- 반려사유
    CONSTRAINT PK_TB_STAY_ROOM PRIMARY KEY (ROOM_ID)
);

-- TB_BUSINESS_AUTH (사업자인증신청)
CREATE TABLE TB_BUSINESS_AUTH (
    AUTH_ID                         NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY,  -- 인증신청 ID
    BIZ_NO                           NUMBER                   NOT NULL,  -- 사업자
    DOC_FILE_ID                      NUMBER                   NULL,  -- 등록증 파일
    BIZ_REG_NO                       VARCHAR2(12)             NOT NULL,  -- 사업자등록번호
    BIZ_TYPE                         VARCHAR2(10)             NOT NULL,  -- 업종
    AD_APPLY_YN                      CHAR(1)                  NULL,  -- 광고 동시신청
    STATUS_CD                        VARCHAR2(10)             NOT NULL,  -- 상태코드 (PENDING/APPROVE/REJECT)
    REJECT_REASON                    VARCHAR2(500)            NULL,  -- 거절사유
    APPLY_DATE                       DATE                     NOT NULL,  -- 신청일
    APPROVE_DATE                     DATE                     NULL,  -- 승인일
    ADMIN_NO                         NUMBER                   NULL,  -- 처리 관리자
    CONSTRAINT PK_TB_BUSINESS_AUTH PRIMARY KEY (AUTH_ID)
);

-- TB_ADMIN_LOG (관리자작업로그)
-- CREATE TABLE TB_ADMIN_LOG (
--     LOG_ID                           NUMBER                   NOT NULL,  -- 로그ID
--     ADMIN_NO                         NUMBER                   NOT NULL,  -- 관리자번호
--     ACTION_TYPE                      VARCHAR2(200)            NULL,  -- 작업 유형
--     TARGET_TYPE                      VARCHAR2(200)            NULL,  -- 대상 유형
--     TARGET_ID                        VARCHAR2(200)            NULL,  -- 대상ID
--     IP_ADDR                          VARCHAR2(200)            NULL,  -- IP주소
--     REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
--     CONSTRAINT PK_TB_ADMIN_LOG PRIMARY KEY (LOG_ID)
-- );

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_POI_REQUEST (POI등록신청)
-- CREATE TABLE TB_POI_REQUEST (
--     REQUEST_ID                       NUMBER                   NOT NULL,  -- 요청ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
--     CATEGORY_ID                      NUMBER                   NOT NULL,  -- 카테고리 ID
--     POI_NAME                         VARCHAR2(200)            NULL,  -- 장소명
--     ADDR                             VARCHAR2(200)            NULL,  -- 주소
--     LAT                              VARCHAR2(200)            NULL,  -- 위도
--     LNG                              VARCHAR2(200)            NULL,  -- 경도
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     REJECT_REASON                    VARCHAR2(200)            NULL,  -- 거절사유
--     APPLY_DATE                       VARCHAR2(200)            NULL,  -- 신청일
--     ADMIN_NO                         NUMBER                   NOT NULL,  -- 관리자번호
--     CONSTRAINT PK_TB_POI_REQUEST PRIMARY KEY (REQUEST_ID)
-- );

-- TB_CONTENT (콘텐츠(공지·FAQ·약관))
CREATE TABLE TB_CONTENT (
    CONTENT_ID                       NUMBER                   NOT NULL,  -- 콘텐츠 ID
    CONTENT_TYPE                     VARCHAR2(20)             NOT NULL,  -- 유형 (NOTICE/FAQ/TERMS)
    TITLE                            VARCHAR2(200)            NOT NULL,  -- 제목
    BODY                             CLOB                     NULL,  -- 본문 (공지·약관 본문, FAQ 답변)
    TARGET_TYPE                      VARCHAR2(20)             NULL,  -- 공지 대상 (ALL/USER/BIZ) [공지]
    IS_PINNED                        CHAR(1)                  NULL,  -- 상단 고정 여부 [공지]
    PUBLISH_DATE                     DATE                     NULL,  -- 게시일 [공지]
    CATEGORY_CD                      VARCHAR2(50)             NULL,  -- FAQ 카테고리 [FAQ]
    QUESTION                         VARCHAR2(500)            NULL,  -- 질문 [FAQ]
    TERMS_TYPE                       VARCHAR2(30)             NULL,  -- 약관 유형 SERVICE/PRIVACY [약관]
    VERSION                          VARCHAR2(20)             NULL,  -- 약관 버전 [약관]
    EFFECTIVE_DATE                   DATE                     NULL,  -- 약관 시행일 [약관]
    SORT_ORDER                       NUMBER                   NULL,  -- FAQ 정렬순서 [FAQ]
    USE_YN                           CHAR(1)                  NULL,  -- 사용 여부
    ADMIN_NO                         NUMBER                   NULL,  -- 등록 관리자
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_CONTENT PRIMARY KEY (CONTENT_ID)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_STATUS_HIST (STATUS_HIST)
-- CREATE TABLE TB_STATUS_HIST (
--     HIST_ID                          NUMBER                   NOT NULL,  -- 이력 ID
--     TARGET_TYPE                      VARCHAR2(20)             NOT NULL,  -- 대상 유형 (MEMBER/BUSINESS)
--     TARGET_ID                        NUMBER                   NOT NULL,  -- 대상 PK
--     BEFORE_STATUS                    VARCHAR2(10)             NULL,  -- 변경전 [테이블 통합]
--     AFTER_STATUS                     VARCHAR2(10)             NOT NULL,  -- 변경후 [테이블 통합]
--     REASON                           VARCHAR2(500)            NULL,  -- 사유 [테이블 통합]
--     ADMIN_NO                         NUMBER                   NULL,  -- 처리 관리자 [테이블 통합]
--     REG_DATE                         DATE                     NOT NULL,  -- 등록일 [테이블 통합]
--     CONSTRAINT PK_TB_STATUS_HIST PRIMARY KEY (HIST_ID)
-- );

-- TB_AD (광고(통합))
-- CREATE TABLE TB_AD (
--     AD_ID                            NUMBER                   NOT NULL,  -- 광고 ID [광고신청 통합]
--     BIZ_NO                           NUMBER                   NOT NULL,  -- 사업자번호 [광고신청 통합]
--     BIZ_TYPE                         VARCHAR2(200)            NULL,  -- 사업자 유형 [광고신청 통합]
--     FILE_ID                          NUMBER                   NOT NULL,  -- 파일 ID [광고신청 통합]
--     BANNER_TEXT                      VARCHAR2(200)            NULL,  -- 배너문구 [광고신청 통합]
--     HOPE_START                       VARCHAR2(200)            NULL,  -- HOPE시작 [광고신청 통합]
--     HOPE_END                         VARCHAR2(200)            NULL,  -- HOPE종료 [광고신청 통합]
--     MONTHLY_FEE                      VARCHAR2(200)            NULL,  -- MONTHLY수수료 [광고신청 통합]
--     DISPLAY_POS                      VARCHAR2(200)            NULL,  -- 노출 위치 [광고신청 통합]
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드 [광고신청 통합]
--     REJECT_REASON                    VARCHAR2(200)            NULL,  -- 거절사유 [광고신청 통합]
--     APPLY_DATE                       VARCHAR2(200)            NULL,  -- 신청일 [광고신청 통합]
--     APPROVE_DATE                     VARCHAR2(200)            NULL,  -- 승인일 [광고신청 통합]
--     ADMIN_NO                         NUMBER                   NOT NULL,  -- 관리자번호 [광고신청 통합]
--     CONTRACT_ID                      NUMBER                   NOT NULL,  -- 계약ID [광고계약 통합]
--     START_DATE                       VARCHAR2(200)            NULL,  -- 시작일 [광고계약 통합]
--     END_DATE                         VARCHAR2(200)            NULL,  -- 종료일 [광고계약 통합]
--     SETTLE_ID                        NUMBER                   NOT NULL,  -- 정산 ID [광고정산 통합]
--     SETTLE_MONTH                     VARCHAR2(200)            NULL,  -- 정산MONTH [광고정산 통합]
--     TOTAL_AMOUNT                     VARCHAR2(200)            NULL,  -- 총 주문금액 [광고정산 통합]
--     BIZ_CNT                          VARCHAR2(200)            NULL,  -- 사업자수 [광고정산 통합]
--     REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일 [광고정산 통합]
--     CONSTRAINT PK_TB_AD PRIMARY KEY (AD_ID)
-- );

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_PET_HEALTH (반려동물 건강기록)
-- CREATE TABLE TB_PET_HEALTH (
--     HEALTH_ID                        NUMBER                   NOT NULL,  -- 건강기록 ID
--     PET_ID                           NUMBER                   NOT NULL,  -- 반려동물 ID
--     HEALTH_TYPE                      VARCHAR2(20)             NOT NULL,  -- 기록 유형 (VACCINE/WEIGHT)
--     RECORD_DATE                      DATE                     NOT NULL,  -- 기록일
--     VALUE                            NUMBER(5,2)              NULL,  -- 체중(kg) [체중]
--     VACC_NAME                        VARCHAR2(100)            NULL,  -- 백신명 [접종]
--     NEXT_DATE                        DATE                     NULL,  -- 다음 접종 예정일 [접종]
--     MEMO                             VARCHAR2(500)            NULL,  -- 메모
--     REG_DATE                         DATE                     NOT NULL,  -- 등록일
--     CONSTRAINT PK_TB_PET_HEALTH PRIMARY KEY (HEALTH_ID)
-- );

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_WALK_RECORD (산책기록)
-- CREATE TABLE TB_WALK_RECORD (
--     WALK_ID                          NUMBER                   NOT NULL,  -- 산책ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
--     PET_ID                           NUMBER                   NOT NULL,  -- 반려동물 ID
--     WALK_DATE                        VARCHAR2(200)            NULL,  -- 산책일
--     DISTANCE_KM                      VARCHAR2(200)            NULL,  -- 거리KM
--     DURATION_MIN                     VARCHAR2(200)            NULL,  -- 시간MIN
--     CALORIES                         VARCHAR2(200)            NULL,  -- 칼로리
--     ROUTE_DATA                       CLOB                     NULL,  -- ROUTE데이터
--     REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
--     CONSTRAINT PK_TB_WALK_RECORD PRIMARY KEY (WALK_ID)
-- );

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_WALK_MATE (산책메이트)
-- CREATE TABLE TB_WALK_MATE (
--     MATE_ID                          NUMBER                   NOT NULL,  -- 메이트ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
--     PET_ID                           NUMBER                   NOT NULL,  -- 반려동물 ID
--     REGION                           VARCHAR2(200)            NULL,  -- 지역
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     CONSTRAINT PK_TB_WALK_MATE PRIMARY KEY (MATE_ID)
-- );

-- TB_INQUIRY (1:1 문의)
-- 2026/07/31 장우철 — 숙소 환불신청: INQUIRY_TYPE=RESERVE, REF_TYPE=RESV, REF_ID=RESV_ID
CREATE TABLE TB_INQUIRY (
    INQUIRY_ID                       NUMBER                   NOT NULL,  -- 문의 ID
    INQUIRY_TYPE                     VARCHAR2(20)             NOT NULL,  -- VET/PARTNER/ORDER/RESERVE/ETC (숙소환불=RESERVE)
    MEMBER_NO                        NUMBER                   NULL,  -- 회원번호
    PET_ID                           NUMBER                   NULL,  -- 반려동물 ID [수의사]
    TITLE                            VARCHAR2(200)            NULL,  -- 문의 제목
    BODY                             CLOB                     NULL,  -- 문의 내용
    SYMPTOM                          CLOB                     NULL,  -- 증상 상세 [수의사]
    COMPANY_NAME                     VARCHAR2(100)            NULL,  -- 회사명 [제휴]
    CONTACT_NAME                     VARCHAR2(50)             NULL,  -- 담당자명 [제휴]
    EMAIL                            VARCHAR2(100)            NULL,  -- 이메일 [제휴]
    REF_TYPE                         VARCHAR2(30)             NULL,  -- ORDER/RESV 등 (숙소환불=RESV)
    REF_ID                           NUMBER                   NULL,  -- 참조 ID (숙소환불=RESV_ID)
    STATUS_CD                        VARCHAR2(20)             NOT NULL,  -- WAIT/ANSWER/DONE (관리자 환불승인 세부는 2-7에서)
    ANSWER                           CLOB                     NULL,  -- 답변 내용
    ADMIN_NO                         NUMBER                   NULL,  -- 답변 관리자
    RATING                           NUMBER(2,1)              NULL,  -- 상담 만족도 [수의사]
    APPLY_DATE                       DATE                     NULL,  -- 문의·신청일
    ANSWER_DATE                      DATE                     NULL,  -- 답변일
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_INQUIRY PRIMARY KEY (INQUIRY_ID)
);
-- 2026-08-11 박유정 — FAQ 테이블
CREATE TABLE TB_FAQ (
    FAQ_ID       NUMBER         NOT NULL,
    CATEGORY_CD  VARCHAR2(20)   NOT NULL,   -- SERVICE / ORDER / MEMBER / RESERVE
    QUESTION     VARCHAR2(500)  NOT NULL,
    ANSWER       CLOB           NOT NULL,
    VISIBLE_YN   CHAR(1)        DEFAULT 'Y' NOT NULL,
    SORT_ORDER   NUMBER         DEFAULT 0,
    REG_DATE     DATE           DEFAULT SYSDATE NOT NULL,
    MOD_DATE     DATE,
    CONSTRAINT PK_TB_FAQ PRIMARY KEY (FAQ_ID)
);


-- TB_POST_LIKE (게시글좋아요)
CREATE TABLE TB_POST_LIKE (
    LIKE_ID                          NUMBER                   NOT NULL,  -- 좋아요ID
    POST_ID                          NUMBER                   NOT NULL,  -- 게시글 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
    REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
    CONSTRAINT PK_TB_POST_LIKE PRIMARY KEY (LIKE_ID)
);

-- TB_POST_REPORT (게시글신고)
CREATE TABLE TB_POST_REPORT (
    REPORT_ID                        NUMBER                   NOT NULL,  -- 신고ID
    POST_ID                          NUMBER                   NOT NULL,  -- 게시글 ID
    COMMENT_ID                       NUMBER                   NULL, --댓글,대댓글 ID
    TARGET_TYPE                      VARCHAR2(10)             DEFAULT 'POST' NOT NULL, -- POST/COMMENT
    REPORTER_NO                      NUMBER                   NOT NULL,  -- REPORTER번호
    REASON                           VARCHAR2(200)            NULL,  -- 사유
    STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
    -- 2026/07/11 장우철 — 신고 접수 시 ADMIN_NO=NULL (처리 전이므로 NULL 허용, 코드 insertReport 와 맞춤)
    ADMIN_NO                         NUMBER                   NULL,  -- 관리자번호 (접수 시 NULL, 처리 시 세팅)
    CONSTRAINT PK_TB_POST_REPORT PRIMARY KEY (REPORT_ID)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_VOLUNTEER_APPLY (봉사신청)
-- CREATE TABLE TB_VOLUNTEER_APPLY (
--     APPLY_ID                         NUMBER                   NOT NULL,  -- 신청 ID
--     VOLUNTEER_ID                     NUMBER                   NOT NULL,  -- 봉사 ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
--     CONTACT                          VARCHAR2(200)            NULL,  -- 연락
--     MOTIVATION                       VARCHAR2(200)            NULL,  -- 지원 동기
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
--     CONSTRAINT PK_TB_VOLUNTEER_APPLY PRIMARY KEY (APPLY_ID)
-- );

-- TB_RESERVATION (예약)
-- 2026/07/31 장우철 — STATUS에 CHECKIN/CHECKOUT 추가, 취소 위약금/환불액 컬럼
CREATE TABLE TB_RESERVATION (
    RESV_ID                          NUMBER                   NOT NULL,  -- 예약 ID
    RESV_NO                          VARCHAR2(100)            NOT NULL,  -- 예약번호
    RESV_TYPE                        VARCHAR2(200)            NOT NULL,  -- 예약유형(HOSPITAL / GROOMING / STAY / STUDIO)
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
    PET_ID                           NUMBER                   NOT NULL,  -- 반려동물 ID
    TARGET_ID                        VARCHAR2(200)            NULL,  -- 대상ID
    ROOM_ID                          NUMBER                   NULL,  -- 객실 ID
    SERVICE_NAME                     VARCHAR2(200)            NULL,  -- SERVICE명
    RESV_DATE                        DATE                     NULL,  -- 예약일
    RESV_TIME                        VARCHAR2(200)            NULL,  -- 예약시간
    CHECKIN_DATE                     DATE                     NULL,  -- 체크인일
    CHECKOUT_DATE                    DATE                     NULL,  -- 체크아웃일
    NIGHT_CNT                        NUMBER                   NULL,  -- NIGHT수
    SYMPTOMS                         VARCHAR2(200)            NULL,  -- 증상
    REQUEST_MEMO                     VARCHAR2(200)            NULL,  -- 요청MEMO
    TOTAL_AMOUNT                     NUMBER(12)               NULL,  -- 총 주문금액
    STATUS_CD                        VARCHAR2(20)             NOT NULL,  -- PENDING/CONFIRMED/CHECKIN/CHECKOUT/DONE/CANCEL/REJECTED
    REJECT_REASON                    VARCHAR2(500)            NULL,  -- 거절·취소 사유
    -- 2026/07/31 장우철 — 유저/사업자 취소 시 금액 스냅샷 (1-4·1-6)
    CANCEL_FEE_AMT                   NUMBER(12)               NULL,  -- 취소수수료(위약금, 정산 A 대상)
    REFUND_AMT                       NUMBER(12)               NULL,  -- 유저 환불액
    CANCEL_AT                        DATE                     NULL,  -- 취소 처리 시각
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    -- 2026/07/15 장우철 고도화작업 — 유형·소요·종료·의사
    TREAT_TYPE_ID                    NUMBER                   NULL,  -- 진료유형 FK
    DURATION_MIN                     NUMBER                   NULL,  -- 소요 분
    END_TIME                         VARCHAR2(20)             NULL,  -- 종료시각
    DOCTOR_ID                        NUMBER                   NULL,  -- 의사 FK
    MEMBER_COUPON_ID                 NUMBER                   NULL,  -- 사용한 회원쿠폰 ID
    COUPON_DISCOUNT                  NUMBER         DEFAULT 0 NULL,  -- 쿠폰 할인 금액
    POINT_USED                       NUMBER         DEFAULT 0 NULL,  -- 결제 시 사용한 포인트
    PET_CNT                          NUMBER         DEFAULT 1 NULL,
    CONSTRAINT PK_TB_RESERVATION PRIMARY KEY (RESV_ID),
    CONSTRAINT UK_TB_RESERVATION_1 UNIQUE (RESV_NO)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_WALK_REWARD_HIST (산책리워드이력)
-- CREATE TABLE TB_WALK_REWARD_HIST (
--     HIST_ID                          NUMBER                   NOT NULL,  -- 이력 ID
--     WALK_ID                          NUMBER                   NOT NULL,  -- 산책ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
--     POINT_AMOUNT                     VARCHAR2(200)            NULL,  -- 포인트금액
--     REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
--     CONSTRAINT PK_TB_WALK_REWARD_HIST PRIMARY KEY (HIST_ID)
-- );

-- TB_MEDICAL_RECORD (진료기록)
CREATE TABLE TB_MEDICAL_RECORD (
    RECORD_ID                        NUMBER                   NOT NULL,  -- 진료기록 ID
    HOSPITAL_ID                      NUMBER                   NOT NULL,  -- 병원
    RESV_ID                          NUMBER                   NULL,  -- 예약
    PET_ID                           NUMBER                   NOT NULL,  -- 반려동물
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원
    VISIT_DATE                       DATE                     NOT NULL,  -- 진료일
    SYMPTOMS                         VARCHAR2(500)            NULL,  -- 증상
    DIAGNOSIS                        VARCHAR2(500)            NULL,  -- 진단
    PRESCRIPTION                     CLOB                     NULL,  -- 처방
    MEMO                             CLOB                     NULL,  -- 메모
    VET_NAME                         VARCHAR2(50)             NULL,  -- 수의사명
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_MEDICAL_RECORD PRIMARY KEY (RECORD_ID)
);
-- 2026/07/29 장우철
-- TB_SETTLEMENT : 정산 마스터 (숙소/쇼핑 공용)
CREATE TABLE TB_SETTLEMENT (
    SETTLE_ID               NUMBER          NOT NULL,  -- 정산 ID (PK)
    SETTLE_TYPE             VARCHAR2(30)    NULL,      -- 기존유형(COMMISSION/FEE/PARTNER 등)
    RESV_ID                 NUMBER          NULL,      -- 예전 단건정산용. 묶음정산/쇼핑은 NULL
    BIZ_NO                  NUMBER          NOT NULL,  -- 사업자번호
    PAY_AMOUNT              NUMBER          NULL,      -- 실결제금액(호환)
    FEE_RATE                NUMBER(5,2)     NULL,      -- 적용 수수료율(%)
    FEE_AMOUNT              NUMBER          NULL,      -- 수수료금액
    SETTLE_STATUS           VARCHAR2(30)    NULL,      -- PENDING/REQUESTED/HOLD/PAID/REJECTED 등
    REG_DATE                DATE            DEFAULT SYSDATE, -- 등록일
    BIZ_TYPE                VARCHAR2(30)    NULL,      -- STAY/STORE 등
    ANNUAL_FEE              NUMBER          NULL,      -- 연회비(호환)
    APPLY_DATE              DATE            NULL,      -- 신청일(호환)
    SETTLE_MONTH            VARCHAR2(7)     NULL,      -- YYYY-MM
    TOTAL_SALES             NUMBER          NULL,      -- 정산 대상 총액(운영표시용)
    TOTAL_FEE               NUMBER          NULL,      -- 합계 수수료
    SETTLE_AMOUNT           NUMBER          NULL,      -- 실지급 정산금
    PAY_STATUS              VARCHAR2(30)    NULL,      -- WAIT/DONE/FAIL
    PAY_DATE                DATE            NULL,      -- 지급일
    REQUEST_ID              NUMBER          NULL,      -- 중간정산 요청 연결
    REQUEST_TYPE            VARCHAR2(20)    NULL,      -- REGULAR / ADHOC
    REQUEST_SCOPE           VARCHAR2(10)    NULL,      -- ALL / ROOM / PRODUCT
    ROOM_ID                 NUMBER          NULL,      -- 숙소 특정객실 정산
    PRODUCT_ID              NUMBER          NULL,      -- 쇼핑 특정상품 정산
    PERIOD_START            DATE            NULL,      -- 집계 시작
    PERIOD_END              DATE            NULL,      -- 집계 종료
    REQUESTED_AT            DATE            NULL,      -- 중간정산 요청일시
    APPROVED_AT             DATE            NULL,      -- 승인일시
    REJECT_REASON           VARCHAR2(500)   NULL,      -- 거절사유
    PRODUCT_SALES_AMOUNT    NUMBER          NULL,      -- 상품매출(택배비 제외)
    DELIVERY_FEE_AMOUNT     NUMBER          NULL,      -- 택배비 합(패스스루)
    RETURN_FEE_AMOUNT       NUMBER          NULL,      -- 반품택배비 합(사업자 부담분 등)
    CONSTRAINT PK_TB_SETTLEMENT PRIMARY KEY (SETTLE_ID)
);
-- 2026/07/29 장우철
-- TB_SETTLEMENT_REQUEST : 중간정산 요청
CREATE TABLE TB_SETTLEMENT_REQUEST (
    REQUEST_ID      NUMBER         NOT NULL,  -- 요청 ID (PK)
    BIZ_NO          NUMBER         NOT NULL,  -- 요청 사업자
    REQUEST_SCOPE   VARCHAR2(10)   NOT NULL,  -- ALL / ROOM / PRODUCT
    ROOM_ID         NUMBER         NULL,      -- 숙소 객실 지정 시
    PRODUCT_ID      NUMBER         NULL,      -- 쇼핑 상품 지정 시
    TARGET_START    DATE           NOT NULL,  -- 요청 대상 시작일
    TARGET_END      DATE           NOT NULL,  -- 요청 대상 종료일
    STATUS_CD       VARCHAR2(20)   NOT NULL,  -- REQUESTED / APPROVED / REJECTED / CANCELED
    REQUEST_MEMO    VARCHAR2(500)  NULL,      -- 사업자 요청 메모
    REJECT_REASON   VARCHAR2(500)  NULL,      -- 거절 사유
    REQUESTED_AT    DATE           DEFAULT SYSDATE NOT NULL, -- 요청일시
    APPROVED_AT     DATE           NULL,      -- 승인일시
    REJECTED_AT     DATE           NULL,      -- 거절일시
    CONSTRAINT PK_TB_SETTLEMENT_REQUEST PRIMARY KEY (REQUEST_ID)
);

-- TB_SETTLEMENT_ITEM : 정산 상세 (숙소=예약, 쇼핑=주문상품)
-- 2026/07/31 장우철 — ITEM_TYPE 추가 (STAY / CANCEL_FEE / ORDER_ITEM)
CREATE TABLE TB_SETTLEMENT_ITEM (
    SETTLE_ITEM_ID        NUMBER         NOT NULL,  -- 상세 ID (PK)
    SETTLE_ID             NUMBER         NOT NULL,  -- TB_SETTLEMENT.SETTLE_ID
    -- 2026/07/31 장우철 — 정산 상세 유형
    ITEM_TYPE             VARCHAR2(20)   NOT NULL,  -- STAY / CANCEL_FEE / ORDER_ITEM
    -- 숙소용
    RESV_ID               NUMBER         NULL,      -- 예약 ID (쇼핑이면 NULL)
    ROOM_ID               NUMBER         NULL,      -- 객실 ID
    CHECKIN_DATE          DATE           NULL,      -- 체크인일
    CHECKOUT_DATE         DATE           NULL,      -- 체크아웃일
    RESV_AMOUNT           NUMBER         NULL,      -- 예약 원금(숙소) 또는 위약금 원금(CANCEL_FEE)
    -- 쇼핑용
    ORDER_ID              NUMBER         NULL,      -- 주문 ID
    ORDER_ITEM_ID         NUMBER         NULL,      -- 주문상품 ID
    PRODUCT_ID            NUMBER         NULL,      -- 상품 ID
    CONFIRMED_AT          DATE           NULL,      -- 구매확정 시각
    ITEM_SALES_AMOUNT     NUMBER         NULL,      -- 상품매출(택배 제외)
    DELIVERY_FEE_AMOUNT   NUMBER         NULL,      -- 이 건 배송비
    RETURN_FEE_AMOUNT     NUMBER         NULL,      -- 반품 택배비
    RETURN_FEE_PAYER      VARCHAR2(10)   NULL,      -- USER / BIZ
    -- 공통 계산/상태
    FEE_RATE              NUMBER(5,2)    NOT NULL,  -- 건별 수수료율
    FEE_AMOUNT            NUMBER         NOT NULL,  -- 건별 수수료
    SETTLE_AMOUNT         NUMBER         NOT NULL,  -- 건별 실정산금
    STATUS_CD             VARCHAR2(20)   NOT NULL,  -- INCLUDED / HOLD / EXCLUDED / REFUNDED
    HOLD_REASON           VARCHAR2(500)  NULL,      -- 보류/제외 사유
    REG_DATE              DATE           DEFAULT SYSDATE, -- 등록일
    CONSTRAINT PK_TB_SETTLEMENT_ITEM PRIMARY KEY (SETTLE_ITEM_ID)
);

-- 숙소: 같은 예약 중복 정산 방지
CREATE UNIQUE INDEX UX_SETTLE_ITEM_RESV
    ON TB_SETTLEMENT_ITEM (RESV_ID);
-- 쇼핑: 같은 주문상품 중복 정산 방지
CREATE UNIQUE INDEX UX_SETTLE_ITEM_ORDER_ITEM
    ON TB_SETTLEMENT_ITEM (ORDER_ITEM_ID);

-- TB_PRODUCT_CATEGORY (상품카테고리)
CREATE TABLE TB_PRODUCT_CATEGORY (
    CATEGORY_ID                      NUMBER                   NOT NULL,  -- 카테고리 ID
    PARENT_ID                        NUMBER                   NOT NULL,  -- 상위 카테고리 ID
    CATEGORY_NAME                    VARCHAR2(200)            NULL,  -- 카테고리명
    DEPTH                            VARCHAR2(200)            NULL,  -- 카테고리 깊이
    USE_YN                           VARCHAR2(200)            NULL,  -- 여부
    CONSTRAINT PK_TB_PRODUCT_CATEGORY PRIMARY KEY (CATEGORY_ID)
);

-- TB_PRODUCT (상품)
CREATE TABLE TB_PRODUCT (
    PRODUCT_ID                       NUMBER                   NOT NULL,  -- 상품 ID
    PRODUCT_CD                       VARCHAR2(100)            NOT NULL,  -- 상품코드
    PRODUCT_NAME                     VARCHAR2(200)            NULL,  -- 상품명
    BIZ_NO                           NUMBER                   NOT NULL,  -- 사업자번호
    CATEGORY_ID                      NUMBER                   NOT NULL,  -- 카테고리 ID
    PRICE                            VARCHAR2(200)            NULL,  -- 가격
    SALE_PRICE                       VARCHAR2(200)            NULL,  -- 판매가격
    STOCK_QTY                        VARCHAR2(200)            NULL,  -- 재고수량
    LOW_STOCK_THRESHOLD              VARCHAR2(200)            NULL,  -- LOW재고THRESHOLD
    DESCRIPTION                      CLOB                     NULL,  -- 설명
    STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
    APPROVE_DATE                     VARCHAR2(200)            NULL,  -- 승인일
    REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
    BRAND_NAME                       VARCHAR2(100)            NULL,  -- 브랜드명 (TB_BRAND 통합)
    TAGS                             VARCHAR2(200)            NULL,
    CONSTRAINT PK_TB_PRODUCT PRIMARY KEY (PRODUCT_ID),
    CONSTRAINT UK_TB_PRODUCT_1 UNIQUE (PRODUCT_CD)
);

-- TB_PRODUCT_OPTION (상품옵션)
CREATE TABLE TB_PRODUCT_OPTION (
    OPTION_ID                        NUMBER                   NOT NULL,  -- 옵션 ID
    PRODUCT_ID                       NUMBER                   NOT NULL,  -- 상품
    OPTION_COLOR                     VARCHAR2(50)             NOT NULL,  -- 색상
    OPTION_SIZE                      VARCHAR2(20)             NULL,  -- 사이즈
    ADD_PRICE                        NUMBER                   NULL,  -- 추가금액
    STOCK_QTY                        NUMBER                   NULL,  -- 옵션 재고
    CONSTRAINT PK_TB_PRODUCT_OPTION PRIMARY KEY (OPTION_ID)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_PRODUCT_APPROVAL (상품승인)
-- CREATE TABLE TB_PRODUCT_APPROVAL (
--     APPROVAL_ID                      NUMBER                   NOT NULL,  -- 승인ID
--     PRODUCT_ID                       NUMBER                   NOT NULL,  -- 상품 ID
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     REJECT_REASON                    VARCHAR2(200)            NULL,  -- 거절사유
--     APPLY_DATE                       VARCHAR2(200)            NULL,  -- 신청일
--     ADMIN_NO                         NUMBER                   NOT NULL,  -- 관리자번호
--     CONSTRAINT PK_TB_PRODUCT_APPROVAL PRIMARY KEY (APPROVAL_ID)
-- );

-- TB_PRODUCT_QNA (상품Q&A)
CREATE TABLE TB_PRODUCT_QNA (
    QNA_ID                           NUMBER                   NOT NULL,  -- 상품문의 ID
    PRODUCT_ID                       NUMBER                   NOT NULL,  -- 상품 ID
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
    QUESTION                         CLOB                     NULL,  -- 질문
    ANSWER                           CLOB                     NULL,  -- 답변
    ANSWER_DATE                      VARCHAR2(200)            NULL,  -- 답변일
    REG_DATE                         VARCHAR2(200)            NULL,  -- 등록일
    OPTION_ID                        NUMBER                   NULL,
    CONSTRAINT PK_TB_PRODUCT_QNA PRIMARY KEY (QNA_ID)
);

-- TB_CART_ITEM (장바구니항목)
CREATE TABLE TB_CART_ITEM (
    CART_ITEM_ID                     NUMBER                   NOT NULL,  -- 장바구니 항목 ID
    CART_ID                          NUMBER                   NOT NULL,  -- 장바구니 ID
    PRODUCT_ID                       NUMBER                   NOT NULL,  -- 상품 ID
    OPTION_ID                        NUMBER                   NOT NULL,  -- 옵션 ID
    QTY                              VARCHAR2(200)            NULL,  -- 수량
    PRICE                            VARCHAR2(200)            NULL,  -- 가격
    CONSTRAINT PK_TB_CART_ITEM PRIMARY KEY (CART_ITEM_ID)
);
-- 2026/07/29 장우철
-- TB_ORDER : 주문
CREATE TABLE TB_ORDER (
    ORDER_ID              NUMBER          NOT NULL,  -- 주문 ID
    ORDER_NO              VARCHAR2(100)   NOT NULL,  -- 주문번호
    MEMBER_NO             NUMBER          NOT NULL,  -- 회원번호
    ORDER_STATUS          VARCHAR2(30)    NOT NULL,  -- 주문상태
    TOTAL_AMOUNT          NUMBER          NOT NULL,  -- 총 주문금액(상품합)
    DISCOUNT_AMOUNT       NUMBER          NOT NULL,  -- 할인금액
    POINT_USED            NUMBER          NOT NULL,  -- 사용 포인트
    PAY_AMOUNT            NUMBER          NOT NULL,  -- 실결제금액
    ORDER_DATE            DATE            NOT NULL,  -- 주문/결제일
    RECV_NAME             VARCHAR2(50)    NOT NULL,  -- 받는 사람
    RECV_PHONE            VARCHAR2(20)    NOT NULL,  -- 연락처
    ZIP_CODE              VARCHAR2(10)    NULL,      -- 우편번호
    ADDR1                 VARCHAR2(200)   NOT NULL,  -- 기본주소
    ADDR2                 VARCHAR2(100)   NULL,      -- 상세주소
    DELIVERY_MEMO         VARCHAR2(500)   NULL,      -- 배송메모(코드에서 사용 중이면 유지)
    DELIVERY_FEE          NUMBER          NULL,      -- 배송비
    BIZ_NO                NUMBER          NULL,  -- 사업자번호
    MEMBER_COUPON_ID      NUMBER          NULL,      -- 사용 쿠폰(코드에서 사용 중이면 유지)
    -- 주문단위 클레임/취소(레거시·주문전체 취소용)
    CLAIM_TYPE            VARCHAR2(20)    NULL,      -- NONE/CANCEL/RETURN (EXCHANGE 미사용)
    CLAIM_STATUS          VARCHAR2(20)    NULL,      -- 클레임 처리상태
    CANCEL_REASON         VARCHAR2(200)   NULL,      -- 취소 사유
    REFUND_AMOUNT         NUMBER          NULL,      -- 환불금액
    REFUND_STATUS         VARCHAR2(30)    NULL,      -- 환불상태
    ADMIN_VIEW_YN         CHAR(1)         NULL,      -- 관리자 열람 여부
    REQUESTED_AT          DATE            NULL,      -- 취소/클레임 신청일시
    -- 주문단위 반품 컬럼(레거시 호환). 상품단위 반품의 본체는 ORDER_ITEM
    ORDER_ITEM_ID         NUMBER          NULL,      -- 단일상품 반품 대상(레거시)
    RETURN_TYPE           VARCHAR2(10)    NULL,      -- RETURN (EXCHANGE 미사용)
    RETURN_REASON         VARCHAR2(500)   NULL,      -- 사유(레거시 텍스트)
    RETURN_STATUS_CD      VARCHAR2(20)    NULL,      -- 주문단위 반품상태(레거시)
    RETURN_REQUESTED_AT   DATE            NULL,      -- 주문단위 반품 신청일시(레거시)
    CONFIRM_YN                        CHAR(1)   DEFAULT 'N'    NULL,  -- 구매확정 여부 (Y=적립금 지급완료, 26.7.23 지윤추가)
    CONFIRMED_AT                      DATE                     NULL,  -- 구매확정 일시 (26.7.23 지윤추가)
    CONSTRAINT PK_TB_ORDER PRIMARY KEY (ORDER_ID),
    CONSTRAINT UK_TB_ORDER_1 UNIQUE (ORDER_NO)
);

-- 2026/07/29 장우철
-- TB_ORDER_ITEM : 주문상품 + 구매확정/반품 상태
CREATE TABLE TB_ORDER_ITEM (
    ORDER_ITEM_ID          NUMBER         NOT NULL,  -- 주문상품 ID
    ORDER_ID               NUMBER         NOT NULL,  -- 주문
    PRODUCT_ID             NUMBER         NOT NULL,  -- 상품
    OPTION_ID              NUMBER         NULL,      -- 선택 옵션
    OPTION_COLOR           VARCHAR2(50)   NULL,      -- 색상 스냅샷
    OPTION_SIZE            VARCHAR2(20)   NULL,      -- 사이즈 스냅샷
    PRODUCT_NAME           VARCHAR2(200)  NULL,      -- 상품명 스냅샷
    QTY                    NUMBER         NOT NULL,  -- 수량
    UNIT_PRICE             NUMBER         NOT NULL,  -- 단가
    TOTAL_PRICE            NUMBER         NOT NULL,  -- 합계
    -- 기존 클레임(있으면 유지)
    CLAIM_STATUS           VARCHAR2(20)   NULL,      -- 클레임 상태
    CLAIM_REASON           VARCHAR2(500)  NULL,      -- 클레임 사유
    -- 구매확정/타이머
    CONFIRMED_AT           DATE           NULL,      -- 구매확정 시각(정산 집계 핵심)
    CONFIRM_DUE_AT         DATE           NULL,      -- 배송완료+7일 자동확정 예정
    CONFIRM_HOLD_YN        CHAR(1)        DEFAULT 'N' NOT NULL, -- 반품중 타이머 보류 Y/N
    -- 반품 상태머신(상품단위)
    RETURN_STATUS_CD       VARCHAR2(20)   NULL,      -- NONE/REQUESTED/REJECTED/APPROVED/RETURNING/DONE
    RETURN_REASON_CD       VARCHAR2(30)   NULL,      -- CHANGE_OF_MIND / DEFECT
    RETURN_CHECK_RESULT_CD VARCHAR2(20)   NULL,      -- PENDING / DEFECT / NOT_DEFECT
    RETURN_FEE_PAYER       VARCHAR2(10)   NULL,      -- USER / BIZ
    RETURN_FEE_AMOUNT      NUMBER         NULL,      -- 반품 택배비
    RETURN_REQUESTED_AT    DATE           NULL,      -- 신청
    RETURN_APPROVED_AT     DATE           NULL,      -- 승인
    RETURN_REJECTED_AT     DATE           NULL,      -- 거절
    RETURN_DONE_AT         DATE           NULL,      -- 환불/반품완료
    REFUND_AMOUNT          NUMBER         NULL,  -- 상품단위 실환불액 (상품금액 - 반품택배비 등)
    RETURN_REJECT_REASON   VARCHAR2(500)  NULL,   -- 사업자 환불 거절 사유
    CONSTRAINT PK_TB_ORDER_ITEM PRIMARY KEY (ORDER_ITEM_ID)
);

-- TB_ORDER_DELIVERY (주문배송)
CREATE TABLE TB_ORDER_DELIVERY (
    DELIVERY_ID                      NUMBER                   NOT NULL,  -- 배송 ID
    ORDER_ID                         NUMBER                   NOT NULL,  -- 주문
    BIZ_NO                           NUMBER                   NOT NULL,  -- 발송 사업자
    COURIER_NAME                     VARCHAR2(50)             NULL,  -- 택배사명
    TRACKING_NO                      VARCHAR2(30)             NULL,  -- 송장번호
    DELIVERY_STATUS                  VARCHAR2(20)             NOT NULL,  -- 배송상태 (READY/SHIPPING/DELIVERED)
    REGISTERED_AT                    DATE                     NULL,  -- 송장등록일(사업자)
    MEMO                             VARCHAR2(200)            NULL,  -- 비고(택배API미사용)
    DELIVERY_FEE                     NUMBER                   NOT NULL,  -- 배송비
    READY_AT                         DATE                     NULL,  -- 배송준비로 바뀐 시각(26.7.21 지윤추가)
    SHIPPING_AT                      DATE                     NULL,  -- 배송중으로 바뀐 시각(26.7.21 지윤추가)
    DELIVERED_AT                     DATE                     NULL,  -- 배송완료로 바뀐 시각(26.7.21 지윤추가)
    COURIER_CODE		VARCHAR(10)	NULL, -- 스마트택배 API 택배사 코드 (26.7.28 지윤추가)
    CONSTRAINT PK_TB_ORDER_DELIVERY PRIMARY KEY (DELIVERY_ID)
);

-- TB_PAYMENT (결제)
-- 2026/07/31 장우철 — 부분환불 금액 REFUND_AMT
CREATE TABLE TB_PAYMENT (
    PAYMENT_ID                       NUMBER                   NOT NULL,  -- 결제 ID
    ORDER_ID                         NUMBER                   NULL,  -- 주문
    RESV_ID                          NUMBER                   NULL,  -- 예약
    PAY_TYPE                         VARCHAR2(20)             NOT NULL,  -- ORDER/RESERVATION
    PAY_METHOD                       VARCHAR2(20)             NULL,  -- CARD/TRANSFER/KAKAO/NAVER
    PAY_AMOUNT                       NUMBER                   NOT NULL,  -- 결제금액
    TOSS_PAYMENT_KEY                 VARCHAR2(200)            NULL,  -- 토스 paymentKey
    TOSS_ORDER_ID                    VARCHAR2(100)            NULL,  -- 토스 orderId
    PAY_STATUS                       VARCHAR2(20)             NOT NULL,  -- READY/DONE/CANCEL/REFUND
    PAY_DATE                         DATE                     NULL,  -- 결제일
    -- 2026/07/31 장우철 — 실제 환불 누적/최종액 (부분환불)
    REFUND_AMT                       NUMBER(12)               NULL,  -- 환불금액 (부분환불 포함)
    CONSTRAINT PK_TB_PAYMENT PRIMARY KEY (PAYMENT_ID)
);
-- TB_POST_COMMENT (게시글댓글)
CREATE TABLE TB_POST_COMMENT (
    COMMENT_ID                       NUMBER                   NOT NULL,  -- 댓글 ID
    POST_ID                          NUMBER                   NOT NULL,  -- 게시글
    PARENT_ID                        NUMBER                   NULL,  -- 부모댓글
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 작성자
    BODY                             VARCHAR2(1000)           NOT NULL,  -- 내용
    IS_DELETED                       CHAR(1)                  NULL,  -- 삭제 Y/N
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    DELETE_DATE                      DATE                     NULL,
    CONSTRAINT PK_TB_POST_COMMENT PRIMARY KEY (COMMENT_ID)
);

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_EXPERIENCE_GROUP (체험단)
-- CREATE TABLE TB_EXPERIENCE_GROUP (
--     EXP_ID                           NUMBER                   NOT NULL,  -- 체험단 ID
--     EXP_NAME                         VARCHAR2(200)            NULL,  -- EXP명
--     PRODUCT_ID                       NUMBER                   NOT NULL,  -- 상품 ID
--     RECRUIT_START                    VARCHAR2(200)            NULL,  -- RECRUIT시작
--     RECRUIT_END                      VARCHAR2(200)            NULL,  -- RECRUIT종료
--     CONSTRAINT PK_TB_EXPERIENCE_GROUP PRIMARY KEY (EXP_ID)
-- );

-- 2026/07/21 장우철 — 제외 예정 테이블 CREATE 주석 (DROP은 유지, 팀 확인 후 DROP도 주석)
-- TB_EXPERIENCE_APPLY (체험단신청)
-- CREATE TABLE TB_EXPERIENCE_APPLY (
--     APPLY_ID                         NUMBER                   NOT NULL,  -- 신청 ID
--     EXP_ID                           NUMBER                   NOT NULL,  -- 체험단 ID
--     MEMBER_NO                        NUMBER                   NOT NULL,  -- 회원번호
--     STATUS_CD                        VARCHAR2(200)            NULL,  -- 상태코드
--     CONSTRAINT PK_TB_EXPERIENCE_APPLY PRIMARY KEY (APPLY_ID)
-- );

-- TB_REVIEW (REVIEW)
CREATE TABLE TB_REVIEW (
    REVIEW_ID                        NUMBER                   NOT NULL,  -- 리뷰 ID
    REVIEW_TYPE                      VARCHAR2(20)             NOT NULL,  -- 리뷰 유형 (HOSPITAL/STAY/PRODUCT)
    TARGET_ID                        NUMBER                   NOT NULL,  -- 대상 ID (병원/숙소/상품)
    MEMBER_NO                        NUMBER                   NOT NULL,  -- 작성 회원
    ORDER_ITEM_ID                    NUMBER                   NULL,  -- 상품리뷰용 주문상품
    RESV_ID                          NUMBER                   NULL,  -- 병원리뷰용 예약
    RATING                           NUMBER(2,1)              NOT NULL,  -- 별점
    CONTENT                          VARCHAR2(2000)           NULL,  -- 리뷰 내용
    BIZ_REPLY                        VARCHAR2(1000)           NULL,  -- 사업자 답글
    REG_DATE                         DATE                     NOT NULL,  -- 작성일
    CONSTRAINT PK_TB_REVIEW PRIMARY KEY (REVIEW_ID)
);

-- 2026/07/13 유정 — 사업자 재능나눔 신청 (커뮤니티 TB_POST BOARD_TYPE=SHARE 무료나눔과 분리)
-- TB_TALENT (재능나눔)
CREATE TABLE TB_TALENT (
    TALENT_ID                        NUMBER                   NOT NULL,  -- 재능나눔 ID
    BIZ_NO                           NUMBER                   NOT NULL,  -- 사업자번호 (TB_BUSINESS.BIZ_NO)
    TITLE                            VARCHAR2(200)            NOT NULL,  -- 제목
    TALENT_TYPE                      VARCHAR2(30)             NOT NULL,  -- 유형 (GROOMING/HOSPITAL/PHOTO/TRANSPORT/ETC)
    CAPACITY                         NUMBER                   DEFAULT 1 NOT NULL,  -- 모집 건수
    CURRENT_CNT                      NUMBER                   DEFAULT 0 NOT NULL,  -- 현재 신청/진행 수
    SCHEDULE                         VARCHAR2(200)            NULL,  -- 진행 일정
    DURATION                         VARCHAR2(100)            NULL,  -- 소요 시간
    LOCATION                         VARCHAR2(300)            NULL,  -- 장소
    CONTACT                          VARCHAR2(50)             NULL,  -- 문의 연락처
    BODY                             CLOB                     NULL,  -- 상세 설명
    THUMB_URL                        VARCHAR2(500)            NULL,  -- 대표 이미지 URL (선택)
    STATUS_CD                        VARCHAR2(20)             DEFAULT 'PENDING' NOT NULL,  -- PENDING/APPROVED/REJECTED/DONE
    REJECT_REASON                    VARCHAR2(500)            NULL,  -- 반려 사유
    ADMIN_NO                         NUMBER                   NULL,  -- 승인·반려 처리 관리자
    REG_DATE                         DATE                     DEFAULT SYSDATE NOT NULL,  -- 등록일
    APPROVE_DATE                     DATE                     NULL,  -- 승인일
    CONSTRAINT PK_TB_TALENT PRIMARY KEY (TALENT_ID)
);
-- 재능나눔 참여 신청 (일반 회원 → 병원 글에 신청)
CREATE TABLE TB_TALENT_APPLY (
    APPLY_ID     NUMBER         NOT NULL,   -- 신청 번호 (PK)
    TALENT_ID    NUMBER         NOT NULL,   -- 어떤 재능나눔 글인지 (TB_TALENT FK)
    MEMBER_NO    NUMBER         NOT NULL,   -- 신청한 회원 번호 (TB_MEMBER FK)
    MESSAGE      VARCHAR2(500),             -- 신청 메시지 (선택)
    STATUS_CD    VARCHAR2(20)    NOT NULL,  -- 신청 상태
    REG_DATE     DATE           DEFAULT SYSDATE,
    CONFIRM_DATE DATE,                    -- 병원이 확인한 날짜
    CONSTRAINT PK_TB_TALENT_APPLY PRIMARY KEY (APPLY_ID)
);
CREATE UNIQUE INDEX UX_TALENT_APPLY_MEMBER
    ON TB_TALENT_APPLY (TALENT_ID, MEMBER_NO);
-- 2026/07/13 장우철 — 유저→병원 / 사업자→리뷰유저 신고 (TB_POST_REPORT 와 별개, 화면은 REPORTER_TYPE 필터)
-- TB_REVIEW_REPORT (서비스·리뷰 신고)
CREATE TABLE TB_REVIEW_REPORT (
    REPORT_ID                        NUMBER                   NOT NULL,  -- 신고 ID
    REPORTER_TYPE                    VARCHAR2(10)             NOT NULL,  -- 신고자 유형 (USER/BIZ)
    REPORTER_NO                      NUMBER                   NOT NULL,  -- USER=MEMBER_NO / BIZ=BIZ_NO
    TARGET_MEMBER_NO                 NUMBER                   NULL,  -- 사업자→유저 신고 시 대상 회원
    HOSPITAL_ID                      NUMBER                   NULL,  -- 유저→병원 신고 시 대상 병원
    REVIEW_ID                        NUMBER                   NULL,  -- 관련 리뷰 (있으면)
    BIZ_NO                           NUMBER                   NULL,  -- 관련 사업자
    REASON                           VARCHAR2(500)            NULL,  -- 신고 사유
    STATUS_CD                        VARCHAR2(20)             DEFAULT 'PENDING' NOT NULL,  -- PENDING/DONE
    ADMIN_NO                         NUMBER                   NULL,  -- 처리 관리자 (접수 시 NULL)
    REG_DATE                         DATE                     DEFAULT SYSDATE NOT NULL,  -- 접수일
    CONSTRAINT PK_TB_REVIEW_REPORT PRIMARY KEY (REPORT_ID)
);

CREATE TABLE TB_REVIEW_DELETE_REQUEST (
    REQUEST_ID      NUMBER          NOT NULL,  -- PK
    REVIEW_ID       NUMBER          NOT NULL,  -- 대상 리뷰
    REVIEW_TYPE     VARCHAR2(20)    NOT NULL,  -- HOSPITAL / STAY
    TARGET_ID       NUMBER          NOT NULL,  -- 병원ID 또는 숙소ID
    BIZ_NO          NUMBER          NOT NULL,  -- 요청 사업자
    REQUEST_REASON  VARCHAR2(1000),            -- 삭제 요청 사유
    REJECT_REASON   VARCHAR2(1000),            -- 관리자 반려 사유
    STATUS_CD       VARCHAR2(20)    DEFAULT 'PENDING' NOT NULL, -- PENDING/APPROVED/REJECTED
    REQ_DATE        DATE            DEFAULT SYSDATE,
    ADMIN_NO        NUMBER,                    -- 처리 관리자
    PROCESS_DATE    DATE,                      -- 승인/반려일
    CONSTRAINT PK_TB_REVIEW_DELETE_REQUEST PRIMARY KEY (REQUEST_ID)
);
-- TB_BILLING_CARD (토스 빌링키/등록카드)
-- 2026/07/27 장우철
CREATE TABLE TB_BILLING_CARD (
    BILLING_CARD_ID                  NUMBER                   NOT NULL,  -- 빌링카드 ID
    OWNER_TYPE                       VARCHAR2(20)             NOT NULL,  -- 소유자 유형 (MEMBER/ADMIN)
    OWNER_NO                         NUMBER                   NOT NULL,  -- 회원번호 또는 관리자번호
    CUSTOMER_KEY                     VARCHAR2(300)            NOT NULL,  -- 토스 customerKey
    BILLING_KEY                      VARCHAR2(300)            NOT NULL,  -- 토스 billingKey
    CARD_COMPANY                     VARCHAR2(100)            NULL,      -- 카드사명
    CARD_NUMBER                      VARCHAR2(100)            NULL,      -- 마스킹 카드번호
    STATUS_CD                        VARCHAR2(20)             NOT NULL,  -- 상태코드 (ACTIVE/DELETED)
    REG_DATE                         DATE                     NOT NULL,  -- 등록일
    CONSTRAINT PK_TB_BILLING_CARD PRIMARY KEY (BILLING_CARD_ID)
);

-- ==================== 3. FOREIGN KEY ====================

-- TB_MEMBER.GRADE_CD → TB_MEMBER_GRADE.GRADE_CD
ALTER TABLE TB_MEMBER
    ADD CONSTRAINT FK_PTN65_0001
    FOREIGN KEY (GRADE_CD) REFERENCES TB_MEMBER_GRADE (GRADE_CD);

-- TB_MEMBER_SOCIAL.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_MEMBER_SOCIAL
    ADD CONSTRAINT FK_PTN65_0002
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_MEMBER_AGREEMENT.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_MEMBER_AGREEMENT
    ADD CONSTRAINT FK_PTN65_0003
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_MEMBER_ADDRESS.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_MEMBER_ADDRESS
    ADD CONSTRAINT FK_PTN65_0004
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_PET.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_PET
    ADD CONSTRAINT FK_PTN65_0005
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_FAVORITE.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_FAVORITE
    ADD CONSTRAINT FK_PTN65_0006
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_NOTIFICATION.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_NOTIFICATION
    ADD CONSTRAINT FK_PTN65_0007
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/08/10 장우철 — TB_FCM_TOKEN CREATE 미사용(주석) + 앱 코드 미연동 → FK 비활성
-- TB_FCM_TOKEN.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_FCM_TOKEN
--     ADD CONSTRAINT FK_PTN65_0008
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_BUSINESS_AUTH.BIZ_NO → TB_BUSINESS.BIZ_NO
ALTER TABLE TB_BUSINESS_AUTH
    ADD CONSTRAINT FK_PTN65_0009
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_BUSINESS_AUTH.DOC_FILE_ID → TB_FILE.FILE_ID
ALTER TABLE TB_BUSINESS_AUTH
    ADD CONSTRAINT FK_PTN65_0010
    FOREIGN KEY (DOC_FILE_ID) REFERENCES TB_FILE (FILE_ID);

-- TB_BUSINESS_AUTH.ADMIN_NO → TB_ADMIN.ADMIN_NO
ALTER TABLE TB_BUSINESS_AUTH
    ADD CONSTRAINT FK_PTN65_0011
    FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- TB_HOSPITAL.BIZ_NO → TB_BUSINESS.BIZ_NO
ALTER TABLE TB_HOSPITAL
    ADD CONSTRAINT FK_PTN65_0012
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_STAY.BIZ_NO → TB_BUSINESS.BIZ_NO
ALTER TABLE TB_STAY
    ADD CONSTRAINT FK_PTN65_0013
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_STAY_ROOM.STAY_ID → TB_STAY.STAY_ID
ALTER TABLE TB_STAY_ROOM
    ADD CONSTRAINT FK_PTN65_0014
    FOREIGN KEY (STAY_ID) REFERENCES TB_STAY (STAY_ID);

-- TB_ADMIN.ROLE_ID → TB_ADMIN_ROLE.ROLE_ID
ALTER TABLE TB_ADMIN
    ADD CONSTRAINT FK_PTN65_0015
    FOREIGN KEY (ROLE_ID) REFERENCES TB_ADMIN_ROLE (ROLE_ID);

-- 2026/08/10 장우철 — TB_ADMIN_LOG CREATE 미사용(주석) + 앱 코드 미연동 → FK 비활성
-- TB_ADMIN_LOG.ADMIN_NO → TB_ADMIN.ADMIN_NO
-- ALTER TABLE TB_ADMIN_LOG
--     ADD CONSTRAINT FK_PTN65_0016
--     FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- TB_PRODUCT_CATEGORY.PARENT_ID → TB_PRODUCT_CATEGORY.CATEGORY_ID
ALTER TABLE TB_PRODUCT_CATEGORY
    ADD CONSTRAINT FK_PTN65_0017
    FOREIGN KEY (PARENT_ID) REFERENCES TB_PRODUCT_CATEGORY (CATEGORY_ID);

-- TB_PRODUCT.BIZ_NO → TB_BUSINESS.BIZ_NO
ALTER TABLE TB_PRODUCT
    ADD CONSTRAINT FK_PTN65_0018
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_PRODUCT.CATEGORY_ID → TB_PRODUCT_CATEGORY.CATEGORY_ID
ALTER TABLE TB_PRODUCT
    ADD CONSTRAINT FK_PTN65_0019
    FOREIGN KEY (CATEGORY_ID) REFERENCES TB_PRODUCT_CATEGORY (CATEGORY_ID);

-- TB_PRODUCT_OPTION.PRODUCT_ID → TB_PRODUCT.PRODUCT_ID
ALTER TABLE TB_PRODUCT_OPTION
    ADD CONSTRAINT FK_PTN65_0020
    FOREIGN KEY (PRODUCT_ID) REFERENCES TB_PRODUCT (PRODUCT_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_PRODUCT_APPROVAL.PRODUCT_ID → TB_PRODUCT.PRODUCT_ID
-- ALTER TABLE TB_PRODUCT_APPROVAL
--     ADD CONSTRAINT FK_PTN65_0021
--     FOREIGN KEY (PRODUCT_ID) REFERENCES TB_PRODUCT (PRODUCT_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_PRODUCT_APPROVAL.ADMIN_NO → TB_ADMIN.ADMIN_NO
-- ALTER TABLE TB_PRODUCT_APPROVAL
--     ADD CONSTRAINT FK_PTN65_0022
--     FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- TB_PRODUCT_QNA.PRODUCT_ID → TB_PRODUCT.PRODUCT_ID
ALTER TABLE TB_PRODUCT_QNA
    ADD CONSTRAINT FK_PTN65_0023
    FOREIGN KEY (PRODUCT_ID) REFERENCES TB_PRODUCT (PRODUCT_ID);

-- TB_PRODUCT_QNA.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_PRODUCT_QNA
    ADD CONSTRAINT FK_PTN65_0024
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_CART.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_CART
    ADD CONSTRAINT FK_PTN65_0025
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_CART_ITEM.CART_ID → TB_CART.CART_ID
ALTER TABLE TB_CART_ITEM
    ADD CONSTRAINT FK_PTN65_0026
    FOREIGN KEY (CART_ID) REFERENCES TB_CART (CART_ID);

-- TB_CART_ITEM.PRODUCT_ID → TB_PRODUCT.PRODUCT_ID
ALTER TABLE TB_CART_ITEM
    ADD CONSTRAINT FK_PTN65_0027
    FOREIGN KEY (PRODUCT_ID) REFERENCES TB_PRODUCT (PRODUCT_ID);

-- TB_CART_ITEM.OPTION_ID → TB_PRODUCT_OPTION.OPTION_ID
ALTER TABLE TB_CART_ITEM
    ADD CONSTRAINT FK_PTN65_0028
    FOREIGN KEY (OPTION_ID) REFERENCES TB_PRODUCT_OPTION (OPTION_ID);

-- TB_ORDER.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_ORDER
    ADD CONSTRAINT FK_PTN65_0029
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_ORDER.BIZ_NO → TB_BUSINESS.BIZ_NO
ALTER TABLE TB_ORDER
    ADD CONSTRAINT FK_PTN65_0030
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_ORDER.ORDER_ITEM_ID → TB_ORDER_ITEM.ORDER_ITEM_ID
ALTER TABLE TB_ORDER
    ADD CONSTRAINT FK_PTN65_0031
    FOREIGN KEY (ORDER_ITEM_ID) REFERENCES TB_ORDER_ITEM (ORDER_ITEM_ID);

-- TB_ORDER_ITEM.ORDER_ID → TB_ORDER.ORDER_ID
ALTER TABLE TB_ORDER_ITEM
    ADD CONSTRAINT FK_PTN65_0032
    FOREIGN KEY (ORDER_ID) REFERENCES TB_ORDER (ORDER_ID);

-- TB_ORDER_ITEM.PRODUCT_ID → TB_PRODUCT.PRODUCT_ID
ALTER TABLE TB_ORDER_ITEM
    ADD CONSTRAINT FK_PTN65_0033
    FOREIGN KEY (PRODUCT_ID) REFERENCES TB_PRODUCT (PRODUCT_ID);

-- TB_ORDER_ITEM.OPTION_ID → TB_PRODUCT_OPTION.OPTION_ID
ALTER TABLE TB_ORDER_ITEM
    ADD CONSTRAINT FK_PTN65_0034
    FOREIGN KEY (OPTION_ID) REFERENCES TB_PRODUCT_OPTION (OPTION_ID);

-- TB_ORDER_DELIVERY.ORDER_ID → TB_ORDER.ORDER_ID
ALTER TABLE TB_ORDER_DELIVERY
    ADD CONSTRAINT FK_PTN65_0035
    FOREIGN KEY (ORDER_ID) REFERENCES TB_ORDER (ORDER_ID);

-- TB_ORDER_DELIVERY.BIZ_NO → TB_BUSINESS.BIZ_NO
ALTER TABLE TB_ORDER_DELIVERY
    ADD CONSTRAINT FK_PTN65_0036
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_PAYMENT.ORDER_ID → TB_ORDER.ORDER_ID
ALTER TABLE TB_PAYMENT
    ADD CONSTRAINT FK_PTN65_0037
    FOREIGN KEY (ORDER_ID) REFERENCES TB_ORDER (ORDER_ID);

-- TB_PAYMENT.RESV_ID → TB_RESERVATION.RESV_ID
ALTER TABLE TB_PAYMENT
    ADD CONSTRAINT FK_PTN65_0038
    FOREIGN KEY (RESV_ID) REFERENCES TB_RESERVATION (RESV_ID);

-- TB_MEMBER_COUPON.COUPON_ID → TB_COUPON.COUPON_ID
ALTER TABLE TB_MEMBER_COUPON
    ADD CONSTRAINT FK_PTN65_0039
    FOREIGN KEY (COUPON_ID) REFERENCES TB_COUPON (COUPON_ID);

-- TB_MEMBER_COUPON.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_MEMBER_COUPON
    ADD CONSTRAINT FK_PTN65_0040
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_BANNER.BIZ_NO → TB_BUSINESS.BIZ_NO
-- 2026/08/01 장우철 — yeju 배너 스키마
ALTER TABLE TB_BANNER
    ADD CONSTRAINT FK_PTN65_0041A
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_BANNER.FILE_ID → TB_FILE.FILE_ID
ALTER TABLE TB_BANNER
    ADD CONSTRAINT FK_PTN65_0041
    FOREIGN KEY (FILE_ID) REFERENCES TB_FILE (FILE_ID);

-- 2026/08/10 장우철 — TB_AD_PAYMENT CREATE 미사용(주석) + 앱 코드 미연동 → FK 비활성
-- TB_AD_PAYMENT.BIZ_NO → TB_BUSINESS.BIZ_NO
-- ALTER TABLE TB_AD_PAYMENT
--     ADD CONSTRAINT FK_PTN65_0042
--     FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_RESERVATION.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_RESERVATION
    ADD CONSTRAINT FK_PTN65_0043
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_RESERVATION.PET_ID → TB_PET.PET_ID
ALTER TABLE TB_RESERVATION
    ADD CONSTRAINT FK_PTN65_0044
    FOREIGN KEY (PET_ID) REFERENCES TB_PET (PET_ID);

-- TB_RESERVATION.ROOM_ID → TB_STAY_ROOM.ROOM_ID
ALTER TABLE TB_RESERVATION
    ADD CONSTRAINT FK_PTN65_0045
    FOREIGN KEY (ROOM_ID) REFERENCES TB_STAY_ROOM (ROOM_ID);

-- 2026/07/16 장우철 고도화작업 — TB_RESERVATION_SLOT.HOSPITAL_ID FK(0046) 제거 (슬롯 테이블 폐기)

-- TB_MEDICAL_RECORD.HOSPITAL_ID → TB_HOSPITAL.HOSPITAL_ID
ALTER TABLE TB_MEDICAL_RECORD
    ADD CONSTRAINT FK_PTN65_0047
    FOREIGN KEY (HOSPITAL_ID) REFERENCES TB_HOSPITAL (HOSPITAL_ID);

-- TB_MEDICAL_RECORD.RESV_ID → TB_RESERVATION.RESV_ID
ALTER TABLE TB_MEDICAL_RECORD
    ADD CONSTRAINT FK_PTN65_0048
    FOREIGN KEY (RESV_ID) REFERENCES TB_RESERVATION (RESV_ID);

-- TB_MEDICAL_RECORD.PET_ID → TB_PET.PET_ID
ALTER TABLE TB_MEDICAL_RECORD
    ADD CONSTRAINT FK_PTN65_0049
    FOREIGN KEY (PET_ID) REFERENCES TB_PET (PET_ID);

-- TB_MEDICAL_RECORD.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_MEDICAL_RECORD
    ADD CONSTRAINT FK_PTN65_0050
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_PET_HEALTH.PET_ID → TB_PET.PET_ID
-- ALTER TABLE TB_PET_HEALTH
--     ADD CONSTRAINT FK_PTN65_0051
--     FOREIGN KEY (PET_ID) REFERENCES TB_PET (PET_ID);

-- TB_POST.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_POST
    ADD CONSTRAINT FK_PTN65_0052
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_POST_COMMENT.POST_ID → TB_POST.POST_ID
ALTER TABLE TB_POST_COMMENT
    ADD CONSTRAINT FK_PTN65_0053
    FOREIGN KEY (POST_ID) REFERENCES TB_POST (POST_ID);

-- TB_POST_COMMENT.PARENT_ID → TB_POST_COMMENT.COMMENT_ID
ALTER TABLE TB_POST_COMMENT
    ADD CONSTRAINT FK_PTN65_0054
    FOREIGN KEY (PARENT_ID) REFERENCES TB_POST_COMMENT (COMMENT_ID);

-- TB_POST_COMMENT.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_POST_COMMENT
    ADD CONSTRAINT FK_PTN65_0055
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_POST_LIKE.POST_ID → TB_POST.POST_ID
ALTER TABLE TB_POST_LIKE
    ADD CONSTRAINT FK_PTN65_0056
    FOREIGN KEY (POST_ID) REFERENCES TB_POST (POST_ID);

-- TB_POST_LIKE.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_POST_LIKE
    ADD CONSTRAINT FK_PTN65_0057
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_POST_REPORT.POST_ID → TB_POST.POST_ID
ALTER TABLE TB_POST_REPORT
    ADD CONSTRAINT FK_PTN65_0058
    FOREIGN KEY (POST_ID) REFERENCES TB_POST (POST_ID);

-- TB_POST_REPORT.REPORTER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_POST_REPORT
    ADD CONSTRAINT FK_PTN65_0059
    FOREIGN KEY (REPORTER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_POST_REPORT.ADMIN_NO → TB_ADMIN.ADMIN_NO
-- 2026/07/11 장우철 — ADMIN_NO NULL 허용 (접수 건은 FK 미연결, 처리 시에만 참조)
ALTER TABLE TB_POST_REPORT
    ADD CONSTRAINT FK_PTN65_0060
    FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_EXPERIENCE_GROUP.PRODUCT_ID → TB_PRODUCT.PRODUCT_ID
-- ALTER TABLE TB_EXPERIENCE_GROUP
--     ADD CONSTRAINT FK_PTN65_0061
--     FOREIGN KEY (PRODUCT_ID) REFERENCES TB_PRODUCT (PRODUCT_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_EXPERIENCE_APPLY.EXP_ID → TB_EXPERIENCE_GROUP.EXP_ID
-- ALTER TABLE TB_EXPERIENCE_APPLY
--     ADD CONSTRAINT FK_PTN65_0062
--     FOREIGN KEY (EXP_ID) REFERENCES TB_EXPERIENCE_GROUP (EXP_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_EXPERIENCE_APPLY.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_EXPERIENCE_APPLY
--     ADD CONSTRAINT FK_PTN65_0063
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_WALK_RECORD.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_WALK_RECORD
--     ADD CONSTRAINT FK_PTN65_0064
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_WALK_RECORD.PET_ID → TB_PET.PET_ID
-- ALTER TABLE TB_WALK_RECORD
--     ADD CONSTRAINT FK_PTN65_0065
--     FOREIGN KEY (PET_ID) REFERENCES TB_PET (PET_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_WALK_COURSE.POI_ID → TB_POI.POI_ID
-- ALTER TABLE TB_WALK_COURSE
--     ADD CONSTRAINT FK_PTN65_0066
--     FOREIGN KEY (POI_ID) REFERENCES TB_POI (POI_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_WALK_MATE.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_WALK_MATE
--     ADD CONSTRAINT FK_PTN65_0067
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_WALK_MATE.PET_ID → TB_PET.PET_ID
-- ALTER TABLE TB_WALK_MATE
--     ADD CONSTRAINT FK_PTN65_0068
--     FOREIGN KEY (PET_ID) REFERENCES TB_PET (PET_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_WALK_REWARD_HIST.WALK_ID → TB_WALK_RECORD.WALK_ID
-- ALTER TABLE TB_WALK_REWARD_HIST
--     ADD CONSTRAINT FK_PTN65_0069
--     FOREIGN KEY (WALK_ID) REFERENCES TB_WALK_RECORD (WALK_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_WALK_REWARD_HIST.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_WALK_REWARD_HIST
--     ADD CONSTRAINT FK_PTN65_0070
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_POI_REQUEST.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_POI_REQUEST
--     ADD CONSTRAINT FK_PTN65_0071
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_POI_REQUEST.ADMIN_NO → TB_ADMIN.ADMIN_NO
-- ALTER TABLE TB_POI_REQUEST
--     ADD CONSTRAINT FK_PTN65_0072
--     FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- TB_POINT.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_POINT
    ADD CONSTRAINT FK_PTN65_0073
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_DONATION.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_DONATION
--     ADD CONSTRAINT FK_PTN65_0074
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_DONATION.SHELTER_ID → TB_SHELTER.SHELTER_ID
-- ALTER TABLE TB_DONATION
--     ADD CONSTRAINT FK_PTN65_0075
--     FOREIGN KEY (SHELTER_ID) REFERENCES TB_SHELTER (SHELTER_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_DONATION.CERT_FILE_ID → TB_FILE.FILE_ID
-- ALTER TABLE TB_DONATION
--     ADD CONSTRAINT FK_PTN65_0076
--     FOREIGN KEY (CERT_FILE_ID) REFERENCES TB_FILE (FILE_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_VOLUNTEER.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_VOLUNTEER
--     ADD CONSTRAINT FK_PTN65_0077
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_VOLUNTEER_APPLY.VOLUNTEER_ID → TB_VOLUNTEER.VOLUNTEER_ID
-- ALTER TABLE TB_VOLUNTEER_APPLY
--     ADD CONSTRAINT FK_PTN65_0078
--     FOREIGN KEY (VOLUNTEER_ID) REFERENCES TB_VOLUNTEER (VOLUNTEER_ID);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_VOLUNTEER_APPLY.MEMBER_NO → TB_MEMBER.MEMBER_NO
-- ALTER TABLE TB_VOLUNTEER_APPLY
--     ADD CONSTRAINT FK_PTN65_0079
--     FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_INQUIRY.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_INQUIRY
    ADD CONSTRAINT FK_PTN65_0080
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_INQUIRY.PET_ID → TB_PET.PET_ID
ALTER TABLE TB_INQUIRY
    ADD CONSTRAINT FK_PTN65_0081
    FOREIGN KEY (PET_ID) REFERENCES TB_PET (PET_ID);

-- TB_INQUIRY.ADMIN_NO → TB_ADMIN.ADMIN_NO
ALTER TABLE TB_INQUIRY
    ADD CONSTRAINT FK_PTN65_0082
    FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- TB_CONTENT.ADMIN_NO → TB_ADMIN.ADMIN_NO
ALTER TABLE TB_CONTENT
    ADD CONSTRAINT FK_PTN65_0083
    FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- TB_REVIEW.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_REVIEW
    ADD CONSTRAINT FK_PTN65_0084
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_REVIEW.ORDER_ITEM_ID → TB_ORDER_ITEM.ORDER_ITEM_ID
ALTER TABLE TB_REVIEW
    ADD CONSTRAINT FK_PTN65_0085
    FOREIGN KEY (ORDER_ITEM_ID) REFERENCES TB_ORDER_ITEM (ORDER_ITEM_ID);

-- TB_REVIEW.RESV_ID → TB_RESERVATION.RESV_ID
ALTER TABLE TB_REVIEW
    ADD CONSTRAINT FK_PTN65_0086
    FOREIGN KEY (RESV_ID) REFERENCES TB_RESERVATION (RESV_ID);

-- 2026/07/13 유정 — TB_TALENT FK
-- TB_TALENT.BIZ_NO → TB_BUSINESS.BIZ_NO
ALTER TABLE TB_TALENT
    ADD CONSTRAINT FK_PTN65_0093
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_TALENT.ADMIN_NO → TB_ADMIN.ADMIN_NO
ALTER TABLE TB_TALENT
    ADD CONSTRAINT FK_PTN65_0094
    FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- 2026/07/13 장우철 — TB_REVIEW_REPORT FK
-- TB_REVIEW_REPORT.TARGET_MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_REVIEW_REPORT
    ADD CONSTRAINT FK_PTN65_0095
    FOREIGN KEY (TARGET_MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- TB_REVIEW_REPORT.HOSPITAL_ID → TB_HOSPITAL.HOSPITAL_ID
ALTER TABLE TB_REVIEW_REPORT
    ADD CONSTRAINT FK_PTN65_0096
    FOREIGN KEY (HOSPITAL_ID) REFERENCES TB_HOSPITAL (HOSPITAL_ID);

-- TB_REVIEW_REPORT.REVIEW_ID → TB_REVIEW.REVIEW_ID
ALTER TABLE TB_REVIEW_REPORT
    ADD CONSTRAINT FK_PTN65_0097
    FOREIGN KEY (REVIEW_ID) REFERENCES TB_REVIEW (REVIEW_ID);

-- TB_REVIEW_REPORT.BIZ_NO → TB_BUSINESS.BIZ_NO
ALTER TABLE TB_REVIEW_REPORT
    ADD CONSTRAINT FK_PTN65_0098
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_REVIEW_REPORT.ADMIN_NO → TB_ADMIN.ADMIN_NO
ALTER TABLE TB_REVIEW_REPORT
    ADD CONSTRAINT FK_PTN65_0099
    FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- 2026/07/21 장우철 — 제외 테이블 관련 FK 주석
-- TB_STATUS_HIST.ADMIN_NO → TB_ADMIN.ADMIN_NO
-- ALTER TABLE TB_STATUS_HIST
--     ADD CONSTRAINT FK_PTN65_0087
--     FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- 기존 유지
ALTER TABLE TB_SETTLEMENT
    ADD CONSTRAINT FK_PTN65_0089
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

ALTER TABLE TB_SETTLEMENT_REQUEST
    ADD CONSTRAINT FK_SETTLE_REQ_BIZ
    FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

ALTER TABLE TB_SETTLEMENT
    ADD CONSTRAINT FK_SETTLE_REQUEST
    FOREIGN KEY (REQUEST_ID) REFERENCES TB_SETTLEMENT_REQUEST (REQUEST_ID);

ALTER TABLE TB_SETTLEMENT_ITEM
    ADD CONSTRAINT FK_SETTLE_ITEM_SETTLE
    FOREIGN KEY (SETTLE_ID) REFERENCES TB_SETTLEMENT (SETTLE_ID);

ALTER TABLE TB_SETTLEMENT_ITEM
    ADD CONSTRAINT FK_SETTLE_ITEM_RESV
    FOREIGN KEY (RESV_ID) REFERENCES TB_RESERVATION (RESV_ID);

ALTER TABLE TB_SETTLEMENT_ITEM
    ADD CONSTRAINT FK_SETTLE_ITEM_ORDER
    FOREIGN KEY (ORDER_ID) REFERENCES TB_ORDER (ORDER_ID);

ALTER TABLE TB_SETTLEMENT_ITEM
    ADD CONSTRAINT FK_SETTLE_ITEM_ORDER_ITEM
    FOREIGN KEY (ORDER_ITEM_ID) REFERENCES TB_ORDER_ITEM (ORDER_ITEM_ID);

-- 2026/08/10 장우철 — TB_AD CREATE 미사용(주석) + 앱 코드 미연동 → FK 비활성
-- TB_AD.BIZ_NO → TB_BUSINESS.BIZ_NO
-- ALTER TABLE TB_AD
--     ADD CONSTRAINT FK_PTN65_0090
--     FOREIGN KEY (BIZ_NO) REFERENCES TB_BUSINESS (BIZ_NO);

-- TB_AD.FILE_ID → TB_FILE.FILE_ID
-- ALTER TABLE TB_AD
--     ADD CONSTRAINT FK_PTN65_0091
--     FOREIGN KEY (FILE_ID) REFERENCES TB_FILE (FILE_ID);

-- TB_AD.ADMIN_NO → TB_ADMIN.ADMIN_NO
-- ALTER TABLE TB_AD
--     ADD CONSTRAINT FK_PTN65_0092
--     FOREIGN KEY (ADMIN_NO) REFERENCES TB_ADMIN (ADMIN_NO);

-- =========================================================
-- 2026/07/15 장우철 고도화작업 — 병원 예약 FK
-- CREATE 절: FK_PTN65_0100 (유형→병원), FK_PTN65_0103 (의사→병원)
-- 2026/07/16 장우철 고도화작업 — 슬롯 FK(0102/0105) 제거, 규칙·예외 FK는 CREATE에 포함(0106~0109)
-- 2026/07/16 장우철 고도화작업 — 선점 FK는 아래 ALTER(0110~0113)
-- =========================================================

-- TB_RESERVATION.TREAT_TYPE_ID → TB_HOSPITAL_TREAT_TYPE.TREAT_TYPE_ID
ALTER TABLE TB_RESERVATION
    ADD CONSTRAINT FK_PTN65_0101
    FOREIGN KEY (TREAT_TYPE_ID) REFERENCES TB_HOSPITAL_TREAT_TYPE (TREAT_TYPE_ID);

-- TB_RESERVATION.DOCTOR_ID → TB_HOSPITAL_DOCTOR.DOCTOR_ID
ALTER TABLE TB_RESERVATION
    ADD CONSTRAINT FK_PTN65_0104
    FOREIGN KEY (DOCTOR_ID) REFERENCES TB_HOSPITAL_DOCTOR (DOCTOR_ID);

-- 2026/07/16 장우철 고도화작업 — 선점 테이블 FK
-- TB_HOSPITAL_RESV_HOLD.HOSPITAL_ID → TB_HOSPITAL.HOSPITAL_ID
ALTER TABLE TB_HOSPITAL_RESV_HOLD
    ADD CONSTRAINT FK_PTN65_0110
    FOREIGN KEY (HOSPITAL_ID) REFERENCES TB_HOSPITAL (HOSPITAL_ID);

-- TB_HOSPITAL_RESV_HOLD.DOCTOR_ID → TB_HOSPITAL_DOCTOR.DOCTOR_ID
ALTER TABLE TB_HOSPITAL_RESV_HOLD
    ADD CONSTRAINT FK_PTN65_0111
    FOREIGN KEY (DOCTOR_ID) REFERENCES TB_HOSPITAL_DOCTOR (DOCTOR_ID);

-- TB_HOSPITAL_RESV_HOLD.TREAT_TYPE_ID → TB_HOSPITAL_TREAT_TYPE.TREAT_TYPE_ID
ALTER TABLE TB_HOSPITAL_RESV_HOLD
    ADD CONSTRAINT FK_PTN65_0112
    FOREIGN KEY (TREAT_TYPE_ID) REFERENCES TB_HOSPITAL_TREAT_TYPE (TREAT_TYPE_ID);

-- TB_HOSPITAL_RESV_HOLD.MEMBER_NO → TB_MEMBER.MEMBER_NO
ALTER TABLE TB_HOSPITAL_RESV_HOLD
    ADD CONSTRAINT FK_PTN65_0113
    FOREIGN KEY (MEMBER_NO) REFERENCES TB_MEMBER (MEMBER_NO);

-- ==================== 4. TABLE / COLUMN COMMENT ====================

-- COMMENT ON TABLE TB_AUTH_VERIFY IS '인증코드 | 이메일·카카오 메시지 인증';
COMMENT ON TABLE TB_MEMBER_GRADE IS '회원등급 | 등급·혜택 정의';
COMMENT ON TABLE TB_BUSINESS IS '사업자 | 병원/펫샵/숙소 사업자 계정';
COMMENT ON TABLE TB_ADMIN_ROLE IS '관리자권한그룹 | 권한 그룹';
-- COMMENT ON TABLE TB_SYSTEM_POLICY IS '운영정책 | 세션·비밀번호 정책';
-- COMMENT ON TABLE TB_PROMOTION IS '기획전 | 기획전·프로모션';
COMMENT ON TABLE TB_COUPON IS '쿠폰 | 정액/정률 쿠폰';
-- COMMENT ON TABLE TB_POI IS 'POI장소 | 관리자·회원 등록 장소';
-- COMMENT ON TABLE TB_SHELTER IS '보호소 | 보호소·공공데이터 연동';
COMMENT ON TABLE TB_FILE IS '파일 | Google Drive 업로드 공통';
-- COMMENT ON TABLE TB_PUBLIC_DATA_SYNC IS '공공데이터동기화 | 병원·보호소 동기화 로그';
COMMENT ON TABLE TB_POLICY IS 'POLICY | 통합 테이블';
COMMENT ON TABLE TB_MEMBER IS '회원 | 일반 회원 마스터';
COMMENT ON TABLE TB_HOSPITAL IS '병원 | 병원 상세·지도·예약';
COMMENT ON TABLE TB_STAY IS '숙소 | 숙소 마스터';
COMMENT ON TABLE TB_AD_PAYMENT IS '광고결제 | 월 선납·연장';
COMMENT ON TABLE TB_ADMIN IS '관리자 | 어드민 계정';
-- COMMENT ON TABLE TB_WALK_COURSE IS '산책코스 | 추천 코스';
COMMENT ON TABLE TB_BANNER IS '배너 | 사업자 신청·관리자 승인·위치별 노출 (yeju)';
COMMENT ON TABLE TB_MEMBER_SOCIAL IS '소셜연동 | 카카오/네이버/구글 OAuth 연동';
COMMENT ON TABLE TB_MEMBER_AGREEMENT IS '회원약관동의 | 이용약관·개인정보·마케팅 동의';
COMMENT ON TABLE TB_MEMBER_ADDRESS IS '회원배송지 | 기본/추가 배송지';
COMMENT ON TABLE TB_PET IS '반려동물 | 회원별 반려동물(최대 5마리)';
COMMENT ON TABLE TB_FAVORITE IS '즐겨찾기 | 상품/병원/숙소/POI 찜';
COMMENT ON TABLE TB_NOTIFICATION IS '알림함 | 예약·주문·공지 알림';
COMMENT ON TABLE TB_NOTICE IS '고객센터 공지사항';
COMMENT ON COLUMN TB_NOTICE.NOTICE_TYPE_CD IS 'NOTICE|INFO';
COMMENT ON COLUMN TB_NOTICE.PIN_YN IS 'Y=상단고정';
COMMENT ON COLUMN TB_NOTICE.VISIBLE_YN IS 'Y=노출';
COMMENT ON TABLE TB_FCM_TOKEN IS 'FCM토큰 | 푸시 알림 디바이스 토큰';
COMMENT ON TABLE TB_CART IS '장바구니 | 회원 장바구니';
COMMENT ON TABLE TB_MEMBER_COUPON IS '회원쿠폰 | 회원 보유 쿠폰';
COMMENT ON TABLE TB_POST IS '게시글 | 동네소식/분실보호/나눔/집사생활';
COMMENT ON TABLE TB_POINT IS '포인트이력 | 적립/차감';
-- COMMENT ON TABLE TB_DONATION IS '기부내역 | 포인트/금액 기부 · 기부증서 포함';
-- COMMENT ON TABLE TB_VOLUNTEER IS '봉사모집 | 유기동물 봉사 모집';
-- 2026/07/16 장우철 고도화작업 — 슬롯 TABLE COMMENT 제거 (TB_RESERVATION_SLOT 폐기)
COMMENT ON TABLE TB_STAY_ROOM IS '숙소객실 | 객실 등록·승인';
COMMENT ON TABLE TB_BUSINESS_AUTH IS '사업자인증신청 | 등록증 업로드·승인대기';
COMMENT ON TABLE TB_ADMIN_LOG IS '관리자작업로그 | 감사 로그';
-- COMMENT ON TABLE TB_POI_REQUEST IS 'POI등록신청 | 회원 장소 등록→관리자승인';
COMMENT ON TABLE TB_CONTENT IS '콘텐츠(공지·FAQ·약관) | 관리자 CMS · 회원가입 약관';
-- COMMENT ON TABLE TB_STATUS_HIST IS 'STATUS_HIST | 통합 테이블';
COMMENT ON TABLE TB_AD IS '광고(통합) | 사업자 배너 광고 신청';
-- COMMENT ON TABLE TB_PET_HEALTH IS '반려동물 건강기록 | 예방접종·체중 기록';
-- COMMENT ON TABLE TB_WALK_RECORD IS '산책기록 | GPS·거리·시간';
-- COMMENT ON TABLE TB_WALK_MATE IS '산책메이트 | 메이트 찾기';
COMMENT ON TABLE TB_INQUIRY IS '1:1 문의 | 수의사·제휴·고객센터 문의 통합';
COMMENT ON TABLE TB_FAQ IS '고객센터 FAQ';
COMMENT ON COLUMN TB_FAQ.CATEGORY_CD IS 'SERVICE|ORDER|MEMBER|RESERVE';
COMMENT ON COLUMN TB_FAQ.VISIBLE_YN IS 'Y=노출 N=숨김';
COMMENT ON TABLE TB_POST_LIKE IS '게시글좋아요 | 좋아요';
COMMENT ON TABLE TB_POST_REPORT IS '게시글신고 | 신고·검수';
-- COMMENT ON TABLE TB_VOLUNTEER_APPLY IS '봉사신청 | 봉사 참여 신청';
COMMENT ON TABLE TB_RESERVATION IS '예약 | 병원·숙소 통합 예약';
-- 2026/07/15 장우철 고도화작업 — 신규 테이블 COMMENT
-- 2026/07/16 장우철 고도화작업 — 규칙·예외 TABLE COMMENT 추가
COMMENT ON TABLE TB_HOSPITAL_TREAT_TYPE IS '병원진료유형 | 병원별 유형·소요분';
COMMENT ON TABLE TB_HOSPITAL_DOCTOR IS '병원의사 | 병원별 의료진(캘린더는 병원단위, 의사는 예약상세)';
-- 2026/07/16 장우철 고도화작업 — TB_HOSPITAL_RESV_RULE COMMENT 제거(병원 테이블로 통합)
COMMENT ON TABLE TB_HOSPITAL_RESV_EXCEPTION IS '병원예약예외 | 특정일 미리 설정(REPLACE/CLOSE)';
-- 2026/07/16 장우철 고도화작업 — 예약 임시 선점 TABLE COMMENT
COMMENT ON TABLE TB_HOSPITAL_RESV_HOLD IS '병원예약선점 | 펫·증상 입력 중 시간 임시 점유';
-- COMMENT ON TABLE TB_WALK_REWARD_HIST IS '산책리워드이력 | 포인트 적립 이력';
COMMENT ON TABLE TB_MEDICAL_RECORD IS '진료기록 | 재방문 확인용(자체DB)';
COMMENT ON TABLE TB_SETTLEMENT IS 'SETTLEMENT | 통합 테이블';
COMMENT ON TABLE TB_PRODUCT_CATEGORY IS '상품카테고리 | 대/소분류 트리';
COMMENT ON TABLE TB_PRODUCT IS '상품 | 상품 마스터';
COMMENT ON TABLE TB_PRODUCT_OPTION IS '상품옵션 | 사이즈·색상 등';
-- COMMENT ON TABLE TB_PRODUCT_APPROVAL IS '상품승인 | 관리자 승인/반려';
-- 2026/07/08 장우철 : COMMENT는 문자열 리터럴만 허용 → CHR(38) 연결식 제거(ORA-00933), SET DEFINE OFF라 & 직접 사용
COMMENT ON TABLE TB_PRODUCT_QNA IS '상품Q&A | 질문·관리자 답변';
COMMENT ON TABLE TB_CART_ITEM IS '장바구니항목 | 장바구니 상품';
COMMENT ON TABLE TB_ORDER IS '주문 | 주문 마스터';
COMMENT ON TABLE TB_ORDER_ITEM IS '주문상품 | 주문 라인';
COMMENT ON TABLE TB_ORDER_DELIVERY IS '주문배송 | 송장번호(사업자입력·조회만)';
COMMENT ON TABLE TB_PAYMENT IS '결제 | 토스페이먼츠 결제';
COMMENT ON TABLE TB_POST_COMMENT IS '게시글댓글 | 댓글·대댓글';
-- COMMENT ON TABLE TB_EXPERIENCE_GROUP IS '체험단 | 체험단 모집';
-- COMMENT ON TABLE TB_EXPERIENCE_APPLY IS '체험단신청 | 체험단 신청';
COMMENT ON TABLE TB_REVIEW IS 'REVIEW | 통합 테이블';
-- 2026/07/13 유정
COMMENT ON TABLE TB_TALENT IS '재능나눔 | 사업자 재능나눔 신청 (TB_POST SHARE 와 별개)';
-- 2026/07/13 장우철
COMMENT ON TABLE TB_REVIEW_REPORT IS '서비스·리뷰 신고 | USER→병원 / BIZ→유저 (TB_POST_REPORT 와 별개)';

-- COMMENT ON COLUMN TB_AUTH_VERIFY.VERIFY_ID IS '인증 ID';
-- COMMENT ON COLUMN TB_AUTH_VERIFY.TARGET_TYPE IS '대상 유형 (MEMBER/BUSINESS)';
-- COMMENT ON COLUMN TB_AUTH_VERIFY.TARGET_NO IS '대상 PK';
-- COMMENT ON COLUMN TB_AUTH_VERIFY.VERIFY_TYPE IS '인증 유형 (EMAIL/KAKAO)';
-- COMMENT ON COLUMN TB_AUTH_VERIFY.TARGET_ADDR IS '이메일 또는 전화';
-- COMMENT ON COLUMN TB_AUTH_VERIFY.VERIFY_CODE IS '인증코드';
-- COMMENT ON COLUMN TB_AUTH_VERIFY.VERIFY_YN IS '인증완료';
-- COMMENT ON COLUMN TB_AUTH_VERIFY.EXPIRE_DATE IS '만료(5분)';
-- COMMENT ON COLUMN TB_AUTH_VERIFY.REG_DATE IS '발송일';
COMMENT ON COLUMN TB_MEMBER_GRADE.GRADE_CD IS '등급코드';
COMMENT ON COLUMN TB_MEMBER_GRADE.GRADE_NAME IS '등급명';
COMMENT ON COLUMN TB_MEMBER_GRADE.MIN_POINT IS '최소포인트';
COMMENT ON COLUMN TB_MEMBER_GRADE.BENEFIT_DESC IS '혜택';
COMMENT ON COLUMN TB_BUSINESS.BIZ_NO IS '사업자번호';
COMMENT ON COLUMN TB_BUSINESS.BIZ_ID IS '로그인 ID';
COMMENT ON COLUMN TB_BUSINESS.BIZ_TYPE IS '사업자 유형 (HOSPITAL/STORE/STAY)';
COMMENT ON COLUMN TB_BUSINESS.BIZ_REG_NO IS '사업자등록번호';
COMMENT ON COLUMN TB_BUSINESS.BIZ_NAME IS '상호명';
COMMENT ON COLUMN TB_BUSINESS.CEO_NAME IS '대표자';
COMMENT ON COLUMN TB_BUSINESS.PHONE IS '연락처';
COMMENT ON COLUMN TB_BUSINESS.EMAIL IS '이메일';
COMMENT ON COLUMN TB_BUSINESS.STATUS_CD IS '상태코드 (PENDING/NORMAL/STOP/WITHDRAW)';
COMMENT ON COLUMN TB_BUSINESS.JOIN_DATE IS '가입일';
COMMENT ON COLUMN TB_BUSINESS.APPROVE_DATE IS '승인일';
COMMENT ON COLUMN TB_BUSINESS.FEE_RATE IS '수수료율(%) [계약 정보 흡수]';
COMMENT ON COLUMN TB_BUSINESS.SETTLE_ACCOUNT IS '정산계좌 [계약 정보 흡수]';
COMMENT ON COLUMN TB_BUSINESS.SETTLE_BANK IS '은행 [계약 정보 흡수]';
COMMENT ON COLUMN TB_BUSINESS.ANNUAL_FEE IS '연회비(병원) [계약 정보 흡수]';
COMMENT ON COLUMN TB_BUSINESS.START_DATE IS '시작 [계약 정보 흡수]';
COMMENT ON COLUMN TB_BUSINESS.END_DATE IS '종료 [계약 정보 흡수]';
COMMENT ON COLUMN TB_BUSINESS.SHOP_NAME IS '펫샵명 (BIZ_TYPE=SHOP) [펫샵 통합]';
COMMENT ON COLUMN TB_ADMIN_ROLE.ROLE_ID IS '역할ID';
COMMENT ON COLUMN TB_ADMIN_ROLE.ROLE_NAME IS '역할명';
COMMENT ON COLUMN TB_ADMIN_ROLE.ROLE_DESC IS '역할DESC';
COMMENT ON COLUMN TB_ADMIN_ROLE.USE_YN IS '여부';
COMMENT ON COLUMN TB_ADMIN_ROLE.MENU_PERMS IS '메뉴 권한 JSON (ROLE_MENU 통합)';
-- COMMENT ON COLUMN TB_SYSTEM_POLICY.POLICY_ID IS '정책 ID';
-- COMMENT ON COLUMN TB_SYSTEM_POLICY.POLICY_KEY IS '정책 키';
-- COMMENT ON COLUMN TB_SYSTEM_POLICY.POLICY_VALUE IS '정책 값';
-- COMMENT ON COLUMN TB_SYSTEM_POLICY.UPD_DATE IS '수정일';
-- COMMENT ON COLUMN TB_PROMOTION.PROMO_ID IS '기획전 ID';
-- COMMENT ON COLUMN TB_PROMOTION.PROMO_NAME IS 'PROMO명';
-- COMMENT ON COLUMN TB_PROMOTION.START_DATE IS '시작일';
-- COMMENT ON COLUMN TB_PROMOTION.END_DATE IS '종료일';
-- COMMENT ON COLUMN TB_PROMOTION.STATUS_CD IS '상태코드';
-- COMMENT ON COLUMN TB_PROMOTION.PRODUCT_IDS IS '기획전 상품 ID JSON';
COMMENT ON COLUMN TB_COUPON.COUPON_ID IS '쿠폰 ID';
COMMENT ON COLUMN TB_COUPON.COUPON_CODE IS '쿠폰CODE';
COMMENT ON COLUMN TB_COUPON.COUPON_NAME IS '쿠폰명';
COMMENT ON COLUMN TB_COUPON.COUPON_TYPE IS '쿠폰유형';
COMMENT ON COLUMN TB_COUPON.DISCOUNT_VALUE IS '할인값';
COMMENT ON COLUMN TB_COUPON.MIN_ORDER_AMT IS 'MIN주문AMT';
COMMENT ON COLUMN TB_COUPON.STATUS_CD IS '상태코드';
-- COMMENT ON COLUMN TB_POI.POI_ID IS '장소 ID';
-- COMMENT ON COLUMN TB_POI.CATEGORY_ID IS '카테고리 ID';
-- COMMENT ON COLUMN TB_POI.POI_NAME IS '장소명';
-- COMMENT ON COLUMN TB_POI.ADDR IS '주소';
-- COMMENT ON COLUMN TB_POI.LAT IS '위도';
-- COMMENT ON COLUMN TB_POI.LNG IS '경도';
-- COMMENT ON COLUMN TB_POI.PET_POLICY IS '반려동물 정책';
-- COMMENT ON COLUMN TB_POI.DATA_SOURCE IS '데이터 출처';
-- COMMENT ON COLUMN TB_POI.STATUS_CD IS '상태코드';
-- COMMENT ON COLUMN TB_POI.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_POI.CATEGORY_CD IS 'POI 카테고리 (POI_CATEGORY 통합)';
-- COMMENT ON COLUMN TB_SHELTER.SHELTER_ID IS '보호소 ID';
-- COMMENT ON COLUMN TB_SHELTER.SHELTER_NAME IS '보호소명';
-- COMMENT ON COLUMN TB_SHELTER.REGION IS '지역';
-- COMMENT ON COLUMN TB_SHELTER.ADDR IS '주소';
-- COMMENT ON COLUMN TB_SHELTER.LAT IS '위도';
-- COMMENT ON COLUMN TB_SHELTER.LNG IS '경도';
-- COMMENT ON COLUMN TB_SHELTER.PUBLIC_DATA_ID IS '공공데이터 키';
-- COMMENT ON COLUMN TB_SHELTER.GOAL_AMOUNT IS 'GOAL금액';
-- COMMENT ON COLUMN TB_SHELTER.TOTAL_DONATION IS '합계기부';
-- COMMENT ON COLUMN TB_SHELTER.STATUS_CD IS '상태코드';
COMMENT ON COLUMN TB_FILE.FILE_ID IS '파일 ID';
COMMENT ON COLUMN TB_FILE.REF_TYPE IS '참조유형';
COMMENT ON COLUMN TB_FILE.REF_ID IS '참조 ID';
COMMENT ON COLUMN TB_FILE.DRIVE_FILE_ID IS 'DRIVE파일ID (Google Drive fileId)';
COMMENT ON COLUMN TB_FILE.FILE_URL IS '접근 URL';
COMMENT ON COLUMN TB_FILE.ORIGIN_NAME IS '원본파일명';
COMMENT ON COLUMN TB_FILE.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_PUBLIC_DATA_SYNC.SYNC_ID IS '동기화 ID';
-- COMMENT ON COLUMN TB_PUBLIC_DATA_SYNC.DATA_TYPE IS '데이터유형 (HOSPITAL/SHELTER)';
-- COMMENT ON COLUMN TB_PUBLIC_DATA_SYNC.SYNC_STATUS IS '동기화상태 (SUCCESS/FAIL)';
-- COMMENT ON COLUMN TB_PUBLIC_DATA_SYNC.SYNC_CNT IS '건수';
-- COMMENT ON COLUMN TB_PUBLIC_DATA_SYNC.ERROR_MSG IS '오류';
-- COMMENT ON COLUMN TB_PUBLIC_DATA_SYNC.SYNC_DATE IS '동기화일(@Scheduled)';
COMMENT ON COLUMN TB_POLICY.POLICY_ID IS '정책 ID';
COMMENT ON COLUMN TB_POLICY.POLICY_TYPE IS 'POINT/WALK_REWARD 등';
COMMENT ON COLUMN TB_POLICY.POLICY_KEY IS '정책 키 [포인트정책 통합]';
COMMENT ON COLUMN TB_POLICY.POLICY_VALUE IS '정책 값 [포인트정책 통합]';
COMMENT ON COLUMN TB_POLICY.POINT_PER_KM IS 'km당 포인트 [산책리워드정책 통합]';
COMMENT ON COLUMN TB_POLICY.DAILY_MAX_POINT IS '일일 최대 포인트 [산책리워드정책 통합]';
COMMENT ON COLUMN TB_POLICY.APPLY_DATE IS '신청일 [산책리워드정책 통합]';
COMMENT ON COLUMN TB_MEMBER.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_MEMBER.MEMBER_ID IS '로그인 ID(이메일)';
COMMENT ON COLUMN TB_MEMBER.MEMBER_PWD IS '비밀번호 BCrypt(소셜가입 시 NULL)';
COMMENT ON COLUMN TB_MEMBER.MEMBER_NAME IS '이름';
COMMENT ON COLUMN TB_MEMBER.NICKNAME IS '닉네임';
COMMENT ON COLUMN TB_MEMBER.EMAIL IS '이메일';
COMMENT ON COLUMN TB_MEMBER.PHONE IS '휴대폰';
COMMENT ON COLUMN TB_MEMBER.ZIP_CODE IS '우편번호';
COMMENT ON COLUMN TB_MEMBER.ADDR1 IS '주소';
COMMENT ON COLUMN TB_MEMBER.ADDR2 IS '상세주소';
COMMENT ON COLUMN TB_MEMBER.GRADE_CD IS '회원등급';
COMMENT ON COLUMN TB_MEMBER.POINT_BALANCE IS '보유 포인트';
COMMENT ON COLUMN TB_MEMBER.PROFILE_IMG_URL IS '프로필(Google Drive)';
COMMENT ON COLUMN TB_MEMBER.STATUS_CD IS '상태코드 (NORMAL/STOP/WITHDRAW)';
COMMENT ON COLUMN TB_MEMBER.MARKETING_YN IS '마케팅 수신';
COMMENT ON COLUMN TB_MEMBER.JOIN_DATE IS '가입일';
COMMENT ON COLUMN TB_MEMBER.LAST_LOGIN_DATE IS '최종 로그인';
COMMENT ON COLUMN TB_MEMBER.WITHDRAW_DATE IS '탈퇴일';
COMMENT ON COLUMN TB_HOSPITAL.HOSPITAL_ID IS '병원 ID';
COMMENT ON COLUMN TB_HOSPITAL.BIZ_NO IS '사업자';
COMMENT ON COLUMN TB_HOSPITAL.HOSPITAL_NAME IS '병원명';
COMMENT ON COLUMN TB_HOSPITAL.PHONE IS '전화';
COMMENT ON COLUMN TB_HOSPITAL.ADDR IS '주소';
COMMENT ON COLUMN TB_HOSPITAL.LAT IS '위도';
COMMENT ON COLUMN TB_HOSPITAL.LNG IS '경도';
COMMENT ON COLUMN TB_HOSPITAL.AVG_RATING IS '평균평점';
COMMENT ON COLUMN TB_HOSPITAL.REVIEW_CNT IS '리뷰수';
COMMENT ON COLUMN TB_HOSPITAL.DATA_SOURCE IS '데이터 출처 (PLATFORM/PUBLIC)';
COMMENT ON COLUMN TB_HOSPITAL.PUBLIC_DATA_ID IS '공공데이터 키';
COMMENT ON COLUMN TB_HOSPITAL.STATUS_CD IS '승인상태';
COMMENT ON COLUMN TB_HOSPITAL.APPROVE_DATE IS '승인일';
COMMENT ON COLUMN TB_HOSPITAL.HOURS_JSON IS '진료시간 JSON (HOSPITAL_HOURS 통합)';
COMMENT ON COLUMN TB_HOSPITAL.TAG_LIST IS '진료과목 (HOSPITAL_DEPT 통합)';
-- 2026/07/15 장우철 고도화작업 — 병원 컬럼 COMMENT
COMMENT ON COLUMN TB_HOSPITAL.RESV_CAPACITY IS '기본 동시 예약 인원';
-- 2026/07/16 장우철 고도화작업 — RESV_RULE 통합: 시작 간격만 병원 컬럼으로
COMMENT ON COLUMN TB_HOSPITAL.RESV_INTERVAL_MIN IS '예약 시작 시각 간격(분)';
COMMENT ON COLUMN TB_STAY.STAY_ID IS '숙소 ID';
COMMENT ON COLUMN TB_STAY.BIZ_NO IS '사업자번호';
COMMENT ON COLUMN TB_STAY.NAME IS '숙소명';
COMMENT ON COLUMN TB_STAY.ADDR IS '주소';
COMMENT ON COLUMN TB_STAY.LAT IS '위도';
COMMENT ON COLUMN TB_STAY.LNG IS '경도';
COMMENT ON COLUMN TB_STAY.PET_POLICY IS '반려동물 정책';
COMMENT ON COLUMN TB_STAY.REFUND_POLICY IS '환불 정책';
COMMENT ON COLUMN TB_STAY.STATUS_CD IS '상태코드';
COMMENT ON COLUMN TB_STAY.APPROVE_DATE IS '승인일';
COMMENT ON COLUMN TB_STAY.FACILITIES IS '편의시설';
COMMENT ON COLUMN TB_STAY.CHECK_IN IS '체크인 시각';
COMMENT ON COLUMN TB_STAY.CHECK_OUT IS '체크아웃 시각';
COMMENT ON COLUMN TB_STAY.DESCRIPTION IS '공간 소개';
COMMENT ON COLUMN TB_STAY.PET_FEE IS '반려동물 추가비용 안내';
COMMENT ON COLUMN TB_AD_PAYMENT.PAYMENT_ID IS '결제 ID';
COMMENT ON COLUMN TB_AD_PAYMENT.CONTRACT_ID IS '계약ID';
COMMENT ON COLUMN TB_AD_PAYMENT.BIZ_NO IS '사업자번호';
COMMENT ON COLUMN TB_AD_PAYMENT.PAY_MONTH IS '결제MONTH';
COMMENT ON COLUMN TB_AD_PAYMENT.PAY_AMOUNT IS '실결제금액';
COMMENT ON COLUMN TB_AD_PAYMENT.PAY_STATUS IS '결제상태';
COMMENT ON COLUMN TB_AD_PAYMENT.PAY_DATE IS '결제일';
COMMENT ON COLUMN TB_ADMIN.ADMIN_NO IS '관리자번호';
COMMENT ON COLUMN TB_ADMIN.ADMIN_ID IS '관리자 로그인 ID';
COMMENT ON COLUMN TB_ADMIN.ADMIN_PWD IS '관리자 비밀번호';
COMMENT ON COLUMN TB_ADMIN.ADMIN_NAME IS '관리자 이름';
COMMENT ON COLUMN TB_ADMIN.ROLE_ID IS '역할ID';
COMMENT ON COLUMN TB_ADMIN.STATUS_CD IS '상태코드';
COMMENT ON COLUMN TB_ADMIN.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_WALK_COURSE.COURSE_ID IS '코스ID';
-- COMMENT ON COLUMN TB_WALK_COURSE.COURSE_NAME IS '코스명';
-- COMMENT ON COLUMN TB_WALK_COURSE.POI_ID IS '장소 ID';
-- COMMENT ON COLUMN TB_WALK_COURSE.DISTANCE_KM IS '거리KM';
-- COMMENT ON COLUMN TB_WALK_COURSE.DIFFICULTY IS '난이도';
-- COMMENT ON COLUMN TB_WALK_COURSE.ROUTE_DATA IS 'ROUTE데이터';
-- COMMENT ON COLUMN TB_WALK_COURSE.USE_YN IS '여부';
COMMENT ON COLUMN TB_BANNER.BANNER_ID IS '배너 ID';
COMMENT ON COLUMN TB_BANNER.BIZ_NO IS '사업자번호';
COMMENT ON COLUMN TB_BANNER.TITLE IS '배너 제목';
COMMENT ON COLUMN TB_BANNER.POSITION_CD IS '노출 위치 (MAIN_HERO/MAIN_MID/STORE/HOSPITAL/STAY/GROOMING)';
COMMENT ON COLUMN TB_BANNER.FILE_ID IS '파일 ID';
COMMENT ON COLUMN TB_BANNER.LINK_URL IS '클릭 이동 URL';
COMMENT ON COLUMN TB_BANNER.START_DATE IS '시작일';
COMMENT ON COLUMN TB_BANNER.END_DATE IS '종료일';
COMMENT ON COLUMN TB_BANNER.STATUS_CD IS '상태 (PENDING/ACTIVE/REJECTED/EXPIRED)';
COMMENT ON COLUMN TB_BANNER.REJECT_REASON IS '반려 사유';
COMMENT ON COLUMN TB_BANNER.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_BANNER.MOD_DATE IS '수정일';
COMMENT ON COLUMN TB_MEMBER_SOCIAL.SOCIAL_ID IS '소셜연동 ID';
COMMENT ON COLUMN TB_MEMBER_SOCIAL.MEMBER_NO IS '회원';
COMMENT ON COLUMN TB_MEMBER_SOCIAL.PROVIDER IS '소셜 제공처 (KAKAO/NAVER/GOOGLE)';
COMMENT ON COLUMN TB_MEMBER_SOCIAL.PROVIDER_UID IS '소셜 고유 ID';
COMMENT ON COLUMN TB_MEMBER_SOCIAL.REG_DATE IS '연동일';
COMMENT ON COLUMN TB_MEMBER_AGREEMENT.AGREE_ID IS '동의 ID';
COMMENT ON COLUMN TB_MEMBER_AGREEMENT.MEMBER_NO IS '회원';
COMMENT ON COLUMN TB_MEMBER_AGREEMENT.TERMS_TYPE IS '약관 유형 (SERVICE/PRIVACY/MARKETING)';
COMMENT ON COLUMN TB_MEMBER_AGREEMENT.TERMS_VER IS '약관버전';
COMMENT ON COLUMN TB_MEMBER_AGREEMENT.AGREE_YN IS '동의여부';
COMMENT ON COLUMN TB_MEMBER_AGREEMENT.AGREE_DATE IS '동의일';
COMMENT ON COLUMN TB_MEMBER_ADDRESS.ADDR_ID IS '배송지 ID';
COMMENT ON COLUMN TB_MEMBER_ADDRESS.MEMBER_NO IS '회원';
COMMENT ON COLUMN TB_MEMBER_ADDRESS.RECV_NAME IS '수령인';
COMMENT ON COLUMN TB_MEMBER_ADDRESS.RECV_PHONE IS '연락처';
COMMENT ON COLUMN TB_MEMBER_ADDRESS.ZIP_CODE IS '우편번호';
COMMENT ON COLUMN TB_MEMBER_ADDRESS.ADDR1 IS '주소';
COMMENT ON COLUMN TB_MEMBER_ADDRESS.ADDR2 IS '상세주소';
COMMENT ON COLUMN TB_MEMBER_ADDRESS.IS_DEFAULT IS '기본배송지 Y/N';
COMMENT ON COLUMN TB_PET.PET_ID IS '반려동물 ID';
COMMENT ON COLUMN TB_PET.MEMBER_NO IS '회원';
COMMENT ON COLUMN TB_PET.PET_NAME IS '이름';
COMMENT ON COLUMN TB_PET.SPECIES IS '반려동물 종 (DOG/CAT/ETC)';
COMMENT ON COLUMN TB_PET.BREED IS '품종';
COMMENT ON COLUMN TB_PET.GENDER IS '성별 (M/F)';
COMMENT ON COLUMN TB_PET.BIRTH_DATE IS '생년월일';
COMMENT ON COLUMN TB_PET.AGE IS '나이';
COMMENT ON COLUMN TB_PET.WEIGHT IS '체중(kg)';
COMMENT ON COLUMN TB_PET.IS_REPRESENT IS '대표 Y/N';
COMMENT ON COLUMN TB_PET.PHOTO_URL IS '사진(Google Drive)';
-- 2026/07/11 장우철 — 펫 소프트 삭제 플래그
COMMENT ON COLUMN TB_PET.DEL_YN IS '삭제 Y/N (Y=소프트삭제, 목록·예약선택 비표시)';
COMMENT ON COLUMN TB_PET.REG_DATE IS '등록일';
-- 2026/07/08 장우철 : 관심상품(찜) COUNT 기준 테이블 확인용 (TB_WISHLIST 아님, TB_FAVORITE 사용)
COMMENT ON COLUMN TB_FAVORITE.FAV_ID IS '즐겨찾기 ID';
COMMENT ON COLUMN TB_FAVORITE.MEMBER_NO IS '회원';
COMMENT ON COLUMN TB_FAVORITE.FAV_TYPE IS '즐겨찾기 유형 (PRODUCT/HOSPITAL/STAY/POI)';
COMMENT ON COLUMN TB_FAVORITE.TARGET_ID IS '대상 PK';
COMMENT ON COLUMN TB_FAVORITE.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_NOTIFICATION.NOTI_ID IS '알림 ID';
COMMENT ON COLUMN TB_NOTIFICATION.MEMBER_NO IS '회원';
COMMENT ON COLUMN TB_NOTIFICATION.NOTI_TYPE IS '알림 유형 (ORDER/RESERVE/COMMUNITY/SYSTEM)';
COMMENT ON COLUMN TB_NOTIFICATION.TITLE IS '제목';
COMMENT ON COLUMN TB_NOTIFICATION.CONTENT IS '내용';
COMMENT ON COLUMN TB_NOTIFICATION.LINK_URL IS '이동 URL';
COMMENT ON COLUMN TB_NOTIFICATION.IS_READ IS '읽음 Y/N';
COMMENT ON COLUMN TB_NOTIFICATION.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_FCM_TOKEN.TOKEN_ID IS '토큰 ID';
COMMENT ON COLUMN TB_FCM_TOKEN.MEMBER_NO IS '회원';
COMMENT ON COLUMN TB_FCM_TOKEN.DEVICE_TOKEN IS 'FCM 토큰';
COMMENT ON COLUMN TB_FCM_TOKEN.DEVICE_TYPE IS '기기 유형 (WEB/ANDROID/IOS)';
COMMENT ON COLUMN TB_FCM_TOKEN.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_CART.CART_ID IS '장바구니 ID';
COMMENT ON COLUMN TB_CART.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_CART.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_MEMBER_COUPON.MEMBER_COUPON_ID IS '회원쿠폰ID';
COMMENT ON COLUMN TB_MEMBER_COUPON.COUPON_ID IS '쿠폰 ID';
COMMENT ON COLUMN TB_MEMBER_COUPON.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_MEMBER_COUPON.EXPIRE_DATE IS '만료일';
-- 2026/07/08 장우철 : STATUS_CD 코멘트에 상태값 3단계 명시 (기존 '상태코드' → UNUSED/USED/EXPIRED)
COMMENT ON COLUMN TB_MEMBER_COUPON.STATUS_CD IS '상태코드 (UNUSED=미사용/이용중, USED=사용완료, EXPIRED=기간만료)';
COMMENT ON COLUMN TB_POST.POST_ID IS '게시글 ID';
COMMENT ON COLUMN TB_POST.MEMBER_NO IS '작성자';
COMMENT ON COLUMN TB_POST.BOARD_TYPE IS '게시판 유형 (TOWN/LOST/SHARE/LIFE)';
COMMENT ON COLUMN TB_POST.TITLE IS '제목';
COMMENT ON COLUMN TB_POST.BODY IS '본문';
COMMENT ON COLUMN TB_POST.VIEW_COUNT IS '조회수';
COMMENT ON COLUMN TB_POST.LIKE_CNT IS '좋아요';
COMMENT ON COLUMN TB_POST.LOST_SPECIES IS '분실:동물종류';
COMMENT ON COLUMN TB_POST.LOST_FEATURE IS '분실:특징';
COMMENT ON COLUMN TB_POST.LOST_LAT IS '분실:위도';
COMMENT ON COLUMN TB_POST.LOST_LNG IS '분실:경도';
COMMENT ON COLUMN TB_POST.LOST_CONTACT IS '분실:연락처';
COMMENT ON COLUMN TB_POST.REGION IS '지역';
COMMENT ON COLUMN TB_POST.STATUS_CD IS '상태코드 (ACTIVE/HIDDEN/DELETED)';
COMMENT ON COLUMN TB_POST.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_POST.TAGS IS '해시태그 (HASHTAG 통합)';
COMMENT ON COLUMN TB_POINT.POINT_ID IS '포인트ID';
COMMENT ON COLUMN TB_POINT.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_POINT.POINT_TYPE IS '포인트유형';
COMMENT ON COLUMN TB_POINT.POINT_AMOUNT IS '포인트금액';
COMMENT ON COLUMN TB_POINT.BALANCE_AFTER IS '잔액이후';
COMMENT ON COLUMN TB_POINT.REASON_CD IS '사유코드';
COMMENT ON COLUMN TB_POINT.REF_TYPE IS '참조 유형';
COMMENT ON COLUMN TB_POINT.REF_ID IS '참조 대상 ID';
COMMENT ON COLUMN TB_POINT.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_DONATION.DONATION_ID IS '기부 ID';
-- COMMENT ON COLUMN TB_DONATION.MEMBER_NO IS '회원번호';
-- COMMENT ON COLUMN TB_DONATION.SHELTER_ID IS '보호소 ID';
-- COMMENT ON COLUMN TB_DONATION.DONATION_TYPE IS '기부유형';
-- COMMENT ON COLUMN TB_DONATION.AMOUNT IS '금액';
-- COMMENT ON COLUMN TB_DONATION.DONATION_DATE IS '기부일';
-- COMMENT ON COLUMN TB_DONATION.CERT_NO IS '기부증서 번호 [증서 통합]';
-- COMMENT ON COLUMN TB_DONATION.CERT_FILE_ID IS '증서 파일 ID';
-- COMMENT ON COLUMN TB_DONATION.CERT_ISSUE_DATE IS '증서 발급일 [증서 통합]';
-- COMMENT ON COLUMN TB_VOLUNTEER.VOLUNTEER_ID IS '봉사 ID';
-- COMMENT ON COLUMN TB_VOLUNTEER.MEMBER_NO IS '회원번호';
-- COMMENT ON COLUMN TB_VOLUNTEER.VOL_TYPE IS 'VOL유형';
-- COMMENT ON COLUMN TB_VOLUNTEER.TITLE IS '제목';
-- COMMENT ON COLUMN TB_VOLUNTEER.BODY IS '본문';
-- COMMENT ON COLUMN TB_VOLUNTEER.LOCATION IS '장소';
-- COMMENT ON COLUMN TB_VOLUNTEER.VOL_DATE IS 'VOL일';
-- COMMENT ON COLUMN TB_VOLUNTEER.MAX_COUNT IS '최대 인원';
-- COMMENT ON COLUMN TB_VOLUNTEER.CURRENT_COUNT IS '현재 신청 인원';
-- COMMENT ON COLUMN TB_VOLUNTEER.STATUS_CD IS '상태코드';
-- COMMENT ON COLUMN TB_VOLUNTEER.REG_DATE IS '등록일';
-- 2026/07/16 장우철 고도화작업 — 슬롯 COLUMN COMMENT 제거 (TB_RESERVATION_SLOT 폐기)
COMMENT ON COLUMN TB_STAY_ROOM.ROOM_ID IS '객실 ID';
COMMENT ON COLUMN TB_STAY_ROOM.STAY_ID IS '숙소';
COMMENT ON COLUMN TB_STAY_ROOM.NAME IS '객실명';
COMMENT ON COLUMN TB_STAY_ROOM.PRICE_PER_NIGHT IS '1박 요금';
COMMENT ON COLUMN TB_STAY_ROOM.CAPACITY IS '정원';
COMMENT ON COLUMN TB_STAY_ROOM.PET_LIMIT IS '반려동물 수 제한';
COMMENT ON COLUMN TB_STAY_ROOM.STATUS_CD IS '상태코드 (PENDING/APPROVE/REJECT)';
COMMENT ON COLUMN TB_STAY_ROOM.REJECT_REASON IS '반려사유';
COMMENT ON COLUMN TB_BUSINESS_AUTH.AUTH_ID IS '인증신청 ID';
COMMENT ON COLUMN TB_BUSINESS_AUTH.BIZ_NO IS '사업자';
COMMENT ON COLUMN TB_BUSINESS_AUTH.DOC_FILE_ID IS '등록증 파일';
COMMENT ON COLUMN TB_BUSINESS_AUTH.BIZ_REG_NO IS '사업자등록번호';
COMMENT ON COLUMN TB_BUSINESS_AUTH.BIZ_TYPE IS '업종';
COMMENT ON COLUMN TB_BUSINESS_AUTH.AD_APPLY_YN IS '광고 동시신청';
COMMENT ON COLUMN TB_BUSINESS_AUTH.STATUS_CD IS '상태코드 (PENDING/APPROVE/REJECT)';
COMMENT ON COLUMN TB_BUSINESS_AUTH.REJECT_REASON IS '거절사유';
COMMENT ON COLUMN TB_BUSINESS_AUTH.APPLY_DATE IS '신청일';
COMMENT ON COLUMN TB_BUSINESS_AUTH.APPROVE_DATE IS '승인일';
COMMENT ON COLUMN TB_BUSINESS_AUTH.ADMIN_NO IS '처리 관리자';
COMMENT ON COLUMN TB_ADMIN_LOG.LOG_ID IS '로그ID';
COMMENT ON COLUMN TB_ADMIN_LOG.ADMIN_NO IS '관리자번호';
COMMENT ON COLUMN TB_ADMIN_LOG.ACTION_TYPE IS '작업 유형';
COMMENT ON COLUMN TB_ADMIN_LOG.TARGET_TYPE IS '대상 유형';
COMMENT ON COLUMN TB_ADMIN_LOG.TARGET_ID IS '대상ID';
COMMENT ON COLUMN TB_ADMIN_LOG.IP_ADDR IS 'IP주소';
COMMENT ON COLUMN TB_ADMIN_LOG.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_POI_REQUEST.REQUEST_ID IS '요청ID';
-- COMMENT ON COLUMN TB_POI_REQUEST.MEMBER_NO IS '회원번호';
-- COMMENT ON COLUMN TB_POI_REQUEST.CATEGORY_ID IS '카테고리 ID';
-- COMMENT ON COLUMN TB_POI_REQUEST.POI_NAME IS '장소명';
-- COMMENT ON COLUMN TB_POI_REQUEST.ADDR IS '주소';
-- COMMENT ON COLUMN TB_POI_REQUEST.LAT IS '위도';
-- COMMENT ON COLUMN TB_POI_REQUEST.LNG IS '경도';
-- COMMENT ON COLUMN TB_POI_REQUEST.STATUS_CD IS '상태코드';
-- COMMENT ON COLUMN TB_POI_REQUEST.REJECT_REASON IS '거절사유';
-- COMMENT ON COLUMN TB_POI_REQUEST.APPLY_DATE IS '신청일';
-- COMMENT ON COLUMN TB_POI_REQUEST.ADMIN_NO IS '관리자번호';
COMMENT ON COLUMN TB_CONTENT.CONTENT_ID IS '콘텐츠 ID';
COMMENT ON COLUMN TB_CONTENT.CONTENT_TYPE IS '유형 (NOTICE/FAQ/TERMS)';
COMMENT ON COLUMN TB_CONTENT.TITLE IS '제목';
COMMENT ON COLUMN TB_CONTENT.BODY IS '본문 (공지·약관 본문, FAQ 답변)';
COMMENT ON COLUMN TB_CONTENT.TARGET_TYPE IS '공지 대상 (ALL/USER/BIZ) [공지]';
COMMENT ON COLUMN TB_CONTENT.IS_PINNED IS '상단 고정 여부 [공지]';
COMMENT ON COLUMN TB_CONTENT.PUBLISH_DATE IS '게시일 [공지]';
COMMENT ON COLUMN TB_CONTENT.CATEGORY_CD IS 'FAQ 카테고리 [FAQ]';
COMMENT ON COLUMN TB_CONTENT.QUESTION IS '질문 [FAQ]';
COMMENT ON COLUMN TB_CONTENT.TERMS_TYPE IS '약관 유형 SERVICE/PRIVACY [약관]';
COMMENT ON COLUMN TB_CONTENT.VERSION IS '약관 버전 [약관]';
COMMENT ON COLUMN TB_CONTENT.EFFECTIVE_DATE IS '약관 시행일 [약관]';
COMMENT ON COLUMN TB_CONTENT.SORT_ORDER IS 'FAQ 정렬순서 [FAQ]';
COMMENT ON COLUMN TB_CONTENT.USE_YN IS '사용 여부';
COMMENT ON COLUMN TB_CONTENT.ADMIN_NO IS '등록 관리자';
COMMENT ON COLUMN TB_CONTENT.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_STATUS_HIST.HIST_ID IS '이력 ID';
-- COMMENT ON COLUMN TB_STATUS_HIST.TARGET_TYPE IS '대상 유형 (MEMBER/BUSINESS)';
-- COMMENT ON COLUMN TB_STATUS_HIST.TARGET_ID IS '대상 PK';
-- COMMENT ON COLUMN TB_STATUS_HIST.BEFORE_STATUS IS '변경전 [테이블 통합]';
-- COMMENT ON COLUMN TB_STATUS_HIST.AFTER_STATUS IS '변경후 [테이블 통합]';
-- COMMENT ON COLUMN TB_STATUS_HIST.REASON IS '사유 [테이블 통합]';
-- COMMENT ON COLUMN TB_STATUS_HIST.ADMIN_NO IS '처리 관리자 [테이블 통합]';
-- COMMENT ON COLUMN TB_STATUS_HIST.REG_DATE IS '등록일 [테이블 통합]';
COMMENT ON COLUMN TB_AD.AD_ID IS '광고 ID [광고신청 통합]';
COMMENT ON COLUMN TB_AD.BIZ_NO IS '사업자번호 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.BIZ_TYPE IS '사업자 유형 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.FILE_ID IS '파일 ID [광고신청 통합]';
COMMENT ON COLUMN TB_AD.BANNER_TEXT IS '배너문구 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.HOPE_START IS 'HOPE시작 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.HOPE_END IS 'HOPE종료 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.MONTHLY_FEE IS 'MONTHLY수수료 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.DISPLAY_POS IS '노출 위치 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.STATUS_CD IS '상태코드 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.REJECT_REASON IS '거절사유 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.APPLY_DATE IS '신청일 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.APPROVE_DATE IS '승인일 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.ADMIN_NO IS '관리자번호 [광고신청 통합]';
COMMENT ON COLUMN TB_AD.CONTRACT_ID IS '계약ID [광고계약 통합]';
COMMENT ON COLUMN TB_AD.START_DATE IS '시작일 [광고계약 통합]';
COMMENT ON COLUMN TB_AD.END_DATE IS '종료일 [광고계약 통합]';
COMMENT ON COLUMN TB_AD.SETTLE_ID IS '정산 ID [광고정산 통합]';
COMMENT ON COLUMN TB_AD.SETTLE_MONTH IS '정산MONTH [광고정산 통합]';
COMMENT ON COLUMN TB_AD.TOTAL_AMOUNT IS '총 주문금액 [광고정산 통합]';
COMMENT ON COLUMN TB_AD.BIZ_CNT IS '사업자수 [광고정산 통합]';
COMMENT ON COLUMN TB_AD.REG_DATE IS '등록일 [광고정산 통합]';
-- COMMENT ON COLUMN TB_PET_HEALTH.HEALTH_ID IS '건강기록 ID';
-- COMMENT ON COLUMN TB_PET_HEALTH.PET_ID IS '반려동물 ID';
-- COMMENT ON COLUMN TB_PET_HEALTH.HEALTH_TYPE IS '기록 유형 (VACCINE/WEIGHT)';
-- COMMENT ON COLUMN TB_PET_HEALTH.RECORD_DATE IS '기록일';
-- COMMENT ON COLUMN TB_PET_HEALTH.VALUE IS '체중(kg) [체중]';
-- COMMENT ON COLUMN TB_PET_HEALTH.VACC_NAME IS '백신명 [접종]';
-- COMMENT ON COLUMN TB_PET_HEALTH.NEXT_DATE IS '다음 접종 예정일 [접종]';
-- COMMENT ON COLUMN TB_PET_HEALTH.MEMO IS '메모';
-- COMMENT ON COLUMN TB_PET_HEALTH.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_WALK_RECORD.WALK_ID IS '산책ID';
-- COMMENT ON COLUMN TB_WALK_RECORD.MEMBER_NO IS '회원번호';
-- COMMENT ON COLUMN TB_WALK_RECORD.PET_ID IS '반려동물 ID';
-- COMMENT ON COLUMN TB_WALK_RECORD.WALK_DATE IS '산책일';
-- COMMENT ON COLUMN TB_WALK_RECORD.DISTANCE_KM IS '거리KM';
-- COMMENT ON COLUMN TB_WALK_RECORD.DURATION_MIN IS '시간MIN';
-- COMMENT ON COLUMN TB_WALK_RECORD.CALORIES IS '칼로리';
-- COMMENT ON COLUMN TB_WALK_RECORD.ROUTE_DATA IS 'ROUTE데이터';
-- COMMENT ON COLUMN TB_WALK_RECORD.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_WALK_MATE.MATE_ID IS '메이트ID';
-- COMMENT ON COLUMN TB_WALK_MATE.MEMBER_NO IS '회원번호';
-- COMMENT ON COLUMN TB_WALK_MATE.PET_ID IS '반려동물 ID';
-- COMMENT ON COLUMN TB_WALK_MATE.REGION IS '지역';
-- COMMENT ON COLUMN TB_WALK_MATE.STATUS_CD IS '상태코드';
COMMENT ON COLUMN TB_INQUIRY.INQUIRY_ID IS '문의 ID';
COMMENT ON COLUMN TB_INQUIRY.INQUIRY_TYPE IS '문의 유형 (VET/PARTNER/ORDER/RESERVE/ETC)';
COMMENT ON COLUMN TB_INQUIRY.MEMBER_NO IS '회원번호 (1:1 문의·수의사)';
COMMENT ON COLUMN TB_INQUIRY.PET_ID IS '반려동물 ID [수의사]';
COMMENT ON COLUMN TB_INQUIRY.TITLE IS '문의 제목';
COMMENT ON COLUMN TB_INQUIRY.BODY IS '문의 내용';
COMMENT ON COLUMN TB_INQUIRY.SYMPTOM IS '증상 상세 [수의사]';
COMMENT ON COLUMN TB_INQUIRY.COMPANY_NAME IS '회사명 [제휴]';
COMMENT ON COLUMN TB_INQUIRY.CONTACT_NAME IS '담당자명 [제휴]';
COMMENT ON COLUMN TB_INQUIRY.EMAIL IS '이메일 [제휴]';
COMMENT ON COLUMN TB_INQUIRY.REF_TYPE IS '참조 유형 ORDER/RESV 등 (선택)';
COMMENT ON COLUMN TB_INQUIRY.REF_ID IS '참조 ID 주문·예약번호 등 (선택)';
COMMENT ON COLUMN TB_INQUIRY.STATUS_CD IS '처리상태 (WAIT/ANSWER/DONE)';
COMMENT ON COLUMN TB_INQUIRY.ANSWER IS '답변 내용';
COMMENT ON COLUMN TB_INQUIRY.ADMIN_NO IS '답변 관리자';
COMMENT ON COLUMN TB_INQUIRY.RATING IS '상담 만족도 [수의사]';
COMMENT ON COLUMN TB_INQUIRY.APPLY_DATE IS '문의·신청일';
COMMENT ON COLUMN TB_INQUIRY.ANSWER_DATE IS '답변일';
COMMENT ON COLUMN TB_INQUIRY.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_POST_LIKE.LIKE_ID IS '좋아요ID';
COMMENT ON COLUMN TB_POST_LIKE.POST_ID IS '게시글 ID';
COMMENT ON COLUMN TB_POST_LIKE.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_POST_LIKE.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_POST_REPORT.REPORT_ID IS '신고ID';
COMMENT ON COLUMN TB_POST_REPORT.POST_ID IS '게시글 ID';
COMMENT ON COLUMN TB_POST_REPORT.TARGET_TYPE IS '신고 대상 유형 (POST/COMMENT)';
COMMENT ON COLUMN TB_POST_REPORT.COMMENT_ID IS '댓글·대댓글 ID (TARGET_TYPE=COMMENT일 때)';
COMMENT ON COLUMN TB_POST_REPORT.REPORTER_NO IS 'REPORTER번호';
COMMENT ON COLUMN TB_POST_REPORT.REASON IS '사유';
COMMENT ON COLUMN TB_POST_REPORT.STATUS_CD IS '상태코드';
-- 2026/07/11 장우철 — 접수 시 NULL, 관리자 처리 시 ADMIN_NO 세팅
COMMENT ON COLUMN TB_POST_REPORT.ADMIN_NO IS '관리자번호 (신고 접수 시 NULL 허용)';
-- COMMENT ON COLUMN TB_VOLUNTEER_APPLY.APPLY_ID IS '신청 ID';
-- COMMENT ON COLUMN TB_VOLUNTEER_APPLY.VOLUNTEER_ID IS '봉사 ID';
-- COMMENT ON COLUMN TB_VOLUNTEER_APPLY.MEMBER_NO IS '회원번호';
-- COMMENT ON COLUMN TB_VOLUNTEER_APPLY.CONTACT IS '연락';
-- COMMENT ON COLUMN TB_VOLUNTEER_APPLY.MOTIVATION IS '지원 동기';
-- COMMENT ON COLUMN TB_VOLUNTEER_APPLY.STATUS_CD IS '상태코드';
-- COMMENT ON COLUMN TB_VOLUNTEER_APPLY.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_RESERVATION.RESV_ID IS '예약 ID';
COMMENT ON COLUMN TB_RESERVATION.RESV_NO IS '예약번호';
COMMENT ON COLUMN TB_RESERVATION.RESV_TYPE IS '예약유형';
COMMENT ON COLUMN TB_RESERVATION.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_RESERVATION.PET_ID IS '반려동물 ID';
COMMENT ON COLUMN TB_RESERVATION.TARGET_ID IS '대상ID';
COMMENT ON COLUMN TB_RESERVATION.ROOM_ID IS '객실 ID';
COMMENT ON COLUMN TB_RESERVATION.SERVICE_NAME IS 'SERVICE명';
COMMENT ON COLUMN TB_RESERVATION.RESV_DATE IS '예약일';
COMMENT ON COLUMN TB_RESERVATION.RESV_TIME IS '예약시간';
COMMENT ON COLUMN TB_RESERVATION.CHECKIN_DATE IS '체크인일';
COMMENT ON COLUMN TB_RESERVATION.CHECKOUT_DATE IS '체크아웃일';
COMMENT ON COLUMN TB_RESERVATION.NIGHT_CNT IS 'NIGHT수';
COMMENT ON COLUMN TB_RESERVATION.SYMPTOMS IS '증상';
COMMENT ON COLUMN TB_RESERVATION.REQUEST_MEMO IS '요청MEMO';
COMMENT ON COLUMN TB_RESERVATION.TOTAL_AMOUNT IS '총 주문금액';
COMMENT ON COLUMN TB_RESERVATION.STATUS_CD IS '상태코드';
COMMENT ON COLUMN TB_RESERVATION.REJECT_REASON IS '거절사유';
COMMENT ON COLUMN TB_RESERVATION.REG_DATE IS '등록일';
-- 2026/07/15 장우철 고도화작업 — 예약·유형·의사 컬럼 COMMENT
-- 2026/07/16 장우철 고도화작업 — SLOT_ID COMMENT 제거, 규칙·예외 컬럼 COMMENT 추가
COMMENT ON COLUMN TB_RESERVATION.TREAT_TYPE_ID IS '진료유형 ID';
COMMENT ON COLUMN TB_RESERVATION.DURATION_MIN IS '소요 분';
COMMENT ON COLUMN TB_RESERVATION.END_TIME IS '종료시각';
COMMENT ON COLUMN TB_RESERVATION.DOCTOR_ID IS '의사 ID';
COMMENT ON COLUMN TB_RESERVATION.MEMBER_COUPON_ID IS '사용한 회원쿠폰 ID (TB_MEMBER_COUPON)';
COMMENT ON COLUMN TB_RESERVATION.COUPON_DISCOUNT IS '쿠폰 할인 금액';
COMMENT ON COLUMN TB_RESERVATION.POINT_USED IS '결제 시 사용한 포인트';
COMMENT ON COLUMN TB_HOSPITAL_TREAT_TYPE.TREAT_TYPE_ID IS '진료유형 ID';
COMMENT ON COLUMN TB_HOSPITAL_TREAT_TYPE.HOSPITAL_ID IS '병원 ID';
COMMENT ON COLUMN TB_HOSPITAL_TREAT_TYPE.TYPE_NAME IS '유형명';
COMMENT ON COLUMN TB_HOSPITAL_TREAT_TYPE.DURATION_MIN IS '소요 분';
COMMENT ON COLUMN TB_HOSPITAL_TREAT_TYPE.STATUS_CD IS '사용여부 Y/N';
COMMENT ON COLUMN TB_HOSPITAL_TREAT_TYPE.SORT_ORDR IS '정렬';
COMMENT ON COLUMN TB_HOSPITAL_TREAT_TYPE.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_HOSPITAL_DOCTOR.DOCTOR_ID IS '의사 ID';
COMMENT ON COLUMN TB_HOSPITAL_DOCTOR.HOSPITAL_ID IS '병원 ID';
COMMENT ON COLUMN TB_HOSPITAL_DOCTOR.DOCTOR_NAME IS '의사명';
COMMENT ON COLUMN TB_HOSPITAL_DOCTOR.SPECIALTY IS '전문분야';
COMMENT ON COLUMN TB_HOSPITAL_DOCTOR.STATUS_CD IS '사용여부 Y/N';
COMMENT ON COLUMN TB_HOSPITAL_DOCTOR.SORT_ORDR IS '정렬';
COMMENT ON COLUMN TB_HOSPITAL_DOCTOR.REG_DATE IS '등록일';
-- 2026/07/16 장우철 고도화작업 — TB_HOSPITAL_RESV_RULE 컬럼 COMMENT 제거
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.EXC_ID IS '예외 ID';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.HOSPITAL_ID IS '병원 ID';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.DOCTOR_ID IS '의사 ID (NULL=공통)';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.EXC_DATE IS '예외 적용일';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.EXC_TYPE IS 'REPLACE(그날 구간만)/CLOSE(구간 불가)';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.START_TIME IS '예외 시작 시각';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.END_TIME IS '예외 종료 시각';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.INTERVAL_MIN IS '시작 간격(분)';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.MEMO IS '메모';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.STATUS_CD IS '사용여부 Y/N';
COMMENT ON COLUMN TB_HOSPITAL_RESV_EXCEPTION.REG_DATE IS '등록일';
-- 2026/07/16 장우철 고도화작업 — 예약 임시 선점 COLUMN COMMENT
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.HOLD_ID IS '선점 ID';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.HOSPITAL_ID IS '병원 ID';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.DOCTOR_ID IS '의사 ID';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.TREAT_TYPE_ID IS '진료유형 ID';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.MEMBER_NO IS '선점 회원';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.RESV_DATE IS '예약일';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.RESV_TIME IS '시작 시각 HH:mm';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.DURATION_MIN IS '소요 분';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.END_TIME IS '종료 시각 HH:mm';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.EXPIRE_DATE IS '선점 만료 시각';
COMMENT ON COLUMN TB_HOSPITAL_RESV_HOLD.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_WALK_REWARD_HIST.HIST_ID IS '이력 ID';
-- COMMENT ON COLUMN TB_WALK_REWARD_HIST.WALK_ID IS '산책ID';
-- COMMENT ON COLUMN TB_WALK_REWARD_HIST.MEMBER_NO IS '회원번호';
-- COMMENT ON COLUMN TB_WALK_REWARD_HIST.POINT_AMOUNT IS '포인트금액';
-- COMMENT ON COLUMN TB_WALK_REWARD_HIST.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_MEDICAL_RECORD.RECORD_ID IS '진료기록 ID';
COMMENT ON COLUMN TB_MEDICAL_RECORD.HOSPITAL_ID IS '병원';
COMMENT ON COLUMN TB_MEDICAL_RECORD.RESV_ID IS '예약';
COMMENT ON COLUMN TB_MEDICAL_RECORD.PET_ID IS '반려동물';
COMMENT ON COLUMN TB_MEDICAL_RECORD.MEMBER_NO IS '회원';
COMMENT ON COLUMN TB_MEDICAL_RECORD.VISIT_DATE IS '진료일';
COMMENT ON COLUMN TB_MEDICAL_RECORD.SYMPTOMS IS '증상';
COMMENT ON COLUMN TB_MEDICAL_RECORD.DIAGNOSIS IS '진단';
COMMENT ON COLUMN TB_MEDICAL_RECORD.PRESCRIPTION IS '처방';
COMMENT ON COLUMN TB_MEDICAL_RECORD.MEMO IS '메모';
COMMENT ON COLUMN TB_MEDICAL_RECORD.VET_NAME IS '수의사명';
COMMENT ON COLUMN TB_MEDICAL_RECORD.REG_DATE IS '등록일';-- 2026/07/29 장우철
-- TB_SETTLEMENT COMMENT
COMMENT ON TABLE TB_SETTLEMENT IS '정산 마스터(숙소/쇼핑 공용)';
COMMENT ON COLUMN TB_SETTLEMENT.SETTLE_ID IS '정산 ID (PK)';
COMMENT ON COLUMN TB_SETTLEMENT.RESV_ID IS '예전 단건정산용. 묶음정산/쇼핑은 NULL';
COMMENT ON COLUMN TB_SETTLEMENT.BIZ_NO IS '사업자번호';
COMMENT ON COLUMN TB_SETTLEMENT.FEE_RATE IS '적용 수수료율(%)';
COMMENT ON COLUMN TB_SETTLEMENT.FEE_AMOUNT IS '수수료금액';
COMMENT ON COLUMN TB_SETTLEMENT.SETTLE_STATUS IS 'PENDING/REQUESTED/HOLD/PAID/REJECTED 등';
COMMENT ON COLUMN TB_SETTLEMENT.BIZ_TYPE IS 'STAY/STORE 등';
COMMENT ON COLUMN TB_SETTLEMENT.SETTLE_MONTH IS '정산월 YYYY-MM';
COMMENT ON COLUMN TB_SETTLEMENT.TOTAL_SALES IS '정산 대상 총액(표시용)';
COMMENT ON COLUMN TB_SETTLEMENT.TOTAL_FEE IS '합계 수수료';
COMMENT ON COLUMN TB_SETTLEMENT.SETTLE_AMOUNT IS '실지급 정산금';
COMMENT ON COLUMN TB_SETTLEMENT.PAY_STATUS IS 'WAIT/DONE/FAIL';
COMMENT ON COLUMN TB_SETTLEMENT.PAY_DATE IS '지급일';
COMMENT ON COLUMN TB_SETTLEMENT.REQUEST_ID IS '중간정산 요청 ID';
COMMENT ON COLUMN TB_SETTLEMENT.REQUEST_TYPE IS 'REGULAR / ADHOC';
COMMENT ON COLUMN TB_SETTLEMENT.REQUEST_SCOPE IS 'STAY: ALL/ROOM, STORE: ALL/PRODUCT';
COMMENT ON COLUMN TB_SETTLEMENT.ROOM_ID IS '숙소 특정 객실 정산';
COMMENT ON COLUMN TB_SETTLEMENT.PRODUCT_ID IS '쇼핑 특정 상품 정산';
COMMENT ON COLUMN TB_SETTLEMENT.PERIOD_START IS '집계 시작일';
COMMENT ON COLUMN TB_SETTLEMENT.PERIOD_END IS '집계 종료일';
COMMENT ON COLUMN TB_SETTLEMENT.REQUESTED_AT IS '중간정산 요청일시';
COMMENT ON COLUMN TB_SETTLEMENT.APPROVED_AT IS '승인일시';
COMMENT ON COLUMN TB_SETTLEMENT.REJECT_REASON IS '거절사유';
COMMENT ON COLUMN TB_SETTLEMENT.PRODUCT_SALES_AMOUNT IS '상품매출(택배비 제외)';
COMMENT ON COLUMN TB_SETTLEMENT.DELIVERY_FEE_AMOUNT IS '택배비 합(패스스루)';
COMMENT ON COLUMN TB_SETTLEMENT.RETURN_FEE_AMOUNT IS '반품택배비 합(사업자 부담분 등)';

-- TB_SETTLEMENT_REQUEST COMMENT
COMMENT ON TABLE TB_SETTLEMENT_REQUEST IS '중간정산 요청';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.REQUEST_ID IS '요청 ID (PK)';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.BIZ_NO IS '요청 사업자';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.REQUEST_SCOPE IS 'STAY: ALL/ROOM, STORE: ALL/PRODUCT';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.ROOM_ID IS '숙소 객실 지정 시';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.PRODUCT_ID IS '쇼핑 상품 지정 시';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.TARGET_START IS '요청 대상 시작일';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.TARGET_END IS '요청 대상 종료일';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.STATUS_CD IS 'REQUESTED/APPROVED/REJECTED/CANCELED';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.REQUEST_MEMO IS '사업자 요청 메모';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.REJECT_REASON IS '거절 사유';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.REQUESTED_AT IS '요청일시';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.APPROVED_AT IS '승인일시';
COMMENT ON COLUMN TB_SETTLEMENT_REQUEST.REJECTED_AT IS '거절일시';

-- TB_SETTLEMENT_ITEM COMMENT
COMMENT ON TABLE TB_SETTLEMENT_ITEM IS '정산 상세(숙소=예약, 쇼핑=주문상품)';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.SETTLE_ITEM_ID IS '상세 ID (PK)';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.SETTLE_ID IS 'TB_SETTLEMENT.SETTLE_ID';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.RESV_ID IS '예약 ID(쇼핑이면 NULL)';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.ROOM_ID IS '객실 ID';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.CHECKIN_DATE IS '체크인일';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.CHECKOUT_DATE IS '체크아웃일';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.RESV_AMOUNT IS '예약 원금(숙소)';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.ORDER_ID IS '주문 ID';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.ORDER_ITEM_ID IS '주문상품 ID(중복정산 방지)';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.PRODUCT_ID IS '상품 ID';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.CONFIRMED_AT IS '구매확정 시각';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.ITEM_SALES_AMOUNT IS '상품매출(택배 제외)';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.DELIVERY_FEE_AMOUNT IS '이 건 배송비';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.RETURN_FEE_AMOUNT IS '반품 택배비';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.RETURN_FEE_PAYER IS 'USER / BIZ';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.FEE_RATE IS '건별 수수료율';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.FEE_AMOUNT IS '건별 수수료';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.SETTLE_AMOUNT IS '건별 실정산금';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.STATUS_CD IS 'INCLUDED/HOLD/EXCLUDED/REFUNDED';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.HOLD_REASON IS '보류/제외 사유';
COMMENT ON COLUMN TB_SETTLEMENT_ITEM.REG_DATE IS '등록일';


COMMENT ON COLUMN TB_PRODUCT_CATEGORY.CATEGORY_ID IS '카테고리 ID';
COMMENT ON COLUMN TB_PRODUCT_CATEGORY.PARENT_ID IS '상위 카테고리 ID';
COMMENT ON COLUMN TB_PRODUCT_CATEGORY.CATEGORY_NAME IS '카테고리명';
COMMENT ON COLUMN TB_PRODUCT_CATEGORY.DEPTH IS '카테고리 깊이';
COMMENT ON COLUMN TB_PRODUCT_CATEGORY.USE_YN IS '여부';
COMMENT ON COLUMN TB_PRODUCT.PRODUCT_ID IS '상품 ID';
COMMENT ON COLUMN TB_PRODUCT.PRODUCT_CD IS '상품코드';
COMMENT ON COLUMN TB_PRODUCT.PRODUCT_NAME IS '상품명';
COMMENT ON COLUMN TB_PRODUCT.BIZ_NO IS '사업자번호';
COMMENT ON COLUMN TB_PRODUCT.CATEGORY_ID IS '카테고리 ID';
COMMENT ON COLUMN TB_PRODUCT.PRICE IS '가격';
COMMENT ON COLUMN TB_PRODUCT.SALE_PRICE IS '판매가격';
COMMENT ON COLUMN TB_PRODUCT.STOCK_QTY IS '재고수량';
COMMENT ON COLUMN TB_PRODUCT.LOW_STOCK_THRESHOLD IS 'LOW재고THRESHOLD';
COMMENT ON COLUMN TB_PRODUCT.DESCRIPTION IS '설명';
COMMENT ON COLUMN TB_PRODUCT.STATUS_CD IS '상태코드';
COMMENT ON COLUMN TB_PRODUCT.APPROVE_DATE IS '승인일';
COMMENT ON COLUMN TB_PRODUCT.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_PRODUCT.BRAND_NAME IS '브랜드명 (TB_BRAND 통합)';
COMMENT ON COLUMN TB_PRODUCT_OPTION.OPTION_ID IS '옵션 ID';
COMMENT ON COLUMN TB_PRODUCT_OPTION.PRODUCT_ID IS '상품';
COMMENT ON COLUMN TB_PRODUCT_OPTION.OPTION_COLOR IS '색상';
COMMENT ON COLUMN TB_PRODUCT_OPTION.OPTION_SIZE IS '사이즈';
COMMENT ON COLUMN TB_PRODUCT_OPTION.ADD_PRICE IS '추가금액';
COMMENT ON COLUMN TB_PRODUCT_OPTION.STOCK_QTY IS '옵션 재고';
-- COMMENT ON COLUMN TB_PRODUCT_APPROVAL.APPROVAL_ID IS '승인ID';
-- COMMENT ON COLUMN TB_PRODUCT_APPROVAL.PRODUCT_ID IS '상품 ID';
-- COMMENT ON COLUMN TB_PRODUCT_APPROVAL.STATUS_CD IS '상태코드';
-- COMMENT ON COLUMN TB_PRODUCT_APPROVAL.REJECT_REASON IS '거절사유';
-- COMMENT ON COLUMN TB_PRODUCT_APPROVAL.APPLY_DATE IS '신청일';
-- COMMENT ON COLUMN TB_PRODUCT_APPROVAL.ADMIN_NO IS '관리자번호';
COMMENT ON COLUMN TB_PRODUCT_QNA.QNA_ID IS '상품문의 ID';
COMMENT ON COLUMN TB_PRODUCT_QNA.PRODUCT_ID IS '상품 ID';
COMMENT ON COLUMN TB_PRODUCT_QNA.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_PRODUCT_QNA.QUESTION IS '질문';
COMMENT ON COLUMN TB_PRODUCT_QNA.ANSWER IS '답변';
COMMENT ON COLUMN TB_PRODUCT_QNA.ANSWER_DATE IS '답변일';
COMMENT ON COLUMN TB_PRODUCT_QNA.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_CART_ITEM.CART_ITEM_ID IS '장바구니 항목 ID';
COMMENT ON COLUMN TB_CART_ITEM.CART_ID IS '장바구니 ID';
COMMENT ON COLUMN TB_CART_ITEM.PRODUCT_ID IS '상품 ID';
COMMENT ON COLUMN TB_CART_ITEM.OPTION_ID IS '옵션 ID';
COMMENT ON COLUMN TB_CART_ITEM.QTY IS '수량';
COMMENT ON COLUMN TB_CART_ITEM.PRICE IS '가격';
COMMENT ON COLUMN TB_ORDER.ORDER_ID IS '주문 ID';
COMMENT ON COLUMN TB_ORDER.ORDER_NO IS '주문번호';
COMMENT ON COLUMN TB_ORDER.MEMBER_NO IS '회원번호';
COMMENT ON COLUMN TB_ORDER.ORDER_STATUS IS '주문상태';
COMMENT ON COLUMN TB_ORDER.TOTAL_AMOUNT IS '총 주문금액';
COMMENT ON COLUMN TB_ORDER.DELIVERY_FEE IS '배송비';
COMMENT ON COLUMN TB_ORDER.DISCOUNT_AMOUNT IS '할인금액';
COMMENT ON COLUMN TB_ORDER.POINT_USED IS '사용 포인트';
COMMENT ON COLUMN TB_ORDER.PAY_AMOUNT IS '실결제금액';
COMMENT ON COLUMN TB_ORDER.ORDER_DATE IS '주문일';
COMMENT ON COLUMN TB_ORDER.RECV_NAME IS '받는 사람';
COMMENT ON COLUMN TB_ORDER.RECV_PHONE IS '연락처';
COMMENT ON COLUMN TB_ORDER.ZIP_CODE IS '우편번호';
COMMENT ON COLUMN TB_ORDER.ADDR1 IS '기본주소';
COMMENT ON COLUMN TB_ORDER.ADDR2 IS '상세주소';
COMMENT ON COLUMN TB_ORDER.CLAIM_TYPE IS '클레임 유형 (NONE/CANCEL/RETURN/EXCHANGE)';
COMMENT ON COLUMN TB_ORDER.CLAIM_STATUS IS '클레임 처리상태';
COMMENT ON COLUMN TB_ORDER.CANCEL_REASON IS '취소 사유 [취소 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.REFUND_AMOUNT IS '환불금액 [취소 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.REFUND_STATUS IS '환불상태 [취소 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.BIZ_NO IS '사업자번호 [취소 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.ADMIN_VIEW_YN IS '관리자 열람 여부 [취소 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.REQUESTED_AT IS '취소 신청 일시 [취소 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.ORDER_ITEM_ID IS '주문상품 [반품 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.RETURN_TYPE IS '반품·교환 유형 (EXCHANGE/RETURN) [반품 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.RETURN_REASON IS '사유 [반품 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.RETURN_STATUS_CD IS '처리상태 [반품 테이블 통합]';
COMMENT ON COLUMN TB_ORDER.RETURN_REQUESTED_AT IS '반품·교환 신청 일시 [반품 테이블 통합]';
COMMENT ON COLUMN TB_ORDER_ITEM.ORDER_ITEM_ID IS '주문상품 ID';
COMMENT ON COLUMN TB_ORDER_ITEM.ORDER_ID IS '주문';
COMMENT ON COLUMN TB_ORDER_ITEM.PRODUCT_ID IS '상품';
COMMENT ON COLUMN TB_ORDER_ITEM.OPTION_ID IS '선택 옵션';
COMMENT ON COLUMN TB_ORDER_ITEM.OPTION_COLOR IS '주문 시점 색상 스냅샷';
COMMENT ON COLUMN TB_ORDER_ITEM.OPTION_SIZE IS '주문 시점 사이즈 스냅샷';
COMMENT ON COLUMN TB_ORDER_ITEM.PRODUCT_NAME IS '상품명 스냅샷';
COMMENT ON COLUMN TB_ORDER_ITEM.QTY IS '수량';
COMMENT ON COLUMN TB_ORDER_ITEM.UNIT_PRICE IS '단가';
COMMENT ON COLUMN TB_ORDER_ITEM.TOTAL_PRICE IS '합계';
COMMENT ON COLUMN TB_ORDER_ITEM.CLAIM_STATUS IS '클레임 상태';
COMMENT ON COLUMN TB_ORDER_ITEM.CLAIM_REASON IS '클레임 사유';
-- 2026/07/29 장우철
COMMENT ON COLUMN TB_ORDER_ITEM.CONFIRMED_AT IS '구매확정 시각. 정산월 집계 기준';
COMMENT ON COLUMN TB_ORDER_ITEM.CONFIRM_DUE_AT IS '배송완료+7일 자동확정 예정 시각';
COMMENT ON COLUMN TB_ORDER_ITEM.CONFIRM_HOLD_YN IS '반품신청 중 Y면 자동구매확정 중지';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_STATUS_CD IS 'NONE/REQUESTED/REJECTED/APPROVED/RETURNING/DONE';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_REASON_CD IS 'CHANGE_OF_MIND / DEFECT';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_CHECK_RESULT_CD IS 'PENDING/DEFECT/NOT_DEFECT';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_FEE_PAYER IS 'USER / BIZ';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_FEE_AMOUNT IS '반품 택배비';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_REQUESTED_AT IS '반품 신청일시';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_APPROVED_AT IS '반품 승인일시';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_REJECTED_AT IS '반품 거절일시';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_DONE_AT IS '반품/환불 완료일시';
COMMENT ON COLUMN TB_ORDER_ITEM.REFUND_AMOUNT IS '상품단위 실환불액(회수완료 시 토스 환불액)';
COMMENT ON COLUMN TB_ORDER_ITEM.RETURN_REJECT_REASON IS '환불/반품 거절 사유';
COMMENT ON COLUMN TB_ORDER_DELIVERY.DELIVERY_ID IS '배송 ID';
COMMENT ON COLUMN TB_ORDER_DELIVERY.ORDER_ID IS '주문';
COMMENT ON COLUMN TB_ORDER_DELIVERY.BIZ_NO IS '발송 사업자';
COMMENT ON COLUMN TB_ORDER_DELIVERY.COURIER_NAME IS '택배사명';
COMMENT ON COLUMN TB_ORDER_DELIVERY.TRACKING_NO IS '송장번호';
COMMENT ON COLUMN TB_ORDER_DELIVERY.DELIVERY_STATUS IS '배송상태 (READY/SHIPPING/DELIVERED)';
COMMENT ON COLUMN TB_ORDER_DELIVERY.REGISTERED_AT IS '송장등록일(사업자)';
COMMENT ON COLUMN TB_ORDER_DELIVERY.MEMO IS '비고(택배API미사용)';
COMMENT ON COLUMN TB_PAYMENT.PAYMENT_ID IS '결제 ID';
COMMENT ON COLUMN TB_PAYMENT.ORDER_ID IS '주문';
COMMENT ON COLUMN TB_PAYMENT.RESV_ID IS '예약';
COMMENT ON COLUMN TB_PAYMENT.PAY_TYPE IS '결제유형 (ORDER/RESERVATION)';
COMMENT ON COLUMN TB_PAYMENT.PAY_METHOD IS '결제METHOD (CARD/TRANSFER/KAKAO/NAVER)';
COMMENT ON COLUMN TB_PAYMENT.PAY_AMOUNT IS '결제금액';
COMMENT ON COLUMN TB_PAYMENT.TOSS_PAYMENT_KEY IS '토스 paymentKey';
COMMENT ON COLUMN TB_PAYMENT.TOSS_ORDER_ID IS '토스 orderId';
COMMENT ON COLUMN TB_PAYMENT.PAY_STATUS IS '결제상태 (READY/DONE/CANCEL/REFUND)';
COMMENT ON COLUMN TB_PAYMENT.PAY_DATE IS '결제일';
COMMENT ON COLUMN TB_POST_COMMENT.COMMENT_ID IS '댓글 ID';
COMMENT ON COLUMN TB_POST_COMMENT.POST_ID IS '게시글';
COMMENT ON COLUMN TB_POST_COMMENT.PARENT_ID IS '부모댓글';
COMMENT ON COLUMN TB_POST_COMMENT.MEMBER_NO IS '작성자';
COMMENT ON COLUMN TB_POST_COMMENT.BODY IS '내용';
COMMENT ON COLUMN TB_POST_COMMENT.IS_DELETED IS '삭제 Y/N';
COMMENT ON COLUMN TB_POST_COMMENT.REG_DATE IS '등록일';
-- COMMENT ON COLUMN TB_EXPERIENCE_GROUP.EXP_ID IS '체험단 ID';
-- COMMENT ON COLUMN TB_EXPERIENCE_GROUP.EXP_NAME IS 'EXP명';
-- COMMENT ON COLUMN TB_EXPERIENCE_GROUP.PRODUCT_ID IS '상품 ID';
-- COMMENT ON COLUMN TB_EXPERIENCE_GROUP.RECRUIT_START IS 'RECRUIT시작';
-- COMMENT ON COLUMN TB_EXPERIENCE_GROUP.RECRUIT_END IS 'RECRUIT종료';
-- COMMENT ON COLUMN TB_EXPERIENCE_APPLY.APPLY_ID IS '신청 ID';
-- COMMENT ON COLUMN TB_EXPERIENCE_APPLY.EXP_ID IS '체험단 ID';
-- COMMENT ON COLUMN TB_EXPERIENCE_APPLY.MEMBER_NO IS '회원번호';
-- COMMENT ON COLUMN TB_EXPERIENCE_APPLY.STATUS_CD IS '상태코드';
COMMENT ON COLUMN TB_REVIEW.REVIEW_ID IS '리뷰 ID';
COMMENT ON COLUMN TB_REVIEW.REVIEW_TYPE IS '리뷰 유형 (HOSPITAL/STAY/PRODUCT)';
COMMENT ON COLUMN TB_REVIEW.TARGET_ID IS '대상 ID (병원/숙소/상품)';
COMMENT ON COLUMN TB_REVIEW.MEMBER_NO IS '작성 회원';
COMMENT ON COLUMN TB_REVIEW.ORDER_ITEM_ID IS '상품리뷰용 주문상품';
COMMENT ON COLUMN TB_REVIEW.RESV_ID IS '병원리뷰용 예약';
COMMENT ON COLUMN TB_REVIEW.RATING IS '별점';
COMMENT ON COLUMN TB_REVIEW.CONTENT IS '리뷰 내용';
COMMENT ON COLUMN TB_REVIEW.BIZ_REPLY IS '사업자 답글';
COMMENT ON COLUMN TB_REVIEW.REG_DATE IS '작성일';

-- 2026/07/13 유정 — TB_TALENT 컬럼 주석
COMMENT ON COLUMN TB_TALENT.TALENT_ID IS '재능나눔 ID';
COMMENT ON COLUMN TB_TALENT.BIZ_NO IS '사업자번호';
COMMENT ON COLUMN TB_TALENT.TITLE IS '제목';
COMMENT ON COLUMN TB_TALENT.TALENT_TYPE IS '유형 (GROOMING/HOSPITAL/PHOTO/TRANSPORT/ETC)';
COMMENT ON COLUMN TB_TALENT.CAPACITY IS '모집 건수';
COMMENT ON COLUMN TB_TALENT.CURRENT_CNT IS '현재 신청/진행 수 캐시';
COMMENT ON COLUMN TB_TALENT.SCHEDULE IS '진행 일정';
COMMENT ON COLUMN TB_TALENT.DURATION IS '소요 시간';
COMMENT ON COLUMN TB_TALENT.LOCATION IS '장소';
COMMENT ON COLUMN TB_TALENT.CONTACT IS '문의 연락처';
COMMENT ON COLUMN TB_TALENT.BODY IS '상세 설명';
COMMENT ON COLUMN TB_TALENT.THUMB_URL IS '대표 이미지 URL';
COMMENT ON COLUMN TB_TALENT.STATUS_CD IS 'PENDING/APPROVED/REJECTED/DONE';
COMMENT ON COLUMN TB_TALENT.REJECT_REASON IS '반려 사유';
COMMENT ON COLUMN TB_TALENT.ADMIN_NO IS '승인·반려 처리 관리자';
COMMENT ON COLUMN TB_TALENT.REG_DATE IS '등록일';
COMMENT ON COLUMN TB_TALENT.APPROVE_DATE IS '승인일';

-- 2026/07/13 장우철 — TB_REVIEW_REPORT 컬럼 주석
COMMENT ON COLUMN TB_REVIEW_REPORT.REPORT_ID IS '신고 ID';
COMMENT ON COLUMN TB_REVIEW_REPORT.REPORTER_TYPE IS '신고자 유형 (USER/BIZ)';
COMMENT ON COLUMN TB_REVIEW_REPORT.REPORTER_NO IS 'USER=MEMBER_NO / BIZ=BIZ_NO';
COMMENT ON COLUMN TB_REVIEW_REPORT.TARGET_MEMBER_NO IS '사업자→유저 신고 시 대상 회원';
COMMENT ON COLUMN TB_REVIEW_REPORT.HOSPITAL_ID IS '유저→병원 신고 시 대상 병원';
COMMENT ON COLUMN TB_REVIEW_REPORT.REVIEW_ID IS '관련 리뷰';
COMMENT ON COLUMN TB_REVIEW_REPORT.BIZ_NO IS '관련 사업자';
COMMENT ON COLUMN TB_REVIEW_REPORT.REASON IS '신고 사유';
COMMENT ON COLUMN TB_REVIEW_REPORT.STATUS_CD IS 'PENDING/DONE';
COMMENT ON COLUMN TB_REVIEW_REPORT.ADMIN_NO IS '처리 관리자 (접수 시 NULL)';
COMMENT ON COLUMN TB_REVIEW_REPORT.REG_DATE IS '접수일';
-- 2026/07/27 장우철 - TB_BILLING_CARD(토스 빌링키 , 카드등록)
COMMENT ON TABLE TB_BILLING_CARD IS '토스 자동결제(빌링) 등록카드';
COMMENT ON COLUMN TB_BILLING_CARD.BILLING_CARD_ID IS '빌링카드 ID';
COMMENT ON COLUMN TB_BILLING_CARD.OWNER_TYPE IS '소유자 유형 — MEMBER/ADMIN';
COMMENT ON COLUMN TB_BILLING_CARD.OWNER_NO IS 'MEMBER_NO 또는 ADMIN_NO';
COMMENT ON COLUMN TB_BILLING_CARD.CUSTOMER_KEY IS '토스 구매자 식별키';
COMMENT ON COLUMN TB_BILLING_CARD.BILLING_KEY IS '토스 빌링키(자동결제용)';
COMMENT ON COLUMN TB_BILLING_CARD.CARD_COMPANY IS '카드사명';
COMMENT ON COLUMN TB_BILLING_CARD.CARD_NUMBER IS '마스킹 카드번호';
COMMENT ON COLUMN TB_BILLING_CARD.STATUS_CD IS '상태코드 — ACTIVE/DELETED';
COMMENT ON COLUMN TB_BILLING_CARD.REG_DATE IS '등록일';







/* =========================================================
   PETRINI_MIN_DEMO_DATA.sql
   프로젝트 : Petrini / petcare
   용도     : 발표/포트폴리오용 최소 더미 데이터
   전제     : DATABASE_TABLE.sql 실행 완료
   비밀번호 : 모든 테스트 로그인 계정 1234
   ========================================================= */
SET DEFINE OFF;
/* 이미지 파일명 (C:\upload 바로 아래)
   main_banner.jpg / pet_dog.jpg / pet_cat.jpg
   profile_male.jpg / profile_female.jpg
   dog_food.jpg / dog_snack.jpg / dog_goods.jpg
   cat_food.jpg / cat_snack.jpg / cat_goods.jpg
   hospital_main.jpg / stay_main.jpg / stay_deluxe.jpg / stay_suite.jpg
*/
/* =========================================================
   0. 기존 테스트 데이터 정리
   - 개발/발표 DB에서 재실행하기 위한 초기화용
   - FK 자식 → 부모 순서
   ========================================================= */

DELETE FROM TB_SETTLEMENT_ITEM;
DELETE FROM TB_SETTLEMENT_REQUEST;
DELETE FROM TB_SETTLEMENT;

DELETE FROM TB_REVIEW_DELETE_REQUEST;
DELETE FROM TB_REVIEW_REPORT;
DELETE FROM TB_REVIEW;

DELETE FROM TB_PAYMENT;

-- TB_ORDER.ORDER_ITEM_ID가 사용된 레거시 데이터가 있을 수 있으므로 먼저 연결 해제
UPDATE TB_ORDER SET ORDER_ITEM_ID = NULL;
DELETE FROM TB_ORDER_DELIVERY;
DELETE FROM TB_ORDER_ITEM;
DELETE FROM TB_ORDER;

DELETE FROM TB_CART_ITEM;
DELETE FROM TB_CART;

DELETE FROM TB_HOSPITAL_RESV_HOLD;
DELETE FROM TB_RESERVATION;
DELETE FROM TB_MEDICAL_RECORD;
DELETE FROM TB_HOSPITAL_RESV_EXCEPTION;
DELETE FROM TB_HOSPITAL_DOCTOR;
DELETE FROM TB_HOSPITAL_TREAT_TYPE;

DELETE FROM TB_POST_REPORT;
DELETE FROM TB_POST_LIKE;
UPDATE TB_POST_COMMENT SET PARENT_ID = NULL;
DELETE FROM TB_POST_COMMENT;
DELETE FROM TB_POST;

DELETE FROM TB_TALENT_APPLY;
DELETE FROM TB_TALENT;

DELETE FROM TB_PRODUCT_QNA;

DELETE FROM TB_MEMBER_COUPON;
DELETE FROM TB_COUPON;

DELETE FROM TB_FAVORITE;
DELETE FROM TB_NOTIFICATION;
DELETE FROM TB_POINT;
DELETE FROM TB_INQUIRY;
DELETE FROM TB_CONTENT;
DELETE FROM TB_FAQ;
DELETE FROM TB_NOTICE;

DELETE FROM TB_BANNER;
DELETE FROM TB_FILE;

DELETE FROM TB_STAY_ROOM;
DELETE FROM TB_STAY;
DELETE FROM TB_HOSPITAL;
DELETE FROM TB_BUSINESS_AUTH;

DELETE FROM TB_PRODUCT_OPTION;
DELETE FROM TB_PRODUCT;
DELETE FROM TB_PRODUCT_CATEGORY;

DELETE FROM TB_MEMBER_ADDRESS;
DELETE FROM TB_MEMBER_AGREEMENT;
DELETE FROM TB_MEMBER_SOCIAL;
DELETE FROM TB_PET;
DELETE FROM TB_MEMBER;

DELETE FROM TB_POLICY;
DELETE FROM TB_MEMBER_GRADE;

DELETE FROM TB_BUSINESS;
DELETE FROM TB_ADMIN;
DELETE FROM TB_ADMIN_ROLE;

COMMIT;


/* =========================================================
   1. 시퀀스 재생성
   ========================================================= */

BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_MEMBER'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_MEMBER_SOCIAL'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_MEMBER_AGREEMENT'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_PET'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_FILE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_FILE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_RESERVATION'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_POST'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_POST_COMMENT'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_POST_REPORT'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_POST_LIKE'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_TALENT'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_TALENT_APPLY'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_REVIEW_REPORT'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_REVIEW_DELETE_REQUEST'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_PAYMENT'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_COUPON'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_MEMBER_COUPON'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_BANNER'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_SETTLEMENT'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_SETTLEMENT_REQUEST'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_TB_SETTLEMENT_ITEM'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/

CREATE SEQUENCE SEQ_MEMBER START WITH 6 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_MEMBER_SOCIAL START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_MEMBER_AGREEMENT START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_PET START WITH 3 INCREMENT BY 1 NOCACHE;

-- 프로젝트에서 SEQ_FILE / SEQ_TB_FILE을 둘 다 사용하므로 데모에서는 번호 대역을 분리
CREATE SEQUENCE SEQ_TB_FILE START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_FILE START WITH 1000 INCREMENT BY 1 NOCACHE;

CREATE SEQUENCE SEQ_RESERVATION START WITH 7 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TB_POST START WITH 7 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TB_POST_COMMENT START WITH 9 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TB_POST_REPORT START WITH 3 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TB_POST_LIKE START WITH 7 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TB_TALENT START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TB_TALENT_APPLY START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TB_REVIEW_REPORT START WITH 2 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_TB_REVIEW_DELETE_REQUEST START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_PAYMENT START WITH 10 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE SEQ_COUPON START WITH 4 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_MEMBER_COUPON START WITH 5 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_TB_BANNER START WITH 2 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_TB_SETTLEMENT START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_TB_SETTLEMENT_REQUEST START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE SEQ_TB_SETTLEMENT_ITEM START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;


/* =========================================================
   2. 기준정보
   - 아래는 "더미"라기보다 서비스 구동용 기준값
   ========================================================= */

-- 회원 등급
INSERT INTO TB_MEMBER_GRADE (GRADE_CD, GRADE_NAME, MIN_POINT, BENEFIT_DESC) VALUES ('BRONZE', '브론즈', 0, '기본 등급');

INSERT INTO TB_MEMBER_GRADE (GRADE_CD, GRADE_NAME, MIN_POINT, BENEFIT_DESC) VALUES ('SILVER', '실버', 10000, '적립 1% 추가');

INSERT INTO TB_MEMBER_GRADE (GRADE_CD, GRADE_NAME, MIN_POINT, BENEFIT_DESC) VALUES ('GOLD', '골드', 50000, '적립 2% 추가 / 무료배송');

-- 관리자 권한
INSERT INTO TB_ADMIN_ROLE (ROLE_ID, ROLE_NAME, ROLE_DESC, USE_YN, MENU_PERMS) VALUES (1, '최고관리자', '전체 메뉴 접근', 'Y', '{"all":true}');

-- 관리자: admin / 1234
INSERT INTO TB_ADMIN (ADMIN_NO, ADMIN_ID, ADMIN_PWD, ADMIN_NAME, ROLE_ID, STATUS_CD, REG_DATE) VALUES (1, 'admin', '$2a$10$qIkpgyhoGUjLySmgmn8O6OldY5gulqDQBB0I1CFE7Rfn3raFElZNa', '최고관리자', 1, 'NORMAL', TO_CHAR(SYSDATE, 'YYYY-MM-DD'));

-- 상품 카테고리: 기존 트리 유지
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (1, 1, '전체', '1', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (5, 1, '강아지', '2', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (6, 1, '고양이', '2', 'Y');

INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (2, 5, '사료', '3', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (3, 5, '간식', '3', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (4, 5, '용품', '3', 'Y');

INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (10, 6, '사료', '3', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (11, 6, '간식', '3', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (12, 6, '용품', '3', 'Y');

INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (7, 2, '퍼피', '4', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (8, 2, '어덜트', '4', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (9, 2, '시니어', '4', 'Y');

INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (13, 3, '퍼피', '4', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (14, 3, '어덜트', '4', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (15, 3, '시니어', '4', 'Y');

INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (19, 10, '키튼', '4', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (20, 10, '어덜트', '4', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (21, 10, '시니어', '4', 'Y');

INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (22, 11, '키튼', '4', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (23, 11, '어덜트', '4', 'Y');
INSERT INTO TB_PRODUCT_CATEGORY (CATEGORY_ID, PARENT_ID, CATEGORY_NAME, DEPTH, USE_YN) VALUES (24, 11, '시니어', '4', 'Y');

-- 포인트 정책
INSERT INTO TB_POLICY (POLICY_ID, POLICY_TYPE, POLICY_KEY, POLICY_VALUE) VALUES (1, 'POINT', 'PURCHASE_RATE', '1');
INSERT INTO TB_POLICY (POLICY_ID, POLICY_TYPE, POLICY_KEY, POLICY_VALUE) VALUES (2, 'POINT', 'REVIEW_TEXT', '500');
INSERT INTO TB_POLICY (POLICY_ID, POLICY_TYPE, POLICY_KEY, POLICY_VALUE) VALUES (3, 'POINT', 'REVIEW_PHOTO', '1000');
INSERT INTO TB_POLICY (POLICY_ID, POLICY_TYPE, POLICY_KEY, POLICY_VALUE) VALUES (4, 'POINT', 'REVIEW_MIN_LENGTH', '50');


/* =========================================================
   3. 여기부터 실제 발표용 더미 데이터
   ========================================================= */

-- ---------------------------------------------------------
-- 3-1. 일반 회원 2명 + 사업자 로그인용 회원 3명
--      ※ 사업자도 로그인 자체는 TB_MEMBER를 거친 뒤
--         TB_BUSINESS.BIZ_ID로 사업자 권한을 확인하므로
--         물리적으로 TB_MEMBER에는 총 5행이 필요함.
-- ---------------------------------------------------------

-- 일반회원 1: 남
INSERT INTO TB_MEMBER (MEMBER_NO, MEMBER_ID, MEMBER_PWD, MEMBER_NAME, NICKNAME, EMAIL, PHONE, ZIP_CODE, ADDR1, ADDR2, GRADE_CD, POINT_BALANCE, PROFILE_IMG_URL, STATUS_CD, MARKETING_YN, JOIN_DATE, BIRTH_DATE, GENDER) VALUES (1, 'user01', '$2a$10$qIkpgyhoGUjLySmgmn8O6OldY5gulqDQBB0I1CFE7Rfn3raFElZNa', '김민준', '몽이아빠', 'user01@petrini.demo', '010-1111-1111', '34141', '대전광역시 유성구 대학로 10', '101호', 'BRONZE', 3500, '/upload/profile_male.jpg', 'NORMAL', 'Y', SYSDATE - 120, TO_DATE('1992-05-14', 'YYYY-MM-DD'), 'M');
-- 일반회원 2: 여
INSERT INTO TB_MEMBER (MEMBER_NO, MEMBER_ID, MEMBER_PWD, MEMBER_NAME, NICKNAME, EMAIL, PHONE, ZIP_CODE, ADDR1, ADDR2, GRADE_CD, POINT_BALANCE, PROFILE_IMG_URL, STATUS_CD, MARKETING_YN, JOIN_DATE, BIRTH_DATE, GENDER) VALUES (2, 'user02', '$2a$10$qIkpgyhoGUjLySmgmn8O6OldY5gulqDQBB0I1CFE7Rfn3raFElZNa', '이서연', '루나집사', 'user02@petrini.demo', '010-2222-2222', '31156', '충청남도 천안시 서북구 불당로 20', '202호', 'SILVER', 12500, '/upload/profile_female.jpg', 'NORMAL', 'N', SYSDATE - 95, TO_DATE('1995-10-03', 'YYYY-MM-DD'), 'F');
-- 쇼핑몰 사업자 로그인 계정
INSERT INTO TB_MEMBER (MEMBER_NO, MEMBER_ID, MEMBER_PWD, MEMBER_NAME, NICKNAME, EMAIL, PHONE, GRADE_CD, POINT_BALANCE, STATUS_CD, MARKETING_YN, JOIN_DATE) VALUES (3, 'store01', '$2a$10$qIkpgyhoGUjLySmgmn8O6OldY5gulqDQBB0I1CFE7Rfn3raFElZNa', '박민수', '펫마켓운영자', 'store01@petrini.demo', '010-3333-3333', 'BRONZE', 0, 'NORMAL', 'N', SYSDATE - 180);
-- 병원 사업자 로그인 계정
INSERT INTO TB_MEMBER (MEMBER_NO, MEMBER_ID, MEMBER_PWD, MEMBER_NAME, NICKNAME, EMAIL, PHONE, GRADE_CD, POINT_BALANCE, STATUS_CD, MARKETING_YN, JOIN_DATE) VALUES (4, 'hospital01', '$2a$10$qIkpgyhoGUjLySmgmn8O6OldY5gulqDQBB0I1CFE7Rfn3raFElZNa', '정유진', '온누리동물병원', 'hospital01@petrini.demo', '010-4444-4444', 'BRONZE', 0, 'NORMAL', 'N', SYSDATE - 180);
-- 숙소 사업자 로그인 계정
INSERT INTO TB_MEMBER (MEMBER_NO, MEMBER_ID, MEMBER_PWD, MEMBER_NAME, NICKNAME, EMAIL, PHONE, GRADE_CD, POINT_BALANCE, STATUS_CD, MARKETING_YN, JOIN_DATE) VALUES (5, 'stay01', '$2a$10$qIkpgyhoGUjLySmgmn8O6OldY5gulqDQBB0I1CFE7Rfn3raFElZNa', '한소영', '포레스트스테이', 'stay01@petrini.demo', '010-5555-5555', 'BRONZE', 0, 'NORMAL', 'N', SYSDATE - 180);


-- ---------------------------------------------------------
-- 3-2. 반려동물 2마리 (일반회원당 1마리)
-- ---------------------------------------------------------
INSERT INTO TB_PET (PET_ID, MEMBER_NO, PET_NAME, SPECIES, BREED, GENDER, BIRTH_DATE, AGE, WEIGHT, IS_REPRESENT, PHOTO_URL, DEL_YN, REG_DATE, FUR_COLOR, NEUTER_YN, TRAITS, MEMO) VALUES (1, 1, '몽이', 'DOG', '말티푸', 'M', ADD_MONTHS(TRUNC(SYSDATE), -36), 3, 5.2, 'Y', '/upload/pet_dog.jpg', 'N', SYSDATE - 100, '크림', 'Y', '활발함,사람좋아함', '산책을 좋아해요.');

INSERT INTO TB_PET (PET_ID, MEMBER_NO, PET_NAME, SPECIES, BREED, GENDER, BIRTH_DATE, AGE, WEIGHT, IS_REPRESENT, PHOTO_URL, DEL_YN, REG_DATE, FUR_COLOR, NEUTER_YN, TRAITS, MEMO) VALUES (2, 2, '루나', 'CAT', '코리안숏헤어', 'F', ADD_MONTHS(TRUNC(SYSDATE), -48), 4, 4.3, 'Y', '/upload/pet_cat.jpg', 'N', SYSDATE - 80, '고등어', 'Y', '차분함,낯가림', '츄르를 좋아해요.');


-- ---------------------------------------------------------
-- 3-3. 사업자 3명: 쇼핑몰 / 병원 / 숙소
-- ---------------------------------------------------------
INSERT INTO TB_BUSINESS (BIZ_NO, BIZ_ID, BIZ_TYPE, BIZ_REG_NO, BIZ_NAME, CEO_NAME, PHONE, EMAIL, ZIP_CODE, ADDR, ADDR_DETAIL, STATUS_CD, JOIN_DATE, APPROVE_DATE, FEE_RATE, SETTLE_ACCOUNT, SETTLE_BANK, SETTLE_BANK_CODE, SETTLE_HOLDER, SETTLE_VERIFY_YN, SETTLE_VERIFY_DATE, START_DATE, END_DATE, SHOP_NAME) VALUES (1, 'store01', 'STORE', '101-11-11111', 'Petrini 펫마켓', '박민수', '042-111-1111', 'store01@petrini.demo', '04001', '서울특별시 마포구 월드컵로 10', '1층', 'NORMAL', SYSDATE - 180, SYSDATE - 170, 5.0, '110123456789', '신한은행', '088', '박민수', 'Y', SYSDATE - 175, SYSDATE - 170, ADD_MONTHS(SYSDATE, 12), 'Petrini 펫마켓');

INSERT INTO TB_BUSINESS (BIZ_NO, BIZ_ID, BIZ_TYPE, BIZ_REG_NO, BIZ_NAME, CEO_NAME, PHONE, EMAIL, ZIP_CODE, ADDR, ADDR_DETAIL, STATUS_CD, JOIN_DATE, APPROVE_DATE, FEE_RATE, SETTLE_ACCOUNT, SETTLE_BANK, SETTLE_BANK_CODE, SETTLE_HOLDER, SETTLE_VERIFY_YN, SETTLE_VERIFY_DATE, ANNUAL_FEE, START_DATE, END_DATE) VALUES (2, 'hospital01', 'HOSPITAL', '202-22-22222', '온누리 동물병원', '정유진', '042-222-2222', 'hospital01@petrini.demo', '34141', '대전광역시 유성구 대학로 20', '2층', 'NORMAL', SYSDATE - 180, SYSDATE - 170, 3.0, '110987654321', '신한은행', '088', '정유진', 'Y', SYSDATE - 175, 120000, SYSDATE - 170, ADD_MONTHS(SYSDATE, 12));

INSERT INTO TB_BUSINESS (BIZ_NO, BIZ_ID, BIZ_TYPE, BIZ_REG_NO, BIZ_NAME, CEO_NAME, PHONE, EMAIL, ZIP_CODE, ADDR, ADDR_DETAIL, STATUS_CD, JOIN_DATE, APPROVE_DATE, FEE_RATE, SETTLE_ACCOUNT, SETTLE_BANK, SETTLE_BANK_CODE, SETTLE_HOLDER, SETTLE_VERIFY_YN, SETTLE_VERIFY_DATE, START_DATE, END_DATE) VALUES (3, 'stay01', 'STAY', '303-33-33333', '포레스트 펫스테이', '한소영', '033-333-3333', 'stay01@petrini.demo', '25460', '강원특별자치도 강릉시 해안로 30', '별관', 'NORMAL', SYSDATE - 180, SYSDATE - 170, 7.0, '110555555555', '신한은행', '088', '한소영', 'Y', SYSDATE - 175, SYSDATE - 170, ADD_MONTHS(SYSDATE, 12));

-- 관리자 사업자관리 화면에서도 승인 이력이 보이도록 AUTH 3건
INSERT INTO TB_BUSINESS_AUTH (AUTH_ID, BIZ_NO, BIZ_REG_NO, BIZ_TYPE, AD_APPLY_YN, STATUS_CD, APPLY_DATE, APPROVE_DATE, ADMIN_NO) VALUES (1, 1, '101-11-11111', 'STORE', 'N', 'APPROVE', SYSDATE - 180, SYSDATE - 170, 1);

INSERT INTO TB_BUSINESS_AUTH (AUTH_ID, BIZ_NO, BIZ_REG_NO, BIZ_TYPE, AD_APPLY_YN, STATUS_CD, APPLY_DATE, APPROVE_DATE, ADMIN_NO) VALUES (2, 2, '202-22-22222', 'HOSPITAL', 'N', 'APPROVE', SYSDATE - 180, SYSDATE - 170, 1);

INSERT INTO TB_BUSINESS_AUTH (AUTH_ID, BIZ_NO, BIZ_REG_NO, BIZ_TYPE, AD_APPLY_YN, STATUS_CD, APPLY_DATE, APPROVE_DATE, ADMIN_NO) VALUES (3, 3, '303-33-33333', 'STAY', 'N', 'APPROVE', SYSDATE - 180, SYSDATE - 170, 1);


-- ---------------------------------------------------------
-- 3-4. 병원 + 의사 2명 + 진료유형 3개
-- ---------------------------------------------------------
INSERT INTO TB_HOSPITAL (HOSPITAL_ID, BIZ_NO, MEMBER_NO, NAME, PHONE, ADDR, ADDR_DETAIL, LAT, LNG, AVG_RATING, REVIEW_CNT, DATA_SOURCE, STATUS_CD, APPROVE_DATE, HOURS_JSON, DESCRIPTION, TAG_LIST, RESV_CAPACITY, RESV_INTERVAL_MIN) VALUES (1, 2, 4, '온누리 동물병원', '042-222-2222', '대전광역시 유성구 대학로 20', '2층', 36.3622000, 127.3560000, 4.5, 1, 'PLATFORM', 'ACTIVE', SYSDATE - 170, '{"월":{"open":"09:00","close":"18:00","lunchStart":"12:00","lunchEnd":"13:00"},"화":{"open":"09:00","close":"18:00","lunchStart":"12:00","lunchEnd":"13:00"},"수":{"open":"09:00","close":"18:00","lunchStart":"12:00","lunchEnd":"13:00"},"목":{"open":"09:00","close":"18:00","lunchStart":"12:00","lunchEnd":"13:00"},"금":{"open":"09:00","close":"18:00","lunchStart":"12:00","lunchEnd":"13:00"},"토":{"open":"09:00","close":"13:00","lunchStart":"","lunchEnd":""}}', '강아지와 고양이 일반진료, 예방접종, 건강검진을 운영하는 동물병원입니다.', '강아지,고양이,일반진료,예방접종,건강검진', 2, 30);

INSERT INTO TB_HOSPITAL_DOCTOR (DOCTOR_ID, HOSPITAL_ID, DOCTOR_NAME, SPECIALTY, STATUS_CD, SORT_ORDR, REG_DATE) VALUES (1, 1, '김하늘', '내과·예방진료', 'Y', 1, SYSDATE - 150);

INSERT INTO TB_HOSPITAL_DOCTOR (DOCTOR_ID, HOSPITAL_ID, DOCTOR_NAME, SPECIALTY, STATUS_CD, SORT_ORDR, REG_DATE) VALUES (2, 1, '박지호', '피부·건강검진', 'Y', 2, SYSDATE - 150);

INSERT INTO TB_HOSPITAL_TREAT_TYPE (TREAT_TYPE_ID, HOSPITAL_ID, TYPE_NAME, DURATION_MIN, STATUS_CD, SORT_ORDR, REG_DATE) VALUES (1, 1, '일반진료', 30, 'Y', 1, SYSDATE - 150);

INSERT INTO TB_HOSPITAL_TREAT_TYPE (TREAT_TYPE_ID, HOSPITAL_ID, TYPE_NAME, DURATION_MIN, STATUS_CD, SORT_ORDR, REG_DATE) VALUES (2, 1, '예방접종', 20, 'Y', 2, SYSDATE - 150);

INSERT INTO TB_HOSPITAL_TREAT_TYPE (TREAT_TYPE_ID, HOSPITAL_ID, TYPE_NAME, DURATION_MIN, STATUS_CD, SORT_ORDR, REG_DATE) VALUES (3, 1, '건강검진', 60, 'Y', 3, SYSDATE - 150);


-- ---------------------------------------------------------
-- 3-5. 숙소 1곳 + 객실 2개
-- ---------------------------------------------------------
INSERT INTO TB_STAY (STAY_ID, BIZ_NO, MEMBER_NO, NAME, PHONE, ZIP_CODE, ADDR, ADDR_DETAIL, LAT, LNG, PET_POLICY, REFUND_POLICY, STATUS_CD, APPROVE_DATE, FACILITIES, CHECK_IN, CHECK_OUT, DESCRIPTION, PET_FEE, REGION, AVG_RATING, REVIEW_CNT) VALUES (1, 3, 5, '포레스트 펫스테이', '033-333-3333', '25460', '강원특별자치도 강릉시 해안로 30', '별관', '37.7519000', '128.8761000', '기본 1마리 포함, 예방접종 완료 반려동물만 이용 가능합니다.', '체크인 3일 전까지 전액 환불, 이후 일정에 따라 수수료가 부과됩니다.', 'ACTIVE', TO_CHAR(SYSDATE - 170, 'YYYY-MM-DD'), '주차,운동장,펫샤워실,와이파이', '15:00', '11:00', '조용한 휴식을 즐길 수 있는 반려동물 동반 숙소입니다.', 10000, '강원', 5.0, 1);

INSERT INTO TB_STAY_ROOM (ROOM_ID, STAY_ID, NAME, PRICE_PER_NIGHT, CAPACITY, PET_LIMIT, STATUS_CD) VALUES (1, 1, '포레스트 디럭스', 120000, 3, 2, 'APPROVE');

INSERT INTO TB_STAY_ROOM (ROOM_ID, STAY_ID, NAME, PRICE_PER_NIGHT, CAPACITY, PET_LIMIT, STATUS_CD) VALUES (2, 1, '포레스트 스위트', 170000, 4, 2, 'APPROVE');


-- ---------------------------------------------------------
-- 3-6. 상품 6개: 강아지 3 + 고양이 3
-- ---------------------------------------------------------
INSERT INTO TB_PRODUCT (PRODUCT_ID, PRODUCT_CD, PRODUCT_NAME, BIZ_NO, CATEGORY_ID, PRICE, SALE_PRICE, STOCK_QTY, LOW_STOCK_THRESHOLD, DESCRIPTION, STATUS_CD, APPROVE_DATE, REG_DATE, BRAND_NAME, TAGS) VALUES (1, 'DOG-FOOD-001', '네이처밸런스 어덜트 독 사료 2kg', 1, 8, '32000', '28900', '25', '5', '성견을 위한 균형 잡힌 데일리 사료입니다.', 'NORMAL', TO_CHAR(SYSDATE - 90, 'YYYY-MM-DD'), TO_CHAR(SYSDATE - 95, 'YYYY-MM-DD'), '네이처밸런스', '강아지,사료,어덜트');

INSERT INTO TB_PRODUCT (PRODUCT_ID, PRODUCT_CD, PRODUCT_NAME, BIZ_NO, CATEGORY_ID, PRICE, SALE_PRICE, STOCK_QTY, LOW_STOCK_THRESHOLD, DESCRIPTION, STATUS_CD, APPROVE_DATE, REG_DATE, BRAND_NAME, TAGS) VALUES (2, 'DOG-SNACK-001', '오리안심 큐브 트릿 100g', 1, 14, '9800', '8500', '30', '5', '한입 크기로 급여하기 편한 오리안심 간식입니다.', 'NORMAL', TO_CHAR(SYSDATE - 85, 'YYYY-MM-DD'), TO_CHAR(SYSDATE - 90, 'YYYY-MM-DD'), '펫프레시', '강아지,간식,트릿');

INSERT INTO TB_PRODUCT (PRODUCT_ID, PRODUCT_CD, PRODUCT_NAME, BIZ_NO, CATEGORY_ID, PRICE, SALE_PRICE, STOCK_QTY, LOW_STOCK_THRESHOLD, DESCRIPTION, STATUS_CD, APPROVE_DATE, REG_DATE, BRAND_NAME, TAGS) VALUES (3, 'DOG-GOODS-001', '암앤해머 컴플리트케어 효소치약', 1, 4, '24000', '21900', '18', '3', '반려견 일상생활에 활용할 수 있는 실용적인 용품입니다.', 'NORMAL', TO_CHAR(SYSDATE - 80, 'YYYY-MM-DD'), TO_CHAR(SYSDATE - 85, 'YYYY-MM-DD'), '펫데일리', '강아지,용품');

INSERT INTO TB_PRODUCT (PRODUCT_ID, PRODUCT_CD, PRODUCT_NAME, BIZ_NO, CATEGORY_ID, PRICE, SALE_PRICE, STOCK_QTY, LOW_STOCK_THRESHOLD, DESCRIPTION, STATUS_CD, APPROVE_DATE, REG_DATE, BRAND_NAME, TAGS) VALUES (4, 'CAT-FOOD-001', '그레인프리 어덜트 캣 사료 1.5kg', 1, 20, '28000', '25200', '22', '5', '성묘를 위한 그레인프리 데일리 사료입니다.', 'NORMAL', TO_CHAR(SYSDATE - 75, 'YYYY-MM-DD'), TO_CHAR(SYSDATE - 80, 'YYYY-MM-DD'), '캣밸런스', '고양이,사료,어덜트');

INSERT INTO TB_PRODUCT (PRODUCT_ID, PRODUCT_CD, PRODUCT_NAME, BIZ_NO, CATEGORY_ID, PRICE, SALE_PRICE, STOCK_QTY, LOW_STOCK_THRESHOLD, DESCRIPTION, STATUS_CD, APPROVE_DATE, REG_DATE, BRAND_NAME, TAGS) VALUES (5, 'CAT-SNACK-001', '알로키친 산양유 초록홍합 30g', 1, 23, '8900', '7900', '28', '5', '산양유와 초록홍합 원물을 동결건조한 반려동물 간식입니다.', 'NORMAL', TO_CHAR(SYSDATE - 70, 'YYYY-MM-DD'), TO_CHAR(SYSDATE - 75, 'YYYY-MM-DD'), '미유키친', '고양이,간식,동결건조');

INSERT INTO TB_PRODUCT (PRODUCT_ID, PRODUCT_CD, PRODUCT_NAME, BIZ_NO, CATEGORY_ID, PRICE, SALE_PRICE, STOCK_QTY, LOW_STOCK_THRESHOLD, DESCRIPTION, STATUS_CD, APPROVE_DATE, REG_DATE, BRAND_NAME, TAGS) VALUES (6, 'CAT-GOODS-001', '코코캣 캣 하네스', 1, 12, '32000', '27900', '15', '3', '반려묘 일상생활에 활용할 수 있는 실용적인 용품입니다.', 'NORMAL', TO_CHAR(SYSDATE - 65, 'YYYY-MM-DD'), TO_CHAR(SYSDATE - 70, 'YYYY-MM-DD'), '캣데일리', '고양이,용품');

-- 상품 옵션: 화면/재고 계산 오류 방지용으로 상품당 1개씩
INSERT INTO TB_PRODUCT_OPTION (OPTION_ID, PRODUCT_ID, OPTION_COLOR, OPTION_SIZE, ADD_PRICE, STOCK_QTY) VALUES (1, 1, '기본', '2kg', 0, 25);

INSERT INTO TB_PRODUCT_OPTION (OPTION_ID, PRODUCT_ID, OPTION_COLOR, OPTION_SIZE, ADD_PRICE, STOCK_QTY) VALUES (2, 2, '기본', '100g', 0, 30);

INSERT INTO TB_PRODUCT_OPTION (OPTION_ID, PRODUCT_ID, OPTION_COLOR, OPTION_SIZE, ADD_PRICE, STOCK_QTY) VALUES (3, 3, '기본', 'FREE', 0, 18);

INSERT INTO TB_PRODUCT_OPTION (OPTION_ID, PRODUCT_ID, OPTION_COLOR, OPTION_SIZE, ADD_PRICE, STOCK_QTY) VALUES (4, 4, '기본', '1.5kg', 0, 22);

INSERT INTO TB_PRODUCT_OPTION (OPTION_ID, PRODUCT_ID, OPTION_COLOR, OPTION_SIZE, ADD_PRICE, STOCK_QTY) VALUES (5, 5, '기본', '60g', 0, 28);

INSERT INTO TB_PRODUCT_OPTION (OPTION_ID, PRODUCT_ID, OPTION_COLOR, OPTION_SIZE, ADD_PRICE, STOCK_QTY) VALUES (6, 6, '기본', 'FREE', 0, 15);


-- ---------------------------------------------------------
-- 3-7. 이미지 파일 (실제 파일 위치: C:\upload\)
-- FILE_URL은 TB_FILE 화면 코드가 /upload/를 붙여서 쓰므로 파일명만 저장
-- ---------------------------------------------------------
-- 메인 배너 1200x360 권장
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (1, 'BANNER', 1, NULL, 'main_banner.jpg', 'main_banner.jpg', SYSDATE - 30);
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (12, 'BANNER', 2, NULL, 'main_banner_shop.jpg', 'main_banner_shop.jpg', SYSDATE - 20);

-- 상품 6장
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (2, 'PRODUCT', 1, NULL, 'dog_food.jpg', 'dog_food.jpg', SYSDATE - 90);
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (3, 'PRODUCT', 2, NULL, 'dog_snack.jpg', 'dog_snack.jpg', SYSDATE - 85);
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (4, 'PRODUCT', 3, NULL, 'dog_goods.jpg', 'dog_goods.jpg', SYSDATE - 80);
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (5, 'PRODUCT', 4, NULL, 'cat_food.jpg', 'cat_food.jpg', SYSDATE - 75);
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (6, 'PRODUCT', 5, NULL, 'cat_snack.jpg', 'cat_snack.jpg', SYSDATE - 70);
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (7, 'PRODUCT', 6, NULL, 'cat_goods.jpg', 'cat_goods.jpg', SYSDATE - 65);

-- 병원 대표사진
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (8, 'HOSPITAL', 1, NULL, 'hospital_main.jpg', 'hospital_main.jpg', SYSDATE - 60);

-- 숙소 외관 + 디럭스룸 + 스위트룸 (현재 구조상 세 장 모두 STAY_ID=1에 연결)
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (9, 'STAY', 1, NULL, 'stay_main.jpg', 'stay_main.jpg', SYSDATE - 60);
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (10, 'STAY', 1, NULL, 'stay_deluxe.jpg', 'stay_deluxe.jpg', SYSDATE - 60);
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (11, 'STAY', 1, NULL, 'stay_suite.jpg', 'stay_suite.jpg', SYSDATE - 60);

-- 메인 배너
INSERT INTO TB_BANNER (BANNER_ID, BIZ_NO, TITLE, POSITION_CD, FILE_ID, LINK_URL, START_DATE, END_DATE, STATUS_CD, REG_DATE) VALUES (1, 1, '반려동물과 함께하는 행복한 일상', 'MAIN_HERO', 1, '/store', TRUNC(SYSDATE) - 30, TRUNC(SYSDATE) + 365, 'ACTIVE', SYSDATE - 30);
INSERT INTO TB_BANNER (BANNER_ID, BIZ_NO, TITLE, POSITION_CD, FILE_ID, LINK_URL, START_DATE, END_DATE, STATUS_CD, REG_DATE) VALUES (2, 1, '사랑하는 만큼, 더 좋은 것만', 'MAIN_HERO', 12, '/store', TRUNC(SYSDATE) - 20, TRUNC(SYSDATE) + 365, 'ACTIVE', SYSDATE - 20);

--분실 보호
INSERT INTO TB_FILE (FILE_ID, REF_TYPE, REF_ID, DRIVE_FILE_ID, FILE_URL, ORIGIN_NAME, REG_DATE) VALUES (SEQ_TB_FILE.NEXTVAL, 'POST', 5, 'LOCAL', '/upload/give/report/5/lost_dog.jpg', 'lost_dog.jpg', SYSDATE - 1);
-- ---------------------------------------------------------
-- 3-8. 쿠폰 3개 + 회원 보유쿠폰 4개
-- ---------------------------------------------------------
INSERT INTO TB_COUPON (COUPON_ID, COUPON_CODE, COUPON_NAME, COUPON_TYPE, DISCOUNT_VALUE, MAX_DISCOUNT_AMT, MIN_ORDER_AMT, STATUS_CD, TOTAL_BUDGET, ISSUED_BUDGET, TOTAL_QTY, ISSUED_QTY, USE_START_DATE, USE_END_DATE, BIZ_MEMBER_NO, APPROVAL_STATUS, APPROVAL_DATE, REG_DATE, BIZ_NO) VALUES (1, 'STORE10', '펫마켓 10% 할인', 'RATE', 10, 5000, 20000, 'ACTIVE', 500000, 20, 100, 2, TO_CHAR(SYSDATE - 30, 'YYYYMMDD'), TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), 1, 'APPROVED', TO_CHAR(SYSDATE - 29, 'YYYYMMDD'), TO_CHAR(SYSDATE - 30, 'YYYYMMDDHH24MISS'), 1);

INSERT INTO TB_COUPON (COUPON_ID, COUPON_CODE, COUPON_NAME, COUPON_TYPE, DISCOUNT_VALUE, MAX_DISCOUNT_AMT, MIN_ORDER_AMT, STATUS_CD, TOTAL_BUDGET, ISSUED_BUDGET, TOTAL_QTY, ISSUED_QTY, USE_START_DATE, USE_END_DATE, BIZ_MEMBER_NO, APPROVAL_STATUS, APPROVAL_DATE, REG_DATE, BIZ_NO) VALUES (2, 'HOSP5000', '병원 5,000원 할인', 'FIXED', 5000, NULL, 30000, 'ACTIVE', 250000, 5000, 50, 1, TO_CHAR(SYSDATE - 30, 'YYYYMMDD'), TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), 2, 'APPROVED', TO_CHAR(SYSDATE - 29, 'YYYYMMDD'), TO_CHAR(SYSDATE - 30, 'YYYYMMDDHH24MISS'), 2);

INSERT INTO TB_COUPON (COUPON_ID, COUPON_CODE, COUPON_NAME, COUPON_TYPE, DISCOUNT_VALUE, MAX_DISCOUNT_AMT, MIN_ORDER_AMT, STATUS_CD, TOTAL_BUDGET, ISSUED_BUDGET, TOTAL_QTY, ISSUED_QTY, USE_START_DATE, USE_END_DATE, BIZ_MEMBER_NO, APPROVAL_STATUS, APPROVAL_DATE, REG_DATE, BIZ_NO) VALUES (3, 'STAY10000', '펫스테이 10,000원 할인', 'FIXED', 10000, NULL, 80000, 'ACTIVE', 300000, 10000, 30, 1, TO_CHAR(SYSDATE - 30, 'YYYYMMDD'), TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), 3, 'APPROVED', TO_CHAR(SYSDATE - 29, 'YYYYMMDD'), TO_CHAR(SYSDATE - 30, 'YYYYMMDDHH24MISS'), 3);

-- user01: 쇼핑쿠폰은 사용완료, 병원쿠폰은 미사용
INSERT INTO TB_MEMBER_COUPON (MEMBER_COUPON_ID, COUPON_ID, MEMBER_NO, EXPIRE_DATE, USE_END_DATE, REG_DATE, STATUS_CD) VALUES (1, 1, 1, TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), TO_CHAR(SYSDATE - 20, 'YYYYMMDDHH24MISS'), 'USED');

INSERT INTO TB_MEMBER_COUPON (MEMBER_COUPON_ID, COUPON_ID, MEMBER_NO, EXPIRE_DATE, USE_END_DATE, REG_DATE, STATUS_CD) VALUES (2, 2, 1, TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), TO_CHAR(SYSDATE - 15, 'YYYYMMDDHH24MISS'), 'UNUSED');

-- user02: 쇼핑쿠폰 미사용, 숙소쿠폰 사용완료
INSERT INTO TB_MEMBER_COUPON (MEMBER_COUPON_ID, COUPON_ID, MEMBER_NO, EXPIRE_DATE, USE_END_DATE, REG_DATE, STATUS_CD) VALUES (3, 1, 2, TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), TO_CHAR(SYSDATE - 12, 'YYYYMMDDHH24MISS'), 'UNUSED');

INSERT INTO TB_MEMBER_COUPON (MEMBER_COUPON_ID, COUPON_ID, MEMBER_NO, EXPIRE_DATE, USE_END_DATE, REG_DATE, STATUS_CD) VALUES (4, 3, 2, TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), TO_CHAR(SYSDATE + 180, 'YYYYMMDD'), TO_CHAR(SYSDATE - 10, 'YYYYMMDDHH24MISS'), 'USED');


-- ---------------------------------------------------------
-- 3-9. 쇼핑 주문 3건 + 주문상품 4건 + 결제/배송
-- ---------------------------------------------------------

-- 주문 1: 배송준비중 / user01 / 강아지 용품 / 쿠폰 사용
INSERT INTO TB_ORDER (ORDER_ID, ORDER_NO, MEMBER_NO, ORDER_STATUS, TOTAL_AMOUNT, DISCOUNT_AMOUNT, POINT_USED, PAY_AMOUNT, ORDER_DATE, RECV_NAME, RECV_PHONE, ZIP_CODE, ADDR1, ADDR2, DELIVERY_MEMO, DELIVERY_FEE, BIZ_NO, MEMBER_COUPON_ID, CONFIRM_YN) VALUES (1, 'ORD-DEMO-0001', 1, 'READY', 21900, 2190, 0, 22710, SYSDATE - 2, '김민준', '010-1111-1111', '34141', '대전광역시 유성구 대학로 10', '101호', '문 앞에 놓아주세요.', 3000, 1, 1, 'N');

INSERT INTO TB_ORDER_ITEM (ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, OPTION_ID, OPTION_COLOR, OPTION_SIZE, PRODUCT_NAME, QTY, UNIT_PRICE, TOTAL_PRICE) VALUES (1, 1, 3, 3, '기본', 'FREE', '암앤해머 컴플리트케어 효소치약', 1, 21900, 21900);

-- 주문 2: 배송중 / user02 / 고양이 간식 2개
INSERT INTO TB_ORDER (ORDER_ID, ORDER_NO, MEMBER_NO, ORDER_STATUS, TOTAL_AMOUNT, DISCOUNT_AMOUNT, POINT_USED, PAY_AMOUNT, ORDER_DATE, RECV_NAME, RECV_PHONE, ZIP_CODE, ADDR1, ADDR2, DELIVERY_MEMO, DELIVERY_FEE, BIZ_NO, CONFIRM_YN) VALUES (2, 'ORD-DEMO-0002', 2, 'SHIPPING', 15800, 0, 0, 18800, SYSDATE - 4, '이서연', '010-2222-2222', '31156', '충청남도 천안시 서북구 불당로 20', '202호', '배송 전 연락 부탁드립니다.', 3000, 1, 'N');

INSERT INTO TB_ORDER_ITEM (ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, OPTION_ID, OPTION_COLOR, OPTION_SIZE, PRODUCT_NAME, QTY, UNIT_PRICE, TOTAL_PRICE) VALUES (2, 2, 5, 5, '기본', '60g', '알로키친 산양유 초록홍합 30g', 2, 7900, 15800);

-- 주문 3: 배송완료 + 구매확정 / user01 / 상품 2개
INSERT INTO TB_ORDER (ORDER_ID, ORDER_NO, MEMBER_NO, ORDER_STATUS, TOTAL_AMOUNT, DISCOUNT_AMOUNT, POINT_USED, PAY_AMOUNT, ORDER_DATE, RECV_NAME, RECV_PHONE, ZIP_CODE, ADDR1, ADDR2, DELIVERY_MEMO, DELIVERY_FEE, BIZ_NO, CONFIRM_YN, CONFIRMED_AT) VALUES (3, 'ORD-DEMO-0003', 1, 'DONE', 37400, 0, 0, 37400, SYSDATE - 20, '김민준', '010-1111-1111', '34141', '대전광역시 유성구 대학로 10', '101호', NULL, 0, 1, 'Y', SYSDATE - 14);

INSERT INTO TB_ORDER_ITEM (ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, OPTION_ID, OPTION_COLOR, OPTION_SIZE, PRODUCT_NAME, QTY, UNIT_PRICE, TOTAL_PRICE, CONFIRMED_AT, CONFIRM_DUE_AT) VALUES (3, 3, 1, 1, '기본', '2kg', '네이처밸런스 어덜트 독 사료 2kg', 1, 28900, 28900, SYSDATE - 14, SYSDATE - 14);

INSERT INTO TB_ORDER_ITEM (ORDER_ITEM_ID, ORDER_ID, PRODUCT_ID, OPTION_ID, OPTION_COLOR, OPTION_SIZE, PRODUCT_NAME, QTY, UNIT_PRICE, TOTAL_PRICE, CONFIRMED_AT, CONFIRM_DUE_AT) VALUES (4, 3, 2, 2, '기본', '100g', '오리안심 큐브 트릿 100g', 1, 8500, 8500, SYSDATE - 14, SYSDATE - 14);

-- 주문 결제
INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (1, 1, NULL, 'ORDER', 'CARD', 22710, 'dummy_pay_order_1', 'ORD-DEMO-0001', 'DONE', SYSDATE - 2, 0);

INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (2, 2, NULL, 'ORDER', 'KAKAO', 18800, 'dummy_pay_order_2', 'ORD-DEMO-0002', 'DONE', SYSDATE - 4, 0);

INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (3, 3, NULL, 'ORDER', 'CARD', 37400, 'dummy_pay_order_3', 'ORD-DEMO-0003', 'DONE', SYSDATE - 20, 0);

-- 배송
INSERT INTO TB_ORDER_DELIVERY (DELIVERY_ID, ORDER_ID, BIZ_NO, COURIER_NAME, TRACKING_NO, DELIVERY_STATUS, REGISTERED_AT, DELIVERY_FEE, READY_AT, COURIER_CODE) VALUES (1, 1, 1, NULL, NULL, 'READY', NULL, 3000, SYSDATE - 1, NULL);

INSERT INTO TB_ORDER_DELIVERY (DELIVERY_ID, ORDER_ID, BIZ_NO, COURIER_NAME, TRACKING_NO, DELIVERY_STATUS, REGISTERED_AT, DELIVERY_FEE, READY_AT, SHIPPING_AT, COURIER_CODE) VALUES (2, 2, 1, 'CJ대한통운', '123456789012', 'SHIPPING', SYSDATE - 3, 3000, SYSDATE - 3, SYSDATE - 2, '04');

INSERT INTO TB_ORDER_DELIVERY (DELIVERY_ID, ORDER_ID, BIZ_NO, COURIER_NAME, TRACKING_NO, DELIVERY_STATUS, REGISTERED_AT, DELIVERY_FEE, READY_AT, SHIPPING_AT, DELIVERED_AT, COURIER_CODE) VALUES (3, 3, 1, 'CJ대한통운', '987654321098', 'DELIVERED', SYSDATE - 19, 0, SYSDATE - 19, SYSDATE - 18, SYSDATE - 16, '04');


-- ---------------------------------------------------------
-- 3-10. 병원 예약 3건
-- ---------------------------------------------------------

-- 진료완료
INSERT INTO TB_RESERVATION (RESV_ID, RESV_NO, RESV_TYPE, MEMBER_NO, PET_ID, TARGET_ID, SERVICE_NAME, RESV_DATE, RESV_TIME, TOTAL_AMOUNT, STATUS_CD, REG_DATE, TREAT_TYPE_ID, DURATION_MIN, END_TIME, DOCTOR_ID, SYMPTOMS, REQUEST_MEMO) VALUES (1, 'HOSP-DEMO-0001', 'HOSPITAL', 1, 1, '1', '일반진료', TRUNC(SYSDATE) - 10, '10:00', 30000, 'DONE', SYSDATE - 15, 1, 30, '10:30', 1, '귀를 자주 긁어요.', '처음 방문합니다.');

-- 예약확정
INSERT INTO TB_RESERVATION (RESV_ID, RESV_NO, RESV_TYPE, MEMBER_NO, PET_ID, TARGET_ID, SERVICE_NAME, RESV_DATE, RESV_TIME, TOTAL_AMOUNT, STATUS_CD, REG_DATE, TREAT_TYPE_ID, DURATION_MIN, END_TIME, DOCTOR_ID, SYMPTOMS, REQUEST_MEMO) VALUES (2, 'HOSP-DEMO-0002', 'HOSPITAL', 2, 2, '1', '예방접종', TRUNC(SYSDATE) + 3, '14:00', 40000, 'CONFIRMED', SYSDATE - 2, 2, 20, '14:20', 2, '정기 예방접종', '고양이가 낯을 많이 가립니다.');

-- 취소
INSERT INTO TB_RESERVATION (RESV_ID, RESV_NO, RESV_TYPE, MEMBER_NO, PET_ID, TARGET_ID, SERVICE_NAME, RESV_DATE, RESV_TIME, TOTAL_AMOUNT, STATUS_CD, REJECT_REASON, CANCEL_FEE_AMT, REFUND_AMT, CANCEL_AT, REG_DATE, TREAT_TYPE_ID, DURATION_MIN, END_TIME, DOCTOR_ID, SYMPTOMS) VALUES (3, 'HOSP-DEMO-0003', 'HOSPITAL', 1, 1, '1', '건강검진', TRUNC(SYSDATE) + 5, '11:00', 60000, 'CANCEL', '개인 일정으로 예약 취소', 0, 60000, SYSDATE - 1, SYSDATE - 5, 3, 60, '12:00', 1, '정기 건강검진');


-- ---------------------------------------------------------
-- 3-11. 숙소 예약 3건
-- ---------------------------------------------------------

-- 이용완료 + 쿠폰 사용
INSERT INTO TB_RESERVATION (RESV_ID, RESV_NO, RESV_TYPE, MEMBER_NO, PET_ID, TARGET_ID, ROOM_ID, SERVICE_NAME, CHECKIN_DATE, CHECKOUT_DATE, NIGHT_CNT, RESV_DATE, TOTAL_AMOUNT, STATUS_CD, REG_DATE, MEMBER_COUPON_ID, COUPON_DISCOUNT, POINT_USED, PET_CNT) VALUES (4, 'STAY-DEMO-0001', 'STAY', 2, 2, '1', 1, '포레스트 디럭스', TRUNC(SYSDATE) - 12, TRUNC(SYSDATE) - 11, 1, TRUNC(SYSDATE) - 12, 120000, 'DONE', SYSDATE - 20, 4, 10000, 0, 1);

-- 예약확정
INSERT INTO TB_RESERVATION (RESV_ID, RESV_NO, RESV_TYPE, MEMBER_NO, PET_ID, TARGET_ID, ROOM_ID, SERVICE_NAME, CHECKIN_DATE, CHECKOUT_DATE, NIGHT_CNT, RESV_DATE, TOTAL_AMOUNT, STATUS_CD, REG_DATE, COUPON_DISCOUNT, POINT_USED, PET_CNT, REQUEST_MEMO) VALUES (5, 'STAY-DEMO-0002', 'STAY', 1, 1, '1', 2, '포레스트 스위트', TRUNC(SYSDATE) + 14, TRUNC(SYSDATE) + 16, 2, TRUNC(SYSDATE) + 14, 340000, 'CONFIRMED', SYSDATE - 3, 0, 0, 1, '산책 후 체크인 예정입니다.');

-- 취소
INSERT INTO TB_RESERVATION (RESV_ID, RESV_NO, RESV_TYPE, MEMBER_NO, PET_ID, TARGET_ID, ROOM_ID, SERVICE_NAME, CHECKIN_DATE, CHECKOUT_DATE, NIGHT_CNT, RESV_DATE, TOTAL_AMOUNT, STATUS_CD, REJECT_REASON, CANCEL_FEE_AMT, REFUND_AMT, CANCEL_AT, REG_DATE, COUPON_DISCOUNT, POINT_USED, PET_CNT) VALUES (6, 'STAY-DEMO-0003', 'STAY', 2, 2, '1', 2, '포레스트 스위트', TRUNC(SYSDATE) + 20, TRUNC(SYSDATE) + 21, 1, TRUNC(SYSDATE) + 20, 170000, 'CANCEL', '여행 일정 변경', 0, 170000, SYSDATE - 1, SYSDATE - 6, 0, 0, 1);


-- ---------------------------------------------------------
-- 3-12. 예약 결제
-- ---------------------------------------------------------

-- 병원 3건
INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (4, NULL, 1, 'RESERVATION', 'CARD', 30000, 'dummy_pay_hosp_1', 'HOSP-DEMO-0001', 'DONE', SYSDATE - 15, 0);

INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (5, NULL, 2, 'RESERVATION', 'CARD', 40000, 'dummy_pay_hosp_2', 'HOSP-DEMO-0002', 'DONE', SYSDATE - 2, 0);

INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (6, NULL, 3, 'RESERVATION', 'CARD', 60000, 'dummy_pay_hosp_3', 'HOSP-DEMO-0003', 'REFUND', SYSDATE - 5, 60000);

-- 숙소 3건
INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (7, NULL, 4, 'RESERVATION', 'CARD', 110000, 'dummy_pay_stay_1', 'STAY-DEMO-0001', 'DONE', SYSDATE - 20, 0);

INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (8, NULL, 5, 'RESERVATION', 'CARD', 340000, 'dummy_pay_stay_2', 'STAY-DEMO-0002', 'DONE', SYSDATE - 3, 0);

INSERT INTO TB_PAYMENT (PAYMENT_ID, ORDER_ID, RESV_ID, PAY_TYPE, PAY_METHOD, PAY_AMOUNT, TOSS_PAYMENT_KEY, TOSS_ORDER_ID, PAY_STATUS, PAY_DATE, REFUND_AMT) VALUES (9, NULL, 6, 'RESERVATION', 'CARD', 170000, 'dummy_pay_stay_3', 'STAY-DEMO-0003', 'REFUND', SYSDATE - 6, 170000);


-- ---------------------------------------------------------
-- 3-13. 리뷰 4건
-- ---------------------------------------------------------

-- 상품 리뷰 2개: 배송완료/구매확정 주문상품과 연결
INSERT INTO TB_REVIEW (REVIEW_ID, REVIEW_TYPE, TARGET_ID, MEMBER_NO, ORDER_ITEM_ID, RESV_ID, RATING, CONTENT, BIZ_REPLY, REG_DATE) VALUES (1, 'PRODUCT', 1, 1, 3, NULL, 5.0, '알갱이 크기가 적당하고 몽이가 잘 먹어요. 포장도 깔끔했습니다.', '소중한 후기 감사합니다. 앞으로도 좋은 상품으로 준비하겠습니다.', SYSDATE - 12);

INSERT INTO TB_REVIEW (REVIEW_ID, REVIEW_TYPE, TARGET_ID, MEMBER_NO, ORDER_ITEM_ID, RESV_ID, RATING, CONTENT, BIZ_REPLY, REG_DATE) VALUES (2, 'PRODUCT', 2, 1, 4, NULL, 4.5, '훈련할 때 한 조각씩 주기 좋고 냄새도 강하지 않아 만족합니다.', NULL, SYSDATE - 11);

-- 병원 리뷰
INSERT INTO TB_REVIEW (REVIEW_ID, REVIEW_TYPE, TARGET_ID, MEMBER_NO, ORDER_ITEM_ID, RESV_ID, RATING, CONTENT, BIZ_REPLY, REG_DATE) VALUES (3, 'HOSPITAL', 1, 1, NULL, 1, 4.5, '설명을 차분하게 해주셔서 처음 방문했는데도 안심됐어요.', '방문해 주셔서 감사합니다. 몽이 건강관리도 함께 도와드리겠습니다.', SYSDATE - 9);

-- 숙소 리뷰
INSERT INTO TB_REVIEW (REVIEW_ID, REVIEW_TYPE, TARGET_ID, MEMBER_NO, ORDER_ITEM_ID, RESV_ID, RATING, CONTENT, BIZ_REPLY, REG_DATE) VALUES (4, 'STAY', 1, 2, NULL, 4, 5.0, '객실이 깔끔하고 반려동물 동선이 편해서 루나와 편하게 쉬었습니다.', '좋은 후기 감사합니다. 다음 방문도 편안하게 준비해두겠습니다.', SYSDATE - 10);


-- ---------------------------------------------------------
-- 3-14. 커뮤니티 게시글 6개
--      TOWN / LIFE / LOST / SHARE 골고루
-- ---------------------------------------------------------

INSERT INTO TB_POST (POST_ID, MEMBER_NO, BOARD_TYPE, TITLE, BODY, VIEW_COUNT, LIKE_CNT, REGION, STATUS_CD, REG_DATE, TAGS) VALUES (1, 1, 'TOWN', '요즘 저녁 산책은 몇 시쯤 나가세요?', '낮에는 아직 조금 더운 것 같아서 저녁 산책 시간을 늦춰볼까 고민 중이에요. 다른 분들은 보통 몇 시쯤 나가시는지 궁금합니다.', 32, 1, '대전', 'ACTIVE', SYSDATE - 3, '#강아지 #산책 #동네');

INSERT INTO TB_POST (POST_ID, MEMBER_NO, BOARD_TYPE, TITLE, BODY, VIEW_COUNT, LIKE_CNT, REGION, STATUS_CD, REG_DATE, TAGS) VALUES (2, 2, 'TOWN', '고양이 이동장 적응 팁 있을까요?', '루나가 이동장만 보면 숨으려고 해서 병원 갈 때마다 힘들어요. 평소에 적응시키는 방법이 있으면 알려주세요.', 28, 1, '천안', 'ACTIVE', SYSDATE - 4, '#고양이 #이동장');

INSERT INTO TB_POST (POST_ID, MEMBER_NO, BOARD_TYPE, TITLE, BODY, VIEW_COUNT, LIKE_CNT, REGION, STATUS_CD, REG_DATE, TAGS) VALUES (3, 1, 'LIFE', '반려견 양치 처음 시작할 때 이렇게 했어요', '처음부터 칫솔을 사용하기보다 손가락에 치약을 조금 묻혀 냄새에 익숙해지게 한 뒤 천천히 칫솔로 넘어갔습니다.', 45, 1, NULL, 'ACTIVE', SYSDATE - 6, '#강아지 #양치 #생활팁');

INSERT INTO TB_POST (POST_ID, MEMBER_NO, BOARD_TYPE, TITLE, BODY, VIEW_COUNT, LIKE_CNT, REGION, STATUS_CD, REG_DATE, TAGS) VALUES (4, 2, 'LIFE', '고양이 물 잘 마시게 하는 작은 방법', '물그릇을 밥그릇과 조금 떨어진 곳에 두고 집 안 여러 곳에 나눠두니 전보다 물을 자주 마시는 것 같아요.', 51, 1, NULL, 'ACTIVE', SYSDATE - 8, '#고양이 #음수량 #생활');

INSERT INTO TB_POST (POST_ID, MEMBER_NO, BOARD_TYPE, TITLE, BODY, VIEW_COUNT, LIKE_CNT, LOST_SPECIES, LOST_FEATURE, LOST_LAT, LOST_LNG, LOST_CONTACT, REGION, STATUS_CD, REG_DATE, TAGS) VALUES (5, 1, 'LOST', '갈색 푸들 목격하신 분 계실까요?', '오늘 오후 공원 근처에서 목줄 없이 이동하는 작은 갈색 푸들을 봤습니다. 보호자를 찾는 중인 것 같아 제보 남깁니다.', 76, 1, 'DOG', '작은 체구, 갈색 털, 빨간색 목줄', 36.3500000, 127.3840000, '010-1111-1111', '대전', 'ACTIVE', SYSDATE - 1, '#목격 #푸들 #대전');

INSERT INTO TB_POST (POST_ID, MEMBER_NO, BOARD_TYPE, TITLE, BODY, VIEW_COUNT, LIKE_CNT, REGION, STATUS_CD, REG_DATE, TAGS) VALUES (6, 2, 'SHARE', '사용하지 않는 고양이 장난감 나눔합니다', '루나가 관심을 보이지 않아 거의 사용하지 않은 낚싯대 장난감 두 개 나눔하려고 합니다. 가까운 분이면 직접 전달할게요.', 39, 1, '천안', 'ACTIVE', SYSDATE - 2, '#무료나눔 #고양이 #장난감');


-- ---------------------------------------------------------
-- 3-15. 댓글 8개
-- ---------------------------------------------------------
INSERT INTO TB_POST_COMMENT (COMMENT_ID, POST_ID, PARENT_ID, MEMBER_NO, BODY, IS_DELETED, REG_DATE) VALUES (1, 1, NULL, 2, '저는 해 지고 한 시간 정도 지난 뒤에 나가요. 바닥 열기도 많이 빠져서 괜찮더라고요.', 'N', SYSDATE - 3);

INSERT INTO TB_POST_COMMENT (COMMENT_ID, POST_ID, PARENT_ID, MEMBER_NO, BODY, IS_DELETED, REG_DATE) VALUES (2, 1, 1, 1, '좋은 팁 감사합니다. 오늘부터 조금 늦게 나가봐야겠어요.', 'N', SYSDATE - 3);

INSERT INTO TB_POST_COMMENT (COMMENT_ID, POST_ID, PARENT_ID, MEMBER_NO, BODY, IS_DELETED, REG_DATE) VALUES (3, 2, NULL, 1, '평소에 이동장 문을 열어두고 간식을 안에 넣어두니 조금씩 들어가더라고요.', 'N', SYSDATE - 4);

INSERT INTO TB_POST_COMMENT (COMMENT_ID, POST_ID, PARENT_ID, MEMBER_NO, BODY, IS_DELETED, REG_DATE) VALUES (4, 3, NULL, 2, '칫솔부터 들이밀어서 매번 실패했는데 이 방법으로 다시 해볼게요.', 'N', SYSDATE - 5);

INSERT INTO TB_POST_COMMENT (COMMENT_ID, POST_ID, PARENT_ID, MEMBER_NO, BODY, IS_DELETED, REG_DATE) VALUES (5, 4, NULL, 1, '저도 물그릇 위치를 바꾸니까 확실히 자주 마시는 느낌이었어요.', 'N', SYSDATE - 7);

INSERT INTO TB_POST_COMMENT (COMMENT_ID, POST_ID, PARENT_ID, MEMBER_NO, BODY, IS_DELETED, REG_DATE) VALUES (6, 4, 5, 2, '그렇죠! 물그릇 재질도 바꿔보려고 해요.', 'N', SYSDATE - 7);

INSERT INTO TB_POST_COMMENT (COMMENT_ID, POST_ID, PARENT_ID, MEMBER_NO, BODY, IS_DELETED, REG_DATE) VALUES (7, 5, NULL, 2, '근처 단체 채팅방에도 비슷한 강아지 제보가 있었어요. 확인해볼게요.', 'N', SYSDATE - 1);

INSERT INTO TB_POST_COMMENT (COMMENT_ID, POST_ID, PARENT_ID, MEMBER_NO, BODY, IS_DELETED, REG_DATE) VALUES (8, 6, NULL, 1, '아직 나눔 전이면 제가 받을 수 있을까요?', 'N', SYSDATE - 1);


-- ---------------------------------------------------------
-- 3-16. 좋아요 6건
-- ---------------------------------------------------------
INSERT INTO TB_POST_LIKE (LIKE_ID, POST_ID, MEMBER_NO, REG_DATE) VALUES (1, 1, 2, TO_CHAR(SYSDATE - 3, 'YYYY-MM-DD'));

INSERT INTO TB_POST_LIKE (LIKE_ID, POST_ID, MEMBER_NO, REG_DATE) VALUES (2, 2, 1, TO_CHAR(SYSDATE - 4, 'YYYY-MM-DD'));

INSERT INTO TB_POST_LIKE (LIKE_ID, POST_ID, MEMBER_NO, REG_DATE) VALUES (3, 3, 2, TO_CHAR(SYSDATE - 5, 'YYYY-MM-DD'));

INSERT INTO TB_POST_LIKE (LIKE_ID, POST_ID, MEMBER_NO, REG_DATE) VALUES (4, 4, 1, TO_CHAR(SYSDATE - 7, 'YYYY-MM-DD'));

INSERT INTO TB_POST_LIKE (LIKE_ID, POST_ID, MEMBER_NO, REG_DATE) VALUES (5, 5, 2, TO_CHAR(SYSDATE - 1, 'YYYY-MM-DD'));

INSERT INTO TB_POST_LIKE (LIKE_ID, POST_ID, MEMBER_NO, REG_DATE) VALUES (6, 6, 1, TO_CHAR(SYSDATE - 1, 'YYYY-MM-DD'));


-- ---------------------------------------------------------
-- 3-17. 신고
--      게시글 신고 1 + 댓글 신고 1 + 리뷰 신고 1
-- ---------------------------------------------------------
INSERT INTO TB_POST_REPORT (REPORT_ID, POST_ID, COMMENT_ID, TARGET_TYPE, REPORTER_NO, REASON, STATUS_CD, ADMIN_NO) VALUES (1, 3, NULL, 'POST', 2, '상업성 홍보 게시글인지 확인이 필요합니다.', 'PENDING', NULL);

INSERT INTO TB_POST_REPORT (REPORT_ID, POST_ID, COMMENT_ID, TARGET_TYPE, REPORTER_NO, REASON, STATUS_CD, ADMIN_NO) VALUES (2, 4, 6, 'COMMENT', 1, '신고 기능 테스트용 댓글 신고입니다.', 'PENDING', NULL);

INSERT INTO TB_REVIEW_REPORT (REPORT_ID, REPORTER_TYPE, REPORTER_NO, TARGET_MEMBER_NO, HOSPITAL_ID, REVIEW_ID, BIZ_NO, REASON, STATUS_CD, ADMIN_NO, REG_DATE) VALUES (1, 'BIZ', 2, 1, 1, 3, 2, '리뷰 내용 확인이 필요하여 신고합니다.', 'PENDING', NULL, SYSDATE - 8);


-- ---------------------------------------------------------
-- 3-18. 재능나눔 2건
-- ---------------------------------------------------------
INSERT INTO TB_TALENT (TALENT_ID, BIZ_NO, TITLE, TALENT_TYPE, CAPACITY, CURRENT_CNT, SCHEDULE, DURATION, LOCATION, CONTACT, BODY, STATUS_CD, ADMIN_NO, REG_DATE, APPROVE_DATE) VALUES (SEQ_TB_TALENT.NEXTVAL, 2, '반려동물 무료 건강상담', 'HOSPITAL', 5, 0, '매주 토요일 10:00~12:00', '30분', '대전 유성구', '042-222-2222', '반려동물의 기본 건강상태를 확인하고 간단한 건강상담을 진행합니다.', 'APPROVED', 1, SYSDATE - 10, SYSDATE - 9);

INSERT INTO TB_TALENT (TALENT_ID, BIZ_NO, TITLE, TALENT_TYPE, CAPACITY, CURRENT_CNT, SCHEDULE, DURATION, LOCATION, CONTACT, BODY, STATUS_CD, ADMIN_NO, REG_DATE, APPROVE_DATE) VALUES (SEQ_TB_TALENT.NEXTVAL, 3, '반려동물 돌봄 상담', 'ETC', 4, 0, '매월 둘째 주 일요일', '1시간', '강원 강릉시', '033-333-3333', '반려동물과 여행할 때 필요한 준비사항과 돌봄 방법을 안내합니다.', 'APPROVED', 1, SYSDATE - 8, SYSDATE - 7);

-- ---------------------------------------------------------
-- 3-19. 화면용 누적값 정리
-- ---------------------------------------------------------
UPDATE TB_MEMBER SET POST_COUNT = 3, COMMENT_COUNT = 4 WHERE MEMBER_NO IN (1, 2);

-- ---------------------------------------------------------
-- 고객센터 FAQ 3건 (TB_FAQ — MemberCsMapper 조회 테이블)
-- ---------------------------------------------------------
INSERT INTO TB_FAQ (FAQ_ID, CATEGORY_CD, QUESTION, ANSWER, VISIBLE_YN, SORT_ORDER, REG_DATE) VALUES (1, 'MEMBER', '비밀번호는 어디서 변경하나요?', '마이페이지 > 회원정보 수정에서 비밀번호를 변경할 수 있습니다.', 'Y', 1, SYSDATE - 20);

INSERT INTO TB_FAQ (FAQ_ID, CATEGORY_CD, QUESTION, ANSWER, VISIBLE_YN, SORT_ORDER, REG_DATE) VALUES (2, 'ORDER', '배송 상태는 어디서 확인하나요?', '주문 완료 후 마이페이지 > 주문내역에서 배송 상태를 확인할 수 있습니다.', 'Y', 2, SYSDATE - 18);

INSERT INTO TB_FAQ (FAQ_ID, CATEGORY_CD, QUESTION, ANSWER, VISIBLE_YN, SORT_ORDER, REG_DATE) VALUES (3, 'RESERVE', '병원이나 숙소 예약은 어떻게 하나요?', '병원 또는 숙소 상세 화면에서 원하는 날짜와 시간을 선택해 예약할 수 있습니다.', 'Y', 3, SYSDATE - 15);

-- ---------------------------------------------------------
-- 고객센터 공지사항 2건 (TB_NOTICE — MemberCsMapper 조회 테이블)
-- ---------------------------------------------------------
INSERT INTO TB_NOTICE (NOTICE_ID, NOTICE_TYPE_CD, TITLE, BODY, WRITER_NAME, PIN_YN, VISIBLE_YN, VIEW_COUNT, REG_DATE) VALUES (1, 'NOTICE', '펫린이 서비스 이용 안내', '펫린이를 이용해 주셔서 감사합니다. 쇼핑, 병원 예약, 숙소 예약 등 다양한 반려동물 서비스를 이용하실 수 있습니다.', '관리자', 'Y', 'Y', 0, SYSDATE - 10);

INSERT INTO TB_NOTICE (NOTICE_ID, NOTICE_TYPE_CD, TITLE, BODY, WRITER_NAME, PIN_YN, VISIBLE_YN, VIEW_COUNT, REG_DATE) VALUES (2, 'NOTICE', '고객센터 운영 안내', '고객센터는 평일 오전 9시부터 오후 6시까지 운영됩니다. 문의사항은 1:1 문의를 이용해 주세요.', '관리자', 'N', 'Y', 0, SYSDATE - 5);

/* =========================================================
   4. IDENTITY / 호환 설정
   ========================================================= */

ALTER TABLE TB_BUSINESS MODIFY (
    BIZ_NO GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH LIMIT VALUE)
);

ALTER TABLE TB_BUSINESS_AUTH MODIFY (
    AUTH_ID GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH LIMIT VALUE)
);

ALTER TABLE TB_BANNER MODIFY (
    BANNER_ID GENERATED BY DEFAULT ON NULL AS IDENTITY (START WITH LIMIT VALUE)
);

-- 옵션 없는 상품도 장바구니 담기가 가능하도록 기존 프로젝트 보정 유지
ALTER TABLE TB_CART_ITEM MODIFY (OPTION_ID NULL);

COMMIT;


/* =========================================================
   테스트 로그인 계정
   ---------------------------------------------------------
   관리자
   - admin / 1234

   일반회원
   - user01 / 1234
   - user02 / 1234

   사업자
   - store01    / 1234   (쇼핑몰)
   - hospital01 / 1234   (병원)
   - stay01     / 1234   (숙소)
   ========================================================= */
