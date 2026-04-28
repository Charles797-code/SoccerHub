package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("MATCH_PREDICTION")
public class MatchPrediction {
    @TableId(value = "PREDICTION_ID", type = IdType.AUTO)
    private Long predictionId;
    private Long userId;
    private String matchId;
    private String predictedResult;
    private Integer predictedHomeScore;
    private Integer predictedAwayScore;
    private String status;
    private Integer pointsEarned;
    private String actualResult;
    private LocalDateTime createdAt;
    private LocalDateTime settledAt;
}