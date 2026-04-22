package com.soccerhub.dto;

import lombok.Data;
import java.util.List;

@Data
public class FinishMatchRequest {
    private String matchId;
    private Integer homeScore;
    private Integer awayScore;
    private List<MatchEventInput> events;

    @Data
    public static class MatchEventInput {
        private String eventType;
        private Long playerId;
        private Long assistPlayerId;
        private Long clubId;
        private Integer matchMinute;
    }
}
