package com.soccerhub.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.*;
import com.soccerhub.entity.Post;
import com.soccerhub.entity.SysUser;
import com.soccerhub.service.AuthService;
import com.soccerhub.service.SocialService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/social")
public class SocialController {

    @Autowired
    private SocialService socialService;

    @Autowired
    private AuthService authService;

    @GetMapping("/user/{userId}")
    public ResponseEntity<?> getUserProfile(@PathVariable Long userId, Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        UserProfileDTO profile = socialService.getUserProfile(userId, currentUserId);
        if (profile == null) {
            return ResponseEntity.ok(ApiResponse.error("User not found"));
        }
        return ResponseEntity.ok(ApiResponse.success(profile));
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @RequestBody UpdateProfileRequest request,
            Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }

        socialService.updateProfile(userId, request.getNickname(), request.getBio(), request.getFavoriteClubId());
        UserProfileDTO profile = socialService.getUserProfile(userId, userId);
        return ResponseEntity.ok(ApiResponse.success(profile));
    }

    @PostMapping("/follow/{userId}")
    public ResponseEntity<?> toggleFollow(@PathVariable Long userId, Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        if (currentUserId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }

        boolean isFollowing = socialService.toggleFollow(currentUserId, userId);
        Map<String, Object> data = new HashMap<>();
        data.put("isFollowing", isFollowing);
        return ResponseEntity.ok(ApiResponse.success(isFollowing ? "Followed successfully" : "Unfollowed successfully", data));
    }

    @GetMapping("/followers/{userId}")
    public ResponseEntity<?> getFollowers(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<UserProfileDTO> result = socialService.getFollowers(userId, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @GetMapping("/following/{userId}")
    public ResponseEntity<?> getFollowing(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<UserProfileDTO> result = socialService.getFollowing(userId, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @GetMapping("/circles")
    public ResponseEntity<?> getAllCircles(Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        List<CircleDTO> circles = socialService.getAllCircles(currentUserId);
        return ResponseEntity.ok(ApiResponse.success(circles));
    }

    @GetMapping("/circles/main")
    public ResponseEntity<?> getMainCircle(Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        CircleDTO circle = socialService.getMainCircle(currentUserId);
        if (circle == null) {
            return ResponseEntity.ok(ApiResponse.error("Circle not found"));
        }
        return ResponseEntity.ok(ApiResponse.success(circle));
    }

    @GetMapping("/circles/{circleId}")
    public ResponseEntity<?> getCircle(@PathVariable Long circleId, Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        CircleDTO circle = socialService.getCircle(circleId, currentUserId);
        if (circle == null) {
            return ResponseEntity.ok(ApiResponse.error("Circle not found"));
        }
        return ResponseEntity.ok(ApiResponse.success(circle));
    }

    @PostMapping("/circles/{circleId}/join")
    public ResponseEntity<?> joinCircle(@PathVariable Long circleId, Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }

        boolean isMember = socialService.joinCircle(circleId, userId);
        Map<String, Object> data = new HashMap<>();
        data.put("isMember", isMember);
        return ResponseEntity.ok(ApiResponse.success(isMember ? "Joined circle successfully" : "Left circle successfully", data));
    }

    @GetMapping("/circles/{circleId}/posts")
    public ResponseEntity<?> getCirclePosts(
            @PathVariable Long circleId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getCirclePosts(circleId, page, pageSize, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @PostMapping("/posts")
    public ResponseEntity<?> createPost(
            @RequestBody CreatePostRequest request,
            Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }

        Post post = socialService.createPost(userId, request.getContent(), request.getImageUrls(), request.getClubId(), request.getCircleId());
        return ResponseEntity.ok(ApiResponse.success(post));
    }

    @DeleteMapping("/posts/{postId}")
    public ResponseEntity<?> deletePost(@PathVariable Long postId, Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }

        socialService.deletePost(postId, userId);
        return ResponseEntity.ok(ApiResponse.success("Post deleted successfully"));
    }

    @GetMapping("/posts")
    public ResponseEntity<?> getPosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getPosts(page, pageSize, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @GetMapping("/posts/user/{userId}")
    public ResponseEntity<?> getUserPosts(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getUserPosts(userId, page, pageSize, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @GetMapping("/posts/{postId}")
    public ResponseEntity<?> getPost(@PathVariable Long postId, Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        PostDTO post = socialService.getPost(postId, currentUserId);
        if (post == null) {
            return ResponseEntity.ok(ApiResponse.error("Post not found"));
        }
        return ResponseEntity.ok(ApiResponse.success(post));
    }

    @PostMapping("/posts/{postId}/like")
    public ResponseEntity<?> toggleLike(@PathVariable Long postId, Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }

        boolean isLiked = socialService.toggleLike(postId, userId);
        Map<String, Object> data = new HashMap<>();
        data.put("isLiked", isLiked);
        return ResponseEntity.ok(ApiResponse.success(isLiked ? "Liked successfully" : "Unliked successfully", data));
    }

    @PostMapping("/posts/{postId}/favorite")
    public ResponseEntity<?> toggleFavorite(@PathVariable Long postId, Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }

        boolean isFavorited = socialService.toggleFavorite(postId, userId);
        Map<String, Object> data = new HashMap<>();
        data.put("isFavorited", isFavorited);
        return ResponseEntity.ok(ApiResponse.success(isFavorited ? "Favorited successfully" : "Unfavorited successfully", data));
    }

    @GetMapping("/favorites")
    public ResponseEntity<?> getFavoritePosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }

        Page<PostDTO> result = socialService.getFavoritePosts(userId, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @GetMapping("/posts/essence")
    public ResponseEntity<?> getEssencePosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getEssencePosts(page, pageSize, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    @PostMapping("/admin/posts/{postId}/pin")
    public ResponseEntity<?> pinPost(@PathVariable Long postId, @RequestParam boolean pinned, Authentication authentication) {
        if (!isSuperAdmin(authentication)) {
            return ResponseEntity.ok(ApiResponse.error("Not authorized"));
        }

        socialService.pinPost(postId, pinned);
        return ResponseEntity.ok(ApiResponse.success(pinned ? "Post pinned successfully" : "Post unpinned successfully"));
    }

    @PostMapping("/admin/posts/{postId}/essence")
    public ResponseEntity<?> setEssencePost(@PathVariable Long postId, @RequestParam boolean essence, Authentication authentication) {
        if (!isSuperAdmin(authentication)) {
            return ResponseEntity.ok(ApiResponse.error("Not authorized"));
        }

        socialService.setEssencePost(postId, essence);
        return ResponseEntity.ok(ApiResponse.success(essence ? "Post marked as essence" : "Post unmarked as essence"));
    }

    @GetMapping("/admin/posts")
    public ResponseEntity<?> getAllPostsForAdmin(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        if (!isSuperAdmin(authentication)) {
            return ResponseEntity.ok(ApiResponse.error("Not authorized"));
        }

        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getAllPostsForAdmin(page, pageSize, currentUserId);
        return ResponseEntity.ok(ApiResponse.success(result));
    }

    private Long getCurrentUserId(Authentication authentication) {
        if (authentication == null) {
            return null;
        }
        String username = authentication.getName();
        return authService.getCurrentUser(username).getUserId();
    }

    private boolean isSuperAdmin(Authentication authentication) {
        if (authentication == null) {
            return false;
        }
        String username = authentication.getName();
        SysUser user = authService.getCurrentUser(username);
        return user != null && "SUPER_ADMIN".equals(user.getRole());
    }

    // ==================== Post Comments ====================

    @GetMapping("/posts/{postId}/comments")
    public ResponseEntity<?> getPostComments(
            @PathVariable Long postId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize) {
        var comments = socialService.getPostComments(postId, page, pageSize);
        return ResponseEntity.ok(ApiResponse.success(comments));
    }

    @PostMapping("/posts/{postId}/comments")
    public ResponseEntity<?> addComment(
            @PathVariable Long postId,
            @RequestBody Map<String, Object> body,
            Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }
        String content = (String) body.get("content");
        Long parentId = body.get("parentId") != null ? ((Number) body.get("parentId")).longValue() : null;
        var comment = socialService.addComment(postId, userId, content, parentId);
        return ResponseEntity.ok(ApiResponse.success(comment));
    }

    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<?> deleteComment(
            @PathVariable Long commentId,
            Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.ok(ApiResponse.error("Not authenticated"));
        }
        boolean isAdmin = isSuperAdmin(authentication);
        socialService.deleteComment(commentId, userId, isAdmin);
        return ResponseEntity.ok(ApiResponse.success("Comment deleted", null));
    }
}
