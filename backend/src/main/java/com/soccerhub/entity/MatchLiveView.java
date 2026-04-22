package com.soccerhub.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class MatchLiveView {
    private String matchId;
    private LocalDateTime matchTime;
    private String status;
    private Integer homeScore;
    private Integer awayScore;
    private String round;
    private String venue;
    private String league;
    private String season;
    private String homeTeamName;
    private String homeTeamShort;
    private String homeTeamLogo;
    private String awayTeamName;
    private String awayTeamShort;
    private String awayTeamLogo;
    private String liveMinute;
    private LocalDateTime fullTimeMarker;
}
