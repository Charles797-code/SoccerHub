package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.FinishMatchRequest;
import com.soccerhub.dto.PlayerStatsRanking;
import com.soccerhub.entity.*;
import com.soccerhub.mapper.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.TransientDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class MatchEventService {

    private final MatchEventMapper matchEventMapper;
    private final PlayerSeasonStatsMapper statsMapper;
    private final MatchScheduleMapper matchMapper;
    private final LeagueStandingMapper standingMapper;
    private final PlayerMapper playerMapper;
    private final ClubMapper clubMapper;
    private final JdbcTemplate jdbcTemplate;

    @Transactional
    public MatchSchedule finishMatch(FinishMatchRequest request) {
        MatchSchedule match = matchMapper.selectById(request.getMatchId());
        if (match == null) throw new RuntimeException("比赛不存在");
        if ("FINISHED".equals(match.getStatus())) throw new RuntimeException("比赛已结束，不能重复操作");

        match.setHomeScore(request.getHomeScore());
        match.setAwayScore(request.getAwayScore());
        match.setStatus("FINISHED");
        match.setUpdatedAt(LocalDateTime.now());

        if (request.getEvents() != null) {
            for (int attempt = 0; attempt < 3; attempt++) {
                try {
                    for (FinishMatchRequest.MatchEventInput input : request.getEvents()) {
                        MatchEvent event = new MatchEvent();
                        event.setMatchId(request.getMatchId());
                        event.setEventType(input.getEventType());
                        event.setPlayerId(input.getPlayerId());
                        event.setAssistPlayerId(input.getAssistPlayerId());
                        event.setClubId(input.getClubId());
                        event.setMatchMinute(input.getMatchMinute());
                        event.setCreatedAt(LocalDateTime.now());
                        matchEventMapper.insert(event);
                    }
                    break;
                } catch (TransientDataAccessException e) {
                    if (attempt == 2) throw new RuntimeException("插入比赛事件失败（死锁），请重试", e);
                    try { Thread.sleep(100L * (attempt + 1)); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
                }
            }
        }

        for (int attempt = 0; attempt < 3; attempt++) {
            try {
                matchMapper.updateById(match);
                break;
            } catch (TransientDataAccessException e) {
                if (attempt == 2) throw new RuntimeException("更新比赛状态失败（死锁），请重试", e);
                try { Thread.sleep(100L * (attempt + 1)); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
            }
        }

        updateStandings(match);
        updatePlayerStats(match, request.getEvents());

        return match;
    }

    private void updateStandings(MatchSchedule match) {
        String league = match.getLeague();
        String season = match.getSeason();
        if (league == null || season == null) return;

        int homeScore = match.getHomeScore() != null ? match.getHomeScore() : 0;
        int awayScore = match.getAwayScore() != null ? match.getAwayScore() : 0;

        updateClubStanding(league, season, match.getHomeClubId(), homeScore, awayScore);
        updateClubStanding(league, season, match.getAwayClubId(), awayScore, homeScore);

        recalculatePositions(league, season);
    }

    private void updateClubStanding(String league, String season, Long clubId, int gf, int ga) {
        QueryWrapper<LeagueStanding> wrapper = new QueryWrapper<>();
        wrapper.eq("LEAGUE", league).eq("SEASON", season).eq("CLUB_ID", clubId);
        LeagueStanding standing = standingMapper.selectOne(wrapper);

        if (standing == null) {
            standing = new LeagueStanding();
            standing.setLeague(league);
            standing.setSeason(season);
            standing.setClubId(clubId);
            standing.setPlayed(1);
            standing.setWon(gf > ga ? 1 : 0);
            standing.setDrawn(gf == ga ? 1 : 0);
            standing.setLost(gf < ga ? 1 : 0);
            standing.setGoalsFor(gf);
            standing.setGoalsAgainst(ga);
            standing.setGoalDiff(gf - ga);
            standing.setPoints(gf > ga ? 3 : (gf == ga ? 1 : 0));
            standing.setUpdatedAt(LocalDateTime.now());
            standingMapper.insert(standing);
        } else {
            standing.setPlayed(standing.getPlayed() + 1);
            standing.setWon(standing.getWon() + (gf > ga ? 1 : 0));
            standing.setDrawn(standing.getDrawn() + (gf == ga ? 1 : 0));
            standing.setLost(standing.getLost() + (gf < ga ? 1 : 0));
            standing.setGoalsFor(standing.getGoalsFor() + gf);
            standing.setGoalsAgainst(standing.getGoalsAgainst() + ga);
            standing.setGoalDiff(standing.getGoalsFor() + gf - standing.getGoalsAgainst() - ga);
            standing.setPoints(standing.getPoints() + (gf > ga ? 3 : (gf == ga ? 1 : 0)));
            standing.setUpdatedAt(LocalDateTime.now());
            standingMapper.updateById(standing);
        }
    }

    private void recalculatePositions(String league, String season) {
        QueryWrapper<LeagueStanding> wrapper = new QueryWrapper<>();
        wrapper.eq("LEAGUE", league).eq("SEASON", season);
        wrapper.orderByDesc("POINTS", "GOAL_DIFF", "GOALS_FOR");
        List<LeagueStanding> all = standingMapper.selectList(wrapper);
        for (int i = 0; i < all.size(); i++) {
            LeagueStanding s = all.get(i);
            s.setPosition(i + 1);
            standingMapper.updateById(s);
        }
    }

    private void updatePlayerStats(MatchSchedule match, List<FinishMatchRequest.MatchEventInput> events) {
        String league = match.getLeague();
        String season = match.getSeason();
        if (league == null || season == null || events == null) return;

        Set<Long> appearedPlayers = new HashSet<>();
        for (FinishMatchRequest.MatchEventInput event : events) {
            if (event.getPlayerId() != null) appearedPlayers.add(event.getPlayerId());
            if (event.getAssistPlayerId() != null) appearedPlayers.add(event.getAssistPlayerId());
        }

        for (Long playerId : appearedPlayers) {
            Player player = playerMapper.selectById(playerId);
            if (player == null) continue;
            Long clubId = player.getClubId();
            if (clubId == null) clubId = findClubFromEvents(playerId, events);

            ensureStatsEntry(playerId, season, league, clubId);
        }

        for (FinishMatchRequest.MatchEventInput event : events) {
            if (event.getPlayerId() == null) continue;
            Player player = playerMapper.selectById(event.getPlayerId());
            if (player == null) continue;
            Long clubId = player.getClubId();
            if (clubId == null) clubId = findClubFromEvents(event.getPlayerId(), events);

            QueryWrapper<PlayerSeasonStats> wrapper = new QueryWrapper<>();
            wrapper.eq("PLAYER_ID", event.getPlayerId()).eq("SEASON", season).eq("LEAGUE", league);
            PlayerSeasonStats stats = statsMapper.selectOne(wrapper);
            if (stats == null) continue;

            switch (event.getEventType()) {
                case "GOAL":
                case "PENALTY":
                    stats.setGoals(stats.getGoals() + 1);
                    break;
                case "OWN_GOAL":
                    break;
                case "YELLOW_CARD":
                    stats.setYellowCards(stats.getYellowCards() + 1);
                    break;
                case "RED_CARD":
                    stats.setRedCards(stats.getRedCards() + 1);
                    break;
            }
            stats.setUpdatedAt(LocalDateTime.now());
            statsMapper.updateById(stats);

            if ("GOAL".equals(event.getEventType()) || "PENALTY".equals(event.getEventType())) {
                if (event.getAssistPlayerId() != null) {
                    QueryWrapper<PlayerSeasonStats> assistWrapper = new QueryWrapper<>();
                    assistWrapper.eq("PLAYER_ID", event.getAssistPlayerId()).eq("SEASON", season).eq("LEAGUE", league);
                    PlayerSeasonStats assistStats = statsMapper.selectOne(assistWrapper);
                    if (assistStats != null) {
                        assistStats.setAssists(assistStats.getAssists() + 1);
                        assistStats.setUpdatedAt(LocalDateTime.now());
                        statsMapper.updateById(assistStats);
                    }
                }
            }
        }

        for (Long playerId : appearedPlayers) {
            Player player = playerMapper.selectById(playerId);
            if (player == null) continue;
            Long clubId = player.getClubId();
            if (clubId == null) clubId = findClubFromEvents(playerId, events);

            QueryWrapper<PlayerSeasonStats> wrapper = new QueryWrapper<>();
            wrapper.eq("PLAYER_ID", playerId).eq("SEASON", season).eq("LEAGUE", league);
            PlayerSeasonStats stats = statsMapper.selectOne(wrapper);
            if (stats != null) {
                stats.setAppearances(stats.getAppearances() + 1);
                stats.setUpdatedAt(LocalDateTime.now());
                statsMapper.updateById(stats);
            }
        }
    }

    private Long findClubFromEvents(Long playerId, List<FinishMatchRequest.MatchEventInput> events) {
        for (FinishMatchRequest.MatchEventInput e : events) {
            if (playerId.equals(e.getPlayerId()) && e.getClubId() != null) return e.getClubId();
            if (playerId.equals(e.getAssistPlayerId()) && e.getClubId() != null) return e.getClubId();
        }
        return null;
    }

    private void ensureStatsEntry(Long playerId, String season, String league, Long clubId) {
        if (clubId == null) return;
        QueryWrapper<PlayerSeasonStats> wrapper = new QueryWrapper<>();
        wrapper.eq("PLAYER_ID", playerId).eq("SEASON", season).eq("LEAGUE", league);
        PlayerSeasonStats existing = statsMapper.selectOne(wrapper);
        if (existing == null) {
            PlayerSeasonStats stats = new PlayerSeasonStats();
            stats.setPlayerId(playerId);
            stats.setSeason(season);
            stats.setLeague(league);
            stats.setClubId(clubId);
            stats.setGoals(0);
            stats.setAssists(0);
            stats.setYellowCards(0);
            stats.setRedCards(0);
            stats.setAppearances(0);
            stats.setMinutesPlayed(0);
            stats.setUpdatedAt(LocalDateTime.now());
            statsMapper.insert(stats);
        }
    }

    public List<MatchEvent> getMatchEvents(String matchId) {
        QueryWrapper<MatchEvent> wrapper = new QueryWrapper<>();
        wrapper.eq("MATCH_ID", matchId).orderByAsc("MATCH_MINUTE");
        return matchEventMapper.selectList(wrapper);
    }

    public Page<PlayerStatsRanking> getScorerRankings(String league, String season, int page, int pageSize) {
        return getStatsRankings(league, season, "GOALS", page, pageSize);
    }

    public Page<PlayerStatsRanking> getAssistRankings(String league, String season, int page, int pageSize) {
        return getStatsRankings(league, season, "ASSISTS", page, pageSize);
    }

    public Page<PlayerStatsRanking> getYellowCardRankings(String league, String season, int page, int pageSize) {
        return getStatsRankings(league, season, "YELLOW_CARDS", page, pageSize);
    }

    public Page<PlayerStatsRanking> getRedCardRankings(String league, String season, int page, int pageSize) {
        return getStatsRankings(league, season, "RED_CARDS", page, pageSize);
    }

    private Page<PlayerStatsRanking> getStatsRankings(String league, String season, String sortBy, int page, int pageSize) {
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT s.PLAYER_ID, p.NAME AS PLAYER_NAME, p.NAME_CN AS PLAYER_NAME_CN, ");
        sql.append("p.POSITION, s.CLUB_ID, c.NAME AS CLUB_NAME, c.SHORT_NAME AS CLUB_SHORT, ");
        sql.append("c.LOGO_URL AS CLUB_LOGO, s.LEAGUE, s.GOALS, s.ASSISTS, s.YELLOW_CARDS, ");
        sql.append("s.RED_CARDS, s.APPEARANCES, p.AVATAR_URL AS AVATAR_URL, ");
        sql.append("ROW_NUMBER() OVER (ORDER BY s.").append(sortBy).append(" DESC, s.GOALS DESC) AS RNK ");
        sql.append("FROM PLAYER_SEASON_STATS s ");
        sql.append("JOIN PLAYER p ON s.PLAYER_ID = p.PLAYER_ID ");
        sql.append("JOIN CLUB c ON s.CLUB_ID = c.CLUB_ID ");
        sql.append("WHERE 1=1 ");
        if (league != null && !league.isEmpty()) sql.append("AND s.LEAGUE = ? ");
        if (season != null && !season.isEmpty()) sql.append("AND s.SEASON = ? ");
        sql.append("AND s.").append(sortBy).append(" > 0 ");

        String countSql = "SELECT COUNT(*) FROM (" + sql + ")";
        String dataSql = "SELECT * FROM (SELECT a.*, ROWNUM RN FROM (" + sql + " ORDER BY " + sortBy + " DESC, s.GOALS DESC) a WHERE ROWNUM <= ?) WHERE RN > ?";

        List<Object> countParams = new ArrayList<>();
        if (league != null && !league.isEmpty()) countParams.add(league);
        if (season != null && !season.isEmpty()) countParams.add(season);

        Long total = jdbcTemplate.queryForObject(countSql, Long.class, countParams.toArray());

        List<Object> dataParams = new ArrayList<>(countParams);
        int offset = (page - 1) * pageSize;
        dataParams.add(offset + pageSize);
        dataParams.add(offset);

        List<Map<String, Object>> rows = jdbcTemplate.queryForList(dataSql, dataParams.toArray());

        List<PlayerStatsRanking> rankings = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            PlayerStatsRanking r = new PlayerStatsRanking();
            r.setPlayerId(((Number) row.get("PLAYER_ID")).longValue());
            r.setPlayerName((String) row.get("PLAYER_NAME"));
            r.setPlayerNameCn((String) row.get("PLAYER_NAME_CN"));
            r.setPosition((String) row.get("POSITION"));
            r.setClubId(((Number) row.get("CLUB_ID")).longValue());
            r.setClubName((String) row.get("CLUB_NAME"));
            r.setClubShort((String) row.get("CLUB_SHORT"));
            r.setClubLogo((String) row.get("CLUB_LOGO"));
            r.setLeague((String) row.get("LEAGUE"));
            r.setGoals(row.get("GOALS") != null ? ((Number) row.get("GOALS")).intValue() : 0);
            r.setAssists(row.get("ASSISTS") != null ? ((Number) row.get("ASSISTS")).intValue() : 0);
            r.setYellowCards(row.get("YELLOW_CARDS") != null ? ((Number) row.get("YELLOW_CARDS")).intValue() : 0);
            r.setRedCards(row.get("RED_CARDS") != null ? ((Number) row.get("RED_CARDS")).intValue() : 0);
            r.setAppearances(row.get("APPEARANCES") != null ? ((Number) row.get("APPEARANCES")).intValue() : 0);
            r.setRank(row.get("RNK") != null ? ((Number) row.get("RNK")).longValue() : 0L);
            r.setAvatarUrl((String) row.get("AVATAR_URL"));
            rankings.add(r);
        }

        Page<PlayerStatsRanking> result = new Page<>(page, pageSize);
        result.setRecords(rankings);
        result.setTotal(total != null ? total : 0);
        return result;
    }
}
