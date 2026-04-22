package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.MatchUpsertRequest;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.entity.MatchSchedule;
import com.soccerhub.service.MatchService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/matches")
@RequiredArgsConstructor
@Tag(name = "Matches", description = "Match schedule endpoints")
public class MatchController {

    private final MatchService matchService;

    @GetMapping
    @Operation(summary = "List matches")
    public ResponseEntity<ApiResponse<PageResponse<MatchSchedule>>> listMatches(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String league,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long clubId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        Page<MatchSchedule> result = matchService.listMatches(page, pageSize, league, status, clubId, date);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get match by ID")
    public ResponseEntity<ApiResponse<MatchSchedule>> getMatch(@PathVariable String id) {
        MatchSchedule match = matchService.getMatchById(id);
        if (match == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(ApiResponse.success(match));
    }

    @GetMapping("/today")
    @Operation(summary = "Get today's matches")
    public ResponseEntity<ApiResponse<List<MatchSchedule>>> getTodayMatches() {
        return ResponseEntity.ok(ApiResponse.success(matchService.getTodayMatches()));
    }

    @GetMapping("/live")
    @Operation(summary = "Get live matches")
    public ResponseEntity<ApiResponse<List<MatchSchedule>>> getLiveMatches() {
        return ResponseEntity.ok(ApiResponse.success(matchService.getLiveMatches()));
    }

    @GetMapping("/upcoming")
    @Operation(summary = "Get upcoming matches")
    public ResponseEntity<ApiResponse<List<MatchSchedule>>> getUpcomingMatches(
            @RequestParam(defaultValue = "10") int limit) {
        return ResponseEntity.ok(ApiResponse.success(matchService.getUpcomingMatches(limit)));
    }

    @PostMapping("/upsert")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'CLUB_ADMIN')")
    @Operation(summary = "Upsert match")
    public ResponseEntity<ApiResponse<MatchSchedule>> upsertMatch(@RequestBody MatchUpsertRequest request) {
        return ResponseEntity.ok(ApiResponse.success("Match upserted", matchService.upsertMatch(request)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Delete match")
    public ResponseEntity<ApiResponse<Void>> deleteMatch(@PathVariable String id) {
        matchService.deleteMatch(id);
        return ResponseEntity.ok(ApiResponse.success("Match deleted", null));
    }
}
