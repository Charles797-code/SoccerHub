package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("MATCH_PLAYER_RATING")
public class MatchPlayerRating {
    @TableId(value = "RATING_ID", type = IdType.AUTO)
    private Long ratingId;
    private String matchId;
    private Long playerId;
    private Long userId;
    private Integer score;
    private LocalDateTime createdAt;
}
