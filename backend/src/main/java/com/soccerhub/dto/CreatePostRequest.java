package com.soccerhub.dto;

import lombok.Data;
import java.util.List;

@Data
public class CreatePostRequest {
    private String content;
    private List<String> imageUrls;
    private Long clubId;
    private Long circleId;
}
