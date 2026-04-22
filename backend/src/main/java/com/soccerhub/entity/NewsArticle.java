package com.soccerhub.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("NEWS_ARTICLE")
public class NewsArticle {
    @TableId(value = "ARTICLE_ID", type = IdType.AUTO)
    private Long articleId;
    private String title;
    private String summary;
    private String content;
    private Long authorId;
    private Long clubId;
    private String tags;
    private String coverImageUrl;
    private Integer viewCount;
    private Boolean isPublished;
    private LocalDateTime publishedAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
