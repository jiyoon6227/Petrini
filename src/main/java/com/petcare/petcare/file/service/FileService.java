package com.petcare.petcare.file.service;

import java.io.File;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.BlobInfo;
import com.google.cloud.storage.Storage;
import com.petcare.petcare.file.mapper.FileMapper;
import com.petcare.petcare.file.vo.FileVO;

@Service
public class FileService {
    @Value("${file.upload-dir}")
    public String uploadDir;

    @Value("${gcs.enabled:false}")
    private boolean gcsEnabled;

    @Value("${gcs.bucket-name:}")
    private String gcsBucket;

    @Autowired(required = false)
    private Storage storage;

    @Autowired
    public FileMapper fileMapper;

    @Transactional
    public FileVO uploadFile(MultipartFile file, String refType, Long refId) throws Exception {

        // 1) 저장 경로: hospital/3/
        String subDir = refType.toLowerCase() + "/" + refId;

        // 2) 파일명 중복 방지: UUID + 원본 확장자
        String originName = file.getOriginalFilename();
        String ext = "";
        if (originName != null && originName.contains(".")) {
            ext = originName.substring(originName.lastIndexOf("."));
        }
        String savedName = UUID.randomUUID().toString() + ext;
        String objectPath = subDir + "/" + savedName;

        if (gcsEnabled) {
            // [GCS 업로드 — gcs.enabled=true] 2026/07/21 장우철
            //#region구글 스토리지 GCS 전환코드 START
            if (storage == null) {
                throw new IllegalStateException("GCS enabled but Storage bean is missing");
            }
            String contentType = file.getContentType();
            if (contentType == null || contentType.isBlank()) {
                contentType = "application/octet-stream";
            }
            BlobInfo blobInfo = BlobInfo.newBuilder(BlobId.of(gcsBucket, objectPath))
                    .setContentType(contentType)
                    .build();
            storage.create(blobInfo, file.getBytes());
            //#endregion GCS 전환코드 END
        } else {
            // [로컬 저장 — gcs.enabled=false] 2026/07/21 장우철
            //#region로컬 파일관리
            File dir = new File(uploadDir + subDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            File dest = new File(dir, savedName);
            file.transferTo(dest);
            //#endregion
        }

        // 3) DB INSERT (selectKey로 fileId가 VO에 자동 세팅됨)
        FileVO vo = new FileVO();
        vo.setRefType(refType);
        vo.setRefId(refId);
        vo.setFileUrl(objectPath);
        vo.setOriginName(originName);
        vo.setDriveFileId(gcsEnabled ? "GCS" : "LOCAL");
        fileMapper.insertFile(vo);

        return vo;
    }

    @Transactional
    public void deleteFile(Long fileId) throws Exception {

        // 1) DB에서 경로 조회
        FileVO file = fileMapper.selectFile(fileId);
        if (file == null) {
            return;
        }

        if (gcsEnabled) {
            // [GCS 삭제 — gcs.enabled=true] 2026/07/21 장우철
            //#region구글 스토리지 GCS 전환코드 START
            if (storage != null) {
                storage.delete(BlobId.of(gcsBucket, file.getFileUrl()));
            }
            //#endregion GCS 전환코드 END
        } else {
            // [로컬 삭제 — gcs.enabled=false] 2026/07/21 장우철
            //#region로컬 파일관리
            File diskFile = new File(uploadDir + file.getFileUrl());
            if (diskFile.exists()) {
                diskFile.delete();
            }
            //#endregion
        }

        // 2) DB 삭제
        fileMapper.deleteFile(fileId);
    }

    public List<FileVO> getFileList(String refType, Long refId) throws Exception {
        FileVO param = new FileVO();
        param.setRefType(refType);
        param.setRefId(refId);
        param.setDriveFileId(refType.toLowerCase() + "_" + System.currentTimeMillis());
        return fileMapper.selectFileList(param);
    }

    //지윤 26.07.15 추가: 상품 이미지 교체 시 기존 파일들(디스크+DB) 전부 삭제 - 새 이미지 올리기 전에 호출
    @Transactional
    public void deleteFilesByRef(String refType, Long refId) throws Exception {
        List<FileVO> files = getFileList(refType, refId);
        for (FileVO f : files) {
            deleteFile(f.getFileId());
        }
    }
}
