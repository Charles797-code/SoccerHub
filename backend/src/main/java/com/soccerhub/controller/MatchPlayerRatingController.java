package com.soccerhub.controller;

import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.MatchPlayerRatingVO;
import com.soccerhub.entity.SysUser;
import com.soccerhub.service.AuthService;
import com.soccerhub.service.MatchPlayerRatingService;
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
@RequestMapping("/matches/{matchId}/player-ratings")
@RequiredArgsConstructor
@Tag(name = "Match Player Ratings", description = "Player rating endpoints for matches")
public class MatchPlayerRatingController {

    private final MatchPlayerRatingService ratingService;
    private final AuthService authService;

    @GetMapping
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get player ratings for a match by club")
    public ResponseEntity<ApiResponse<List<MatchPlayerRatingVO>>> getPlayerRatings(
            @PathVariable String matchId,
            @RequestParam Long clubId,
            Authentication authentication) {
        SysUser user = authService.getCurrentUser(authentication.getName());
        List<MatchPlayerRatingVO> ratings = ratingService.getMatchPlayerRatings(matchId, clubId, user.getUserId());
        return ResponseEntity.ok(ApiResponse.success(ratings));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('FAN', 'CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Rate a player in a match")
    public ResponseEntity<ApiResponse<MatchPlayerRatingVO>> ratePlayer(
            @PathVariable String matchId,
            @RequestBody Map<String, Object> body,
            Authentication authentication) {
        try {
            SysUser user = authService.getCurrentUser(authentication.getName());
            Long playerId = Long.valueOf(body.get("playerId").toString());
            Integer score = (int) Math.round(Double.parseDouble(body.get("score").toString()));
            MatchPlayerRatingVO result = ratingService.ratePlayer(matchId, playerId, user.getUserId(), score);
            return ResponseEntity.ok(ApiResponse.success("评分成功", result));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
