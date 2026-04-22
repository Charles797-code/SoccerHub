package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.entity.NewsArticle;
import com.soccerhub.entity.NewsComment;
import com.soccerhub.service.AdminService;
import com.soccerhub.service.AuthService;
import com.soccerhub.service.NewsCommentService;
import com.soccerhub.service.NewsScraperService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/news")
@RequiredArgsConstructor
@Tag(name = "News", description = "News article endpoints")
public class NewsController {

    private final AdminService adminService;
    private final AuthService authService;
    private final NewsScraperService scraperService;
    private final NewsCommentService commentService;

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
    @Operation(summary = "Get article by ID with view count increment")
    public ResponseEntity<ApiResponse<NewsArticle>> getArticle(@PathVariable Long id) {
        scraperService.incrementViewCount(id);
        NewsArticle article = scraperService.scrapeArticleDetail(id);
        return ResponseEntity.ok(ApiResponse.success(article));
    }

    @PostMapping("/scrape")
    @PreAuthorize("hasAnyRole('SUPER_ADMIN', 'CLUB_ADMIN')")
    @Operation(summary = "Scrape latest football news")
    public ResponseEntity<ApiResponse<List<NewsArticle>>> scrapeNews() {
        List<NewsArticle> articles = scraperService.scrapeFromDongqiudi();
        if (articles.isEmpty()) {
            articles = scraperService.scrapeFromSinaSports();
        }
        return ResponseEntity.ok(ApiResponse.success("Scraped " + articles.size() + " articles", articles));
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

    @GetMapping("/{articleId}/comments")
    @Operation(summary = "Get comments for an article")
    public ResponseEntity<ApiResponse<PageResponse<NewsComment>>> getComments(
            @PathVariable Long articleId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Page<NewsComment> result = commentService.getComments(articleId, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @PostMapping("/{articleId}/comments")
    @Operation(summary = "Add comment to an article")
    public ResponseEntity<ApiResponse<NewsComment>> addComment(
            @PathVariable Long articleId,
            @RequestBody Map<String, String> body,
            Authentication authentication) {
        Long userId = authService.getCurrentUser(authentication.getName()).getUserId();
        NewsComment comment = commentService.addComment(articleId, userId, body.get("content"));
        return ResponseEntity.ok(ApiResponse.success("Comment added", comment));
    }

    @DeleteMapping("/comments/{commentId}")
    @Operation(summary = "Delete a comment")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @PathVariable Long commentId,
            Authentication authentication) {
        Long userId = authService.getCurrentUser(authentication.getName()).getUserId();
        String role = authentication.getAuthorities().iterator().next().getAuthority().replace("ROLE_", "");
        commentService.deleteComment(commentId, userId, role);
        return ResponseEntity.ok(ApiResponse.success("Comment deleted", null));
    }
}
