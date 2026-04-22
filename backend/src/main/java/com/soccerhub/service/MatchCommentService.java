package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.MatchComment;
import com.soccerhub.mapper.MatchCommentMapper;
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
public class MatchCommentService {

    private final MatchCommentMapper commentMapper;
    private final JdbcTemplate jdbcTemplate;

    public void ensureTableExists() {
        try {
            jdbcTemplate.execute("SELECT 1 FROM MATCH_COMMENT WHERE 1=0");
        } catch (Exception e) {
            log.info("MATCH_COMMENT table not found, creating...");
            jdbcTemplate.execute("""
                CREATE TABLE MATCH_COMMENT (
                    COMMENT_ID  NUMBER        GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
                    MATCH_ID    VARCHAR2(50)  NOT NULL,
                    USER_ID     NUMBER        NOT NULL,
                    CONTENT     VARCHAR2(1000) NOT NULL,
                    IS_DELETED  NUMBER        DEFAULT 0,
                    DELETED_BY  NUMBER,
                    DELETED_AT  TIMESTAMP,
                    CREATED_AT  TIMESTAMP     DEFAULT SYSTIMESTAMP
                )
                """);
            jdbcTemplate.execute("CREATE INDEX IDX_MATCH_COMMENT_MATCH ON MATCH_COMMENT(MATCH_ID)");
            log.info("MATCH_COMMENT table created successfully");
        }
    }

    public Page<MatchComment> getComments(String matchId, int page, int pageSize) {
        ensureTableExists();
        Page<MatchComment> p = new Page<>(page, pageSize);
        QueryWrapper<MatchComment> wrapper = new QueryWrapper<>();
        wrapper.eq("MATCH_ID", matchId);
        wrapper.eq("IS_DELETED", 0);
        wrapper.orderByDesc("CREATED_AT");
        return commentMapper.selectPage(p, wrapper);
    }

    public List<MatchComment> getRecentComments(String matchId, int limit) {
        ensureTableExists();
        QueryWrapper<MatchComment> wrapper = new QueryWrapper<>();
        wrapper.eq("MATCH_ID", matchId);
        wrapper.eq("IS_DELETED", 0);
        wrapper.orderByDesc("CREATED_AT");
        wrapper.last("FETCH FIRST " + limit + " ROWS ONLY");
        List<MatchComment> comments = commentMapper.selectList(wrapper);
        return comments.reversed();
    }

    @Transactional
    public MatchComment addComment(String matchId, Long userId, String content) {
        ensureTableExists();
        if (content == null || content.trim().isEmpty()) {
            throw new RuntimeException("评论内容不能为空");
        }
        if (content.length() > 1000) {
            throw new RuntimeException("评论内容不能超过1000个字符");
        }
        MatchComment comment = new MatchComment();
        comment.setMatchId(matchId);
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
        MatchComment comment = commentMapper.selectById(commentId);
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
