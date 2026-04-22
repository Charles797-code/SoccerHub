package com.soccerhub.entity;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class ChatMessageView {
    private Long messageId;
    private Long clubId;
    private Long userId;
    private String userNickname;
    private String userAvatar;
    private String userRole;
    private String content;
    private String messageType;
    private Integer isDeleted;
    private Integer isCollapsed;
    private LocalDateTime createdAt;
    private Integer isRecent;
}
