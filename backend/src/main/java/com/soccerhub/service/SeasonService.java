package com.soccerhub.service;

import com.soccerhub.entity.Season;
import com.soccerhub.mapper.SeasonMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SeasonService {
    private final SeasonMapper seasonMapper;
    private final JdbcTemplate jdbcTemplate;

    public List<Season> getAllSeasons() {
        return seasonMapper.findAllSeasons();
    }

    public List<Season> getSeasonsByLeague(String league) {
        return seasonMapper.findByLeague(league);
    }

    public Season getActiveSeason(String league) {
        return seasonMapper.findActiveByLeague(league);
    }

    public List<Season> getAllActiveSeasons() {
        return seasonMapper.findAllActive();
    }

    @Transactional
    public Season createSeason(Season season) {
        season.setCreatedAt(LocalDateTime.now());
        season.setUpdatedAt(LocalDateTime.now());
        season.setStatus("ACTIVE");
        seasonMapper.insert(season);
        return season;
    }

    @Transactional
    public void startNewSeason(String league, String seasonName, int totalRounds) {
        jdbcTemplate.execute("UPDATE SEASON SET STATUS = 'FINISHED' WHERE LEAGUE = '" + league + "' AND STATUS = 'ACTIVE'");

        Season season = new Season();
        season.setLeague(league);
        season.setSeasonName(seasonName);
        season.setStartYear(seasonName.split("-")[0]);
        season.setEndYear(seasonName.split("-")[1]);
        season.setTotalRounds(totalRounds);
        season.setStatus("ACTIVE");
        season.setCreatedAt(LocalDateTime.now());
        season.setUpdatedAt(LocalDateTime.now());
        seasonMapper.insert(season);
    }

    @Transactional
    public void resetSeasonData(String league) {
        jdbcTemplate.execute("DELETE FROM LEAGUE_STANDINGS WHERE LEAGUE = '" + league + "'");
        jdbcTemplate.execute("DELETE FROM PLAYER_SEASON_STATS WHERE LEAGUE = '" + league + "'");
        jdbcTemplate.execute("DELETE FROM MATCH_SCHEDULE WHERE LEAGUE = '" + league + "'");
    }

    @Transactional
    public void finishSeason(String league) {
        jdbcTemplate.execute("UPDATE SEASON SET STATUS = 'FINISHED' WHERE LEAGUE = '" + league + "' AND STATUS = 'ACTIVE'");
    }
}