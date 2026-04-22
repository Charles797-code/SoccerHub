package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.NewsComment;
import com.soccerhub.mapper.NewsCommentMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class NewsCommentService {

    private final NewsCommentMapper commentMapper;
    private final JdbcTemplate jdbcTemplate;

    public void ensureTableExists() {
        try {
            jdbcTemplate.execute("SELECT 1 FROM NEWS_COMMENT WHERE 1=0");
            ensureColumnsExist();
        } catch (Exception e) {
            log.info("NEWS_COMMENT table not found, creating...");
            jdbcTemplate.execute("""
                CREATE TABLE NEWS_COMMENT (
                    COMMENT_ID  NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    ARTICLE_ID  NUMBER        NOT NULL,
                    USER_ID     NUMBER        NOT NULL,
                    CONTENT     VARCHAR2(1000) NOT NULL,
                    IS_DELETED  NUMBER        DEFAULT 0,
                    DELETED_BY  NUMBER,
                    DELETED_AT  TIMESTAMP,
                    CREATED_AT  TIMESTAMP     DEFAULT SYSTIMESTAMP
                )
                """);
            try {
                jdbcTemplate.execute("CREATE INDEX IDX_NEWS_COMMENT_ARTICLE ON NEWS_COMMENT(ARTICLE_ID)");
            } catch (Exception ignored) {}
            log.info("NEWS_COMMENT table created successfully");
        }
    }

    private void ensureColumnsExist() {
        String[][] columns = {
            {"ARTICLE_ID", "NUMBER NOT NULL"},
            {"USER_ID", "NUMBER NOT NULL"},
            {"CONTENT", "VARCHAR2(1000) NOT NULL"},
            {"IS_DELETED", "NUMBER DEFAULT 0"},
            {"DELETED_BY", "NUMBER"},
            {"DELETED_AT", "TIMESTAMP"},
            {"CREATED_AT", "TIMESTAMP DEFAULT SYSTIMESTAMP"}
        };
        for (String[] col : columns) {
            addColumnIfNotExists("NEWS_COMMENT", col[0], col[1]);
        }
    }

    private void addColumnIfNotExists(String table, String column, String definition) {
        try {
            jdbcTemplate.execute("SELECT " + column + " FROM " + table + " WHERE 1=0");
        } catch (Exception e) {
            log.info("Adding column {} to {}", column, table);
            try {
                jdbcTemplate.execute("ALTER TABLE " + table + " ADD " + column + " " + definition);
                log.info("Column {} added successfully", column);
            } catch (Exception ex) {
                log.warn("Failed to add column {}: {}", column, ex.getMessage());
            }
        }
    }

    public Page<NewsComment> getComments(Long articleId, int page, int pageSize) {
        ensureTableExists();
        Page<NewsComment> p = new Page<>(page, pageSize);
        QueryWrapper<NewsComment> wrapper = new QueryWrapper<>();
        wrapper.eq("ARTICLE_ID", articleId);
        wrapper.eq("IS_DELETED", 0);
        wrapper.orderByDesc("CREATED_AT");
        return commentMapper.selectPage(p, wrapper);
    }

    public List<NewsComment> getRecentComments(Long articleId, int limit) {
        ensureTableExists();
        QueryWrapper<NewsComment> wrapper = new QueryWrapper<>();
        wrapper.eq("ARTICLE_ID", articleId);
        wrapper.eq("IS_DELETED", 0);
        wrapper.orderByDesc("CREATED_AT");
        wrapper.last("FETCH FIRST " + limit + " ROWS ONLY");
        List<NewsComment> comments = commentMapper.selectList(wrapper);
        return comments.reversed();
    }

    @Transactional
    public NewsComment addComment(Long articleId, Long userId, String content) {
        ensureTableExists();
        if (content == null || content.trim().isEmpty()) {
            throw new RuntimeException("评论内容不能为空");
        }
        if (content.length() > 1000) {
            throw new RuntimeException("评论内容不能超过1000个字符");
        }
        NewsComment comment = new NewsComment();
        comment.setArticleId(articleId);
        comment.setUserId(userId);
        comment.setContent(content.trim());
        comment.setIsDeleted(0);
        comment.setCreatedAt(LocalDateTime.now());
        commentMapper.insert(comment);
        return comment;
    }

    @Transactional
    public void deleteComment(Long commentId, Long userId, String userRole) {
        ensureTableExists();
        NewsComment comment = commentMapper.selectById(commentId);
        if (comment == null) throw new RuntimeException("评论不存在");
        if (!comment.getUserId().equals(userId) && !"SUPER_ADMIN".equals(userRole)) {
            throw new RuntimeException("您没有权限删除此评论");
        }
        comment.setIsDeleted(1);
        comment.setDeletedBy(userId);
        comment.setDeletedAt(LocalDateTime.now());
        commentMapper.updateById(comment);
    }
}
