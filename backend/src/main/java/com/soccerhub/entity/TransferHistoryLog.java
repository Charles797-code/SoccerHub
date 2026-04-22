package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("TRANSFER_HISTORY_LOG")
public class TransferHistoryLog {
    @TableId(value = "LOG_ID", type = IdType.AUTO)
    private Long logId;
    private Long playerId;
    private Long oldClubId;
    private Long newClubId;
    private String transferType;
    private Long transferFee;
    private String season;
    private Long actionUserId;
    private LocalDateTime actionTime;
    private String notes;
}
