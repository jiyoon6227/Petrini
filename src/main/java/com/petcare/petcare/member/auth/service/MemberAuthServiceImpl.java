/**
 * 역할: MemberAuthService 구현체 (@Service)
 *
 * - 박유정 / 2026-07-22 — 정지 회원 로그인 허용·세션 status 세팅·탈퇴 이메일 재가입 차단
 *
 * 연결: MemberAuthMapper, PasswordEncoder
 */

package com.petcare.petcare.member.auth.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.petcare.petcare.file.service.FileService;
import com.petcare.petcare.file.vo.FileVO;
import com.petcare.petcare.member.auth.exception.MemberLoginBlockedException;
import com.petcare.petcare.member.auth.mapper.MemberAuthMapper;
import com.petcare.petcare.member.auth.vo.AdminAuthVO;
import com.petcare.petcare.member.auth.vo.EmailCheckResultVO;
import com.petcare.petcare.member.auth.vo.KakaoUserVO;
import com.petcare.petcare.member.auth.vo.MemberAuthBizVO;
import com.petcare.petcare.member.auth.vo.MemberAuthVO;
import com.petcare.petcare.member.auth.vo.MemberRegisterVO;
import com.petcare.petcare.member.vo.MemberVO;

@Service
public class MemberAuthServiceImpl implements MemberAuthService {

    private static final Logger log = LoggerFactory.getLogger(MemberAuthServiceImpl.class);

    private final MemberAuthMapper memberAuthMapper;
    private final PasswordEncoder passwordEncoder;
    private final FileService fileService;

    public MemberAuthServiceImpl(MemberAuthMapper memberAuthMapper,
                                 PasswordEncoder passwordEncoder,
                                 FileService fileService) {
        this.memberAuthMapper = memberAuthMapper;
        this.passwordEncoder = passwordEncoder;
        this.fileService = fileService;
    }

    // 2026/07/06 장우철 — login(로그인)

