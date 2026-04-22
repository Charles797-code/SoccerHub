package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.entity.Coach;
import com.soccerhub.service.CoachService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/coaches")
@RequiredArgsConstructor
@Tag(name = "Coaches", description = "Coach management endpoints")
public class CoachController {

    private final CoachService coachService;

    @GetMapping
    @Operation(summary = "List coaches")
    public ResponseEntity<ApiResponse<PageResponse<Coach>>> listCoaches(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) Long clubId) {
        Page<Coach> result = coachService.listCoaches(page, pageSize, clubId);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get coach by ID")
    public ResponseEntity<ApiResponse<Coach>> getCoach(@PathVariable Long id) {
        Coach coach = coachService.getCoachById(id);
        if (coach == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(ApiResponse.success(coach));
    }

    @GetMapping("/rankings")
    @Operation(summary = "Get coach rankings")
    public ResponseEntity<ApiResponse<PageResponse<Coach>>> getRankings(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Page<Coach> result = coachService.getRankings(page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Create coach")
    public ResponseEntity<ApiResponse<Coach>> createCoach(@RequestBody Coach coach) {
        return ResponseEntity.ok(ApiResponse.success("Coach created", coachService.createCoach(coach)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Update coach")
    public ResponseEntity<ApiResponse<Coach>> updateCoach(@PathVariable Long id, @RequestBody Coach coach) {
        return ResponseEntity.ok(ApiResponse.success("Coach updated", coachService.updateCoach(id, coach)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Delete coach")
    public ResponseEntity<ApiResponse<Void>> deleteCoach(@PathVariable Long id) {
        coachService.deleteCoach(id);
        return ResponseEntity.ok(ApiResponse.success("Coach deleted", null));
    }
}
