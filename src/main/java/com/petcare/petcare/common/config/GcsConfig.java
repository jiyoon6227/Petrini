package com.petcare.petcare.common.config;

import java.io.FileInputStream;
import java.io.IOException;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageOptions;

/**
 * GCS Storage 빈 — gcs.enabled=true 일 때만 로드
 * 2026/07/21 장우철
 */
@Configuration
@ConditionalOnProperty(name = "gcs.enabled", havingValue = "true")
public class GcsConfig {

    @Value("${gcs.credentials-path}")
    private String credentialsPath;

    @Bean
    public Storage storage() throws IOException {
        try (FileInputStream stream = new FileInputStream(credentialsPath)) {
            GoogleCredentials credentials = GoogleCredentials.fromStream(stream);
            return StorageOptions.newBuilder()
                    .setCredentials(credentials)
                    .build()
                    .getService();
        }
    }
}
