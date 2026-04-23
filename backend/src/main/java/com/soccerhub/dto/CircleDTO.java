package com.soccerhub.dto;

import lombok.Data;

@Data
public class CircleDTO {
    private Long circleId;
    private Long clubId;
    private String clubName;
    private String name;
    private String description;
    private String logoUrl;
    private Integer memberCount;
    private Integer postCount;
    private String status;
    private Boolean isMember;
}
