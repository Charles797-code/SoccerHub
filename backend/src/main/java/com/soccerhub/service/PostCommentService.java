package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.CommentDTO;
import com.soccerhub.entity.Post;
import com.soccerhub.entity.PostComment;
import com.soccerhub.entity.SysUser;
import com.soccerhub.mapper.PostCommentMapper;
import com.soccerhub.mapper.PostMapper;
import com.soccerhub.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostCommentService {
    private final PostCommentMapper commentMapper;
    private final PostMapper postMapper;
    private final SysUserMapper userMapper;

    public Page<CommentDTO> getComments(Long postId, int page, int pageSize) {
        QueryWrapper<PostComment> wrapper = new QueryWrapper<>();
        wrapper.eq("POST_ID", postId).eq("IS_DELETED", 0).isNull("PARENT_ID");
        wrapper.orderByDesc("CREATED_AT");
        
        Page<PostComment> pageObj = new Page<>(page, pageSize);
        Page<PostComment> result = commentMapper.selectPage(pageObj, wrapper);
        
        List<CommentDTO> dtos = result.getRecords().stream()
                .map(this::toDTO)
                .collect(Collectors.toList());
        
        dtos.forEach(dto -> dto.setReplies(getReplies(dto.getCommentId())));
        
        Page<CommentDTO> dtoPage = new Page<>(result.getCurrent(), result.getSize(), result.getTotal());
        dtoPage.setRecords(dtos);
        return dtoPage;
    }

    private List<CommentDTO> getReplies(Long parentId) {
        QueryWrapper<PostComment> wrapper = new QueryWrapper<>();
        wrapper.eq("PARENT_ID", parentId).eq("IS_DELETED", 0);
        wrapper.orderByAsc("CREATED_AT");
        
        List<PostComment> replies = commentMapper.selectList(wrapper);
        return replies.stream().map(this::toDTO).collect(Collectors.toList());
    }

    private CommentDTO toDTO(PostComment comment) {
        CommentDTO dto = new CommentDTO();
        dto.setCommentId(comment.getCommentId());
        dto.setPostId(comment.getPostId());
        dto.setUserId(comment.getUserId());
        dto.setParentId(comment.getParentId());
        dto.setContent(comment.getContent());
        dto.setCreatedAt(comment.getCreatedAt());
        
        SysUser user = userMapper.selectById(comment.getUserId());
        if (user != null) {
            dto.setUsername(user.getUsername());
            dto.setUserAvatar(user.getAvatarUrl());
        }
        
        return dto;
    }

    @Transactional
    public CommentDTO addComment(Long postId, Long userId, String content, Long parentId) {
        PostComment comment = new PostComment();
        comment.setPostId(postId);
        comment.setUserId(userId);
        comment.setContent(content);
        comment.setParentId(parentId);
        comment.setCreatedAt(LocalDateTime.now());
        comment.setUpdatedAt(LocalDateTime.now());
        comment.setIsDeleted(0);
        
        commentMapper.insert(comment);
        
        Post post = postMapper.selectById(postId);
        if (post != null) {
            post.setCommentCount((post.getCommentCount() == null ? 0 : post.getCommentCount()) + 1);
            postMapper.updateById(post);
        }
        
        return toDTO(comment);
    }

    @Transactional
    public void deleteComment(Long commentId, Long userId, String role) {
        PostComment comment = commentMapper.selectById(commentId);
        if (comment == null) return;
        
        if (!comment.getUserId().equals(userId) && !"SUPER_ADMIN".equals(role)) {
            throw new RuntimeException("无权删除此评论");
        }
        
        comment.setIsDeleted(1);
        comment.setUpdatedAt(LocalDateTime.now());
        commentMapper.updateById(comment);
    }

    public int getCommentCount(Long postId) {
        QueryWrapper<PostComment> wrapper = new QueryWrapper<>();
        wrapper.eq("POST_ID", postId).eq("IS_DELETED", 0);
        return Math.toIntExact(commentMapper.selectCount(wrapper));
    }
}
