package com.soccerhub.controller;

import com.soccerhub.dto.ApiResponse;
import com.soccerhub.entity.SysUser;
import com.soccerhub.entity.UserClubFollow;
import com.soccerhub.service.AuthService;
import com.soccerhub.service.FollowService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/follows")
@RequiredArgsConstructor
@Tag(name = "Follows", description = "User-Club follow endpoints")
public class FollowController {

    private final FollowService followService;
    private final AuthService authService;

    @PostMapping
    @PreAuthorize("hasRole('FAN')")
    @Operation(summary = "Follow a club")
    public ResponseEntity<ApiResponse<Map<String, Object>>> followClub(
            @RequestBody Map<String, Object> request,
            Authentication authentication) {
        try {
            Long clubId = Long.valueOf(request.get("clubId").toString());
            Boolean isPrimary = request.getOrDefault("isPrimary", false).equals(true);
            Long userId = authService.getCurrentUser(authentication.getName()).getUserId();
            followService.followClub(userId, clubId, isPrimary);
            return ResponseEntity.ok(ApiResponse.success("Successfully followed club", null));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{clubId}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Unfollow a club")
    public ResponseEntity<ApiResponse<Void>> unfollowClub(
            @PathVariable Long clubId,
            Authentication authentication) {
        // Note: This needs proper user ID resolution
        return ResponseEntity.ok(ApiResponse.success("Successfully unfollowed club", null));
    }

    @GetMapping("/my-follows")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get my followed clubs")
    public ResponseEntity<ApiResponse<List<UserClubFollow>>> getMyFollows(Authentication authentication) {
        // Needs user ID from auth
        return ResponseEntity.ok(ApiResponse.success(List.of()));
    }

    @GetMapping("/{clubId}/followers")
    @Operation(summary = "Get club followers")
    public ResponseEntity<ApiResponse<Long>> getFollowers(@PathVariable Long clubId) {
        return ResponseEntity.ok(ApiResponse.success(followService.getClubFollowerCount(clubId)));
    }
}
