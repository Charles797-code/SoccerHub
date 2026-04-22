package com.soccerhub.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PlayerRanking {
    private Long playerId;
    private String name;
    private String nameCn;
    private String position;
    private Long clubId;
    private String clubName;
    private Integer jerseyNumber;
    private String nationality;
    private String birthDate;
    private Integer heightCm;
    private Integer weightKg;
    private String status;
    private Long marketValue;
    private String avatarUrl;
    private BigDecimal avgScore;
    private Integer totalRatings;
    private String league;
}
