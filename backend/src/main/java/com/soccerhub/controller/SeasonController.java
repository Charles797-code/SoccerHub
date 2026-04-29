package com.soccerhub.controller;

import com.soccerhub.dto.ApiResponse;
import com.soccerhub.entity.Season;
import com.soccerhub.service.SeasonService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/seasons")
@RequiredArgsConstructor
public class SeasonController {
    private final SeasonService seasonService;
    private final org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    @PostMapping("/init-db")
    public ResponseEntity<ApiResponse<String>> initDb() {
        try {
            jdbcTemplate.execute("CREATE TABLE SEASON (" +
                "SEASON_ID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY, " +
                "LEAGUE VARCHAR2(100) NOT NULL, " +
                "SEASON_NAME VARCHAR2(50) NOT NULL, " +
                "START_YEAR VARCHAR2(4), " +
                "END_YEAR VARCHAR2(4), " +
                "STATUS VARCHAR2(20) DEFAULT 'ACTIVE', " +
                "TOTAL_ROUNDS NUMBER DEFAULT 38, " +
                "CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                "UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
            return ResponseEntity.ok(ApiResponse.success("Season table created", null));
        } catch (Exception e) {
            if (e.getMessage() != null && e.getMessage().contains("ORA-00955")) {
                return ResponseEntity.ok(ApiResponse.success("Season table already exists", null));
            }
            return ResponseEntity.ok(ApiResponse.success("Error: " + e.getMessage(), null));
        }
    }

    @PostMapping("/seed")
    public ResponseEntity<ApiResponse<String>> seedSeasons() {
        try {
            String[] leagues = {"Bundesliga", "La Liga", "Ligue 1", "Premier League", "Serie A"};
            int[] rounds = {34, 38, 34, 38, 38};
            for (int i = 0; i < leagues.length; i++) {
                jdbcTemplate.execute("MERGE INTO SEASON S USING DUAL ON (S.LEAGUE = '" + leagues[i] + "') " +
                    "WHEN NOT MATCHED THEN INSERT (LEAGUE, SEASON_NAME, START_YEAR, END_YEAR, STATUS, TOTAL_ROUNDS) " +
                    "VALUES ('" + leagues[i] + "', '2025-2026', '2025', '2026', 'ACTIVE', " + rounds[i] + ")");
            }
            return ResponseEntity.ok(ApiResponse.success("Seasons seeded", null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Season>>> getAllSeasons() {
        try {
            List<Season> seasons = seasonService.getAllSeasons();
            return ResponseEntity.ok(ApiResponse.success(seasons));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }

    @GetMapping("/active")
    public ResponseEntity<ApiResponse<List<Season>>> getActiveSeasons() {
        try {
            return ResponseEntity.ok(ApiResponse.success(seasonService.getAllActiveSeasons()));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }

    @GetMapping("/league/{league}")
    public ResponseEntity<ApiResponse<List<Season>>> getSeasonsByLeague(@PathVariable String league) {
        try {
            return ResponseEntity.ok(ApiResponse.success(seasonService.getSeasonsByLeague(league)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }

    @GetMapping("/active/{league}")
    public ResponseEntity<ApiResponse<Season>> getActiveSeason(@PathVariable String league) {
        try {
            Season season = seasonService.getActiveSeason(league);
            if (season == null) {
                return ResponseEntity.ok(ApiResponse.success("No active season", null));
            }
            return ResponseEntity.ok(ApiResponse.success(season));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }

    @PostMapping
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<Season>> createSeason(@RequestBody Season season) {
        try {
            return ResponseEntity.ok(ApiResponse.success("Season created", seasonService.createSeason(season)));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }

    @PostMapping("/start-new")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<String>> startNewSeason(@RequestBody Map<String, Object> request) {
        try {
            String league = (String) request.get("league");
            String seasonName = (String) request.get("seasonName");
            int totalRounds = request.get("totalRounds") != null ? ((Number) request.get("totalRounds")).intValue() : 38;
            seasonService.startNewSeason(league, seasonName, totalRounds);
            return ResponseEntity.ok(ApiResponse.success("New season started for " + league, null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }

    @PostMapping("/reset/{league}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<String>> resetSeasonData(@PathVariable String league) {
        try {
            seasonService.resetSeasonData(league);
            return ResponseEntity.ok(ApiResponse.success("Season data reset for " + league, null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }

    @PutMapping("/finish/{league}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    public ResponseEntity<ApiResponse<String>> finishSeason(@PathVariable String league) {
        try {
            seasonService.finishSeason(league);
            return ResponseEntity.ok(ApiResponse.success("Season finished for " + league, null));
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Error: " + e.getMessage()));
        }
    }
}