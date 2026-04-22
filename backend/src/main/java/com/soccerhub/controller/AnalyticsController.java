package com.soccerhub.controller;

import com.soccerhub.dto.AnalyticsStats;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.service.AnalyticsService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/analytics")
@RequiredArgsConstructor
@Tag(name = "Analytics", description = "Analytics and import/export endpoints")
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @GetMapping("/stats")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Get comprehensive analytics statistics")
    public ResponseEntity<ApiResponse<AnalyticsStats>> getAnalytics() {
        return ResponseEntity.ok(ApiResponse.success(analyticsService.getAnalytics()));
    }

    @GetMapping("/export/{type}")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Export data as Excel or CSV")
    public ResponseEntity<byte[]> exportData(
            @PathVariable String type,
            @RequestParam(defaultValue = "xlsx") String format) throws Exception {
        byte[] data;
        String contentType;
        String extension;

        if ("csv".equalsIgnoreCase(format)) {
            data = analyticsService.exportCsv(type);
            contentType = "text/csv";
            extension = ".csv";
        } else {
            data = analyticsService.exportExcel(type);
            contentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
            extension = ".xlsx";
        }

        String filename = URLEncoder.encode(type + "_" + System.currentTimeMillis() + extension, StandardCharsets.UTF_8);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=" + filename)
                .contentType(MediaType.parseMediaType(contentType))
                .body(data);
    }

    @PostMapping("/import/players")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Import players from Excel file")
    public ResponseEntity<ApiResponse<Integer>> importPlayers(@RequestParam("file") MultipartFile file) throws Exception {
        if (file.isEmpty()) return ResponseEntity.badRequest().body(ApiResponse.error("文件为空"));
        int count = analyticsService.importPlayersFromExcel(file.getBytes());
        return ResponseEntity.ok(ApiResponse.success("成功导入 " + count + " 条球员数据", count));
    }

    @PostMapping("/import/matches")
    @PreAuthorize("hasRole('SUPER_ADMIN')")
    @Operation(summary = "Import matches from Excel file")
    public ResponseEntity<ApiResponse<Integer>> importMatches(@RequestParam("file") MultipartFile file) throws Exception {
        if (file.isEmpty()) return ResponseEntity.badRequest().body(ApiResponse.error("文件为空"));
        int count = analyticsService.importMatchesFromExcel(file.getBytes());
        return ResponseEntity.ok(ApiResponse.success("成功导入 " + count + " 条比赛数据", count));
    }
}
