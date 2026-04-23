package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("CIRCLE_MEMBER")
public class CircleMember {
    @TableId(value = "MEMBER_ID", type = IdType.AUTO)
    private Long memberId;
    private Long circleId;
    private Long userId;
    private LocalDateTime joinedAt;
}
