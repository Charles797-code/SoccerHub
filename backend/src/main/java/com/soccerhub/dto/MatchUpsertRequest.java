package com.soccerhub.dto;

import lombok.Data;

@Data
public class MatchUpsertRequest {
    private String matchId;
    private Long homeClubId;
    private Long awayClubId;
    private java.time.LocalDateTime matchTime;
    private Integer homeScore;
    private Integer awayScore;
    private String status;
    private String round;
    private String venue;
    private String referee;
    private String league;
    private String season;
}
