package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("PLAYER_SEASON_STATS")
public class PlayerSeasonStats {
    @TableId(value = "STATS_ID", type = IdType.AUTO)
    private Long statsId;
    private Long playerId;
    private String season;
    private String league;
    private Long clubId;
    private Integer goals;
    private Integer assists;
    private Integer yellowCards;
    private Integer redCards;
    private Integer appearances;
    private Integer minutesPlayed;
    private LocalDateTime updatedAt;
}
