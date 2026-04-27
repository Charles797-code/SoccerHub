package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.CircleDTO;
import com.soccerhub.dto.CommentDTO;
import com.soccerhub.dto.PostDTO;
import com.soccerhub.dto.UserProfileDTO;
import com.soccerhub.entity.*;
import com.soccerhub.mapper.*;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class SocialService {

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private ClubMapper clubMapper;

    @Autowired
    private UserFollowMapper followMapper;

    @Autowired
    private PostMapper postMapper;

    @Autowired
    private PostLikeMapper likeMapper;

    @Autowired
    private PostFavoriteMapper favoriteMapper;

    @Autowired
    private CircleMapper circleMapper;

    @Autowired
    private CircleMemberMapper circleMemberMapper;

    @Autowired
    private PostCommentMapper postCommentMapper;

    private final ObjectMapper objectMapper = new ObjectMapper();

    public UserProfileDTO getUserProfile(Long userId, Long currentUserId) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            return null;
        }

        UserProfileDTO dto = new UserProfileDTO();
        dto.setUserId(user.getUserId());
        dto.setUsername(user.getUsername());
        dto.setNickname(user.getNickname());
        dto.setAvatarUrl(user.getAvatarUrl());
        dto.setBio(user.getBio());
        dto.setFavoriteClubId(user.getFavoriteClubId());
        dto.setFollowingCount(followMapper.countFollowing(userId));
        dto.setFollowerCount(followMapper.countFollowers(userId));
        dto.setPostCount(countUserPosts(userId));

        if (user.getFavoriteClubId() != null) {
            Club club = clubMapper.selectById(user.getFavoriteClubId());
            if (club != null) {
                dto.setFavoriteClubName(club.getName());
                dto.setFavoriteClubLogo(club.getLogoUrl());
            }
        }

        if (currentUserId != null && !currentUserId.equals(userId)) {
            dto.setIsFollowing(followMapper.isFollowing(currentUserId, userId) > 0);
        } else {
            dto.setIsFollowing(false);
        }

        return dto;
    }

    @Transactional
    public void updateProfile(Long userId, String nickname, String bio, Long favoriteClubId) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }

        if (nickname != null && !nickname.isEmpty()) {
            user.setNickname(nickname);
        }
        user.setBio(bio);
        user.setFavoriteClubId(favoriteClubId);
        user.setUpdatedAt(LocalDateTime.now());

        userMapper.updateById(user);
    }

    @Transactional
    public boolean toggleFollow(Long followerId, Long followingId) {
        if (followerId.equals(followingId)) {
            throw new RuntimeException("Cannot follow yourself");
        }

        int exists = followMapper.isFollowing(followerId, followingId);
        if (exists > 0) {
            QueryWrapper<UserFollow> wrapper = new QueryWrapper<>();
            wrapper.eq("FOLLOWER_ID", followerId).eq("FOLLOWING_ID", followingId);
            followMapper.delete(wrapper);
            return false;
        } else {
            UserFollow follow = new UserFollow();
            follow.setFollowerId(followerId);
            follow.setFollowingId(followingId);
            follow.setCreatedAt(LocalDateTime.now());
            followMapper.insert(follow);
            return true;
        }
    }

    public Page<UserProfileDTO> getFollowers(Long userId, int page, int pageSize) {
        Page<UserFollow> followPage = new Page<>(page, pageSize);
        QueryWrapper<UserFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("FOLLOWING_ID", userId).orderByDesc("CREATED_AT");
        followMapper.selectPage(followPage, wrapper);

        Page<UserProfileDTO> result = new Page<>(page, pageSize);
        result.setTotal(followPage.getTotal());

        List<UserProfileDTO> list = followPage.getRecords().stream()
                .map(f -> getUserProfile(f.getFollowerId(), userId))
                .collect(Collectors.toList());
        result.setRecords(list);

        return result;
    }

    public Page<UserProfileDTO> getFollowing(Long userId, int page, int pageSize) {
        Page<UserFollow> followPage = new Page<>(page, pageSize);
        QueryWrapper<UserFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("FOLLOWER_ID", userId).orderByDesc("CREATED_AT");
        followMapper.selectPage(followPage, wrapper);

        Page<UserProfileDTO> result = new Page<>(page, pageSize);
        result.setTotal(followPage.getTotal());

        List<UserProfileDTO> list = followPage.getRecords().stream()
                .map(f -> getUserProfile(f.getFollowingId(), userId))
                .collect(Collectors.toList());
        result.setRecords(list);

        return result;
    }

    public List<CircleDTO> getAllCircles(Long currentUserId) {
        QueryWrapper<Circle> wrapper = new QueryWrapper<>();
        wrapper.eq("STATUS", "ACTIVE").orderByDesc("POST_COUNT");
        List<Circle> circles = circleMapper.selectList(wrapper);

        return circles.stream().map(c -> convertToCircleDTO(c, currentUserId)).collect(Collectors.toList());
    }

    public CircleDTO getCircle(Long circleId, Long currentUserId) {
        Circle circle = circleMapper.selectById(circleId);
        if (circle == null) {
            return null;
        }
        return convertToCircleDTO(circle, currentUserId);
    }

    public CircleDTO getMainCircle(Long currentUserId) {
        QueryWrapper<Circle> wrapper = new QueryWrapper<>();
        wrapper.isNull("CLUB_ID").eq("STATUS", "ACTIVE");
        Circle circle = circleMapper.selectOne(wrapper);
        if (circle == null) {
            return null;
        }
        return convertToCircleDTO(circle, currentUserId);
    }

    @Transactional
    public boolean joinCircle(Long circleId, Long userId) {
        if (circleMemberMapper.isMember(circleId, userId) > 0) {
            QueryWrapper<CircleMember> wrapper = new QueryWrapper<>();
            wrapper.eq("CIRCLE_ID", circleId).eq("USER_ID", userId);
            circleMemberMapper.delete(wrapper);
            circleMapper.updateMemberCount(circleId, -1);
            return false;
        } else {
            CircleMember member = new CircleMember();
            member.setCircleId(circleId);
            member.setUserId(userId);
            member.setJoinedAt(LocalDateTime.now());
            circleMemberMapper.insert(member);
            circleMapper.updateMemberCount(circleId, 1);
            return true;
        }
    }

    @Transactional
    public Post createPost(Long userId, String content, List<String> imageUrls, Long clubId, Long circleId) {
        if (circleId != null && circleMemberMapper.isMember(circleId, userId) == 0) {
            throw new RuntimeException("请先加入圈子后再发帖");
        }

        Post post = new Post();
        post.setUserId(userId);
        post.setContent(content);
        if (imageUrls != null && !imageUrls.isEmpty()) {
            try {
                post.setImageUrls(objectMapper.writeValueAsString(imageUrls));
            } catch (JsonProcessingException e) {
                post.setImageUrls("[]");
            }
        }
        post.setClubId(clubId);
        post.setCircleId(circleId);
        post.setLikeCount(0);
        post.setFavoriteCount(0);
        post.setCommentCount(0);
        post.setIsPinned(0);
        post.setIsEssence(0);
        post.setStatus("ACTIVE");
        post.setCreatedAt(LocalDateTime.now());

        postMapper.insert(post);

        if (circleId != null) {
            circleMapper.updatePostCount(circleId, 1);
        }

        return post;
    }

    @Transactional
    public void deletePost(Long postId, Long userId) {
        Post post = postMapper.selectById(postId);
        if (post == null) {
            throw new RuntimeException("Post not found");
        }
        if (!post.getUserId().equals(userId)) {
            throw new RuntimeException("Not authorized to delete this post");
        }

        post.setStatus("DELETED");
        post.setUpdatedAt(LocalDateTime.now());
        postMapper.updateById(post);

        if (post.getCircleId() != null) {
            circleMapper.updatePostCount(post.getCircleId(), -1);
        }
    }

    public Page<PostDTO> getPosts(int page, int pageSize, Long currentUserId) {
        Page<Post> postPage = new Page<>(page, pageSize);
        QueryWrapper<Post> wrapper = new QueryWrapper<>();
        wrapper.eq("STATUS", "ACTIVE").isNull("CIRCLE_ID").orderByDesc("IS_PINNED").orderByDesc("CREATED_AT");
        postMapper.selectPage(postPage, wrapper);

        Page<PostDTO> result = new Page<>(page, pageSize);
        result.setTotal(postPage.getTotal());

        List<PostDTO> list = postPage.getRecords().stream()
                .map(p -> convertToDTO(p, currentUserId))
                .collect(Collectors.toList());
        result.setRecords(list);

        return result;
    }

    public Page<PostDTO> getCirclePosts(Long circleId, int page, int pageSize, Long currentUserId) {
        Page<Post> postPage = new Page<>(page, pageSize);
        QueryWrapper<Post> wrapper = new QueryWrapper<>();
        wrapper.eq("STATUS", "ACTIVE").eq("CIRCLE_ID", circleId).orderByDesc("IS_PINNED").orderByDesc("CREATED_AT");
        postMapper.selectPage(postPage, wrapper);

        Page<PostDTO> result = new Page<>(page, pageSize);
        result.setTotal(postPage.getTotal());

        List<PostDTO> list = postPage.getRecords().stream()
                .map(p -> convertToDTO(p, currentUserId))
                .collect(Collectors.toList());
        result.setRecords(list);

        return result;
    }

    public Page<PostDTO> getUserPosts(Long userId, int page, int pageSize, Long currentUserId) {
        Page<Post> postPage = new Page<>(page, pageSize);
        QueryWrapper<Post> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId).eq("STATUS", "ACTIVE").orderByDesc("CREATED_AT");
        postMapper.selectPage(postPage, wrapper);

        Page<PostDTO> result = new Page<>(page, pageSize);
        result.setTotal(postPage.getTotal());

        List<PostDTO> list = postPage.getRecords().stream()
                .map(p -> convertToDTO(p, currentUserId))
                .collect(Collectors.toList());
        result.setRecords(list);

        return result;
    }

    public PostDTO getPost(Long postId, Long currentUserId) {
        Post post = postMapper.selectById(postId);
        if (post == null || "DELETED".equals(post.getStatus())) {
            return null;
        }
        return convertToDTO(post, currentUserId);
    }

    @Transactional
    public boolean toggleLike(Long postId, Long userId) {
        int exists = likeMapper.hasLiked(postId, userId);
        if (exists > 0) {
            QueryWrapper<PostLike> wrapper = new QueryWrapper<>();
            wrapper.eq("POST_ID", postId).eq("USER_ID", userId);
            likeMapper.delete(wrapper);
            postMapper.updateLikeCount(postId, -1);
            return false;
        } else {
            PostLike like = new PostLike();
            like.setPostId(postId);
            like.setUserId(userId);
            like.setCreatedAt(LocalDateTime.now());
            likeMapper.insert(like);
            postMapper.updateLikeCount(postId, 1);
            return true;
        }
    }

    @Transactional
    public boolean toggleFavorite(Long postId, Long userId) {
        int exists = favoriteMapper.hasFavorited(postId, userId);
        if (exists > 0) {
            QueryWrapper<PostFavorite> wrapper = new QueryWrapper<>();
            wrapper.eq("POST_ID", postId).eq("USER_ID", userId);
            favoriteMapper.delete(wrapper);
            postMapper.updateFavoriteCount(postId, -1);
            return false;
        } else {
            PostFavorite favorite = new PostFavorite();
            favorite.setPostId(postId);
            favorite.setUserId(userId);
            favorite.setCreatedAt(LocalDateTime.now());
            favoriteMapper.insert(favorite);
            postMapper.updateFavoriteCount(postId, 1);
            return true;
        }
    }

    public Page<PostDTO> getFavoritePosts(Long userId, int page, int pageSize) {
        Page<PostFavorite> favPage = new Page<>(page, pageSize);
        QueryWrapper<PostFavorite> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId).orderByDesc("CREATED_AT");
        favoriteMapper.selectPage(favPage, wrapper);

        Page<PostDTO> result = new Page<>(page, pageSize);
        result.setTotal(favPage.getTotal());

        List<PostDTO> list = favPage.getRecords().stream()
                .map(f -> getPost(f.getPostId(), userId))
                .filter(p -> p != null)
                .collect(Collectors.toList());
        result.setRecords(list);

        return result;
    }

    @Transactional
    public void pinPost(Long postId, boolean pinned) {
        Post post = postMapper.selectById(postId);
        if (post == null) {
            throw new RuntimeException("Post not found");
        }
        post.setIsPinned(pinned ? 1 : 0);
        post.setUpdatedAt(LocalDateTime.now());
        postMapper.updateById(post);
    }

    @Transactional
    public void setEssencePost(Long postId, boolean essence) {
        Post post = postMapper.selectById(postId);
        if (post == null) {
            throw new RuntimeException("Post not found");
        }
        post.setIsEssence(essence ? 1 : 0);
        post.setUpdatedAt(LocalDateTime.now());
        postMapper.updateById(post);
    }

    public Page<PostDTO> getEssencePosts(int page, int pageSize, Long currentUserId) {
        Page<Post> postPage = new Page<>(page, pageSize);
        QueryWrapper<Post> wrapper = new QueryWrapper<>();
        wrapper.eq("STATUS", "ACTIVE").eq("IS_ESSENCE", 1).orderByDesc("CREATED_AT");
        postMapper.selectPage(postPage, wrapper);

        Page<PostDTO> result = new Page<>(page, pageSize);
        result.setTotal(postPage.getTotal());

        List<PostDTO> list = postPage.getRecords().stream()
                .map(p -> convertToDTO(p, currentUserId))
                .collect(Collectors.toList());
        result.setRecords(list);

        return result;
    }

    public Page<PostDTO> getAllPostsForAdmin(int page, int pageSize, Long currentUserId) {
        Page<Post> postPage = new Page<>(page, pageSize);
        QueryWrapper<Post> wrapper = new QueryWrapper<>();
        wrapper.ne("STATUS", "DELETED").orderByDesc("CREATED_AT");
        postMapper.selectPage(postPage, wrapper);

        Page<PostDTO> result = new Page<>(page, pageSize);
        result.setTotal(postPage.getTotal());

        List<PostDTO> list = postPage.getRecords().stream()
                .map(p -> convertToDTO(p, currentUserId))
                .collect(Collectors.toList());
        result.setRecords(list);

        return result;
    }

    private CircleDTO convertToCircleDTO(Circle circle, Long currentUserId) {
        CircleDTO dto = new CircleDTO();
        dto.setCircleId(circle.getCircleId());
        dto.setClubId(circle.getClubId());
        dto.setName(circle.getName());
        dto.setDescription(circle.getDescription());
        dto.setLogoUrl(circle.getLogoUrl());
        dto.setMemberCount(circle.getMemberCount());
        dto.setPostCount(circle.getPostCount());
        dto.setStatus(circle.getStatus());

        if (circle.getClubId() != null) {
            Club club = clubMapper.selectById(circle.getClubId());
            if (club != null) {
                dto.setClubName(club.getName());
                if (dto.getLogoUrl() == null || dto.getLogoUrl().isEmpty()) {
                    dto.setLogoUrl(club.getLogoUrl());
                }
            }
        }

        if (currentUserId != null) {
            dto.setIsMember(circleMemberMapper.isMember(circle.getCircleId(), currentUserId) > 0);
        } else {
            dto.setIsMember(false);
        }

        return dto;
    }

    private PostDTO convertToDTO(Post post, Long currentUserId) {
        PostDTO dto = new PostDTO();
        dto.setPostId(post.getPostId());
        dto.setUserId(post.getUserId());
        dto.setContent(post.getContent());
        dto.setClubId(post.getClubId());
        dto.setCircleId(post.getCircleId());
        dto.setLikeCount(post.getLikeCount());
        dto.setFavoriteCount(post.getFavoriteCount());
        dto.setCommentCount(post.getCommentCount());
        dto.setIsPinned(post.getIsPinned() != null && post.getIsPinned() == 1);
        dto.setIsEssence(post.getIsEssence() != null && post.getIsEssence() == 1);
        dto.setCreatedAt(post.getCreatedAt());
        dto.setUpdatedAt(post.getUpdatedAt());

        if (post.getImageUrls() != null && !post.getImageUrls().isEmpty()) {
            try {
                List<String> urls = objectMapper.readValue(post.getImageUrls(), new TypeReference<List<String>>() {});
                dto.setImageUrls(urls);
            } catch (JsonProcessingException e) {
                dto.setImageUrls(new ArrayList<>());
            }
        } else {
            dto.setImageUrls(new ArrayList<>());
        }

        SysUser user = userMapper.selectById(post.getUserId());
        if (user != null) {
            dto.setUsername(user.getUsername());
            dto.setUserNickname(user.getNickname());
            dto.setUserAvatar(user.getAvatarUrl());
            dto.setUserFavoriteClubId(user.getFavoriteClubId());

            if (user.getFavoriteClubId() != null) {
                Club favClub = clubMapper.selectById(user.getFavoriteClubId());
                if (favClub != null) {
                    dto.setUserFavoriteClubName(favClub.getName());
                    dto.setUserFavoriteClubLogo(favClub.getLogoUrl());
                }
            }
        }

        if (post.getClubId() != null) {
            Club club = clubMapper.selectById(post.getClubId());
            if (club != null) {
                dto.setClubName(club.getName());
                dto.setClubLogo(club.getLogoUrl());
            }
        }

        if (post.getCircleId() != null) {
            Circle circle = circleMapper.selectById(post.getCircleId());
            if (circle != null) {
                dto.setCircleName(circle.getName());
            }
        }

        if (currentUserId != null) {
            dto.setIsLiked(likeMapper.hasLiked(post.getPostId(), currentUserId) > 0);
            dto.setIsFavorited(favoriteMapper.hasFavorited(post.getPostId(), currentUserId) > 0);
            if (!post.getUserId().equals(currentUserId)) {
                dto.setIsFollowing(followMapper.isFollowing(currentUserId, post.getUserId()) > 0);
            } else {
                dto.setIsFollowing(false);
            }
        } else {
            dto.setIsLiked(false);
            dto.setIsFavorited(false);
            dto.setIsFollowing(false);
        }

        return dto;
    }

    private int countUserPosts(Long userId) {
        QueryWrapper<Post> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId).eq("STATUS", "ACTIVE");
        return Math.toIntExact(postMapper.selectCount(wrapper));
    }

    public Page<CommentDTO> getPostComments(Long postId, int page, int pageSize) {
        Page<PostComment> p = new Page<>(page, pageSize);
        QueryWrapper<PostComment> wrapper = new QueryWrapper<>();
        wrapper.eq("POST_ID", postId).eq("IS_DELETED", 0).orderByDesc("CREATED_AT");
        Page<PostComment> result = postCommentMapper.selectPage(p, wrapper);

        Page<CommentDTO> pageDto = new Page<>(result.getCurrent(), result.getSize(), result.getTotal());
        List<CommentDTO> dtoList = result.getRecords().stream().map(c -> {
            CommentDTO dto = new CommentDTO();
            dto.setCommentId(c.getCommentId());
            dto.setPostId(c.getPostId());
            dto.setUserId(c.getUserId());
            dto.setContent(c.getContent());
            dto.setParentId(c.getParentId());
            dto.setCreatedAt(c.getCreatedAt());
            SysUser user = userMapper.selectById(c.getUserId());
            if (user != null) {
                dto.setUsername(user.getUsername());
                dto.setUserNickname(user.getNickname());
                dto.setUserAvatar(user.getAvatarUrl());
            }
            return dto;
        }).collect(Collectors.toList());
        pageDto.setRecords(dtoList);
        return pageDto;
    }

    @Transactional
    public CommentDTO addComment(Long postId, Long userId, String content, Long parentId) {
        PostComment comment = new PostComment();
        comment.setPostId(postId);
        comment.setUserId(userId);
        comment.setContent(content);
        comment.setParentId(parentId);
        comment.setIsDeleted(0);
        comment.setCreatedAt(LocalDateTime.now());
        postCommentMapper.insert(comment);
        postMapper.updateCommentCount(postId, 1);

        CommentDTO dto = new CommentDTO();
        dto.setCommentId(comment.getCommentId());
        dto.setPostId(postId);
        dto.setUserId(userId);
        dto.setContent(content);
        dto.setParentId(parentId);
        dto.setCreatedAt(comment.getCreatedAt());
        SysUser user = userMapper.selectById(userId);
        if (user != null) {
            dto.setUsername(user.getUsername());
            dto.setUserNickname(user.getNickname());
            dto.setUserAvatar(user.getAvatarUrl());
        }
        return dto;
    }

    @Transactional
    public void deleteComment(Long commentId, Long userId, boolean isAdmin) {
        PostComment comment = postCommentMapper.selectById(commentId);
        if (comment == null) {
            throw new RuntimeException("Comment not found");
        }
        if (!isAdmin && !comment.getUserId().equals(userId)) {
            throw new RuntimeException("Not authorized to delete this comment");
        }
        comment.setIsDeleted(1);
        comment.setUpdatedAt(LocalDateTime.now());
        postCommentMapper.updateById(comment);
        // Update post comment count
        postMapper.updateCommentCount(comment.getPostId(), -1);
    }
}
