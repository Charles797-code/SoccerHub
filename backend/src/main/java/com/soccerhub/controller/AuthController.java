package com.soccerhub.controller;

import com.soccerhub.dto.*;
import com.soccerhub.entity.SysUser;
import com.soccerhub.entity.UserClubFollow;
import com.soccerhub.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "User authentication endpoints")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @Operation(summary = "Register a new user")
    public ResponseEntity<ApiResponse<SysUser>> register(@Valid @RequestBody RegisterRequest request) {
        try {
            SysUser user = authService.register(request);
            return ResponseEntity.ok(ApiResponse.success("Registration successful", user));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/login")
    @Operation(summary = "User login")
    public ResponseEntity<ApiResponse<LoginResponse>> login(@Valid @RequestBody LoginRequest request) {
        try {
            LoginResponse response = authService.login(request);
            return ResponseEntity.ok(ApiResponse.success("Login successful", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Invalid credentials"));
        }
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh JWT token")
    public ResponseEntity<ApiResponse<LoginResponse>> refresh(@RequestBody String refreshToken) {
        try {
            LoginResponse response = authService.refreshToken(refreshToken.replace("\"", ""));
            return ResponseEntity.ok(ApiResponse.success("Token refreshed", response));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Invalid refresh token"));
        }
    }

    @GetMapping("/profile")
    @Operation(summary = "Get current user profile")
    public ResponseEntity<ApiResponse<SysUser>> getProfile(Authentication authentication) {
        SysUser user = authService.getCurrentUser(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success(user));
    }

    @PutMapping("/profile")
    @Operation(summary = "Update user profile")
    public ResponseEntity<ApiResponse<SysUser>> updateProfile(Authentication auth, @RequestBody SysUser updateData) {
        SysUser user = authService.updateProfile(auth.getName(), updateData);
        return ResponseEntity.ok(ApiResponse.success("Profile updated", user));
    }

    @GetMapping("/my-follows")
    @Operation(summary = "Get user's followed clubs")
    public ResponseEntity<ApiResponse<List<UserClubFollow>>> getMyFollows(Authentication authentication) {
        SysUser user = authService.getCurrentUser(authentication.getName());
        List<UserClubFollow> follows = authService.getUserFollows(user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(follows));
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get user basic info by ID")
    public ResponseEntity<ApiResponse<SysUser>> getUserById(@PathVariable Long userId) {
        SysUser user = authService.getUserById(userId);
        if (user == null) return ResponseEntity.notFound().build();
        user.setPasswordHash(null);
        return ResponseEntity.ok(ApiResponse.success(user));
    }
}
