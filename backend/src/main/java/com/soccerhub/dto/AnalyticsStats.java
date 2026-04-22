package com.soccerhub.dto;

import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class AnalyticsStats {
    private Overview overview;
    private List<LeagueStats> leagueStats;
    private List<PositionDist> positionDist;
    private List<MonthlyMatch> monthlyMatches;

    @Data
    public static class Overview {
        private Long totalUsers;
        private Long totalClubs;
        private Long totalPlayers;
        private Long totalMatches;
        private Long totalRatings;
        private Long finishedMatches;
        private Long pendingMatches;
        private Long inProgressMatches;
        private Long totalGoals;
        private Long totalAssists;
        private Long totalYellowCards;
        private Long totalRedCards;
        private Long totalNews;
        private Long activePlayers;
        private Long injuredPlayers;
    }

    @Data
    public static class LeagueStats {
        private String league;
        private Integer clubCount;
        private Integer playerCount;
        private Integer matchCount;
        private Integer totalGoals;
    }

    @Data
    public static class PositionDist {
        private String position;
        private Integer count;
    }

    @Data
    public static class MonthlyMatch {
        private String month;
        private Integer matchCount;
        private Integer goalCount;
    }
}