    // 2026/07/07 장우철 — 관리자 로그인 확장
    // 변경 이유:
    // - 관리자도 별도 /admin/login 이 아니라 유저 홈(/login)에서 동일하게 로그인.
    // - TB_MEMBER 에 없으면 TB_ADMIN 을 조회해서, 관리자면 세션 role=ADMIN 으로 반환.
    // - 관리자 여부는 "어느 테이블에서 조회됐는지"로 구분 (TB_ADMIN 유지, ADMIN_NO FK 보존).
    @Override
    public MemberVO login(String loginId, String rawPassword) {

        String id = loginId.trim();

        // 2026-07-21 박유정 — 기간 정지 만료 회원 자동 복구 (로그인 시)
        memberAuthMapper.releaseExpiredSuspensions();

        // [1] 먼저 일반 회원 조회 (이메일 = MEMBER_ID 또는 EMAIL)
        MemberAuthVO found = memberAuthMapper.selectMemberByLoginId(id);

        // [2] 회원이면 기존 회원 로그인 처리 (role=USER)
        if (found != null) {

            // [2-1] 정상 회원만 로그인 허용 (STATUS_CD = NORMAL)
            // 2026-07-22 박유정 — 탈퇴 회원만 로그인 차단 (정지는 로그인 후 고객센터만)
            if ("WITHDRAWN".equals(found.getStatusCd())) {
                throw new MemberLoginBlockedException(found.getStatusCd());
            }

            // [2-2] BCrypt 비밀번호 검증
            if (found.getMemberPwd() == null
                    || !passwordEncoder.matches(rawPassword, found.getMemberPwd())) {
                return null;
            }

            // [2-3] 로그인 성공 → 최종 로그인 일시 갱신
            memberAuthMapper.updateLastLoginDate(found.getMemberNo());

            // [2-4] 세션용 MemberVO 변환 (비밀번호는 세션에 넣지 않음)
            MemberVO sessionMember = new MemberVO();
            sessionMember.setMemberNo(found.getMemberNo());
            sessionMember.setMemberId(found.getMemberId());
            sessionMember.setEmail(found.getEmail());
            sessionMember.setMemberName(found.getMemberName());
            sessionMember.setNickname(found.getNickname());
            sessionMember.setRole("USER");
            // 2026-07-22 박유정 — 세션에 회원 상태 (정지 회원 고객센터 제한용)
            sessionMember.setStatus(found.getStatusCd());
            // 2026/07/08 장우철 — 마이페이지 A단계: TB_MEMBER 보유 포인트 세션에 담기
            sessionMember.setPointBalance(
                    found.getPointBalance() != null ? found.getPointBalance() : 0L);
            // 2026/07/10 지윤 — 주문서 배송지 자동입력용으로 추가
            sessionMember.setPhone(found.getPhone());
            sessionMember.setZipcode(found.getZipcode());
            sessionMember.setAddr1(found.getAddr1());
            sessionMember.setAddr2(found.getAddr2());
            // 2026-08-04 박유정 — 프로필 사진 URL 세션 반영 (사이드바 표시)
            sessionMember.setProfileImgUrl(found.getProfileImgUrl());

            // 2026-07-09 장우철 — [변경 후] 승인된 사업자면 role=BIZ + bizType 세팅
            // 이유: TB_BUSINESS.STATUS_CD=APPROVED 일 때 신청 시 저장한 BIZ_TYPE 으로
            //       /biz/hospital, /biz/stay, /biz/store 등 업종별 화면 진입 (test* URL 과 동일 분기)
            // 2026-07-22 박유정 — 정지 회원은 사업자 권한 안 줌
            if (!"SUSPENDED".equals(found.getStatusCd())) {
                enrichSessionWithApprovedBiz(sessionMember);
            }

            /* [변경 전] 2026-07-09 장우철 — role=USER 고정만 하고 사업자 조회 없음
            sessionMember.setRole("USER");
            return sessionMember;
            */

            return sessionMember;
        }

        // [3] 회원이 아니면 관리자(TB_ADMIN) 조회 (ADMIN_ID 는 이메일 형식 아님)
        AdminAuthVO admin = memberAuthMapper.selectAdminByLoginId(id);
        if (admin == null) {
            return null; // 회원도 관리자도 아님 → 로그인 실패
        }

        // [3-1] 정상 관리자만 로그인 허용 (STATUS_CD = NORMAL)
        if (!"NORMAL".equals(admin.getStatusCd())) {
            return null;
        }

        // [3-2] BCrypt 비밀번호 검증 (관리자도 회원과 동일한 PasswordEncoder 사용)
        if (admin.getAdminPwd() == null
                || !passwordEncoder.matches(rawPassword, admin.getAdminPwd())) {
            return null;
        }

        // [3-3] 세션용 MemberVO 변환 — 관리자 (role=ADMIN)
        MemberVO sessionAdmin = new MemberVO();
        sessionAdmin.setAdminNo(admin.getAdminNo());
        sessionAdmin.setMemberId(admin.getAdminId());
        sessionAdmin.setMemberName(admin.getAdminName());
        sessionAdmin.setRole("ADMIN");
        // 2026/07/08 장우철 — 관리자는 TB_MEMBER 포인트 없음 → 0 표시
        sessionAdmin.setPointBalance(0L);
        return sessionAdmin;
    }

    // 2026-07-09 장우철 — TB_BUSINESS 승인 완료 시 세션에 사업자 권한 반영
    // 이유: 로그인·/mypage/biz 진입 공통 처리 — BIZ_ID=회원 이메일, BIZ_TYPE 은 신청(apply) 시 저장값 그대로 사용
    @Override
    public void enrichSessionWithApprovedBiz(MemberVO sessionMember) {
        if (sessionMember == null || sessionMember.getMemberId() == null) {
            return;
        }
        MemberAuthBizVO approved = memberAuthMapper.selectApprovedBusinessByBizId(
                sessionMember.getMemberId());
        if (approved != null && "APPROVED".equals(approved.getStatusCd())) {
            sessionMember.setRole("BIZ");
            sessionMember.setBizType(approved.getBizType());
        }
    }

    /* ── [변경 전] login (2026/07/06) — TB_MEMBER 단독 조회, role=USER 고정 ──
     * 변경 이유: 관리자도 유저 홈(/login)에서 로그인할 수 있도록 TB_ADMIN 조회 분기 추가
     *
    @Override
    public MemberVO login(String loginId, String rawPassword) {

        // [1] DB에서 회원 조회 (이메일 = MEMBER_ID 또는 EMAIL)
        MemberAuthVO found = memberAuthMapper.selectMemberByLoginId(loginId.trim());
        if (found == null) {
            return null;
        }

        // [2] 정상 회원만 로그인 허용 (STATUS_CD = NORMAL)
        if (!"NORMAL".equals(found.getStatusCd())) {
            return null;
        }

        // [3] BCrypt 비밀번호 검증
        if (found.getMemberPwd() == null
                || !passwordEncoder.matches(rawPassword, found.getMemberPwd())) {
            return null;
        }

        // [4] 로그인 성공 → 최종 로그인 일시 갱신
        memberAuthMapper.updateLastLoginDate(found.getMemberNo());

        // [5] 세션용 MemberVO 변환 (비밀번호는 세션에 넣지 않음)
        MemberVO sessionMember = new MemberVO();
        sessionMember.setMemberNo(found.getMemberNo());
        sessionMember.setMemberId(found.getMemberId());
        sessionMember.setEmail(found.getEmail());
        sessionMember.setMemberName(found.getMemberName());
        sessionMember.setNickname(found.getNickname());
        sessionMember.setRole("USER");
        return sessionMember;
    }
     */

