package com.soccerhub.dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;

@Data
public class PostDTO {
    private Long postId;
    private Long userId;
    private String username;
    private String userNickname;
    private String userAvatar;
    private Long userFavoriteClubId;
    private String userFavoriteClubName;
    private String userFavoriteClubLogo;
    private String content;
    private List<String> imageUrls;
    private Long clubId;
    private String clubName;
    private String clubLogo;
    private Long circleId;
    private String circleName;
    private Integer likeCount;
    private Integer favoriteCount;
    private Integer commentCount;
    private Boolean isPinned;
    private Boolean isEssence;
    private Boolean isLiked;
    private Boolean isFavorited;
    private Boolean isFollowing;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
