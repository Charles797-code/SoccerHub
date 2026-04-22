package com.soccerhub.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class RatingRequest {
    @NotNull(message = "Target ID cannot be null")
    private Long targetId;
    
    @NotNull(message = "Target type cannot be null")
    private String targetType;
    
    @NotNull(message = "Score cannot be null")
    @Min(value = 1, message = "Score must be at least 1")
    @Max(value = 10, message = "Score cannot exceed 10")
    private Integer score;
    
    @Size(max = 500, message = "Comment cannot exceed 500 characters")
    private String commentText;
    
    private String ratingType = "GENERAL";
    
    private String matchId;
    
    @NotNull(message = "Club ID is required for rating")
    private Long clubId;
}
