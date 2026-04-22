package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.ApiResponse;
import com.soccerhub.dto.ChatMessageRequest;
import com.soccerhub.dto.ChatMessageVO;
import com.soccerhub.dto.PageResponse;
import com.soccerhub.entity.SysUser;
import com.soccerhub.service.AuthService;
import com.soccerhub.service.ChatService;
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
@RequestMapping("/chat")
@RequiredArgsConstructor
@Tag(name = "Chat", description = "Club chat endpoints")
public class ChatController {

    private final ChatService chatService;
    private final AuthService authService;

    @GetMapping("/{clubId}/messages")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get chat messages for a club")
    public ResponseEntity<ApiResponse<PageResponse<ChatMessageVO>>> getMessages(
            @PathVariable Long clubId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int pageSize) {
        Page<ChatMessageVO> result = chatService.getMessages(clubId, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(
                PageResponse.of(result.getRecords(), result.getTotal(), (long) result.getCurrent(), (long) result.getSize())));
    }

    @GetMapping("/{clubId}/recent")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Get recent messages for a club")
    public ResponseEntity<ApiResponse<List<ChatMessageVO>>> getRecentMessages(
            @PathVariable Long clubId,
            @RequestParam(defaultValue = "50") int limit) {
        return ResponseEntity.ok(ApiResponse.success(chatService.getRecentMessages(clubId, limit)));
    }

    @PostMapping("/{clubId}/messages")
    @PreAuthorize("isAuthenticated()")
    @Operation(summary = "Send a chat message")
    public ResponseEntity<ApiResponse<ChatMessageVO>> sendMessage(
            @PathVariable Long clubId,
            @Valid @RequestBody ChatMessageRequest request,
            Authentication authentication) {
        try {
            SysUser user = authService.getCurrentUser(authentication.getName());
            ChatMessageVO message = chatService.sendMessage(
                    clubId, user.getUserId(), request.getContent(), request.getMessageType());
            return ResponseEntity.ok(ApiResponse.success("Message sent", message));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{clubId}/messages/{messageId}")
    @PreAuthorize("hasAnyRole('CLUB_ADMIN', 'SUPER_ADMIN')")
    @Operation(summary = "Delete a message (admin)")
    public ResponseEntity<ApiResponse<Void>> deleteMessage(
            @PathVariable Long clubId,
            @PathVariable Long messageId,
            Authentication authentication) {
        try {
            SysUser user = authService.getCurrentUser(authentication.getName());
            chatService.deleteMessage(messageId, user.getUserId(), user.getManagedClubId(), user.getRole());
            return ResponseEntity.ok(ApiResponse.success("Message deleted", null));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
