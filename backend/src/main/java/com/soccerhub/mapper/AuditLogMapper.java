package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.AuditLog;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AuditLogMapper extends BaseMapper<AuditLog> {
}
