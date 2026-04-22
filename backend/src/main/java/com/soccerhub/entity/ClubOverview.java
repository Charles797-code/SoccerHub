package com.soccerhub.entity;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class ClubOverview {
    private Long clubId;
    private String clubName;
    private String shortName;
    private String league;
    private String city;
    private String stadium;
    private Integer stadiumCapacity;
    private String logoUrl;
    private BigDecimal totalScore;
    private Long totalPlayers;
    private BigDecimal teamAverageScore;
    private String topPlayerName;
    private BigDecimal topPlayerScore;
    private String headCoachName;
    private Long followerCount;
    private Long fwCount;
    private Long mfCount;
    private Long dfCount;
    private Long gkCount;
}
