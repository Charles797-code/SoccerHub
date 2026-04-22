package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.entity.Club;
import com.soccerhub.entity.Coach;
import com.soccerhub.entity.Player;
import com.soccerhub.service.ClubService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/clubs")
@RequiredArgsConstructor
@Tag(name = "Clubs", description = "Club management endpoints")
public class ClubController {

    private final ClubService clubService;

    @GetMapping
    @Operation(summary = "List all clubs (paginated)")
    public ResponseEntity<ApiResponse<PageResponse<Club>>> listClubs(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) String league,
            @RequestParam(required = false) String keyword) {
        Page<Club> result = clubService.listClubs(page, pageSize, league, keyword);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get club by ID")
    public ResponseEntity<ApiResponse<Club>> getClub(@PathVariable Long id) {
        Club club = clubService.getClubById(id);
        if (club == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(ApiResponse.success(club));
    }

    @GetMapping("/{id}/players")
    @Operation(summary = "Get club players")
    public ResponseEntity<ApiResponse<PageResponse<Player>>> getClubPlayers(
            @PathVariable Long id,
            @RequestParam(required = false) String position,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int pageSize) {
        Page<Player> result = clubService.getClubPlayersPaged(id, position, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/{id}/coaches")
    @Operation(summary = "Get club coaches")
    public ResponseEntity<ApiResponse<List<Coach>>> getClubCoaches(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(clubService.getClubCoaches(id)));
    }

    @GetMapping("/{id}/followers/count")
    @Operation(summary = "Get club follower count")
    public ResponseEntity<ApiResponse<Long>> getFollowerCount(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.success(clubService.getClubFollowerCount(id)));
    }

    @GetMapping("/leagues")
    @Operation(summary = "Get all available leagues")
    public ResponseEntity<ApiResponse<List<String>>> getLeagues() {
        return ResponseEntity.ok(ApiResponse.success(clubService.getAllLeagues()));
    }

    @PostMapping
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Create a new club")
    public ResponseEntity<ApiResponse<Club>> createClub(@RequestBody Club club) {
        return ResponseEntity.ok(ApiResponse.success("Club created", clubService.createClub(club)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Update club")
    public ResponseEntity<ApiResponse<Club>> updateClub(@PathVariable Long id, @RequestBody Club club) {
        return ResponseEntity.ok(ApiResponse.success("Club updated", clubService.updateClub(id, club)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Delete club")
    public ResponseEntity<ApiResponse<Void>> deleteClub(@PathVariable Long id) {
        clubService.deleteClub(id);
        return ResponseEntity.ok(ApiResponse.success("Club deleted", null));
    }
}
