package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.MatchComment;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface MatchCommentMapper extends BaseMapper<MatchComment> {
}