    /**
     * HYJ 26.07.15 카카오 로그인 처리
     * MEMBER_ID = 카카오 고유 ID 이므로 selectMemberByLoginId 로 바로 조회
     * [1] MEMBER_ID 로 기존 회원 조회 → 있으면 로그인
     * [2] 없으면 null 반환 → Controller 에서 회원가입 페이지로 안내
     */
    @Override
    @Transactional
    public MemberVO kakaoLogin(KakaoUserVO kakaoUser) {

        String kakaoId = kakaoUser.getKakaoId();
        
        // 2026-07-21 박유정 — 기간 정지 만료 회원 자동 복구
        memberAuthMapper.releaseExpiredSuspensions();

        // [1] MEMBER_ID = 카카오ID 인 회원 조회
        MemberAuthVO found = memberAuthMapper.selectMemberByLoginId(kakaoId);

        // [2] 가입된 회원이 아님 → null 반환 (회원가입 필요)
        if (found == null) {
            return null;
        }

        // 2026-07-22 박유정 — 탈퇴 회원만 로그인 차단 (정지는 로그인 후 고객센터만)
        if ("WITHDRAWN".equals(found.getStatusCd())) {
            throw new MemberLoginBlockedException(found.getStatusCd());
        }

        // [3] 로그인 성공 → 최종 로그인 일시 갱신
        memberAuthMapper.updateLastLoginDate(found.getMemberNo());

        // [4] 세션용 MemberVO 변환
        MemberVO sessionMember = new MemberVO();
        sessionMember.setMemberNo(found.getMemberNo());
        sessionMember.setMemberId(found.getMemberId());
        sessionMember.setEmail(found.getEmail());
        sessionMember.setMemberName(found.getMemberName());
        sessionMember.setNickname(found.getNickname());
        sessionMember.setRole("USER");
        // 2026-07-22 박유정 — 세션에 회원 상태 (정지 회원 고객센터 제한용)
        sessionMember.setStatus(found.getStatusCd());
        sessionMember.setPointBalance(found.getPointBalance() != null ? found.getPointBalance() : 0L);
        sessionMember.setPhone(found.getPhone());
        sessionMember.setZipcode(found.getZipcode());
        sessionMember.setAddr1(found.getAddr1());
        sessionMember.setAddr2(found.getAddr2());
        // 2026-08-04 박유정 — 프로필 사진 URL 세션 반영 (카카오 로그인·사이드바 표시)
        sessionMember.setProfileImgUrl(found.getProfileImgUrl());

        // 사업자 승인 여부 확인
        // 2026-07-22 박유정 — 정지 회원은 사업자 권한 안 줌
        if (!"SUSPENDED".equals(found.getStatusCd())) {
             enrichSessionWithApprovedBiz(sessionMember);
        }

        return sessionMember;
    }

    // 2026/07/07 장우철 — join(회원가입)

    /** join.jsp 와 동일한 비밀번호 규칙: 8자 이상 + 영문 + 숫자 + 특수문자 */
    private static final String PASSWORD_PATTERN =
            "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[^a-zA-Z0-9]).{8,}$";

    private static final String EMAIL_PATTERN =
            "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$";

    /** TB_MEMBER_AGREEMENT.TERMS_VER — 시드 더미와 동일 */
    private static final String TERMS_VERSION = "1.0";

