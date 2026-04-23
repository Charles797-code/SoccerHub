package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.PostLike;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface PostLikeMapper extends BaseMapper<PostLike> {
    
    @Select("SELECT COUNT(*) FROM POST_LIKE WHERE POST_ID = #{postId} AND USER_ID = #{userId}")
    int hasLiked(@Param("postId") Long postId, @Param("userId") Long userId);
}
