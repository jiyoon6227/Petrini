/**
 * 역할: 공통 유틸 API 처리 → Service 호출
 *
 * 연결
 * - Service: CommonUtilService
 *
 * SQL·비즈니스 로직은 넣지 말 것 → Service로 위임
 * return 경로는 담당 JSP와 동일하게 맞출 것
 */

package com.petcare.petcare.common.util.controller;

import org.springframework.stereotype.Controller;

@Controller("commonUtilController")
public class CommonUtilController {
    public int pageSize = 20;
}