    /**
     * join — checkEmail
     * 이메일 형식 검증 후 DB 중복 여부 반환 (Controller 는 JSON 그대로 전달)
     */
    @Override
    @Transactional(readOnly = true)
    public EmailCheckResultVO checkEmail(String email) {
        if (email == null || email.isBlank()) {
            return new EmailCheckResultVO(false, "이메일을 입력해 주세요.");
        }
        String trimmed = email.trim();
        if (!trimmed.matches(EMAIL_PATTERN)) {
            return new EmailCheckResultVO(false, "올바른 이메일 형식이 아닙니다.");
        }
        // 2026-07-22 박유정 — 탈퇴 이메일 재가입 불가
        if (memberAuthMapper.countWithdrawnMemberByEmail(trimmed) > 0) {
            return new EmailCheckResultVO(false, "탈퇴한 이메일은 재가입할 수 없습니다.");
        }
        if (memberAuthMapper.countMemberByEmail(trimmed) > 0) {
            return new EmailCheckResultVO(false, "이미 사용 중인 이메일입니다.");
        }
        return new EmailCheckResultVO(true, "사용 가능한 이메일입니다.");
    } 

    /**
     * join — checkMemberId
     * 아이디 중복 확인 (Controller 는 JSON 그대로 전달)
     */
    @Override
    @Transactional(readOnly = true)
    public EmailCheckResultVO checkMemberId(String memberId) {
        if (memberId == null || memberId.isBlank()) {
            return new EmailCheckResultVO(false, "아이디를 입력해 주세요.");
        }
        String trimmed = memberId.trim();
        if (trimmed.length() < 4) {
            return new EmailCheckResultVO(false, "아이디는 4자 이상이어야 합니다.");
        }
        if (memberAuthMapper.countMemberById(trimmed) > 0) {
            return new EmailCheckResultVO(false, "이미 사용 중인 아이디입니다.");
        }
        return new EmailCheckResultVO(true, "사용 가능한 아이디입니다.");
    }

    /**
     * join — register
     * 흐름: 검증 → 중복재확인 → BCrypt → TB_MEMBER → TB_MEMBER_AGREEMENT → (선택) TB_PET
     * @Transactional : 중간 실패 시 INSERT 전부 롤백
     */
    @Override
    @Transactional
    public String register(MemberRegisterVO vo, MultipartFile petPhoto) {
        if (vo == null) {
            return "invalid";
        }

        // [1] 서버 측 유효성 검증 (join.jsp 우회 방지)
        String validateError = validateRegister(vo);
        if (validateError != null) {
            return validateError;
        }

        String email = vo.getEmail().trim();
        
        // 2026-07-22 박유정 — 탈퇴 이메일 재가입 불가 (POST 우회 방지)
        if (memberAuthMapper.countWithdrawnMemberByEmail(email) > 0) {
            return "withdrawn_email";
        }

        // [2] 아이디 중복 재확인
        String memberId = vo.getMemberId() != null ? vo.getMemberId().trim() : null;
        if (memberId == null || memberId.isBlank()) {
            return "id";
        }
        if (memberAuthMapper.countMemberById(memberId) > 0) {
            return "id_duplicate";
        }

        // [2-1] 이메일 중복 재확인 (Ajax 없이 POST 만 보내는 경우 차단)
        if (memberAuthMapper.countMemberByEmail(email) > 0) {
            return "duplicate";
        }

        // [3] 평문 비밀번호 → BCrypt 해시 (로그인 때와 동일 PasswordEncoder 사용)
        vo.setPassword(passwordEncoder.encode(vo.getPassword()));

        // [4] 마케팅 Y/N — TB_MEMBER.MARKETING_YN + 약관 행에 사용
        vo.setAgreeMarketing(toYn(vo.getAgreeMarketing()));

        // [5] TB_MEMBER INSERT — memberNo 는 XML selectKey 로 vo 에 세팅됨
        memberAuthMapper.insertMember(vo);
        Long memberNo = vo.getMemberNo();

        // [6] TB_MEMBER_AGREEMENT — 필수·선택 약관 각 1행 (AGREE_ID 는 전역 시퀀스)
        saveAgreement(memberNo, "SERVICE", vo.getAgreeService());
        saveAgreement(memberNo, "PRIVACY", vo.getAgreePrivacy());
        saveAgreement(memberNo, "LOCATION", vo.getAgreeLocation());
        saveAgreement(memberNo, "MARKETING", vo.getAgreeMarketing());

        // [7] TB_PET — petName 이 있을 때만 (없으면 Step3 스킵과 동일)
        // 2026/08/11 장우철 — GENDER·PHOTO_URL 저장 (사진은 INSERT 후 업로드)
        if (hasPetInfo(vo)) {
            vo.setPetType(mapPetSpecies(vo.getPetType()));
            vo.setPetGender(normalizePetGender(vo.getPetGender()));
            memberAuthMapper.insertPet(vo);
            savePetPhoto(vo.getPetId(), memberNo, petPhoto);
        }

        // HYJ 26.07.15 [8] 카카오 로그인 → 회원가입 흐름이면 SOCIAL_ID 연동
        //     같은 트랜잭션 안에서 처리 → 실패 시 TB_MEMBER INSERT 도 함께 롤백
        vo.setMemberNo(memberNo);
        if (vo.getSocialId() != null && !vo.getSocialId().isBlank()) {
            memberAuthMapper.insertSocialLink(memberNo, vo.getSocialId());
        }

        return null;
    }

