package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("POST_LIKE")
public class PostLike {
    @TableId(value = "LIKE_ID", type = IdType.AUTO)
    private Long likeId;
    private Long postId;
    private Long userId;
    private LocalDateTime createdAt;
}
