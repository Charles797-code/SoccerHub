package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("RATING_RECORD")
public class RatingRecord {
    @TableId(value = "RECORD_ID", type = IdType.AUTO)
    private Long recordId;
    private Long userId;
    private Long targetId;
    private String targetType;
    private Integer score;
    private String commentText;
    private String ratingType;
    private String matchId;
    private Integer isCollapsed;
    private LocalDateTime createdAt;
}
