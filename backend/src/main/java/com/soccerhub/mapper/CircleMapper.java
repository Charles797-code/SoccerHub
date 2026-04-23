package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.Circle;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface CircleMapper extends BaseMapper<Circle> {
    
    @Select("SELECT * FROM CIRCLE WHERE CLUB_ID = #{clubId}")
    Circle findByClubId(@Param("clubId") Long clubId);
    
    @Update("UPDATE CIRCLE SET MEMBER_COUNT = MEMBER_COUNT + #{delta} WHERE CIRCLE_ID = #{circleId}")
    int updateMemberCount(@Param("circleId") Long circleId, @Param("delta") int delta);
    
    @Update("UPDATE CIRCLE SET POST_COUNT = POST_COUNT + #{delta} WHERE CIRCLE_ID = #{circleId}")
    int updatePostCount(@Param("circleId") Long circleId, @Param("delta") int delta);
}
