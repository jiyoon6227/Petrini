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
