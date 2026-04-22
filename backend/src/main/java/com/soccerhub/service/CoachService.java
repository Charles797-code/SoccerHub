package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.Coach;
import com.soccerhub.mapper.CoachMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CoachService {

    private final CoachMapper coachMapper;

    public Page<Coach> listCoaches(int page, int pageSize, Long clubId) {
        Page<Coach> p = new Page<>(page, pageSize);
        QueryWrapper<Coach> wrapper = new QueryWrapper<>();
        if (clubId != null) wrapper.eq("CLUB_ID", clubId);
        wrapper.orderByDesc("IS_HEAD_COACH", "AVG_SCORE");
        return coachMapper.selectPage(p, wrapper);
    }

    public Coach getCoachById(Long id) {
        return coachMapper.selectById(id);
    }

    public Page<Coach> getRankings(int page, int pageSize) {
        Page<Coach> p = new Page<>(page, pageSize);
        QueryWrapper<Coach> wrapper = new QueryWrapper<>();
        wrapper.eq("IS_HEAD_COACH", 1);
        wrapper.gt("AVG_SCORE", 0);
        wrapper.orderByDesc("AVG_SCORE");
        return coachMapper.selectPage(p, wrapper);
    }

    public Coach createCoach(Coach coach) {
        coach.setCreatedAt(LocalDateTime.now());
        coach.setAvgScore(java.math.BigDecimal.ZERO);
        coach.setTotalRatings(0);
        coachMapper.insert(coach);
        return coach;
    }

    public Coach updateCoach(Long id, Coach coach) {
        Coach existing = coachMapper.selectById(id);
        if (existing == null) throw new RuntimeException("Coach not found");
        coach.setCoachId(id);
        coach.setUpdatedAt(LocalDateTime.now());
        coachMapper.updateById(coach);
        return coachMapper.selectById(id);
    }

    public void deleteCoach(Long id) {
        coachMapper.deleteById(id);
    }
}
