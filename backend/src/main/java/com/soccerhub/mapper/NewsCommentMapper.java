package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.NewsComment;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface NewsCommentMapper extends BaseMapper<NewsComment> {
}
