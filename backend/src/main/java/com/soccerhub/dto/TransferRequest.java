package com.soccerhub.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class TransferRequest {
    @NotNull(message = "Player ID is required")
    private Long playerId;
    
    @NotNull(message = "New club ID is required")
    private Long newClubId;
    
    @NotNull(message = "Transfer type is required")
    private String transferType;
    
    private Long transferFee;
    private String season;
    private String notes;
}
