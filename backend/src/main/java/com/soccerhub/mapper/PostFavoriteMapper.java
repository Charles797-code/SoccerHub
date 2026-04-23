package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.PostFavorite;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface PostFavoriteMapper extends BaseMapper<PostFavorite> {
    
    @Select("SELECT COUNT(*) FROM POST_FAVORITE WHERE POST_ID = #{postId} AND USER_ID = #{userId}")
    int hasFavorited(@Param("postId") Long postId, @Param("userId") Long userId);
}
