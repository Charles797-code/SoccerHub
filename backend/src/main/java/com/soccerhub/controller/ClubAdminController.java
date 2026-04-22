package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.*;
import com.soccerhub.entity.*;
import com.soccerhub.service.ClubAdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/club-admin")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
@Tag(name = "ClubAdmin", description = "Club admin management endpoints")
public class ClubAdminController {

    private final ClubAdminService clubAdminService;

    @GetMapping("/club")
    @Operation(summary = "Get my club info")
    public ResponseEntity<ApiResponse<Club>> getMyClub(Authentication authentication) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success(clubAdminService.getMyClub(clubId)));
    }

    @PutMapping("/club")
    @Operation(summary = "Update my club info")
    public ResponseEntity<ApiResponse<Club>> updateMyClub(Authentication authentication, @RequestBody Club club) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success("Club updated", clubAdminService.updateMyClub(clubId, club)));
    }

    @GetMapping("/players")
    @Operation(summary = "List my club players")
    public ResponseEntity<ApiResponse<PageResponse<Player>>> listMyPlayers(
            Authentication authentication,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String position,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        Page<Player> result = clubAdminService.listMyPlayers(clubId, page, pageSize, position, status, keyword);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PostMapping("/players")
    @Operation(summary = "Create player for my club")
    public ResponseEntity<ApiResponse<Player>> createMyPlayer(Authentication authentication, @RequestBody Player player) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success("Player created", clubAdminService.createMyPlayer(clubId, player)));
    }

    @PutMapping("/players/{id}")
    @Operation(summary = "Update my club player")
    public ResponseEntity<ApiResponse<Player>> updateMyPlayer(
            Authentication authentication, @PathVariable Long id, @RequestBody Player player) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success("Player updated", clubAdminService.updateMyPlayer(clubId, id, player)));
    }

    @DeleteMapping("/players/{id}")
    @Operation(summary = "Delete my club player")
    public ResponseEntity<ApiResponse<Void>> deleteMyPlayer(Authentication authentication, @PathVariable Long id) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        clubAdminService.deleteMyPlayer(clubId, id);
        return ResponseEntity.ok(ApiResponse.success("Player deleted", null));
    }

    @PostMapping("/players/{id}/transfer")
    @Operation(summary = "Transfer my club player")
    public ResponseEntity<ApiResponse<TransferHistoryLog>> transferMyPlayer(
            Authentication authentication, @PathVariable Long id,
            @Valid @RequestBody TransferRequest request) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        SysUser user = new SysUser();
        user.setUsername(authentication.getName());
        TransferHistoryLog log = clubAdminService.transferMyPlayer(
                clubId, id, request.getNewClubId(), request.getTransferType(),
                request.getTransferFee(), request.getSeason(), 1L, request.getNotes());
        return ResponseEntity.ok(ApiResponse.success("Player transferred", log));
    }

    @GetMapping("/coaches")
    @Operation(summary = "List my club coaches")
    public ResponseEntity<ApiResponse<List<Coach>>> listMyCoaches(Authentication authentication) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success(clubAdminService.listMyCoaches(clubId)));
    }

    @PostMapping("/coaches")
    @Operation(summary = "Create coach for my club")
    public ResponseEntity<ApiResponse<Coach>> createMyCoach(Authentication authentication, @RequestBody Coach coach) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success("Coach created", clubAdminService.createMyCoach(clubId, coach)));
    }

    @PutMapping("/coaches/{id}")
    @Operation(summary = "Update my club coach")
    public ResponseEntity<ApiResponse<Coach>> updateMyCoach(
            Authentication authentication, @PathVariable Long id, @RequestBody Coach coach) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        return ResponseEntity.ok(ApiResponse.success("Coach updated", clubAdminService.updateMyCoach(clubId, id, coach)));
    }

    @DeleteMapping("/coaches/{id}")
    @Operation(summary = "Delete my club coach")
    public ResponseEntity<ApiResponse<Void>> deleteMyCoach(Authentication authentication, @PathVariable Long id) {
        Long clubId = clubAdminService.resolveManagedClubId(authentication.getName());
        clubAdminService.deleteMyCoach(clubId, id);
        return ResponseEntity.ok(ApiResponse.success("Coach deleted", null));
    }
}
