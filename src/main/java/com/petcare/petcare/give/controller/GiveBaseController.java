package com.petcare.petcare.give.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller("giveController")
@RequestMapping("/give")
public class GiveBaseController {

    @GetMapping({"", "/"})
    public String give() {
        return "redirect:/give/animal/list";
    }
}
