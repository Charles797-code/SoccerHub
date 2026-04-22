package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("CLUB_CHAT_MESSAGE")
public class ClubChatMessage {
    @TableId(value = "MESSAGE_ID", type = IdType.AUTO)
    private Long messageId;
    private Long clubId;
    private Long userId;
    private String content;
    private String messageType;
    private Integer isDeleted;
    private Long deletedBy;
    private LocalDateTime deletedAt;
    private LocalDateTime createdAt;
}
