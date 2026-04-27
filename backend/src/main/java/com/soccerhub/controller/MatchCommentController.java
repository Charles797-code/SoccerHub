package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.entity.MatchComment;
import com.soccerhub.entity.SysUser;
import com.soccerhub.service.AuthService;
import com.soccerhub.service.MatchCommentService;
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
@RequestMapping("/matches/{matchId}/comments")
@RequiredArgsConstructor
@Tag(name = "Match Comments", description = "Match comment/chat endpoints")
public class MatchCommentController {

    private final MatchCommentService commentService;
    private final AuthService authService;

    @GetMapping
    @Operation(summary = "Get comments for a match")
    public ResponseEntity<ApiResponse<PageResponse<MatchComment>>> getComments(
            @PathVariable String matchId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        Page<MatchComment> result = commentService.getComments(matchId, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/recent")
    @Operation(summary = "Get recent comments for a match")
    public ResponseEntity<ApiResponse<List<MatchComment>>> getRecentComments(
            @PathVariable String matchId,
            @RequestParam(defaultValue = "50") int limit) {
        return ResponseEntity.ok(ApiResponse.success(commentService.getRecentComments(matchId, limit)));
    }

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Add a comment to a match")
    public ResponseEntity<ApiResponse<MatchComment>> addComment(
            @PathVariable String matchId,
            @RequestBody Map<String, String> body,
            Authentication authentication) {
        try {
            SysUser user = authService.getCurrentUser(authentication.getName());
            String content = body.get("content");
            MatchComment comment = commentService.addComment(matchId, user.getUserId(), content);
            return ResponseEntity.ok(ApiResponse.success("评论发送成功", comment));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{commentId}")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Delete a comment")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @PathVariable String matchId,
            @PathVariable Long commentId,
            Authentication authentication) {
        try {
            SysUser user = authService.getCurrentUser(authentication.getName());
            commentService.deleteComment(commentId, user.getUserId(), user.getRole());
            return ResponseEntity.ok(ApiResponse.success("评论已删除", null));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
