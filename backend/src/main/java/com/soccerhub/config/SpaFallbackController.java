package com.soccerhub.config;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/")
public class SpaFallbackController {

    private static final String[] STATIC_PREFIXES = {"uploads", "assets", "api", "auth", "social", "clubs", "players", "matches", "news", "stands", "upload", "admin", "ai", "follows", "chat", "club-admin", "analytics", "ws"};

    @GetMapping(value = "/{path:[^\\.]+}/{pathSegment}")
    public String fallbackMulti(@PathVariable String path) {
        for (String prefix : STATIC_PREFIXES) {
            if (path.startsWith(prefix)) {
                return null;
            }
        }
        return "forward:/index.html";
    }

    @GetMapping(value = "/{path:[^\\.]+}")
    public String fallback(@PathVariable(required = false) String path) {
        if (path == null) return "forward:/index.html";
        for (String prefix : STATIC_PREFIXES) {
            if (path.startsWith(prefix)) {
                return null;
            }
        }
        return "forward:/index.html";
    }

    @GetMapping(value = "")
    public String root() {
        return "forward:/index.html";
    }
}