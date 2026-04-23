package com.soccerhub.dto;

import lombok.Data;

@Data
public class UserProfileDTO {
    private Long userId;
    private String username;
    private String nickname;
    private String avatarUrl;
    private String bio;
    private Long favoriteClubId;
    private String favoriteClubName;
    private String favoriteClubLogo;
    private Integer followingCount;
    private Integer followerCount;
    private Integer postCount;
    private Boolean isFollowing;
}
