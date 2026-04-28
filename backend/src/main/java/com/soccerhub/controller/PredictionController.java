package com.soccerhub.controller;

import com.soccerhub.dto.ApiResponse;
import com.soccerhub.entity.MatchPrediction;
import com.soccerhub.entity.MatchSchedule;
import com.soccerhub.service.PredictionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/predictions")
@RequiredArgsConstructor
@Tag(name = "Predictions", description = "Match prediction endpoints")
public class PredictionController {

    private final PredictionService predictionService;

    @PostMapping
    @Operation(summary = "Make a prediction")
    public ResponseEntity<ApiResponse<MatchPrediction>> makePrediction(
            @RequestParam Long userId,
            @RequestParam String matchId,
            @RequestParam String predictedResult) {
        try {
            MatchPrediction prediction = predictionService.makePrediction(userId, matchId, predictedResult);
            return ResponseEntity.ok(ApiResponse.success("预测成功", prediction));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/match/{matchId}")
    @Operation(summary = "Get user's prediction for a match")
    public ResponseEntity<ApiResponse<MatchPrediction>> getUserPrediction(
            @RequestParam Long userId,
            @PathVariable String matchId) {
        MatchPrediction prediction = predictionService.getUserPredictionForMatch(userId, matchId);
        return ResponseEntity.ok(ApiResponse.success(prediction));
    }

    @GetMapping("/user/{userId}")
    @Operation(summary = "Get user's all predictions")
    public ResponseEntity<ApiResponse<List<MatchPrediction>>> getUserPredictions(
            @PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(predictionService.getUserPredictions(userId)));
    }

    @GetMapping("/user/{userId}/with-match")
    @Operation(summary = "Get user's predictions with match info")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> getUserPredictionsWithMatch(
            @PathVariable Long userId) {
        return ResponseEntity.ok(ApiResponse.success(predictionService.getUserPredictionsWithMatchInfo(userId)));
    }

    @GetMapping("/user/{userId}/points")
    @Operation(summary = "Get user's points")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getUserPoints(@PathVariable Long userId) {
        try {
            return ResponseEntity.ok(ApiResponse.success(predictionService.getUserPoints(userId)));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/match/{matchId}/all")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Get all predictions for a match (admin)")
    public ResponseEntity<ApiResponse<List<MatchPrediction>>> getMatchPredictions(
            @PathVariable String matchId) {
        return ResponseEntity.ok(ApiResponse.success(predictionService.getPredictionsByMatch(matchId)));
    }

    @GetMapping("/pending")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Get all pending predictions (admin)")
    public ResponseEntity<ApiResponse<List<MatchPrediction>>> getPendingPredictions() {
        return ResponseEntity.ok(ApiResponse.success(predictionService.getPendingPredictions()));
    }

    @PostMapping("/settle/{matchId}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Settle predictions for a match (admin)")
    public ResponseEntity<ApiResponse<Map<String, Object>>> settleMatch(@PathVariable String matchId) {
        try {
            return ResponseEntity.ok(ApiResponse.success("结算成功", predictionService.settleMatch(matchId)));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/admin/settled-matches")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Get finished matches for settlement (admin)")
    public ResponseEntity<ApiResponse<List<MatchSchedule>>> getSettledMatches() {
        try {
            return ResponseEntity.ok(ApiResponse.success(predictionService.getSettledMatches()));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body(ApiResponse.error("获取比赛列表失败: " + e.getMessage()));
        }
    }
}