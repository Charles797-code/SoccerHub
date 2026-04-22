package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("AUDIT_LOG")
public class AuditLog {
    @TableId(value = "LOG_ID", type = IdType.AUTO)
    private Long logId;
    private Long userId;
    private String actionModule;
    private String actionType;
    private String targetType;
    private Long targetId;
    private String oldValue;
    private String newValue;
    private String ipAddress;
    private String userAgent;
    private LocalDateTime actionTime;
}
