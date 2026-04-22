package com.soccerhub.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ChatMessageRequest {
    @NotNull(message = "Content cannot be null")
    private String content;
    
    private String messageType = "TEXT";
}
