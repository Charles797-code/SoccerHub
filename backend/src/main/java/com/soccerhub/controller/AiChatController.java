package com.soccerhub.controller;

import com.soccerhub.dto.ApiResponse;
import com.soccerhub.service.AiChatService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
@Tag(name = "AI Chat", description = "AI chatbot endpoints")
public class AiChatController {

    private final AiChatService aiChatService;

    @PostMapping("/chat")
    @Operation(summary = "Chat with Hub球宝 AI assistant")
    public ResponseEntity<ApiResponse<String>> chat(@RequestBody Map<String, String> request) {
        String message = request.get("message");
        if (message == null || message.trim().isEmpty()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Message cannot be empty"));
        }
        String reply = aiChatService.chat(message);
        return ResponseEntity.ok(ApiResponse.success(reply));
    }
}
