package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("LEAGUE_STANDINGS")
public class LeagueStanding {
    @TableId(value = "STANDING_ID", type = IdType.AUTO)
    private Long standingId;
    private String league;
    private String season;
    private Long clubId;
    private Integer position;
    private Integer played;
    private Integer won;
    private Integer drawn;
    private Integer lost;
    private Integer goalsFor;
    private Integer goalsAgainst;
    private Integer goalDiff;
    private Integer points;
    private LocalDateTime updatedAt;
}
