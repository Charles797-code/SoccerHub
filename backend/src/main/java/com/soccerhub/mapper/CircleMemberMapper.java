package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.CircleMember;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CircleMemberMapper extends BaseMapper<CircleMember> {
    
    @Select("SELECT COUNT(*) FROM CIRCLE_MEMBER WHERE CIRCLE_ID = #{circleId} AND USER_ID = #{userId}")
    int isMember(@Param("circleId") Long circleId, @Param("userId") Long userId);
}
