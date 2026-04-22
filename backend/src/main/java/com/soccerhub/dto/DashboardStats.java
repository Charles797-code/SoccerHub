package com.soccerhub.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DashboardStats {
    private Long totalUsers;
    private Long totalClubs;
    private Long totalPlayers;
    private Long totalMatches;
    private Long totalRatings;
    private Long todayMatches;
    private Long liveMatches;
}
