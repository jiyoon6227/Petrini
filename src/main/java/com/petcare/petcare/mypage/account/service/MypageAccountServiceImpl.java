/**
 * 역할: MypageAccountService 구현체 (@Service)
 *
 * - 2026-08-04 박유정 — 프로필 사진 로컬 저장 (C:/upload/member/profile/) + DB URL UPDATE
 * - 2026/08/14 장우철 — gcs.enabled 분기 (로컬 ↔ GCS)
 */

package com.petcare.petcare.mypage.account.service;

import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.petcare.petcare.mypage.account.mapper.MypageAccountMapper;
import com.petcare.petcare.mypage.account.vo.MypageAccountVO;
import com.petcare.petcare.mypage.address.mapper.MypageAddressMapper;
import com.petcare.petcare.mypage.address.vo.MypageAddressVO;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.multipart.MultipartFile;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;

@Service
public class MypageAccountServiceImpl implements MypageAccountService {

    private static final Logger log = LoggerFactory.getLogger(MypageAccountServiceImpl.class);

    private final MypageAccountMapper mypageAccountMapper;
    private final MypageAddressMapper mypageAddressMapper;
    private final BCryptPasswordEncoder passwordEncoder;

    @Value("${file.upload-dir}")
    private String uploadDir;   // application.properties → C:/upload/

    @Value("${gcs.enabled:false}")
    private boolean gcsEnabled;

    @Value("${gcs.bucket-name:}")
    private String gcsBucket;

    @Autowired(required = false)
    private Storage storage;

    public MypageAccountServiceImpl(MypageAccountMapper mypageAccountMapper,
                                     MypageAddressMapper mypageAddressMapper,
                                     BCryptPasswordEncoder passwordEncoder) {
        this.mypageAccountMapper = mypageAccountMapper;
        this.mypageAddressMapper = mypageAddressMapper;
        this.passwordEncoder = passwordEncoder;
    }

    // 2026-07-28 박유정 — 회원정보 수정 화면용 프로필 조회
    @Override
    @Transactional(readOnly = true)
    public MypageAccountVO getMemberProfile(Long memberNo) {
        if (memberNo == null) {
            return null;
        }
        return mypageAccountMapper.selectMemberProfile(memberNo);
    }

    // 2026-08-04 박유정 — 프로필 사진 저장 + DB URL UPDATE
    @Override
    @Transactional
    public String updateProfileImage(Long memberNo, MultipartFile file) {

    // 2026-08-04 박유정 — [1] 회원번호·파일 기본 검증
    if (memberNo == null) {
        throw new IllegalArgumentException("회원 정보가 없습니다.");
    }
    if (file == null || file.isEmpty()) {
        throw new IllegalArgumentException("업로드할 사진을 선택해 주세요.");
    }

    // 2026-08-04 박유정 — [2] 이미지 MIME 타입 검증
    String contentType = file.getContentType();
    if (contentType == null || !contentType.startsWith("image/")) {
        throw new IllegalArgumentException("이미지 파일만 업로드할 수 있습니다.");
    }

    // 2026-08-04 박유정 — [3] 저장 (분실신고와 동일 경로 패턴)
    // 2026/08/14 장우철 — gcs.enabled 분기
    String savedName = UUID.randomUUID() + resolveExtension(file.getOriginalFilename());
    String objectPath = "member/profile/" + memberNo + "/" + savedName;
    String fileUrl = "/upload/" + objectPath;

    if (gcsEnabled) {
        if (storage == null) {
            throw new IllegalStateException("GCS enabled but Storage bean is missing");
        }
        try {
            String gcsContentType = file.getContentType();
            if (gcsContentType == null || gcsContentType.isBlank()) {
                gcsContentType = "application/octet-stream";
            }
            BlobInfo blobInfo = BlobInfo.newBuilder(BlobId.of(gcsBucket, objectPath))
                    .setContentType(gcsContentType)
                    .build();
            storage.create(blobInfo, file.getBytes());
        } catch (IOException e) {
            throw new IllegalStateException("FILE_SAVE_FAILED", e);
        }
    } else {
        Path dir = Paths.get(uploadDir, "member", "profile", String.valueOf(memberNo));
        try {
            Files.createDirectories(dir);
            file.transferTo(dir.resolve(savedName));
        } catch (IOException e) {
            throw new IllegalStateException("FILE_SAVE_FAILED", e);
        }
    }

    // 2026-08-04 박유정 — [4] TB_MEMBER.PROFILE_IMG_URL UPDATE
    // 2026/08/06 장우철 — updateProfileImageUrl 로 분리 (회원정보 UPDATE 와 구분)
    MypageAccountVO vo = new MypageAccountVO();
    vo.setMemberNo(memberNo);
    vo.setProfileImgUrl(fileUrl);
    mypageAccountMapper.updateProfileImageUrl(vo);

    return fileUrl;
}

