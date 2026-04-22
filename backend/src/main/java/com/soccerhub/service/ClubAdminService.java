package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.*;
import com.soccerhub.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ClubAdminService {

    private final ClubMapper clubMapper;
    private final PlayerMapper playerMapper;
    private final CoachMapper coachMapper;
    private final TransferHistoryLogMapper transferLogMapper;
    private final SysUserMapper userMapper;

    public Club getMyClub(Long managedClubId) {
        return clubMapper.selectById(managedClubId);
    }

    @Transactional
    public Club updateMyClub(Long managedClubId, Club club) {
        Club existing = clubMapper.selectById(managedClubId);
        if (existing == null) throw new RuntimeException("Club not found");
        club.setClubId(managedClubId);
        club.setUpdatedAt(LocalDateTime.now());
        clubMapper.updateById(club);
        return clubMapper.selectById(managedClubId);
    }

    public Page<Player> listMyPlayers(Long managedClubId, int page, int pageSize, String position, String status, String keyword) {
        Page<Player> p = new Page<>(page, pageSize);
        QueryWrapper<Player> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", managedClubId);
        if (position != null && !position.isEmpty()) wrapper.eq("POSITION", position);
        if (status != null && !status.isEmpty()) wrapper.eq("STATUS", status);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like("NAME", keyword).or().like("NAME_CN", keyword));
        }
        wrapper.orderByAsc("POSITION", "JERSEY_NUMBER");
        return playerMapper.selectPage(p, wrapper);
    }

    @Transactional
    public Player createMyPlayer(Long managedClubId, Player player) {
        player.setClubId(managedClubId);
        player.setAvgScore(java.math.BigDecimal.ZERO);
        player.setTotalRatings(0);
        player.setCreatedAt(LocalDateTime.now());
        playerMapper.insert(player);
        return player;
    }

    @Transactional
    public Player updateMyPlayer(Long managedClubId, Long playerId, Player player) {
        Player existing = playerMapper.selectById(playerId);
        if (existing == null) throw new RuntimeException("Player not found");
        if (!managedClubId.equals(existing.getClubId())) throw new RuntimeException("No permission to manage this player");
        player.setPlayerId(playerId);
        player.setClubId(managedClubId);
        player.setUpdatedAt(LocalDateTime.now());
        playerMapper.updateById(player);
        return playerMapper.selectById(playerId);
    }

    @Transactional
    public void deleteMyPlayer(Long managedClubId, Long playerId) {
        Player existing = playerMapper.selectById(playerId);
        if (existing == null) throw new RuntimeException("Player not found");
        if (!managedClubId.equals(existing.getClubId())) throw new RuntimeException("No permission to manage this player");
        playerMapper.deleteById(playerId);
    }

    @Transactional
    public TransferHistoryLog transferMyPlayer(Long managedClubId, Long playerId, Long newClubId,
                                                String transferType, Long transferFee, String season,
                                                Long actionUserId, String notes) {
        Player player = playerMapper.selectById(playerId);
        if (player == null) throw new RuntimeException("Player not found");
        if (!managedClubId.equals(player.getClubId())) throw new RuntimeException("No permission to transfer this player");

        Long oldClubId = player.getClubId();

        TransferHistoryLog log = new TransferHistoryLog();
        log.setPlayerId(playerId);
        log.setOldClubId(oldClubId);
        log.setNewClubId(newClubId);
        log.setTransferType(transferType);
        log.setTransferFee(transferFee);
        log.setSeason(season);
        log.setActionUserId(actionUserId);
        log.setActionTime(LocalDateTime.now());
        log.setNotes(notes);
        transferLogMapper.insert(log);

        player.setClubId(newClubId);
        player.setUpdatedAt(LocalDateTime.now());
        playerMapper.updateById(player);

        return log;
    }

    public List<Coach> listMyCoaches(Long managedClubId) {
        QueryWrapper<Coach> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", managedClubId);
        wrapper.orderByDesc("IS_HEAD_COACH", "AVG_SCORE");
        return coachMapper.selectList(wrapper);
    }

    @Transactional
    public Coach createMyCoach(Long managedClubId, Coach coach) {
        coach.setClubId(managedClubId);
        coach.setIsHeadCoach("HEAD_COACH".equals(coach.getRole()) ? 1 : 0);
        coach.setAvgScore(java.math.BigDecimal.ZERO);
        coach.setTotalRatings(0);
        coach.setCreatedAt(LocalDateTime.now());
        coachMapper.insert(coach);
        return coach;
    }

    @Transactional
    public Coach updateMyCoach(Long managedClubId, Long coachId, Coach coach) {
        Coach existing = coachMapper.selectById(coachId);
        if (existing == null) throw new RuntimeException("Coach not found");
        if (!managedClubId.equals(existing.getClubId())) throw new RuntimeException("No permission to manage this coach");
        coach.setCoachId(coachId);
        coach.setClubId(managedClubId);
        coach.setIsHeadCoach("HEAD_COACH".equals(coach.getRole()) ? 1 : 0);
        coach.setUpdatedAt(LocalDateTime.now());
        coachMapper.updateById(coach);
        return coachMapper.selectById(coachId);
    }

    @Transactional
    public void deleteMyCoach(Long managedClubId, Long coachId) {
        Coach existing = coachMapper.selectById(coachId);
        if (existing == null) throw new RuntimeException("Coach not found");
        if (!managedClubId.equals(existing.getClubId())) throw new RuntimeException("No permission to manage this coach");
        coachMapper.deleteById(coachId);
    }

    public Long resolveManagedClubId(String username) {
        SysUser user = userMapper.selectByUsername(username);
        if (user == null) throw new RuntimeException("User not found");
        if (user.getManagedClubId() == null) throw new RuntimeException("No club assigned to this admin");
        return user.getManagedClubId();
    }
}
