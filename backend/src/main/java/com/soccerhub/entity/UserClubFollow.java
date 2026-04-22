package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("USER_CLUB_FOLLOW")
public class UserClubFollow {
    private Long userId;
    private Long clubId;
    private Integer isPrimary;
    private LocalDateTime followTime;
}
