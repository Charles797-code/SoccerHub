package com.soccerhub.dto;

import lombok.Data;

@Data
public class UpdateProfileRequest {
    private String nickname;
    private String bio;
    private Long favoriteClubId;
}