    /**
     * 회원정보 수정 (닉네임, 전화번호, 주소)
     * + 주소가 입력되었으면 기본배송지(TB_MEMBER_ADDRESS)도 동기화
     */
    @Override
    @Transactional
    public String updateProfile(MypageAccountVO vo) {
        if (vo == null || vo.getMemberNo() == null) {
            return "회원 정보를 찾을 수 없습니다.";
        }

        // 닉네임 빈값 체크
        if (vo.getNickname() == null || vo.getNickname().isBlank()) {
            return "닉네임을 입력해 주세요.";
        }

        // 전화번호 빈값 체크
        if (vo.getPhone() == null || vo.getPhone().isBlank()) {
            return "전화번호를 입력해 주세요.";
        }

        // [1] TB_MEMBER 업데이트
        mypageAccountMapper.updateMemberProfile(vo);

        // [2] 주소가 입력되었으면 기본배송지 동기화
        if (vo.getZipcode() != null && !vo.getZipcode().isBlank()) {
            syncDefaultAddress(vo);
        }

        return null;
    }

    /**
     * 기본배송지 동기화
     * - 기존 기본배송지가 있으면 → 주소만 UPDATE
     * - 없으면 → 신규 INSERT (IS_DEFAULT = 'Y')
     */
    private void syncDefaultAddress(MypageAccountVO vo) {
        Long memberNo = vo.getMemberNo();

        // 회원 이름·전화번호를 수령인 정보로 사용
        MypageAccountVO profile = mypageAccountMapper.selectMemberProfile(memberNo);
        String recvName  = profile.getMemberName();
        // 2026/08/11 장우철 — 기본배송지 전화 하이픈 정규화 (주문서 SSR 파싱용)
        String recvPhone = com.petcare.petcare.common.util.PhoneNormalizeUtil.toHyphenPhone(vo.getPhone());

        MypageAddressVO existing = mypageAddressMapper.selectDefaultAddress(memberNo);

        if (existing != null) {
            // 기존 기본배송지 UPDATE
            mypageAddressMapper.updateAddress(
                existing.getAddrId(), memberNo,
                recvName, recvPhone,
                vo.getZipcode(), vo.getAddr1(), vo.getAddr2()
            );
        } else {
            // 신규 기본배송지 INSERT
            mypageAddressMapper.clearDefaultAddress(memberNo);
            Long nextId = mypageAddressMapper.selectNextAddrId();
            mypageAddressMapper.insertAddress(
                nextId, memberNo,
                recvName, recvPhone,
                vo.getZipcode(), vo.getAddr1(), vo.getAddr2(),
                "Y"
            );
        }
    }