    /** 2026/08/11 장우철 — TB_PET.GENDER 는 M/F 만 허용 */
    private String normalizePetGender(String gender) {
        if (gender == null) {
            return null;
        }
        String g = gender.trim().toUpperCase();
        if ("M".equals(g) || "F".equals(g)) {
            return g;
        }
        return null;
    }

    /** 2026/08/11 장우철 — 가입 Step3 대표사진 → FileService + TB_PET.PHOTO_URL */
    private void savePetPhoto(Long petId, Long memberNo, MultipartFile petPhoto) {
        if (petId == null || memberNo == null || petPhoto == null || petPhoto.isEmpty()) {
            return;
        }
        String contentType = petPhoto.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            log.warn("join pet photo skipped: not an image (petId={})", petId);
            return;
        }
        try {
            FileVO file = fileService.uploadFile(petPhoto, "PET", petId);
            String path = file.getFileUrl() == null ? "" : file.getFileUrl().replace('\\', '/');
            String photoUrl = path.startsWith("/upload/") ? path : "/upload/" + path;
            memberAuthMapper.updatePetPhotoUrl(petId, memberNo, photoUrl);
        } catch (Exception e) {
            // 가입은 유지 — 사진은 마이페이지에서 재등록 가능
            log.warn("join pet photo upload failed (petId={}): {}", petId, e.toString());
        }
    }

    // ── 2026/07/07 장우철 — join(회원가입) private 헬퍼 ──

    /** 가입 폼 전체 검증 — 문제 있으면 오류 코드, 없으면 null */
    private String validateRegister(MemberRegisterVO vo) {
        if (vo.getMemberName() == null || vo.getMemberName().isBlank()) {
            return "name";
        }
        if (vo.getEmail() == null || !vo.getEmail().trim().matches(EMAIL_PATTERN)) {
            return "email";
        }
        if (vo.getPassword() == null || !vo.getPassword().matches(PASSWORD_PATTERN)) {
            return "password";
        }
        if (vo.getPasswordConfirm() == null
                || !vo.getPassword().equals(vo.getPasswordConfirm())) {
            return "password_mismatch";
        }
        if (vo.getPhone() == null || !vo.getPhone().matches("^01[0-9]-\\d{4}-\\d{4}$")) {
            return "phone";
        }
        // 2026-07-28 박유정 — 생년월일 필수 (join.jsp Step2와 동일)
        if (vo.getBirthDate() == null || vo.getBirthDate().isBlank()) {
            return "birth";
        }
        if (!isAgreed(vo.getAgreeService()) || !isAgreed(vo.getAgreePrivacy())) {
            return "terms";
        }
        return null;
    }

    /** 체크박스 값이 동의인지 (Y / on / true) */
    private boolean isAgreed(String value) {
        if (value == null) {
            return false;
        }
        String v = value.trim();
        return "Y".equalsIgnoreCase(v)
                || "on".equalsIgnoreCase(v)
                || "true".equalsIgnoreCase(v);
    }

    /** 동의 여부를 DB용 Y/N 문자열로 */
    private String toYn(String value) {
        return isAgreed(value) ? "Y" : "N";
    }

    /** 약관 1건 INSERT — 동의 안 한 선택 약관도 N 으로 이력 남김 */
    private void saveAgreement(Long memberNo, String termsType, String agreeValue) {
        memberAuthMapper.insertMemberAgreement(
                memberNo, termsType, TERMS_VERSION, toYn(agreeValue));
    }

    /** petName 이 비어 있지 않으면 펫 등록 */
    private boolean hasPetInfo(MemberRegisterVO vo) {
        return vo.getPetName() != null && !vo.getPetName().isBlank();
    }

    /** join.jsp petType(dog/cat/etc) → TB_PET.SPECIES(DOG/CAT/ETC) */
    private String mapPetSpecies(String petType) {
        if (petType == null) {
            return "ETC";
        }
        return switch (petType.toLowerCase()) {
            case "dog" -> "DOG";
            case "cat" -> "CAT";
            default -> "ETC";
        };
    }
}
