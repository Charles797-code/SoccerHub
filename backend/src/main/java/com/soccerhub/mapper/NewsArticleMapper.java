package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.NewsArticle;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface NewsArticleMapper extends BaseMapper<NewsArticle> {
}
