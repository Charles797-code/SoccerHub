package com.soccerhub.dto;

import lombok.Data;

@Data
public class PlayerStatsRanking {
    private Long playerId;
    private String playerName;
    private String playerNameCn;
    private String position;
    private Long clubId;
    private String clubName;
    private String clubShort;
    private String clubLogo;
    private String league;
    private Integer goals;
    private Integer assists;
    private Integer yellowCards;
    private Integer redCards;
    private Integer appearances;
    private Long rank;
}
