package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("POST_FAVORITE")
public class PostFavorite {
    @TableId(value = "FAVORITE_ID", type = IdType.AUTO)
    private Long favoriteId;
    private Long postId;
    private Long userId;
    private LocalDateTime createdAt;
}
