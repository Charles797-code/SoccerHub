package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("SEASON")
public class Season {
    @TableId(value = "SEASON_ID", type = IdType.AUTO)
    private Long seasonId;
    private String league;
    private String seasonName;
    private String startYear;
    private String endYear;
    private String status;
    private Integer totalRounds;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}