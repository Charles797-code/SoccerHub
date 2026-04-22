package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("MATCH_EVENT")
public class MatchEvent {
    @TableId(value = "EVENT_ID", type = IdType.AUTO)
    private Long eventId;
    private String matchId;
    private String eventType;
    private Long playerId;
    private Long assistPlayerId;
    private Long clubId;
    private Integer matchMinute;
    private LocalDateTime createdAt;
}
