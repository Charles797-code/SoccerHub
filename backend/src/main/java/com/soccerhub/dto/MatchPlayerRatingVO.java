package com.soccerhub.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class MatchPlayerRatingVO {
    private Long playerId;
    private String playerName;
    private String playerNameCn;
    private String position;
    private Integer jerseyNumber;
    private Long clubId;
    private BigDecimal avgScore;
    private Integer totalRatings;
    private Integer myScore;
}
