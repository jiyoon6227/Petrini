# PetCare (펫린이)
반려동물 **숙소 · 쇼핑 · 병원 · 커뮤니티 · 가족찾기 · 펫맵**을 하나의 웹에서 이용할 수 있는 **Spring Boot 기반 통합 플랫폼** 팀 프로젝트입니다.
| 항목 | 내용 |
|------|------|
| **교육 과정** | [디지털컨버전스] AI활용 파이썬&자바 기반 Spring 웹 개발자 |
| **개발 기간** | 2026.06.17 ~ 2026.08.19  |
| **팀 규모** | 4명 |
---
## 목차
- [프로젝트 소개](#프로젝트-소개)
- [주요 기능](#주요-기능)
- [역할 구조](#역할-구조)
- [팀원 / 담당](#팀원--담당)
- [기술 스택](#기술-스택)
- [외부 연동 API](#외부-연동-api)
- [프로젝트 구조](#프로젝트-구조)
- [실행 방법](#실행-방법)
- [배치 스케줄러](#배치-스케줄러)
- [개발 규칙](#개발-규칙)
- [미구현·플레이스홀더](#미구현플레이스홀더)
---
## 프로젝트 소개
**PetCare(펫린이)**는 반려인이 필요한 서비스를 **한곳에서** 이용할 수 있도록 기획한 팀 협업 웹 프로젝트입니다.
- **일반 회원(USER)** — 숙소·쇼핑·병원 예약, 커뮤니티, 분실·보호 신고, 마이페이지
- **사업자(BIZ)** — 병원 / 숙소 / 쇼핑 사업자센터 운영
- **관리자(ADMIN)** — 회원·콘텐츠·쿠폰·배너·통계·정산 관리
회원가입부터 **주문 · 예약 · 결제 · 환불 · 정산 · 운영 관리**까지 End-to-End 흐름을 구현했습니다.
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
| 산책 | `/walk` | 산책 코스 *(UI 플레이스홀더)* |
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
| **1:1 문의** | 문의 · 환불 신청 처리 |
---
## 역할 구조
```
USER  ──→  서비스 이용 (예약·주문·커뮤니티·마이페이지)
BIZ   ──→  사업자센터 (/biz/hospital · /biz/stay · /biz/store)
ADMIN ──→  관리자 백오피스 (/admin)
```
---
## 팀원 / 담당
> 코드 주석·협업 이력 기준으로 정리했습니다.  
> 결제·알림·파일 저장 등 **공통 기능은 여러 명이 함께** 작업했습니다.
| 이름 | 담당 영역 | 주요 기능 |
|------|-----------|-----------|
| **박유정** | 관리자 · 커뮤니티 · 가족찾기 · CMS · 운영 | 관리자 대시보드·통계·CSV, 회원 관리(정지·등급·포인트), 커뮤니티(게시글·댓글·좋아요·신고), 커뮤니티 관리자 검수, 리뷰 삭제 승인, FAQ·공지 CMS, 배너 만료·운영, 쿠폰(관리자), 1:1 문의, 유기동물(공공 API), 분실·보호 신고, 재능나눔, 정지 회원 접근 제어 |
| **장우철** | 병원 · 숙소 · 정산 · 결제 · 마이페이지 · 인프라 | 병원 예약(홀드·슬롯·스케줄·진료기록), 숙소 취소·환불 정책, 토스 결제·빌링, 금결원 계좌 실명 조회, GCS·로컬 파일 업로드, 사업자 입점 승인, 정산(숙소·쇼핑), 마이페이지(예약·반려동물·건강수첩·알림·찜), 메인 홈·섹션, 검색, 관리자 예약·정산·숙소 |
| **곽지윤** | 쇼핑 · 주문 · 쿠폰 · 배송 | 쇼핑몰(목록·상세·장바구니·주문·결제), 사업자 쇼핑(상품·주문·배송·Q&A·리뷰·환불), 마이페이지 주문·리뷰·구매확정·환불, 배송지, 쿠폰 발급·적용·조기 마감, 스마트택배 연동, 자동 구매확정 스케줄러 |
| **하예주** | 숙소 예약·결제 · 회원 · 보안 | 숙소 예약·결제(토스·포인트·빌링·쿠폰), 미결제 자동 취소·숙박 완료 스케줄러, 카카오 OAuth·로그인 잠금, 회원 탈퇴·7일 후 개인정보 삭제, 커뮤니티 수정·삭제·7일 purge, 쿠폰 만료 스케줄러, 사업자 숙소 쿠폰·배너·대시보드, CSRF 공통 처리 |
### 모듈별 담당 요약
| 모듈 | 주 담당 | 협업 |
|------|---------|------|
| `admin/` | 박유정 | 장우철(정산·예약·주문), 하예주(쿠폰) |
| `community/` | 박유정 | 하예주(수정·삭제·purge), 장우철(파일·LIFE 규칙) |
| `give/` | 박유정 | 장우철(파일·지도) |
| `coupon/` | 곽지윤 | 박유정(검증·관리자), 하예주(만료), 장우철(조건) |
| `store/` · `biz/store/` | 곽지윤 | 장우철(빌링·포인트), 하예주(토스) |
| `hospital/` · `biz/hospital/` | 장우철 | 박유정(재능·리뷰), 곽지윤(대시보드), 하예주(대시보드) |
| `stay/` · `biz/stay/` | 하예주 · 장우철 | 곽지윤(쿠폰), 박유정(리뷰·환불 알림·배너) |
| `member/` · `mypage/` | 장우철 · 하예주 | 박유정(정지·CS), 곽지윤(주문·포인트) |
| `settlement/` | 장우철 | — |
| `common/external/` | 장우철 | 전원(각 API 연동) |
| `petmap/` | *(미표기)* | 공공 API + 카카오맵 |
| `walk/` | *(미표기)* | 스켈레톤 |
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
| Frontend | CSS (`petcare.css`, `biz.css`, `admin.css`), JavaScript |
---
## 외부 연동 API
| API | 용도 |
|-----|------|
| **카카오 OAuth** | 카카오 로그인 |
| **카카오맵 / REST** | 지도 표시 · 주소 좌표 변환 |
| **다음 우편번호** | 주소 검색 (회원가입 · 주문 · 사업자 신청 등) |
| **토스페이먼츠** | 결제 · 빌링(자동결제) · 환불 |
| **금결원 오픈뱅킹** | 사업자 정산 계좌 실명 조회 |
| **Google Cloud Storage** | 이미지·파일 업로드 (선택) |
| **Google SMTP** | 이메일 발송 |
| **공공데이터** | 유기동물 · 반려동물 동반여행 |
| **스마트택배(Sweet Tracker)** | 택배 배송 조회 |
> API 키·DB 접속 정보는 `application.properties`에 설정합니다. (**Git에 커밋하지 않음**)
---
## 프로젝트 구조
```
src/main/java/com/petcare/petcare/
├── admin/          # 관리자 백오피스
├── biz/            # 사업자센터 (hospital · stay · store)
├── community/      # 커뮤니티 (post · comment · reaction · report)
├── coupon/         # 쿠폰
├── give/           # 가족찾기 (animal · report · talent)
├── hospital/       # 병원 (사용자)
├── member/         # 로그인 · 회원가입 · 고객센터
├── mypage/         # 마이페이지
├── store/          # 쇼핑
├── stay/           # 숙소
├── settlement/     # 정산
├── petmap/         # 펫맵
├── walk/           # 산책 (플레이스홀더)
├── main/           # 메인 · 배너 · 섹션
├── common/         # 설정 · 예외 · 외부 API · 인터셉터
└── file/           # 파일 업로드
src/main/webapp/WEB-INF/views/   # JSP 화면
src/main/resources/mybatis/mapper/   # MyBatis XML
```
---
## 실행 방법
### 요구 사항
- **JDK 21**
- **Maven 3.x**
- **Oracle Database**
- API 키 (카카오 · 토스 · 공공데이터 등 — 기능별 선택)
### 1. 설정 파일
`src/main/resources/application.properties`는 **Git에 포함되지 않습니다.**  
팀 내부 공유 설정을 복사하거나, 아래 항목을 참고해 직접 작성하세요.
```properties
# DB
spring.datasource.url=jdbc:oracle:thin:@//host:1521/service
spring.datasource.username=
spring.datasource.password=
# 파일 업로드 (로컬)
file.upload-dir=C:/upload/
# GCS (로컬 개발 시 false)
gcs.enabled=false
# API 키 (필요한 기능만)
public.service-api-key=
kakao.rest-api-key=
kakao.js-api-key=
kakao.client-secret=
kakao.redirect-uri=
toss.client-key=
toss.secret-key=
toss.billing.secret-key=
smarttracker.api-key=
# 메일 (선택)
spring.mail.host=smtp.gmail.com
spring.mail.port=587
spring.mail.username=
spring.mail.password=
```
### 2. 빌드 & 실행
```bash
# 클론
git clone <repository-url>
cd petcare
# 빌드
mvn clean package
# 실행 (내장 Tomcat)
mvn spring-boot:run
# 또는 IDE에서 com.petcare.petcare.PetcareApplication 실행
```
### 3. 접속
- 기본: `http://localhost:8080`
- 관리자: `/admin/login`
---
## 배치 스케줄러
`@EnableScheduling`으로 아래 배치가 동작합니다.
| 스케줄러 | 설명 | 관련 |
|----------|------|------|
| `MemberSuspendScheduler` | 기간 정지 만료 해제 | 박유정 |
| `BannerExpiryScheduler` | 배너 노출 기간 만료 처리 | 박유정 |
| `StayReservationScheduler` | 숙박 완료(CHECKOUT→DONE), 미결제 PENDING 취소 | 하예주 |
| `CouponScheduler` | 쿠폰 만료 처리 | 하예주 |
| `CommunityPostPurgeScheduler` | 탈퇴 회원 게시글 7일 후 purge | 하예주 |
| `WithdrawPurgeScheduler` | 탈퇴 회원 개인정보 7일 후 삭제 | 하예주 |
| `AutoConfirmPurchaseScheduler` | 배송완료 7일 후 구매 자동 확정 | 곽지윤 |
| `DeliveryAutoSyncScheduler` | 택배 배송 상태 자동 동기화 | 곽지윤 |
| `SettlementScheduler` | 숙소·쇼핑 정산 배치 | 장우철 |
| `HospitalResvHoldCleanupScheduler` | 병원 예약 홀드 만료 정리 | 장우철 |
---
## 개발 규칙
### 코드 주석
팀에서 사용하는 주석 형식:
```java
/**
 * 역할: ...
 *
 * - 작성자 / YYYY-MM-DD — 설명
 *
 * [화면 흐름]
 * 1. ...
 */
```
### 레이어 규칙
```
Controller  →  URL·파라미터·JSP 반환
Service     →  비즈니스 로직
Mapper/XML  →  SQL
```
- SQL은 **Mapper XML**에만 작성 (`@Select` 등 어노테이션 SQL 지양)
- 비즈니스 로직은 **Service**에 작성 (Controller·Mapper에 직접 작성 X)
### Git
- `application.properties`, `.env`, `gcs-key.json`, `/sql/` — **커밋 금지** (`.gitignore` 참고)
- README·공용 코드 변경 시 **팀원과 PR 리뷰** 후 merge
---
## 미구현·플레이스홀더
| 영역 | 상태 |
|------|------|
| `/walk` | UI·컨트롤러 스켈레톤 |
| `/grooming`, `/studio` | 화면 목업 수준 |
| `/biz/grooming`, `/biz/studio`, `/biz/restaurant` | 사이드바·JSP stub |
---
## License
교육용 팀 프로젝트
