package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("SYS_USER")
public class SysUser {
    @TableId(value = "USER_ID", type = IdType.AUTO)
    private Long userId;
    private String username;
    private String passwordHash;
    private String nickname;
    private String email;
    private String avatarUrl;
    @TableField("ROLE")
    private String role;
    private String status;
    private Long managedClubId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime lastLoginAt;
}
