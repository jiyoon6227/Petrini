/**
 * 역할: 공통 설정 API 처리 → Service 호출
 *
 * 연결
 * - Service: CommonConfigService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.common.config.controller;

import org.springframework.beans.factory.annotation.Autowired;

import com.petcare.petcare.common.external.service.ApiService;
import com.petcare.petcare.common.util.controller.CommonUtilController;

public class CommonConfigController {
    @Autowired
    public ApiService apiService;
    @Autowired
    public CommonUtilController commonUtilController;          
}
