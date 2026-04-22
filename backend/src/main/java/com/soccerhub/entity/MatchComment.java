package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("MATCH_COMMENT")
public class MatchComment {
    @TableId(value = "COMMENT_ID", type = IdType.AUTO)
    private Long commentId;
    private String matchId;
    private Long userId;
    private String content;
    private Integer isDeleted;
    private Long deletedBy;
    private LocalDateTime deletedAt;
    private LocalDateTime createdAt;
}
