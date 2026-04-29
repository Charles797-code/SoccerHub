package com.soccerhub.config;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/")
public class SpaFallbackController {

    @GetMapping(value = "")
    public String root() {
        return "forward:/index.html";
    }
}