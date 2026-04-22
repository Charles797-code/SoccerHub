package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("SYSTEM_DICTIONARY")
public class SystemDictionary {
    @TableId(value = "DICT_ID", type = IdType.AUTO)
    private Long dictId;
    private String dictType;
    private String dictKey;
    private String dictValue;
    private Integer sortOrder;
    private Integer isEnabled;
    private String description;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
