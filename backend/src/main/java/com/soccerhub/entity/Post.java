package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("POST")
public class Post {
    @TableId(value = "POST_ID", type = IdType.AUTO)
    private Long postId;
    private Long userId;
    private String content;
    private String imageUrls;
    private Long clubId;
    private Long circleId;
    private Integer likeCount;
    private Integer favoriteCount;
    private Integer commentCount;
    private Integer isPinned;
    private Integer isEssence;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
