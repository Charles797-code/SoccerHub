package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("PLAYER")
public class Player {
    @TableId(value = "PLAYER_ID", type = IdType.AUTO)
    private Long playerId;
    private String name;
    private String nameCn;
    private String position;
    private Long clubId;
    private Integer jerseyNumber;
    private String nationality;
    private LocalDate birthDate;
    private Integer heightCm;
    private Integer weightKg;
    private String status;
    private Long marketValue;
    private String avatarUrl;
    private BigDecimal avgScore;
    private Integer totalRatings;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
