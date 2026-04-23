package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("USER_FOLLOW")
public class UserFollow {
    @TableId(value = "FOLLOW_ID", type = IdType.AUTO)
    private Long followId;
    private Long followerId;
    private Long followingId;
    private LocalDateTime createdAt;
}
