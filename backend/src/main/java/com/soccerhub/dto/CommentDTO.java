package com.soccerhub.dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class CommentDTO {
    private Long commentId;
    private Long postId;
    private Long userId;
    private String username;
    private String userNickname;
    private String userAvatar;
    private Long parentId;
    private String content;
    private LocalDateTime createdAt;
    private List<CommentDTO> replies;
}
