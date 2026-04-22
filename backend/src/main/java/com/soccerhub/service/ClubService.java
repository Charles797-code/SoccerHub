package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.*;
import com.soccerhub.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ClubService {

    private final ClubMapper clubMapper;
    private final PlayerMapper playerMapper;
    private final CoachMapper coachMapper;
    private final UserClubFollowMapper followMapper;

    public Page<Club> listClubs(int page, int pageSize, String league, String keyword) {
        Page<Club> p = new Page<>(page, pageSize);
        QueryWrapper<Club> wrapper = new QueryWrapper<>();
        if (league != null && !league.isEmpty()) {
            wrapper.eq("LEAGUE", league);
        }
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like("NAME", keyword).or().like("CITY", keyword));
        }
        wrapper.orderByAsc("LEAGUE", "NAME");
        return clubMapper.selectPage(p, wrapper);
    }

    public Club getClubById(Long id) {
        return clubMapper.selectById(id);
    }

    public List<Player> getClubPlayers(Long clubId, String position, String status) {
        QueryWrapper<Player> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", clubId);
        if (position != null && !position.isEmpty()) {
            wrapper.eq("POSITION", position);
        }
        if (status != null && !status.isEmpty()) {
            wrapper.eq("STATUS", status);
        }
        wrapper.orderByAsc("POSITION", "AVG_SCORE");
        return playerMapper.selectList(wrapper);
    }

    public List<Coach> getClubCoaches(Long clubId) {
        QueryWrapper<Coach> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", clubId);
        wrapper.orderByDesc("IS_HEAD_COACH", "AVG_SCORE");
        return coachMapper.selectList(wrapper);
    }

    public Page<Player> getClubPlayersPaged(Long clubId, String position, int page, int pageSize) {
        Page<Player> p = new Page<>(page, pageSize);
        QueryWrapper<Player> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", clubId);
        if (position != null && !position.isEmpty()) {
            wrapper.eq("POSITION", position);
        }
        wrapper.orderByAsc("POSITION", "AVG_SCORE");
        return playerMapper.selectPage(p, wrapper);
    }

    public Long getClubFollowerCount(Long clubId) {
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", clubId);
        return followMapper.selectCount(wrapper);
    }

    public List<String> getAllLeagues() {
        QueryWrapper<Club> wrapper = new QueryWrapper<>();
        wrapper.select("DISTINCT LEAGUE");
        wrapper.orderByAsc("LEAGUE");
        List<Club> clubs = clubMapper.selectList(wrapper);
        return clubs.stream().map(Club::getLeague).toList();
    }

    public Club createClub(Club club) {
        club.setCreatedAt(LocalDateTime.now());
        clubMapper.insert(club);
        return club;
    }

    public Club updateClub(Long id, Club club) {
        Club existing = clubMapper.selectById(id);
        if (existing == null) throw new RuntimeException("Club not found");
        club.setClubId(id);
        club.setUpdatedAt(LocalDateTime.now());
        clubMapper.updateById(club);
        return clubMapper.selectById(id);
    }

    public void deleteClub(Long id) {
        clubMapper.deleteById(id);
    }

    public Page<SysUser> getClubFollowers(Long clubId, int page, int pageSize) {
        // This would need a custom query, returning empty for now
        return new Page<>();
    }
}
