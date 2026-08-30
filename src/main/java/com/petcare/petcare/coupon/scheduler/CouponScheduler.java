package com.petcare.petcare.coupon.scheduler;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.petcare.petcare.coupon.mapper.CouponMapper;

@Component
public class CouponScheduler {
    
    @Autowired
    private CouponMapper couponMapper;

    //@Scheduled(cron = "0 0 0 * * *") // 매일 00:00
    @Scheduled(cron = "0 * * * * *")
    public void expireOverdueCoupons() {
        couponMapper.expireOverdueCoupons();
    }
}
