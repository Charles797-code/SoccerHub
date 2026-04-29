package com.soccerhub.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@Order(1)
public class ApiPrefixFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        String path = req.getRequestURI();

        if (path.startsWith("/api/")) {
            String newPath = path.substring(4);
            chain.doFilter(new ApiPathRequestWrapper(req, newPath), response);
        } else {
            chain.doFilter(request, response);
        }
    }

    static class ApiPathRequestWrapper extends HttpServletRequestWrapper {
        private final String newPath;

        public ApiPathRequestWrapper(HttpServletRequest request, String newPath) {
            super(request);
            this.newPath = newPath;
        }

        @Override
        public String getRequestURI() {
            return newPath;
        }

        @Override
        public String getServletPath() {
            return newPath;
        }

        @Override
        public String getPathInfo() {
            if (newPath.contains("/")) {
                return newPath.substring(newPath.indexOf("/", 1));
            }
            return null;
        }
    }
}