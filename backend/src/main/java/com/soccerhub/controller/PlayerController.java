package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.dto.PlayerRanking;
import com.soccerhub.dto.TransferRequest;
import com.soccerhub.entity.Player;
import com.soccerhub.entity.TransferHistoryLog;

import java.util.List;
import com.soccerhub.service.PlayerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/players")
@RequiredArgsConstructor
@Tag(name = "Players", description = "Player management endpoints")
public class PlayerController {

    private final PlayerService playerService;

    @GetMapping
    @Operation(summary = "List players (paginated)")
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

    @GetMapping("/{id}")
    @Operation(summary = "Get player by ID")
    public ResponseEntity<ApiResponse<Player>> getPlayer(@PathVariable Long id) {
        Player player = playerService.getPlayerById(id);
        if (player == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(ApiResponse.success(player));
    }

    @GetMapping("/rankings")
    @Operation(summary = "Get player rankings")
    public ResponseEntity<ApiResponse<PageResponse<PlayerRanking>>> getRankings(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "30") int pageSize,
            @RequestParam(required = false) String league,
            @RequestParam(required = false) String position) {
        List<PlayerRanking> result = playerService.getRankings(page, pageSize, league, position);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result, (long) result.size(), (long) page, (long) pageSize)));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Create player")
    public ResponseEntity<ApiResponse<Player>> createPlayer(@RequestBody Player player) {
        return ResponseEntity.ok(ApiResponse.success("Player created", playerService.createPlayer(player)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Update player")
    public ResponseEntity<ApiResponse<Player>> updatePlayer(@PathVariable Long id, @RequestBody Player player) {
        return ResponseEntity.ok(ApiResponse.success("Player updated", playerService.updatePlayer(id, player)));
    }

    @PostMapping("/{id}/transfer")
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Transfer player")
    public ResponseEntity<ApiResponse<TransferHistoryLog>> transferPlayer(
            @PathVariable Long id,
            @Valid @RequestBody TransferRequest request,
            Authentication authentication) {
        // For simplicity, using placeholder action user id
        TransferHistoryLog log = playerService.transferPlayer(
                request.getPlayerId(), request.getNewClubId(), request.getTransferType(),
                request.getTransferFee(), request.getSeason(), 1L, request.getNotes());
        return ResponseEntity.ok(ApiResponse.success("Player transferred", log));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Delete player")
    public ResponseEntity<ApiResponse<Void>> deletePlayer(@PathVariable Long id) {
        playerService.deletePlayer(id);
        return ResponseEntity.ok(ApiResponse.success("Player deleted", null));
    }
}
