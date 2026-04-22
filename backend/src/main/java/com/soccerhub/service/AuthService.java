package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.*;
import com.soccerhub.entity.SysUser;
import com.soccerhub.entity.UserClubFollow;
import com.soccerhub.mapper.SysUserMapper;
import com.soccerhub.mapper.UserClubFollowMapper;
import com.soccerhub.security.JwtTokenProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final SysUserMapper userMapper;
    private final UserClubFollowMapper followMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public SysUser register(RegisterRequest request) {
        if (userMapper.selectByUsername(request.getUsername()) != null) {
            throw new RuntimeException("Username already exists");
        }
        if (request.getEmail() != null && userMapper.selectByEmail(request.getEmail()) != null) {
            throw new RuntimeException("Email already exists");
        }
        
        SysUser user = new SysUser();
        user.setUsername(request.getUsername());
        user.setPasswordHash(passwordEncoder.encode(request.getPassword()));
        user.setNickname(request.getNickname());
        user.setEmail(request.getEmail());
        user.setRole("FAN");
        user.setStatus("ACTIVE");
        user.setCreatedAt(LocalDateTime.now());
        
        userMapper.insert(user);
        return user;
    }

    public LoginResponse login(LoginRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );
        
        SysUser user = userMapper.selectByUsername(request.getUsername());
        UserDetails userDetails = (UserDetails) authentication.getPrincipal();
        String token = jwtTokenProvider.generateToken(userDetails, user.getUserId(), user.getRole());
        String refreshToken = jwtTokenProvider.generateRefreshToken(userDetails);
        
        // Update last login
        user.setLastLoginAt(LocalDateTime.now());
        userMapper.updateById(user);
        
        return new LoginResponse(
                token, refreshToken, user.getUsername(),
                user.getNickname(), user.getRole(), user.getUserId(),
                user.getAvatarUrl(), jwtTokenProvider.getExpirationMs() / 1000,
                user.getManagedClubId()
        );
    }

    public SysUser getCurrentUser(String username) {
        return userMapper.selectByUsername(username);
    }

    @Transactional
    public SysUser updateProfile(String username, SysUser updateData) {
        SysUser user = userMapper.selectByUsername(username);
        if (updateData.getNickname() != null) {
            user.setNickname(updateData.getNickname());
        }
        if (updateData.getEmail() != null) {
            user.setEmail(updateData.getEmail());
        }
        if (updateData.getAvatarUrl() != null) {
            user.setAvatarUrl(updateData.getAvatarUrl());
        }
        user.setUpdatedAt(LocalDateTime.now());
        userMapper.updateById(user);
        return user;
    }

    public List<UserClubFollow> getUserFollows(Long userId) {
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId);
        return followMapper.selectList(wrapper);
    }

    public SysUser getUserById(Long userId) {
        return userMapper.selectById(userId);
    }

    public LoginResponse refreshToken(String refreshToken) {
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new RuntimeException("Invalid refresh token");
        }
        String username = jwtTokenProvider.extractUsername(refreshToken);
        SysUser user = userMapper.selectByUsername(username);
        UserDetails userDetails = (UserDetails) new org.springframework.security.core.userdetails.User(
                user.getUsername(), user.getPasswordHash(),
                java.util.Collections.singletonList(new org.springframework.security.core.authority.SimpleGrantedAuthority("ROLE_" + user.getRole()))
        );
        String newToken = jwtTokenProvider.generateToken(userDetails, user.getUserId(), user.getRole());
        String newRefreshToken = jwtTokenProvider.generateRefreshToken(userDetails);
        
        return new LoginResponse(
                newToken, newRefreshToken, user.getUsername(),
                user.getNickname(), user.getRole(), user.getUserId(),
                user.getAvatarUrl(), jwtTokenProvider.getExpirationMs() / 1000,
                user.getManagedClubId()
        );
    }
}
