package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.UserFollow;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface UserFollowMapper extends BaseMapper<UserFollow> {
    
    @Select("SELECT COUNT(*) FROM USER_FOLLOW WHERE FOLLOWER_ID = #{userId}")
    int countFollowing(@Param("userId") Long userId);
    
    @Select("SELECT COUNT(*) FROM USER_FOLLOW WHERE FOLLOWING_ID = #{userId}")
    int countFollowers(@Param("userId") Long userId);
    
    @Select("SELECT COUNT(*) FROM USER_FOLLOW WHERE FOLLOWER_ID = #{followerId} AND FOLLOWING_ID = #{followingId}")
    int isFollowing(@Param("followerId") Long followerId, @Param("followingId") Long followingId);
}
