package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.entity.NewsArticle;
import com.soccerhub.service.AdminService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/news")
@RequiredArgsConstructor
@Tag(name = "News", description = "News article endpoints")
public class NewsController {

    private final AdminService adminService;

    @GetMapping
    @Operation(summary = "List news articles")
    public ResponseEntity<ApiResponse<PageResponse<NewsArticle>>> listNews(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            @RequestParam(required = false) Long clubId,
            @RequestParam(required = false) String keyword) {
        Page<NewsArticle> result = adminService.listNews(page, pageSize, clubId, keyword);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get article by ID")
    public ResponseEntity<ApiResponse<NewsArticle>> getArticle(@PathVariable Long id) {
        NewsArticle article = adminService.listNews(1, 1, null, null).getRecords().stream()
                .filter(a -> a.getArticleId().equals(id)).findFirst().orElse(null);
        return ResponseEntity.ok(ApiResponse.success(article));
    }

    @PostMapping
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Create news article")
    public ResponseEntity<ApiResponse<NewsArticle>> createNews(@RequestBody NewsArticle article) {
        return ResponseEntity.ok(ApiResponse.success("Article created", adminService.createNews(article)));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Update news article")
    public ResponseEntity<ApiResponse<NewsArticle>> updateNews(
            @PathVariable Long id,
            @RequestBody NewsArticle article) {
        return ResponseEntity.ok(ApiResponse.success("Article updated", adminService.updateNews(id, article)));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN')")
    @Operation(summary = "Delete news article")
    public ResponseEntity<ApiResponse<Void>> deleteNews(@PathVariable Long id) {
        adminService.deleteNews(id);
        return ResponseEntity.ok(ApiResponse.success("Article deleted", null));
    }
}
