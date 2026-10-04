package com.petcare.petcare;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;

import com.petcare.petcare.coupon.service.CouponService;

// 지윤 26.09.27 추가: 쿠폰 동시 발급 테스트 (10장 쿠폰에 100명 동시 요청)
// 지윤 26.10.05 수정: 출력만 하던 것 -> assert로 검증 + 테스트 데이터 준비/정리 추가
//   - 테스트 전: 수량 10장 쿠폰(99번) + 테스트 회원 100명(9001~9100) 생성
//   - 검증: 성공 10건 / 실패 90건, DB 실제 발급 행수 10건, ISSUED_QTY 10, 상태 EXHAUSTED
//   - 테스트 후: 생성한 데이터 전부 삭제 (데모 데이터에 영향 없음)
@SpringBootTest
class CouponConcurrencyTest {

    private static final long COUPON_ID = 99L;
    private static final int TOTAL_QTY = 10;
    private static final int USERS = 100;
    private static final long MEMBER_START = 9001L;
    private static final long MEMBER_END = MEMBER_START + USERS - 1;

    @Autowired
    private CouponService couponService;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void setUp() {
        // 이전 실행에서 남은 데이터가 있으면 먼저 정리
        cleanUp();

        // 1) 수량 10장짜리 쿠폰 생성 (승인완료 + 게시중 + 정액 1,000원 + 기간 넉넉하게)
        jdbcTemplate.update(
            "INSERT INTO TB_COUPON (COUPON_ID, COUPON_CODE, COUPON_NAME, COUPON_TYPE, DISCOUNT_VALUE, "
          + "MIN_ORDER_AMT, STATUS_CD, TOTAL_BUDGET, ISSUED_BUDGET, TOTAL_QTY, ISSUED_QTY, "
          + "USE_START_DATE, USE_END_DATE, APPROVAL_STATUS, REG_DATE) "
          + "VALUES (?, 'TEST-CONCURRENCY-99', '동시성 테스트 쿠폰', 'FIXED', 1000, "
          + "0, 'ACTIVE', NULL, 0, ?, 0, "
          + "TO_CHAR(SYSDATE - 1, 'YYYYMMDD'), TO_CHAR(SYSDATE + 30, 'YYYYMMDD'), 'APPROVED', "
          + "TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS'))",
            COUPON_ID, TOTAL_QTY);

        // 2) 테스트 회원 100명 생성 (TB_MEMBER_COUPON.MEMBER_NO FK 때문에 실제 회원이 있어야 함)
        for (long memberNo = MEMBER_START; memberNo <= MEMBER_END; memberNo++) {
            jdbcTemplate.update(
                "INSERT INTO TB_MEMBER (MEMBER_NO, MEMBER_ID, MEMBER_NAME, NICKNAME, EMAIL, STATUS_CD, JOIN_DATE) "
              + "VALUES (?, ?, '테스트회원', ?, ?, 'NORMAL', SYSDATE)",
                memberNo, "conc" + memberNo, "conc" + memberNo, "conc" + memberNo + "@test.demo");
        }
    }

    @AfterEach
    void tearDown() {
        cleanUp();
    }

    // 자식(TB_MEMBER_COUPON) -> 부모(TB_COUPON, TB_MEMBER) 순서로 삭제
    private void cleanUp() {
        jdbcTemplate.update("DELETE FROM TB_MEMBER_COUPON WHERE COUPON_ID = ?", COUPON_ID);
        jdbcTemplate.update("DELETE FROM TB_COUPON WHERE COUPON_ID = ?", COUPON_ID);
        jdbcTemplate.update("DELETE FROM TB_MEMBER WHERE MEMBER_NO BETWEEN ? AND ?", MEMBER_START, MEMBER_END);
    }

    @Test
    void 쿠폰_동시_발급_테스트() throws Exception {
        ExecutorService pool = Executors.newFixedThreadPool(USERS);
        CountDownLatch ready = new CountDownLatch(USERS);   // 100개 스레드 준비 대기
        CountDownLatch start = new CountDownLatch(1);       // 동시 출발 신호
        CountDownLatch done  = new CountDownLatch(USERS);   // 100개 요청 처리 완료 대기

        AtomicInteger success = new AtomicInteger();
        AtomicInteger fail = new AtomicInteger();

        for (long memberNo = MEMBER_START; memberNo <= MEMBER_END; memberNo++) {
            final long targetMemberNo = memberNo;
            pool.submit(() -> {
                ready.countDown();
                try {
                    start.await();
                    couponService.claimCoupon(targetMemberNo, COUPON_ID);
                    success.incrementAndGet();
                } catch (Exception e) {
                    fail.incrementAndGet();
                } finally {
                    done.countDown();
                }
            });
        }

        ready.await();
        start.countDown();

        // 무한 대기 방지: 60초 안에 100건 처리가 끝나야 함
        assertTrue(done.await(60, TimeUnit.SECONDS), "60초 안에 모든 요청이 끝나지 않았습니다.");
        pool.shutdown();

        // 1) 요청 결과 검증: 수량만큼만 성공, 나머지는 전부 실패
        assertEquals(TOTAL_QTY, success.get(), "성공 건수는 쿠폰 수량과 같아야 합니다.");
        assertEquals(USERS - TOTAL_QTY, fail.get(), "나머지 요청은 모두 거절되어야 합니다.");

        // 2) DB 실제 발급 행수 검증: 초과 발급이 없어야 함
        Integer issuedRows = jdbcTemplate.queryForObject(
            "SELECT COUNT(*) FROM TB_MEMBER_COUPON WHERE COUPON_ID = ?", Integer.class, COUPON_ID);
        assertEquals(TOTAL_QTY, issuedRows, "TB_MEMBER_COUPON 발급 행수가 쿠폰 수량과 같아야 합니다.");

        // 3) 쿠폰 마스터 검증: 발급수량 10, 상태 EXHAUSTED
        Integer issuedQty = jdbcTemplate.queryForObject(
            "SELECT ISSUED_QTY FROM TB_COUPON WHERE COUPON_ID = ?", Integer.class, COUPON_ID);
        assertEquals(TOTAL_QTY, issuedQty, "TB_COUPON.ISSUED_QTY가 쿠폰 수량과 같아야 합니다.");

        String statusCd = jdbcTemplate.queryForObject(
            "SELECT STATUS_CD FROM TB_COUPON WHERE COUPON_ID = ?", String.class, COUPON_ID);
        assertEquals("EXHAUSTED", statusCd, "수량 소진 후 쿠폰 상태는 EXHAUSTED여야 합니다.");
    }
}