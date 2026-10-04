# Petrini (펫린이) 🐾 
반려동물 **숙소 · 쇼핑 · 병원 · 커뮤니티 · 가족찾기 · 펫맵**을 하나의 웹에서 이용할 수 있는 **Spring Boot 기반 통합 플랫폼** 팀 프로젝트입니다.
이 중 **쇼핑몰 모듈 전반을 주도적으로 개발**하고, 결제 · 쿠폰 · 사업자센터 · 마이페이지 · 관리자 등
**서비스 전반의 기능 개발과 모듈 통합 · 오류 수정**에 참여했습니다.

| 항목 | 내용 |
|------|------|
| **교육&nbsp;과정** | [디지털컨버전스] AI활용 파이썬&자바 기반 Spring 웹 개발자 |
| **개발&nbsp;기간** | 2026.06.17 ~ 2026.08.19 |
| **팀&nbsp;규모** | 4명 |
| **본인&nbsp;담당** | 쇼핑몰 모듈 (상품 · 주문 · 결제 · 배송) |
| **참여&nbsp;범위** | 쿠폰 · 숙소/병원 사업자센터 · 마이페이지 · 관리자 · 가족찾기 등 기능 개발, 모듈 통합 · 오류 수정 |
| **GitHub** | https://github.com/jiyoon6227/Petrini |

