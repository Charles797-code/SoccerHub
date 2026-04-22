package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.PlayerRanking;
import com.soccerhub.entity.Player;
import com.soccerhub.entity.TransferHistoryLog;
import com.soccerhub.mapper.PlayerMapper;
import com.soccerhub.mapper.TransferHistoryLogMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PlayerService {

    private final PlayerMapper playerMapper;
    private final TransferHistoryLogMapper transferLogMapper;

    public Page<Player> listPlayers(int page, int pageSize, Long clubId, String position, String status, String keyword) {
        Page<Player> p = new Page<>(page, pageSize);
        QueryWrapper<Player> wrapper = new QueryWrapper<>();
        if (clubId != null) wrapper.eq("CLUB_ID", clubId);
        if (position != null && !position.isEmpty()) wrapper.eq("POSITION", position);
        if (status != null && !status.isEmpty()) wrapper.eq("STATUS", status);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like("NAME", keyword).or().like("NAME_CN", keyword));
        }
        wrapper.orderByDesc("AVG_SCORE");
        return playerMapper.selectPage(p, wrapper);
    }

    public Player getPlayerById(Long id) {
        return playerMapper.selectById(id);
    }

    public List<PlayerRanking> getRankings(int page, int pageSize, String league, String position) {
        Page<PlayerRanking> p = new Page<>(page, pageSize);
        Page<PlayerRanking> result = playerMapper.selectRankingsWithLeague(p, league, position);
        return result.getRecords();
    }

    public Player createPlayer(Player player) {
        player.setCreatedAt(LocalDateTime.now());
        player.setAvgScore(java.math.BigDecimal.ZERO);
        player.setTotalRatings(0);
        playerMapper.insert(player);
        return player;
    }

    public Player updatePlayer(Long id, Player player) {
        Player existing = playerMapper.selectById(id);
        if (existing == null) throw new RuntimeException("Player not found");
        player.setPlayerId(id);
        player.setUpdatedAt(LocalDateTime.now());
        playerMapper.updateById(player);
        return playerMapper.selectById(id);
    }

    @Transactional
    public TransferHistoryLog transferPlayer(Long playerId, Long newClubId, String transferType,
                                            Long transferFee, String season, Long actionUserId, String notes) {
        Player player = playerMapper.selectById(playerId);
        if (player == null) throw new RuntimeException("Player not found");

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

    public void deletePlayer(Long id) {
        playerMapper.deleteById(id);
    }
}
