package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.Post;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface PostMapper extends BaseMapper<Post> {
    
    @Update("UPDATE POST SET LIKE_COUNT = LIKE_COUNT + #{delta} WHERE POST_ID = #{postId}")
    int updateLikeCount(@Param("postId") Long postId, @Param("delta") int delta);
    
    @Update("UPDATE POST SET FAVORITE_COUNT = FAVORITE_COUNT + #{delta} WHERE POST_ID = #{postId}")
    int updateFavoriteCount(@Param("postId") Long postId, @Param("delta") int delta);
    
    @Update("UPDATE POST SET COMMENT_COUNT = COMMENT_COUNT + #{delta} WHERE POST_ID = #{postId}")
    int updateCommentCount(@Param("postId") Long postId, @Param("delta") int delta);
}
