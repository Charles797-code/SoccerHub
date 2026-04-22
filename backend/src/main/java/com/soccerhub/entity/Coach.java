package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("COACH")
public class Coach {
    @TableId(value = "COACH_ID", type = IdType.AUTO)
    private Long coachId;
    private String name;
    private String nameCn;
    private Long clubId;
    private String role;
    private Integer isHeadCoach;
    private String nationality;
    private LocalDate birthDate;
    private String avatarUrl;
    private BigDecimal avgScore;
    private Integer totalRatings;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
