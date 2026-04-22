package com.soccerhub.entity;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class PlayerView {
    private Long playerId;
    private String name;
    private String nameCn;
    private String position;
    private Long clubId;
    private Integer jerseyNumber;
    private String nationality;
    private String status;
    private BigDecimal avgScore;
    private Integer totalRatings;
    private String avatarUrl;
    private String clubName;
    private String league;
    private String clubShort;
    private String clubLogo;
    private Long globalRank;
    private Long leagueRank;
    private Long positionRank;
}
