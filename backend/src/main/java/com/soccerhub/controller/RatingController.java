package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.dto.RatingRequest;
import com.soccerhub.entity.RatingRecord;
import com.soccerhub.entity.SysUser;
import com.soccerhub.mapper.SysUserMapper;
import com.soccerhub.service.AuthService;
import com.soccerhub.service.RatingService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.Map;

@RestController
@RequestMapping("/ratings")
@RequiredArgsConstructor
@Tag(name = "Ratings", description = "Player/Coach rating endpoints")
public class RatingController {

    private final RatingService ratingService;
    private final AuthService authService;
    private final SysUserMapper userMapper;

    @PostMapping
    @PreAuthorize("hasAnyRole('FAN', 'CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Submit a rating")
    public ResponseEntity<ApiResponse<Map<String, Object>>> submitRating(
            @Valid @RequestBody RatingRequest request,
            Authentication authentication) {
        SysUser user = authService.getCurrentUser(authentication.getName());
        Map<String, Object> result = ratingService.submitRating(
                user.getUserId(), request.getTargetId(), request.getTargetType(),
                request.getScore(), request.getCommentText(), request.getClubId(),
                request.getRatingType(), request.getMatchId());
        
        if ((Boolean) result.get("success")) {
            return ResponseEntity.ok(ApiResponse.success((String) result.get("message"), result));
        } else {
            return ResponseEntity.badRequest().body(ApiResponse.error((String) result.get("message"), result));
        }
    }

    @GetMapping("/target/{type}/{id}")
    @Operation(summary = "Get ratings for a target")
    public ResponseEntity<ApiResponse<PageResponse<RatingRecord>>> getTargetRatings(
            @PathVariable String type,
            @PathVariable Long id,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Page<RatingRecord> result = ratingService.getTargetRatings(type, id, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/target/{type}/{id}/average")
    @Operation(summary = "Get average score for a target")
    public ResponseEntity<ApiResponse<BigDecimal>> getAverageScore(
            @PathVariable String type,
            @PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(ratingService.getTargetAverageScore(type, id)));
    }

    @GetMapping("/my-ratings")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get current user's ratings")
    public ResponseEntity<ApiResponse<PageResponse<RatingRecord>>> getMyRatings(
            Authentication authentication,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        SysUser user = authService.getCurrentUser(authentication.getName());
        Page<RatingRecord> result = ratingService.getUserRatings(user.getUserId(), page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Delete a rating (admin)")
    public ResponseEntity<ApiResponse<Void>> deleteRating(
            @PathVariable Long id,
            Authentication authentication) {
        SysUser user = authService.getCurrentUser(authentication.getName());
        ratingService.deleteRating(id, user.getUserId(), user.getRole());
        return ResponseEntity.ok(ApiResponse.success("Rating deleted", null));
    }
}
