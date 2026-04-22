package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("MATCH_SCHEDULE")
public class MatchSchedule {
    @TableId(value = "MATCH_ID", type = IdType.INPUT)
    private String matchId;
    private Long homeClubId;
    private Long awayClubId;
    private LocalDateTime matchTime;
    private Integer homeScore;
    private Integer awayScore;
    private String status;
    private String round;
    private String venue;
    private String referee;
    private String league;
    private String season;
    private LocalDateTime updatedAt;
}
