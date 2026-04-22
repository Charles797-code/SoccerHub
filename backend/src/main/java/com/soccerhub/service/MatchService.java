package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.MatchSchedule;
import com.soccerhub.config.RedisCacheWrapper;
import com.soccerhub.dto.MatchUpsertRequest;
import com.soccerhub.mapper.MatchScheduleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MatchService {

    private final MatchScheduleMapper matchMapper;
    private final RedisCacheWrapper cache;

    public Page<MatchSchedule> listMatches(int page, int pageSize, String league, String status, Long clubId, LocalDate date) {
        Page<MatchSchedule> p = new Page<>(page, pageSize);
        QueryWrapper<MatchSchedule> wrapper = new QueryWrapper<>();
        if (league != null && !league.isEmpty()) wrapper.eq("LEAGUE", league);
        if (status != null && !status.isEmpty()) wrapper.eq("STATUS", status);
        if (clubId != null) {
            wrapper.and(w -> w.eq("HOME_CLUB_ID", clubId).or().eq("AWAY_CLUB_ID", clubId));
        }
        if (date != null) {
            wrapper.ge("MATCH_TIME", date.atStartOfDay());
            wrapper.lt("MATCH_TIME", date.plusDays(1).atStartOfDay());
        }
        wrapper.orderByAsc("MATCH_TIME");
        return matchMapper.selectPage(p, wrapper);
    }

    public MatchSchedule getMatchById(String id) {
        return matchMapper.selectById(id);
    }

    public List<MatchSchedule> getTodayMatches() {
        LocalDate today = LocalDate.now();
        QueryWrapper<MatchSchedule> wrapper = new QueryWrapper<>();
        wrapper.ge("MATCH_TIME", today.atStartOfDay());
        wrapper.lt("MATCH_TIME", today.plusDays(1).atStartOfDay());
        wrapper.orderByAsc("MATCH_TIME");
        return matchMapper.selectList(wrapper);
    }

    public List<MatchSchedule> getLiveMatches() {
        QueryWrapper<MatchSchedule> wrapper = new QueryWrapper<>();
        wrapper.eq("STATUS", "IN_PROGRESS");
        wrapper.orderByAsc("MATCH_TIME");
        return matchMapper.selectList(wrapper);
    }

    public List<MatchSchedule> getUpcomingMatches(int limit) {
        QueryWrapper<MatchSchedule> wrapper = new QueryWrapper<>();
        wrapper.eq("STATUS", "PENDING");
        wrapper.ge("MATCH_TIME", LocalDateTime.now());
        wrapper.orderByAsc("MATCH_TIME");
        wrapper.last("FETCH FIRST " + limit + " ROWS ONLY");
        return matchMapper.selectList(wrapper);
    }

    @SuppressWarnings("unchecked")
    public MatchSchedule upsertMatch(MatchUpsertRequest request) {
        MatchSchedule match = matchMapper.selectById(request.getMatchId());
        if (match == null) {
            match = new MatchSchedule();
        }
        match.setMatchId(request.getMatchId());
        match.setHomeClubId(request.getHomeClubId());
        match.setAwayClubId(request.getAwayClubId());
        match.setMatchTime(request.getMatchTime());
        match.setHomeScore(request.getHomeScore());
        match.setAwayScore(request.getAwayScore());
        match.setStatus(request.getStatus());
        match.setRound(request.getRound());
        match.setVenue(request.getVenue());
        match.setReferee(request.getReferee());
        match.setLeague(request.getLeague());
        match.setSeason(request.getSeason());
        match.setUpdatedAt(LocalDateTime.now());

        if (matchMapper.selectById(request.getMatchId()) != null) {
            matchMapper.updateById(match);
        } else {
            matchMapper.insert(match);
        }

        // Invalidate cache
        String cacheKey = "match:" + request.getMatchId();
        cache.delete(cacheKey);
        cache.delete("matches:live");

        return match;
    }

    public List<MatchSchedule> getMatchesByDateRange(LocalDate startDate, LocalDate endDate) {
        QueryWrapper<MatchSchedule> wrapper = new QueryWrapper<>();
        wrapper.ge("MATCH_TIME", startDate.atStartOfDay());
        wrapper.le("MATCH_TIME", endDate.atTime(23, 59, 59));
        wrapper.orderByAsc("MATCH_TIME");
        return matchMapper.selectList(wrapper);
    }

    public void deleteMatch(String matchId) {
        matchMapper.deleteById(matchId);
        // Invalidate cache
        cache.delete("match:" + matchId);
        cache.delete("matches:live");
    }
}
