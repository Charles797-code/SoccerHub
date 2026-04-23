package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("CIRCLE")
public class Circle {
    @TableId(value = "CIRCLE_ID", type = IdType.AUTO)
    private Long circleId;
    private Long clubId;
    private String name;
    private String description;
    private String logoUrl;
    private Integer memberCount;
    private Integer postCount;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
