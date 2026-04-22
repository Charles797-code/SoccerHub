package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.entity.LeagueStanding;
import com.soccerhub.entity.NewsArticle;
import com.soccerhub.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/standings")
@RequiredArgsConstructor
@Tag(name = "Standings", description = "League standings endpoints")
public class StandingsController {

    private final AdminService adminService;

    @GetMapping
    @Operation(summary = "Get league standings")
    public ResponseEntity<ApiResponse<PageResponse<LeagueStanding>>> getStandings(
            @RequestParam(required = false) String league,
            @RequestParam(required = false) String season,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Page<LeagueStanding> result = adminService.getStandings(league, season, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PostMapping
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Create or update league standing")
    public ResponseEntity<ApiResponse<LeagueStanding>> upsertStanding(@RequestBody LeagueStanding standing) {
        return ResponseEntity.ok(ApiResponse.success(adminService.upsertStanding(standing)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Delete league standing")
    public ResponseEntity<ApiResponse<Void>> deleteStanding(@PathVariable Long id) {
        adminService.deleteStanding(id);
        return ResponseEntity.ok(ApiResponse.success(null));
    }
}
