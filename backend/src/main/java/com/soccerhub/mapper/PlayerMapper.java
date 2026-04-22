package com.soccerhub.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.PlayerRanking;
import com.soccerhub.entity.Player;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface PlayerMapper extends BaseMapper<Player> {
    Page<PlayerRanking> selectRankingsWithLeague(
            Page<PlayerRanking> page,
            @Param("league") String league,
            @Param("position") String position);
}
