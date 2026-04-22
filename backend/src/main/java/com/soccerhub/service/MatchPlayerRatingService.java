package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.soccerhub.dto.MatchPlayerRatingVO;
import com.soccerhub.entity.MatchPlayerRating;
import com.soccerhub.entity.Player;
import com.soccerhub.mapper.MatchPlayerRatingMapper;
import com.soccerhub.mapper.PlayerMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MatchPlayerRatingService {

    private final MatchPlayerRatingMapper ratingMapper;
    private final PlayerMapper playerMapper;
    private final JdbcTemplate jdbcTemplate;

    public void ensureTableExists() {
        try {
            jdbcTemplate.execute("SELECT 1 FROM MATCH_PLAYER_RATING WHERE 1=0");
        } catch (Exception e) {
            log.info("MATCH_PLAYER_RATING table not found, creating...");
            jdbcTemplate.execute("""
                CREATE TABLE MATCH_PLAYER_RATING (
                    RATING_ID   NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    MATCH_ID    VARCHAR2(50)  NOT NULL,
                    PLAYER_ID   NUMBER        NOT NULL,
                    USER_ID     NUMBER        NOT NULL,
                    SCORE       NUMBER        NOT NULL,
                    CREATED_AT  TIMESTAMP     DEFAULT SYSTIMESTAMP,
                    CONSTRAINT UK_MATCH_PLAYER_USER UNIQUE (MATCH_ID, PLAYER_ID, USER_ID)
                )
                """);
            jdbcTemplate.execute("CREATE INDEX IDX_MPR_MATCH ON MATCH_PLAYER_RATING(MATCH_ID)");
            log.info("MATCH_PLAYER_RATING table created successfully");
        }
    }

    public List<MatchPlayerRatingVO> getMatchPlayerRatings(String matchId, Long clubId, Long userId) {
        ensureTableExists();

        QueryWrapper<Player> pw = new QueryWrapper<>();
        pw.eq("CLUB_ID", clubId);
        pw.eq("STATUS", "ACTIVE");
        pw.orderByAsc("POSITION", "JERSEY_NUMBER");
        List<Player> players = playerMapper.selectList(pw);

        if (players.isEmpty()) return Collections.emptyList();

        List<Long> playerIds = players.stream().map(Player::getPlayerId).collect(Collectors.toList());

        QueryWrapper<MatchPlayerRating> rw = new QueryWrapper<>();
        rw.eq("MATCH_ID", matchId);
        rw.in("PLAYER_ID", playerIds);
        List<MatchPlayerRating> allRatings = ratingMapper.selectList(rw);

        Map<Long, List<MatchPlayerRating>> ratingsByPlayer = allRatings.stream()
                .collect(Collectors.groupingBy(MatchPlayerRating::getPlayerId));

        Map<Long, Integer> myScoreMap = new HashMap<>();
        if (userId != null) {
            for (MatchPlayerRating r : allRatings) {
                if (userId.equals(r.getUserId())) {
                    myScoreMap.put(r.getPlayerId(), r.getScore());
                }
            }
        }

        return players.stream().map(p -> {
            MatchPlayerRatingVO vo = new MatchPlayerRatingVO();
            vo.setPlayerId(p.getPlayerId());
            vo.setPlayerName(p.getName());
            vo.setPlayerNameCn(p.getNameCn());
            vo.setPosition(p.getPosition());
            vo.setJerseyNumber(p.getJerseyNumber());
            vo.setClubId(p.getClubId());

            List<MatchPlayerRating> pr = ratingsByPlayer.getOrDefault(p.getPlayerId(), Collections.emptyList());
            if (!pr.isEmpty()) {
                double avg = pr.stream().mapToInt(MatchPlayerRating::getScore).average().orElse(0);
                vo.setAvgScore(BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP));
                vo.setTotalRatings(pr.size());
            } else {
                vo.setAvgScore(BigDecimal.ZERO);
                vo.setTotalRatings(0);
            }

            vo.setMyScore(myScoreMap.get(p.getPlayerId()));
            return vo;
        }).collect(Collectors.toList());
    }

    @Transactional
    public MatchPlayerRatingVO ratePlayer(String matchId, Long playerId, Long userId, Integer score) {
        ensureTableExists();

        if (score < 1 || score > 10) {
            throw new RuntimeException("评分必须在1-10之间");
        }

        QueryWrapper<MatchPlayerRating> wrapper = new QueryWrapper<>();
        wrapper.eq("MATCH_ID", matchId);
        wrapper.eq("PLAYER_ID", playerId);
        wrapper.eq("USER_ID", userId);
        MatchPlayerRating existing = ratingMapper.selectOne(wrapper);

        if (existing != null) {
            existing.setScore(score);
            existing.setCreatedAt(java.time.LocalDateTime.now());
            ratingMapper.updateById(existing);
        } else {
            MatchPlayerRating rating = new MatchPlayerRating();
            rating.setMatchId(matchId);
            rating.setPlayerId(playerId);
            rating.setUserId(userId);
            rating.setScore(score);
            rating.setCreatedAt(java.time.LocalDateTime.now());
            ratingMapper.insert(rating);
        }

        updatePlayerAvgScore(playerId);

        QueryWrapper<MatchPlayerRating> allWrapper = new QueryWrapper<>();
        allWrapper.eq("MATCH_ID", matchId);
        allWrapper.eq("PLAYER_ID", playerId);
        List<MatchPlayerRating> allRatings = ratingMapper.selectList(allWrapper);
        double avg = allRatings.stream().mapToInt(MatchPlayerRating::getScore).average().orElse(0);

        Player player = playerMapper.selectById(playerId);
        MatchPlayerRatingVO vo = new MatchPlayerRatingVO();
        vo.setPlayerId(playerId);
        vo.setPlayerName(player != null ? player.getName() : null);
        vo.setPlayerNameCn(player != null ? player.getNameCn() : null);
        vo.setPosition(player != null ? player.getPosition() : null);
        vo.setJerseyNumber(player != null ? player.getJerseyNumber() : null);
        vo.setClubId(player != null ? player.getClubId() : null);
        vo.setAvgScore(BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP));
        vo.setTotalRatings(allRatings.size());
        vo.setMyScore(score);
        return vo;
    }

    private void updatePlayerAvgScore(Long playerId) {
        QueryWrapper<MatchPlayerRating> wrapper = new QueryWrapper<>();
        wrapper.eq("PLAYER_ID", playerId);
        List<MatchPlayerRating> allRatings = ratingMapper.selectList(wrapper);
        if (allRatings.isEmpty()) return;

        double avg = allRatings.stream().mapToInt(MatchPlayerRating::getScore).average().orElse(0);
        Player player = playerMapper.selectById(playerId);
        if (player != null) {
            player.setAvgScore(BigDecimal.valueOf(avg).setScale(1, RoundingMode.HALF_UP));
            player.setTotalRatings(allRatings.size());
            playerMapper.updateById(player);
        }
    }
}
