package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.soccerhub.entity.MatchPrediction;
import com.soccerhub.entity.MatchSchedule;
import com.soccerhub.entity.SysUser;
import com.soccerhub.mapper.MatchPredictionMapper;
import com.soccerhub.mapper.MatchScheduleMapper;
import com.soccerhub.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PredictionService {

    private final MatchPredictionMapper predictionMapper;
    private final SysUserMapper userMapper;
    private final MatchScheduleMapper matchMapper;

    private static final int INITIAL_POINTS = 1000;
    private static final int POINTS_CORRECT = 3;

    public MatchPrediction makePrediction(Long userId, String matchId, String predictedResult) {
        MatchSchedule match = matchMapper.selectById(matchId);
        if (match == null) throw new RuntimeException("比赛不存在");
        if (!"PENDING".equals(match.getStatus()) && !"SCHEDULED".equals(match.getStatus())) {
            throw new RuntimeException("比赛已经开始或结束，无法预测");
        }

        QueryWrapper<MatchPrediction> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId).eq("MATCH_ID", matchId);
        MatchPrediction existing = predictionMapper.selectOne(wrapper);
        if (existing != null) {
            throw new RuntimeException("您已经预测过这场比赛了");
        }

        SysUser user = userMapper.selectById(userId);
        if (user == null) throw new RuntimeException("用户不存在");
        if (user.getPoints() == null) {
            user.setPoints(INITIAL_POINTS);
            userMapper.updateById(user);
        }

        MatchPrediction prediction = new MatchPrediction();
        prediction.setUserId(userId);
        prediction.setMatchId(matchId);
        prediction.setPredictedResult(predictedResult);
        prediction.setStatus("PENDING");
        prediction.setCreatedAt(LocalDateTime.now());
        predictionMapper.insert(prediction);

        return prediction;
    }

    public MatchPrediction getUserPredictionForMatch(Long userId, String matchId) {
        QueryWrapper<MatchPrediction> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId).eq("MATCH_ID", matchId);
        return predictionMapper.selectOne(wrapper);
    }

    public List<MatchPrediction> getUserPredictions(Long userId) {
        QueryWrapper<MatchPrediction> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId);
        wrapper.orderByDesc("CREATED_AT");
        return predictionMapper.selectList(wrapper);
    }

    public List<Map<String, Object>> getUserPredictionsWithMatchInfo(Long userId) {
        List<MatchPrediction> predictions = getUserPredictions(userId);
        List<Map<String, Object>> result = new java.util.ArrayList<>();
        for (MatchPrediction p : predictions) {
            Map<String, Object> map = new java.util.HashMap<>();
            map.put("predictionId", p.getPredictionId());
            map.put("matchId", p.getMatchId());
            map.put("predictedResult", p.getPredictedResult());
            map.put("status", p.getStatus());
            map.put("pointsEarned", p.getPointsEarned());
            map.put("actualResult", p.getActualResult());
            map.put("createdAt", p.getCreatedAt());
            map.put("settledAt", p.getSettledAt());

            MatchSchedule match = matchMapper.selectById(p.getMatchId());
            if (match != null) {
                map.put("matchTime", match.getMatchTime());
                map.put("homeClubId", match.getHomeClubId());
                map.put("awayClubId", match.getAwayClubId());
                map.put("homeScore", match.getHomeScore());
                map.put("awayScore", match.getAwayScore());
            }
            result.add(map);
        }
        return result;
    }

    public Map<String, Object> getUserPoints(Long userId) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) throw new RuntimeException("用户不存在");
        Map<String, Object> result = new HashMap<>();
        result.put("userId", userId);
        result.put("points", user.getPoints() != null ? user.getPoints() : INITIAL_POINTS);
        result.put("nickname", user.getNickname());
        return result;
    }

    @Transactional
    public Map<String, Object> settleMatch(String matchId) {
        MatchSchedule match = matchMapper.selectById(matchId);
        if (match == null) throw new RuntimeException("比赛不存在");
        if (!"FINISHED".equals(match.getStatus())) {
            throw new RuntimeException("比赛未结束，无法结算");
        }

        QueryWrapper<MatchPrediction> wrapper = new QueryWrapper<>();
        wrapper.eq("MATCH_ID", matchId).eq("STATUS", "PENDING");
        List<MatchPrediction> predictions = predictionMapper.selectList(wrapper);

        String actualResult;
        if (match.getHomeScore() > match.getAwayScore()) {
            actualResult = "HOME_WIN";
        } else if (match.getHomeScore() < match.getAwayScore()) {
            actualResult = "AWAY_WIN";
        } else {
            actualResult = "DRAW";
        }

        int totalPoints = 0;
        int correctCount = 0;

        for (MatchPrediction prediction : predictions) {
            int pointsEarned = 0;

            if (prediction.getPredictedResult().equals(actualResult)) {
                pointsEarned += POINTS_CORRECT;
                correctCount++;
            }

            prediction.setStatus("SETTLED");
            prediction.setPointsEarned(pointsEarned);
            prediction.setActualResult(actualResult);
            prediction.setSettledAt(LocalDateTime.now());
            predictionMapper.updateById(prediction);

            SysUser user = userMapper.selectById(prediction.getUserId());
            if (user != null) {
                int currentPoints = user.getPoints() != null ? user.getPoints() : INITIAL_POINTS;
                user.setPoints(currentPoints + pointsEarned);
                userMapper.updateById(user);
            }

            totalPoints += pointsEarned;
        }

        Map<String, Object> result = new HashMap<>();
        result.put("matchId", matchId);
        result.put("actualResult", actualResult);
        result.put("totalPredictions", predictions.size());
        result.put("correctPredictions", correctCount);
        result.put("totalPointsDistributed", totalPoints);
        return result;
    }

    public List<MatchPrediction> getPendingPredictions() {
        QueryWrapper<MatchPrediction> wrapper = new QueryWrapper<>();
        wrapper.eq("STATUS", "PENDING");
        return predictionMapper.selectList(wrapper);
    }

    public List<MatchPrediction> getPredictionsByMatch(String matchId) {
        QueryWrapper<MatchPrediction> wrapper = new QueryWrapper<>();
        wrapper.eq("MATCH_ID", matchId);
        return predictionMapper.selectList(wrapper);
    }

    public List<MatchSchedule> getSettledMatches() {
        QueryWrapper<MatchSchedule> wrapper = new QueryWrapper<>();
        wrapper.eq("STATUS", "FINISHED");
        wrapper.orderByDesc("MATCH_TIME");
        return matchMapper.selectList(wrapper);
    }
}