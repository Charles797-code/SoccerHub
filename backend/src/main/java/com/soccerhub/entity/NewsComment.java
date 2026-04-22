package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("NEWS_COMMENT")
public class NewsComment {
    @TableId(value = "COMMENT_ID", type = IdType.AUTO)
    private Long commentId;
    private Long articleId;
    private Long userId;
    private String content;
    private Integer isDeleted;
    private Long deletedBy;
    private LocalDateTime deletedAt;
    private LocalDateTime createdAt;
}
