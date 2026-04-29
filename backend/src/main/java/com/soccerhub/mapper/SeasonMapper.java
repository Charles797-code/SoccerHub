package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.soccerhub.entity.Season;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import java.util.List;

@Mapper
public interface SeasonMapper extends BaseMapper<Season> {

    @Select("SELECT SEASON_ID, LEAGUE, SEASON_NAME, START_YEAR, END_YEAR, STATUS, TOTAL_ROUNDS, CREATED_AT, UPDATED_AT FROM SEASON WHERE LEAGUE = #{league} ORDER BY SEASON_ID DESC")
    List<Season> findByLeague(@Param("league") String league);

    @Select("SELECT SEASON_ID, LEAGUE, SEASON_NAME, START_YEAR, END_YEAR, STATUS, TOTAL_ROUNDS, CREATED_AT, UPDATED_AT FROM SEASON WHERE STATUS = 'ACTIVE' AND LEAGUE = #{league}")
    Season findActiveByLeague(@Param("league") String league);

    @Select("SELECT SEASON_ID, LEAGUE, SEASON_NAME, START_YEAR, END_YEAR, STATUS, TOTAL_ROUNDS, CREATED_AT, UPDATED_AT FROM SEASON WHERE STATUS = 'ACTIVE'")
    List<Season> findAllActive();

    @Select("SELECT SEASON_ID, LEAGUE, SEASON_NAME, START_YEAR, END_YEAR, STATUS, TOTAL_ROUNDS, CREATED_AT, UPDATED_AT FROM SEASON ORDER BY SEASON_ID DESC")
    List<Season> findAllSeasons();

    @Select("UPDATE SEASON SET STATUS = 'FINISHED' WHERE LEAGUE = #{league}")
    void finishSeason(@Param("league") String league);
}