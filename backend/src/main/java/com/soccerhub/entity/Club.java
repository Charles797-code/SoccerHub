package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("CLUB")
public class Club {
    @TableId(value = "CLUB_ID", type = IdType.AUTO)
    private Long clubId;
    private String name;
    private String shortName;
    private String league;
    private String city;
    private String country;
    private String stadium;
    private LocalDate establishDate;
    private Integer stadiumCapacity;
    private String logoUrl;
    private String description;
    private BigDecimal totalScore;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
