package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.MatchSchedule;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MatchScheduleMapper extends BaseMapper<MatchSchedule> {
}
