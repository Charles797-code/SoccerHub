package com.soccerhub.controller;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.*;
import com.soccerhub.entity.*;
import com.soccerhub.service.AdminService;
import com.soccerhub.service.MatchService;
import com.soccerhub.service.MatchEventService;
import com.soccerhub.service.PlayerService;
import com.soccerhub.mapper.TransferHistoryLogMapper;
import com.soccerhub.mapper.PlayerMapper;
import com.soccerhub.mapper.ClubMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('SUPER_ADMIN')")
@Tag(name = "Admin", description = "Super admin endpoints")
public class AdminController {

    private final AdminService adminService;
    private final MatchService matchService;
    private final PlayerService playerService;
    private final MatchEventService matchEventService;
    private final TransferHistoryLogMapper transferLogMapper;
    private final PlayerMapper playerMapper;
    private final ClubMapper clubMapper;

    @GetMapping("/dashboard/stats")
    @Operation(summary = "Get dashboard statistics")
    public ResponseEntity<ApiResponse<DashboardStats>> getStats() {
        return ResponseEntity.ok(ApiResponse.success(adminService.getDashboardStats()));
    }

    @GetMapping("/users")
    @Operation(summary = "List users")
    public ResponseEntity<ApiResponse<PageResponse<SysUser>>> listUsers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String keyword) {
        Page<SysUser> result = adminService.listUsers(page, pageSize, role, keyword);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PutMapping("/users/{id}/role")
    @Operation(summary = "Update user role")
    public ResponseEntity<ApiResponse<SysUser>> updateUserRole(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        return ResponseEntity.ok(ApiResponse.success(
                adminService.updateUserRole(id, request.get("role"))));
    }

    @PutMapping("/users/{id}/status")
    @Operation(summary = "Update user status")
    public ResponseEntity<ApiResponse<Void>> updateUserStatus(
            @PathVariable Long id,
            @RequestBody Map<String, String> request) {
        adminService.updateUserStatus(id, request.get("status"));
        return ResponseEntity.ok(ApiResponse.success("Status updated", null));
    }

    @PutMapping("/users/{id}/club")
    @Operation(summary = "Assign managed club to club admin")
    public ResponseEntity<ApiResponse<SysUser>> assignManagedClub(
            @PathVariable Long id,
            @RequestBody Map<String, Long> request) {
        return ResponseEntity.ok(ApiResponse.success(
                adminService.assignManagedClub(id, request.get("managedClubId"))));
    }

    @GetMapping("/audit-logs")
    @Operation(summary = "Get audit logs")
    public ResponseEntity<ApiResponse<PageResponse<AuditLog>>> getAuditLogs(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String module,
            @RequestParam(required = false) Long userId) {
        Page<AuditLog> result = adminService.listAuditLogs(page, pageSize, module, userId);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/dictionary")
    @Operation(summary = "Get system dictionary")
    public ResponseEntity<ApiResponse<PageResponse<SystemDictionary>>> getDictionary(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int pageSize,
            @RequestParam(required = false) String dictType) {
        Page<SystemDictionary> result = adminService.listDictionary(page, pageSize, dictType);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PostMapping("/dictionary")
    @Operation(summary = "Create dictionary entry")
    public ResponseEntity<ApiResponse<SystemDictionary>> createDictionary(
            @RequestBody SystemDictionary entry) {
        return ResponseEntity.ok(ApiResponse.success(
                adminService.createDictionaryEntry(entry)));
    }

    @PutMapping("/dictionary/{id}")
    @Operation(summary = "Update dictionary entry")
    public ResponseEntity<ApiResponse<SystemDictionary>> updateDictionary(
            @PathVariable Long id,
            @RequestBody SystemDictionary entry) {
        return ResponseEntity.ok(ApiResponse.success(
                adminService.updateDictionaryEntry(id, entry)));
    }

    @DeleteMapping("/dictionary/{id}")
    @Operation(summary = "Delete dictionary entry")
    public ResponseEntity<ApiResponse<Void>> deleteDictionary(@PathVariable Long id) {
        adminService.deleteDictionaryEntry(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }

    // ==================== Transfer Management ====================

    @GetMapping("/transfers")
    @Operation(summary = "List all transfer records")
    public ResponseEntity<ApiResponse<PageResponse<TransferHistoryLog>>> listTransfers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) Long playerId,
            @RequestParam(required = false) String transferType,
            @RequestParam(required = false) String season) {
        Page<TransferHistoryLog> p = new Page<>(page, pageSize);
        QueryWrapper<TransferHistoryLog> wrapper = new QueryWrapper<>();
        if (playerId != null) wrapper.eq("PLAYER_ID", playerId);
        if (transferType != null && !transferType.isEmpty()) wrapper.eq("TRANSFER_TYPE", transferType);
        if (season != null && !season.isEmpty()) wrapper.eq("SEASON", season);
        wrapper.orderByDesc("ACTION_TIME");
        Page<TransferHistoryLog> result = transferLogMapper.selectPage(p, wrapper);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PostMapping("/transfers")
    @Operation(summary = "Create transfer record (transfer a player)")
    public ResponseEntity<ApiResponse<TransferHistoryLog>> createTransfer(
            @Valid @RequestBody TransferRequest request) {
        TransferHistoryLog log = playerService.transferPlayer(
                request.getPlayerId(), request.getNewClubId(), request.getTransferType(),
                request.getTransferFee(), request.getSeason(), 1L, request.getNotes());
        return ResponseEntity.ok(ApiResponse.success("Transfer completed", log));
    }

    @DeleteMapping("/transfers/{id}")
    @Operation(summary = "Delete transfer record")
    public ResponseEntity<ApiResponse<Void>> deleteTransfer(@PathVariable Long id) {
        transferLogMapper.deleteById(id);
        return ResponseEntity.ok(ApiResponse.success("Transfer record deleted", null));
    }

    // ==================== Match Management ====================

    @GetMapping("/matches")
    @Operation(summary = "List all matches for admin")
    public ResponseEntity<ApiResponse<PageResponse<MatchSchedule>>> listMatches(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String league,
            @RequestParam(required = false) String status) {
        Page<MatchSchedule> result = matchService.listMatches(page, pageSize, league, status, null, null);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/matches/{id}")
    @Operation(summary = "Get match by ID")
    public ResponseEntity<ApiResponse<MatchSchedule>> getMatch(@PathVariable String id) {
        MatchSchedule match = matchService.getMatchById(id);
        if (match == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(ApiResponse.success(match));
    }

    @PostMapping("/matches")
    @Operation(summary = "Create a new match")
    public ResponseEntity<ApiResponse<MatchSchedule>> createMatch(@RequestBody MatchUpsertRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Match created", matchService.upsertMatch(request)));
    }

    @PutMapping("/matches/{id}")
    @Operation(summary = "Update match")
    public ResponseEntity<ApiResponse<MatchSchedule>> updateMatch(
            @PathVariable String id, @RequestBody MatchUpsertRequest request) {
        request.setMatchId(id);
        return ResponseEntity.ok(ApiResponse.success("Match updated", matchService.upsertMatch(request)));
    }

    @DeleteMapping("/matches/{id}")
    @Operation(summary = "Delete match")
    public ResponseEntity<ApiResponse<Void>> deleteMatch(@PathVariable String id) {
        matchService.deleteMatch(id);
        return ResponseEntity.ok(ApiResponse.success("Match deleted", null));
    }

    // ==================== Club Management ====================

    @GetMapping("/clubs")
    @Operation(summary = "List all clubs for admin")
    public ResponseEntity<ApiResponse<PageResponse<Club>>> listClubs(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String league,
            @RequestParam(required = false) String keyword) {
        Page<Club> p = new Page<>(page, pageSize);
        QueryWrapper<Club> wrapper = new QueryWrapper<>();
        if (league != null && !league.isEmpty()) wrapper.eq("LEAGUE", league);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like("NAME", keyword).or().like("SHORT_NAME", keyword));
        }
        wrapper.orderByAsc("LEAGUE", "NAME");
        Page<Club> result = clubMapper.selectPage(p, wrapper);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PostMapping("/clubs")
    @Operation(summary = "Create a new club")
    public ResponseEntity<ApiResponse<Club>> createClub(@RequestBody Club club) {
        return ResponseEntity.ok(ApiResponse.success("Club created", adminService.createClub(club)));
    }

    @PutMapping("/clubs/{id}")
    @Operation(summary = "Update club")
    public ResponseEntity<ApiResponse<Club>> updateClub(@PathVariable Long id, @RequestBody Club club) {
        return ResponseEntity.ok(ApiResponse.success("Club updated", adminService.updateClub(id, club)));
    }

    @DeleteMapping("/clubs/{id}")
    @Operation(summary = "Delete club")
    public ResponseEntity<ApiResponse<Void>> deleteClub(@PathVariable Long id) {
        adminService.deleteClub(id);
        return ResponseEntity.ok(ApiResponse.success("Club deleted", null));
    }

    // ==================== Player Management ====================

    @GetMapping("/players")
    @Operation(summary = "List all players for admin")
    public ResponseEntity<ApiResponse<PageResponse<Player>>> listPlayers(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) Long clubId,
            @RequestParam(required = false) String position,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword) {
        Page<Player> result = playerService.listPlayers(page, pageSize, clubId, position, status, keyword);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PostMapping("/players")
    @Operation(summary = "Create a new player")
    public ResponseEntity<ApiResponse<Player>> createPlayer(@RequestBody Player player) {
        return ResponseEntity.ok(ApiResponse.success("Player created", playerService.createPlayer(player)));
    }

    @PutMapping("/players/{id}")
    @Operation(summary = "Update player")
    public ResponseEntity<ApiResponse<Player>> updatePlayer(@PathVariable Long id, @RequestBody Player player) {
        return ResponseEntity.ok(ApiResponse.success("Player updated", playerService.updatePlayer(id, player)));
    }

    @DeleteMapping("/players/{id}")
    @Operation(summary = "Delete player")
    public ResponseEntity<ApiResponse<Void>> deletePlayer(@PathVariable Long id) {
        playerService.deletePlayer(id);
        return ResponseEntity.ok(ApiResponse.success("Player deleted", null));
    }

    @PostMapping("/matches/finish")
    @Operation(summary = "Finish a match with events, auto-update standings and player stats")
    public ResponseEntity<ApiResponse<MatchSchedule>> finishMatch(@RequestBody FinishMatchRequest request) {
        return ResponseEntity.ok(ApiResponse.success("比赛已结束，积分榜和球员统计已更新", matchEventService.finishMatch(request)));
    }

    @GetMapping("/matches/{matchId}/events")
    @Operation(summary = "Get events for a match")
    public ResponseEntity<ApiResponse<List<MatchEvent>>> getMatchEvents(@PathVariable String matchId) {
        return ResponseEntity.ok(ApiResponse.success(matchEventService.getMatchEvents(matchId)));
    }
}
