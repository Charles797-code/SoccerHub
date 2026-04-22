package com.soccerhub.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ChatMessageVO {
    private Long messageId;
    private Long clubId;
    private Long userId;
    private String username;
    private String nickname;
    private String fanClub;
    private String content;
    private String messageType;
    private LocalDateTime createdAt;
}