    /**
     * 비밀번호 변경
     * [1] 현재 비밀번호 확인
     * [2] 새 비밀번호 암호화 후 저장
     */
    @Override
    @Transactional
    public String changePassword(Long memberNo, String currentPassword, String newPassword) {
        if (memberNo == null) {
            return "회원 정보를 찾을 수 없습니다.";
        }

        // 현재 비밀번호 확인
        String storedPwd = mypageAccountMapper.selectPasswordByMemberNo(memberNo);
        if (storedPwd == null) {
            return "회원 정보를 찾을 수 없습니다.";
        }
        if (!passwordEncoder.matches(currentPassword, storedPwd)) {
            return "현재 비밀번호가 일치하지 않습니다.";
        }

        // 새 비밀번호 유효성 검사 (영문+숫자+특수문자 8자 이상)
        if (newPassword == null || newPassword.length() < 8) {
            return "새 비밀번호는 8자 이상이어야 합니다.";
        }
        if (!newPassword.matches("^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=]).{8,}$")) {
            return "영문, 숫자, 특수문자를 모두 포함해야 합니다.";
        }

        // 암호화 후 저장
        String encodedPwd = passwordEncoder.encode(newPassword);
        mypageAccountMapper.updatePassword(memberNo, encodedPwd);
        return null;
    }

    /**
     * HYJ 26.07.29 회원 탈퇴
     * [1] DB 에서 암호화된 비밀번호 조회
     * [2] 입력된 비밀번호와 비교
     * [3] 일치하면 STATUS_CD = 'WITHDRAWN'
     * [4] INSERT INTO TB_MEMBER_WITHDRAW
     */
    @Override
    @Transactional
    public String withdraw(Long memberNo, String password) {

        String storedPwd = mypageAccountMapper.selectPasswordByMemberNo(memberNo);
        if (storedPwd == null) {
            return "회원 정보를 찾을 수 없습니다.";
        }

        if (!passwordEncoder.matches(password, storedPwd)) {
            return "비밀번호가 일치하지 않습니다.";
        }

        mypageAccountMapper.updateStatusToWithdrawn(memberNo);
        mypageAccountMapper.insertMemberWithdraw(memberNo);
        return null;
    }

    /**
     * HYJ 26.07.29 7일 경과 탈퇴 회원 개인정보 삭제
     *
     * 삭제 범위:
     * - TB_MEMBER: 개인정보 익명화 (이름, 이메일, 전화번호 등 → NULL)
     * - TB_MEMBER_SOCIAL: 소셜 연동 삭제
     * - TB_PET: 반려동물 정보 삭제
     * - TB_MEMBER_AGREEMENT: 약관 동의 기록 삭제
     * - TB_MEMBER_WITHDRAW: 탈퇴회원 관리(맨마지막)
     */
    @Override
    @Transactional
    public int purgeExpiredWithdrawnMembers() {

        List<Long> memberNos = mypageAccountMapper.selectExpiredWithdrawnMemberNos();

        if (memberNos.isEmpty()) {
            return 0;
        }

        for (Long memberNo : memberNos) {
            // 관련 테이블 먼저 삭제 (FK 순서)
            mypageAccountMapper.deleteSocialByMemberNo(memberNo);
            mypageAccountMapper.deletePetsByMemberNo(memberNo);
            mypageAccountMapper.deleteAgreementsByMemberNo(memberNo);
            // TB_MEMBER 익명화 (삭제가 아닌 NULL 처리)
            mypageAccountMapper.anonymizeMember(memberNo);

            //HYJ 26.07.29 TB_MEMBER FK참조하는 테이블 확인 후 추가 필요
            //....

            // TB_MEMBER_WITHDRAW (탈퇴회원관리테이블 삭제)
            mypageAccountMapper.deleteMemberWithdrawByMemberNo(memberNo);

            log.info("탈퇴 회원 개인정보 삭제 완료: MEMBER_NO={}", memberNo);
        }

        log.info("총 {}명의 탈퇴 회원 개인정보 삭제 완료", memberNos.size());
        return memberNos.size();
    }
    // 2026-08-04 박유정 — 업로드 파일 확장자 정규화 (.jpg/.jpeg/.png/.webp)
    private String resolveExtension(String originalName) {
        if (originalName == null) {
            return ".jpg";
        }
        int dot = originalName.lastIndexOf('.');
        if (dot < 0) {
            return ".jpg";
        }
        String ext = originalName.substring(dot).toLowerCase();
        if (".jpg".equals(ext) || ".jpeg".equals(ext) || ".png".equals(ext) || ".webp".equals(ext)) {
            return ext;
        }
        return ".jpg";
    }
}
