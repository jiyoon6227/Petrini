package com.petcare.petcare.file.controller;

import java.io.InputStream;
import java.net.URLDecoder;
import java.nio.channels.Channels;
import java.nio.charset.StandardCharsets;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.google.cloud.ReadChannel;
import com.google.cloud.storage.Blob;
import com.google.cloud.storage.BlobId;
import com.google.cloud.storage.Storage;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * GCS 파일 서빙 — /upload/** 요청을 버킷 객체로 스트리밍
 * gcs.enabled=true 일 때만 로드 (WebConfig 로컬 /upload 매핑과 역할 분리)
 * 2026/07/21 장우철
 */
@RestController
@ConditionalOnProperty(name = "gcs.enabled", havingValue = "true")
public class UploadFileController {

    @Value("${gcs.bucket-name}")
    private String gcsBucket;

    @Autowired
    private Storage storage;

    @GetMapping("/upload/**")
    public void serveUpload(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String path = uri.substring(contextPath.length());

        if (!path.startsWith("/upload/")) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String objectPath = URLDecoder.decode(path.substring("/upload/".length()), StandardCharsets.UTF_8);

        Blob blob = storage.get(BlobId.of(gcsBucket, objectPath));
        if (blob == null || !blob.exists()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String contentType = blob.getContentType();
        if (contentType == null || contentType.isBlank()) {
            contentType = MediaType.APPLICATION_OCTET_STREAM_VALUE;
        }

        response.setContentType(contentType);
        response.setContentLengthLong(blob.getSize());

        try (ReadChannel reader = blob.reader()) {
            InputStream in = Channels.newInputStream(reader);
            in.transferTo(response.getOutputStream());
        }
    }
}