---
## 목차
- [프로젝트 소개](#프로젝트-소개)
- [주요 기능](#주요-기능)
- [본인 담당 기능](#본인-담당-기능-곽지윤)
- [핵심 구현 및 문제 해결](#핵심-구현-및-문제-해결-본인-담당)
- [배치 스케줄러](#배치-스케줄러-본인-담당)
- [주문 · 배송 상태 흐름](#주문--배송-상태-흐름)
- [팀 구성 · 담당](#팀-구성--담당)
- [기술 스택](#기술-스택)
- [외부 연동 API](#외부-연동-api)
- [프로젝트 구조](#프로젝트-구조)
- [실행 방법](#실행-방법)

---
## 프로젝트 소개
용품 구매 · 병원 예약 · 숙소 예약 · 반려인 커뮤니티가 각각 다른 사이트에 흩어져 있는 불편을 해결하기 위해,
**하나의 계정으로 반려동물 관련 서비스를 모두 이용할 수 있는 통합 플랫폼**을 만들었습니다.

- **일반 회원(USER)** — 쇼핑 · 병원/숙소 예약 · 커뮤니티 · 가족찾기 · 마이페이지
- **사업자(BIZ)** — 쇼핑몰 / 병원 / 숙소 사업자센터 운영
- **관리자(ADMIN)** — 회원 · 사업자 · 콘텐츠 · 쿠폰 · 정산 관리

---
## 주요 기능
### 사용자 서비스

| 메뉴 | URL | 설명 |
|------|-----|------|
| 메인 | `/` | 인기 상품 · 커뮤니티 · 배너 |
| 숙소 | `/stay` | 펫호텔 검색 · 예약 · 결제 · 취소 · 환불 |
| 쇼핑 | `/store` | 상품 · 장바구니 · 주문 · 토스 결제 · 배송 조회 |
| 병원 | `/hospital` | 병원 검색 · 예약 · 진료 |
| 커뮤니티 | `/community` | 집사생활 · 무료나눔 · 수의사 상담 · 댓글 · 좋아요 · 신고 |
| 가족찾기 | `/give` | 유기동물 · 분실·보호 신고 · 재능나눔 |
| 펫맵 | `/petmap` | 반려동물 동반 여행지 (공공 API + 지도) |
| 검색 | `/search` | 통합 검색 |
| 마이페이지 | `/mypage` | 예약 · 주문 · 반려동물 · 건강수첩 · 포인트 · 쿠폰 · 알림 · 찜 |
| 회원 | `/login`, `/join` | 로그인 · 카카오 OAuth · 회원가입 · 아이디/비밀번호 찾기 |
| 고객센터 | `/member/cs` | FAQ · 공지 · 1:1 문의 |

### 사업자센터 (`/biz/*`)

| 구분 | 주요 기능 |
|------|-----------|
| **병원** | 예약·캘린더·스케줄·진료기록·리뷰·쿠폰·배너·재능나눔 |
| **숙소** | 객실·예약·리뷰·쿠폰·배너·환불 신청·정산 |
| **쇼핑** | 상품·주문·배송·Q&A·리뷰·환불·정산 |

### 관리자 (`/admin/*`)

| 구분 | 주요 기능 |
|------|-----------|
| **대시보드·통계** | 매출·회원·주문 차트, CSV 내보내기 |
| **회원** | 목록 · 상세 · 등급 · 포인트 · 정지 · 강제 탈퇴 |
| **커뮤니티** | 게시글 · 신고 · 숨김 · 삭제 · 복구 |
| **리뷰** | 사업자 삭제 요청 승인/반려 |
| **CMS** | FAQ · 공지사항 · 배너 |
| **쿠폰** | 발급 · 승인 · 소진 관리 |
| **사업자** | 입점 승인/반려 |
| **주문·상품** | 쇼핑 주문 · 상품 관리 |
| **숙소·예약** | 숙소 · 예약 관리 |
| **정산** | 숙소 · 쇼핑 정산 |
| **1:1&nbsp;문의** | 문의 · 환불 신청 처리 |

---
## 본인 담당 기능 (곽지윤)
> 쇼핑몰 모듈(사용자 쇼핑 → 결제 → 사업자 주문 · 배송 관리 → 구매확정)을 중심으로, 쿠폰 · 사업자센터 · 마이페이지 · 관리자 등 **서비스 전반의 기능 개발에 참여**했습니다.

- **담당 모듈 규모** — 화면(JSP) 27개, 소스 84개 파일(약 1.7만 줄) · Controller부터 Service, MyBatis SQL, JSP 화면까지 전 계층 구현
- 아래는 **주요 기능**이며, 이 외에도 팀 공통 기능 개발과 모듈 통합 · 오류 수정에 참여했습니다
- 프로젝트 종료 후에도 개인 레포에서 카카오 로그인 · 메인 화면 · 가족찾기 등의 오류를 수정하며 유지보수하고 있습니다

### 사용자 쇼핑 (`/store`)

<table>
  <thead>
    <tr>
      <th width="100">기능</th>
      <th>내용</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>상품목록</td>
      <td>카테고리 트리 · 검색어 · 정렬 · 가격대 · 브랜드 필터, 페이지네이션</td>
    </tr>
    <tr>
      <td>상품상세</td>
      <td>이미지 · 옵션 선택, 할인율 표시, 리뷰 목록 + 별점 분포 그래프 + 리뷰 사진, 상품 Q&A 등록 · 삭제</td>
    </tr>
    <tr>
      <td>장바구니</td>
      <td>동일 상품 · 옵션 수량 합산, 수량 변경, 선택 삭제, 헤더 장바구니 뱃지 실시간 갱신</td>
    </tr>
    <tr>
      <td>주문서</td>
      <td>바로구매 / 장바구니 주문, 배송지 목록 모달(등록 · 수정 · 삭제 · 기본 배송지), 입력값 검증, 사업자별 배송비 계산</td>
    </tr>
    <tr>
      <td>결제</td>
      <td>쿠폰 · 포인트 적용, 토스페이먼츠 결제 승인 · 완료 처리, 상품 가격 · 쿠폰 · 포인트 서버 재검증</td>
    </tr>
    <tr>
      <td>주문처리</td>
      <td>여러 사업자 상품을 사업자별 주문으로 분리 저장, 재고 차감 · 자동 품절, 사업자 알림</td>
    </tr>
  </tbody>
</table>

### 마이페이지 (`/mypage`)

<table>
  <thead>
    <tr>
      <th width="110">기능</th>
      <th>내용</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>주문내역</td>
      <td>상태별 주문 목록, 같은 결제로 나뉜 사업자별 주문을 하나의 상세 화면으로 표시</td>
    </tr>
    <tr>
      <td>주문처리</td>
      <td>주문취소 신청, 구매확정(포인트 적립), 실시간 배송조회</td>
    </tr>
    <tr>
      <td>리뷰</td>
      <td>배송완료 상품 리뷰 작성(사진 최대 5장), 글자 수 기준 포인트 지급</td>
    </tr>
    <tr>
      <td>포인트</td>
      <td>보유 잔액 · 이번 달 적립 · 적립 / 사용 내역</td>
    </tr>
    <tr>
      <td>배송지</td>
      <td>배송지 목록 · 등록 · 수정 · 삭제, 기본 배송지 지정</td>
    </tr>
  </tbody>
</table>

### 쿠폰 (쇼핑 · 병원 · 숙소 공통)

| 기능 | 내용 |
|------|------|
| 쿠폰존 | 발급 가능 쿠폰 목록, 업종별 필터(전체 · 병원 · 숙소 · 쇼핑몰), 기간 만료 쿠폰 제외 |
| 쿠폰&nbsp;적용&nbsp;상품 | 쿠폰을 발급한 쇼핑몰의 적용 상품 목록 · 검색 · 정렬 |
| 쿠폰&nbsp;발급 | 조기 마감 · 수량 소진 · 기간 종료 쿠폰 발급 차단, **동시 요청 시 초과 발급 방지** |
| 쿠폰&nbsp;적용 | 발급 사업자 상품에만 적용, 최소 주문금액 검증, 정률 쿠폰 최대 할인금액 적용 |
| 사업자&nbsp;쿠폰&nbsp;관리 | 쿠폰 등록 · 수정 · 삭제(승인 전), 승인된 쿠폰 조기 마감 (쇼핑 · 병원 · 숙소 공용) |

### 사업자 쇼핑센터 (`/biz/store`)

| 기능 | 내용 |
|------|------|
| 대시보드 | 오늘 신규 주문, 상태별 주문 수, 사이드바 미처리 주문 뱃지 |
| 상품&nbsp;관리 | 상품 등록 · 수정, 옵션별 재고, 재고 0이면 자동 품절 · 재입고 시 자동 해제, 이미지 교체 |
| 주문&nbsp;관리 | 상태 탭별 주문 목록 · 상세(결제금액 세부 내역), 취소신청 승인(토스 취소 + 재고 · 포인트 · 쿠폰 복구) / 반려 |
| 배송&nbsp;관리 | 송장 등록 · 일괄 등록, 배송 지연(3일 이상) 표시, 스마트택배 배송조회 연동, 배송 단계별 시각 기록 |
| 리뷰&nbsp;관리 | 리뷰 답글, 리뷰 삭제 요청(관리자 승인), 유저 신고 건수 · 신고자 표시 |
| Q&A·정보 | Q&A 답변(미답변 우선 정렬), 사업자 정보 · 사업자등록증 수정 |

### 다른 모듈 지원

<table>
  <thead>
    <tr>
      <th width="140">모듈</th>
      <th>내용</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>숙소 예약 결제</td>
      <td>숙소 결제 화면에 쿠폰 적용 추가 (서버 재검증 · 사용 확정 처리, 완료 화면 포인트 사용 내역 표시)</td>
    </tr>
    <tr>
      <td>사업자 대시보드</td>
      <td>대시보드 UI 구성, 진료완료 · 취소/노쇼 건수 통계, 일간 / 월간 차트 전환</td>
    </tr>
    <tr>
      <td>관리자</td>
      <td>쇼핑 리뷰 삭제 요청 승인 / 반려 (신고 · 삭제요청 참조를 먼저 해제해 FK 오류 방지), 쿠폰 승인 대기 건수 뱃지</td>
    </tr>
    <tr>
      <td>가족찾기</td>
      <td>재능나눔 탭 건수 표시, 재능나눔 화면에서 분실 · 보호 건수가 0으로 표시되던 버그 수정</td>
    </tr>
  </tbody>
</table>

### 알림
- 사업자 알림: 신규 주문 · 주문취소 신청 · 상품 품절 (인앱 알림함)
- 상품 품절 시 사업자에게 이메일 발송 (Gmail SMTP)

---
## 핵심 구현 및 문제 해결 (본인 담당)

### 1. 쿠폰 동시 발급 시 초과 발급
**문제**
수량이 정해진 쿠폰에 발급 요청이 동시에 몰리면, 여러 요청이 같은 잔여 수량을 보고 함께 통과해 총 수량보다 많이 발급될 수 있었습니다.

**원인**
"잔여 수량 조회 → 발급 수량 증가"가 두 단계로 나뉘어 있었습니다.

**해결**
- 잔여 수량 조건을 WHERE절에 넣은 **조건부 UPDATE 한 문장**으로 확인과 증가를 동시에 처리
- 0건 갱신이면 그 사이 다른 요청이 소진한 것으로 보고 예외를 던져, 앞서 INSERT한 회원 쿠폰까지 **트랜잭션 롤백**

```sql
UPDATE TB_COUPON
   SET ISSUED_QTY = NVL(ISSUED_QTY, 0) + 1
 WHERE COUPON_ID = #{couponId}
   AND STATUS_CD = 'ACTIVE'
   AND NVL(ISSUED_QTY, 0) < TOTAL_QTY   -- 확인과 증가를 한 문장에서
```

**결과**
10장 한정 쿠폰에 100명 동시 요청 → **10건만 발급, 90건 거절**

### 2. 여러 사업자 상품이 섞인 장바구니 결제
**문제**
여러 사업자 상품을 한 번에 결제하면 주문이 1건으로 저장되어, 사업자별 주문 관리 · 배송비 · 정산을 나눌 수 없었습니다.

**해결**
- 결제 완료 시 상품을 **사업자(BIZ_NO)별로 그룹핑해 주문을 각각 생성**
- 배송비는 사업자마다 5만원 기준으로 따로 계산, 쿠폰은 **발급한 사업자의 주문에만** 적용
- 포인트는 **상품금액 비율로 배분**하고, 반올림 오차는 마지막 주문이 흡수 (예: 1,000P를 3곳에 나누면 333 · 333 · 334)
- 전체 처리를 `@Transactional`로 묶어 중간 실패 시 전부 롤백

### 3. 결제 승인 · 취소와 DB 정합성
**설계 원칙**
결제는 외부 API(토스)와 DB가 함께 바뀌기 때문에, **외부 API가 성공한 경우에만 DB를 변경**하는 순서로 통일했습니다.
- 결제: 토스 승인(confirm) 성공 → 주문 · 결제내역 저장 (승인 실패 시 주문을 저장하지 않음)
- 취소: 토스 취소 성공 → 결제 상태 · 재고 · 포인트 · 쿠폰 복구

**문제**
취소 승인 시 DB 복구 로직을 같은 클래스 안에서 `@Transactional` 메서드로 호출하면, 프록시를 거치지 않아 **트랜잭션이 적용되지 않는 문제(self-invocation)** 가 있었습니다.

**해결**
- DB 복구 로직을 별도 빈(`OrderCancelTxService`)으로 분리해 트랜잭션이 확실히 적용되도록 구성 (복구 중 하나라도 실패하면 전부 롤백)
- 재고 복구 후 재고가 다시 생긴 상품은 품절 상태 자동 해제

### 4. 상품 옵션 수정 시 FK 위반(ORA-02292)
**문제**
상품 수정 시 옵션을 "전체 삭제 후 재등록"하는 방식이었는데, 이미 주문된 옵션은 `TB_ORDER_ITEM`이 참조하고 있어 삭제 단계에서 FK 위반이 발생했습니다.

**해결**
- `OPTION_ID` 기준 **upsert** 방식으로 변경 (기존 옵션은 UPDATE, 새 옵션은 INSERT)
- 화면에서 빠진 옵션은 **주문 이력이 없으면 삭제, 있으면 재고 0으로 처리**해 주문 이력을 보존

### 5. 택배 API 호출 한도(월 100건) 대응
**문제**
스마트택배 API 무료 플랜이 월 100건 제한이라, 주기적으로 배송 상태를 조회하는 스케줄러를 켜두면 할당량이 금방 소진됐습니다.

**해결**
- **사용자 · 사업자가 배송조회를 할 때 그 결과로 주문 상태를 동기화**하는 방식을 기본으로 사용
  - 배송 단계 2~5(이동 중) → `SHIPPING`, 6(배송완료) → `DONE`
- 주기 동기화 스케줄러도 구현해 두고, 호출 한도 때문에 기본 비활성 (운영 환경에서 주기만 늘려 활성화 가능)
- 상태 변경 UPDATE에 **현재 상태 조건을 포함**해, 이미 진행된 주문이 뒤로 돌아가거나 완료 시각이 중복 기록되지 않도록 처리
- 송장번호를 입력하고 주문 상태를 바꾸지 않은 채 저장해도, 주문 상태와 배송 상태가 어긋나지 않도록 자동으로 `SHIPPING` 보정

---
## 배치 스케줄러 (본인 담당)

| 스케줄러 | 실행 | 내용 |
|----------|------|------|
| `AutoConfirmPurchaseScheduler` | 매일 03:00 | 배송완료 후 7일이 지난 미확정 주문을 자동 구매확정하고 포인트 적립. 한 건이 실패해도 나머지는 계속 처리 |
| `DeliveryAutoSyncScheduler` | 기본 비활성 | 송장이 등록된 미완료 주문의 배송 상태를 택배 API로 일괄 동기화. 구현 완료, 무료 플랜 호출 한도(월 100건)로 기본 비활성 |

---
## 주문 · 배송 상태 흐름

```
결제완료(PAID) → 배송준비(READY) → 배송중(SHIPPING) → 배송완료(DONE) → 구매확정
                                    ↑ 송장 입력 /           ↑ 배송조회 결과
                                      배송조회 결과로 자동      또는 사업자 처리
  └─ 취소신청 → 사업자 승인(토스 취소 + 재고·포인트·쿠폰 복구) / 반려
```

- 배송 단계별 시각(`READY_AT` · `SHIPPING_AT` · `DELIVERED_AT`)을 기록해 배송 타임라인으로 표시

---
## 팀 구성 · 담당
> 팀원별 주요 담당 기능 위주로 정리했습니다.
>
> 결제·알림·파일 저장 등 공통 기능은 여러 명이 함께 작업했습니다.

| 이름 | 담당 영역 | 주요 기능 |
|------|-----------|-----------|
| **곽지윤** | 쇼핑 · 주문 · 결제 · 배송 · 쿠폰 | 쇼핑몰(목록·상세·장바구니·주문·결제), 사업자 쇼핑(상품·주문·배송·Q&A·환불), 리뷰 관리(답글·삭제 요청·신고 확인·쇼핑 리뷰 삭제 승인), 마이페이지 주문·리뷰·구매확정·포인트·배송지, 쿠폰존·쿠폰 발급·적용·조기 마감(전 업종), 숙소 결제 쿠폰 적용, 병원 사업자 대시보드 통계, 스마트택배 연동, 자동 구매확정 스케줄러 |
| **박유정** | 관리자 · 커뮤니티 · 가족찾기 · 운영 | 관리자 대시보드·통계·CSV, 회원 관리, 커뮤니티(게시글·댓글·좋아요·신고), 커뮤니티 관리자 검수, 병원·숙소 리뷰 삭제 승인, FAQ·공지 CMS, 배너 만료·운영, 쿠폰(관리자), 1:1 문의, 유기동물(공공 API), 분실·보호 신고, 재능나눔, 정지 회원 접근 제어 |
| **장우철** | 병원 · 숙소 · 정산 · 결제 | 병원 예약(홀드·슬롯·스케줄·진료기록), 숙소 취소·환불 정책, 토스 결제·빌링, 금결원 계좌 실명 조회, GCS·로컬 파일 업로드, 사업자 입점 승인, 정산(숙소·쇼핑), 관리자 예약·정산·숙소 |
| **하예주** | 숙소 예약·결제 · 회원 · 보안 | 숙소 예약·결제(토스·포인트·빌링·쿠폰), 미결제 자동 취소·숙박 완료 스케줄러, 쿠폰 만료 스케줄러, 카카오 OAuth·로그인 잠금, 회원 탈퇴, 커뮤니티 수정·삭제·7일 purge, 사업자 숙소 쿠폰·배너·대시보드, CSRF 공통 처리 |

---
## 기술 스택

| 분류 | 기술 |
|------|------|
| Language | **Java 21** |
| Framework | **Spring Boot 3.5** |
| View | **JSP**, JSTL |
| Persistence | **MyBatis 3.0.4**, **Oracle** |
| Build | **Maven** (WAR) |
| Server | Embedded **Tomcat** |
| Security | BCrypt, Lucy XSS, Jasypt, CSRF |
| Cache | Spring Cache |
| Mail | Spring Mail (Google SMTP) |
| Cloud | Google Cloud Storage (선택) |
| Utils | Lombok, Jackson, org.json |
| Test | JUnit 5 |
| Frontend | CSS (`petcare.css`, `biz.css`, `admin.css`), JavaScript |

---
## 외부 연동 API

| API | 용도 |
|-----|------|
| **카카오&nbsp;OAuth** | 카카오 로그인 |
| **카카오맵&nbsp;/&nbsp;REST** | 지도 표시 · 주소 좌표 변환 |
| **다음&nbsp;우편번호** | 주소 검색 (회원가입 · 주문 · 사업자 신청 등) |
| **토스페이먼츠** | 결제 · 빌링(자동결제) · 환불 |
| **금결원&nbsp;오픈뱅킹** | 사업자 정산 계좌 실명 조회 |
| **Google&nbsp;Cloud&nbsp;Storage** | 이미지·파일 업로드 (선택) |
| **Google&nbsp;SMTP** | 이메일 발송 |
| **공공데이터** | 유기동물 · 반려동물 동반여행 |
| **스마트택배(Sweet&nbsp;Tracker)** | 택배 배송 조회 |

> API 키는 `application.properties`, DB 접속 정보는 `application-local` / `application-prod.properties`에 설정합니다. (**Git에 커밋하지 않음**)

---
## 프로젝트 구조
```
src/main/java/com/petcare/petcare/
├── admin/          # 관리자 백오피스
├── biz/            # 사업자센터 (hospital · stay · store ← 본인 담당)
├── community/      # 커뮤니티 (post · comment · reaction · report)
├── coupon/         # 쿠폰                       ← 본인 담당
├── give/           # 가족찾기 (animal · report · talent)
├── hospital/       # 병원 (사용자)
├── member/         # 로그인 · 회원가입 · 고객센터
├── mypage/         # 마이페이지 (order · address · point ← 본인 담당)
├── store/          # 쇼핑                       ← 본인 담당
├── stay/           # 숙소
├── settlement/     # 정산
├── petmap/         # 펫맵
├── main/           # 메인 · 배너 · 섹션
├── common/         # 설정 · 예외 · 외부 API · 인터셉터
└── file/           # 파일 업로드
src/main/webapp/WEB-INF/views/   # JSP 화면
src/main/resources/mybatis/mapper/   # MyBatis XML
```

---
## 실행 방법

### 요구 사항
- JDK 21
- Maven 3.x
- Oracle Database
- API 키 (토스 · 스마트택배 · 카카오 · 공공데이터 등, 기능별 선택)

### 1. 설정 파일
`src/main/resources/`의 아래 세 파일은 Git에 포함되지 않습니다. 아래 내용으로 직접 작성하세요.
값이 비어 있는 API 키는 해당 기능을 사용할 때만 입력하면 됩니다. (키 자체는 지우지 마세요. 비어 있어도 서버는 기동됩니다.)

**application.properties**
```properties
spring.profiles.active=local
spring.application.name=petcare

# 인코딩
spring.servlet.encoding.charset=UTF-8
spring.servlet.encoding.enabled=true
spring.servlet.encoding.force=true

# JSP
spring.mvc.view.prefix=/WEB-INF/views/
spring.mvc.view.suffix=.jsp

# 파일 업로드 (로컬)
file.upload-dir=C:/upload/
spring.servlet.multipart.max-file-size=50MB
spring.servlet.multipart.max-request-size=50MB

# MyBatis
mybatis.mapper-locations=classpath:mybatis/mapper/**/*.xml
mybatis.configuration.map-underscore-to-camel-case=true

# API 키
kakao.rest-api-key=
kakao.client-secret=
kakao.js-api-key=
kakao.redirect-uri=
public.service-api-key=
smarttracker.api-key=
toss.client-key=
toss.secret-key=
toss.billing.client-key=
toss.billing.secret-key=

# 메일 (Gmail SMTP)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=
spring.mail.password=
spring.mail.properties.mail.smtp.auth=true
spring.mail.properties.mail.smtp.starttls.enable=true

# 금융결제원 계좌 실명조회 (모의 모드)
kftc.openbanking.mock=true
kftc.openbanking.base-url=https://testapi.openbanking.or.kr
kftc.openbanking.client-id=
kftc.openbanking.client-secret=

# Google Cloud Storage (로컬 개발 시 false)
gcs.enabled=false
gcs.bucket-name=
gcs.credentials-path=
```

**application-local.properties** — 로컬 개발용 DB
```properties
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/서비스명
spring.datasource.username=
spring.datasource.password=
```

**application-prod.properties** — 서버 배포용 DB
```properties
spring.datasource.driver-class-name=oracle.jdbc.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@//운영DB호스트:1521/서비스명
spring.datasource.username=
spring.datasource.password=
```

> 로컬 실행은 `spring.profiles.active=local`, 서버 배포 시에는 `spring.profiles.active=prod`로 변경합니다.

### 2. DB 초기화
`src/main/resources/sql/petrini.sql`을 Oracle에서 실행합니다.
(테이블 · 시퀀스 생성 + 데모 데이터 입력. **기존 테이블과 데이터는 삭제됩니다.**)

| 구분 | ID | PW |
|------|----|----|
| 관리자 | `admin` | `1234` |
| 일반회원 | `user01`, `user02` | `1234` |
| 사업자(쇼핑) | `store01` | `1234` |
| 사업자(병원) | `hospital01` | `1234` |
| 사업자(숙소) | `stay01` | `1234` |

> 테스트 계정은 시연용이며 실제 개인정보를 사용하지 않습니다.
>
> 쇼핑 모듈은 `store01`(사업자)과 `user01` · `user02`(구매자)로 확인할 수 있습니다. 데모 주문이 배송준비 · 배송중 · 구매확정 상태로 1건씩 들어 있습니다.

### 3. 빌드 & 실행
```bash
git clone https://github.com/jiyoon6227/Petrini.git
cd Petrini
mvn clean package
mvn spring-boot:run
```

### 4. 접속
- 사용자: `http://localhost:8080`
- 쇼핑 사업자센터: `/biz/store` (store01 로그인)
- 관리자: `/admin/login`

---
## License
교육용 팀 프로젝트