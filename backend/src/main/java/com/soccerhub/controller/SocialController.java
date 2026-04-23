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
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(profile);
    }

    @PutMapping("/profile")
    public ResponseEntity<?> updateProfile(
            @RequestBody UpdateProfileRequest request,
            Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(401).body("Not authenticated");
        }

        socialService.updateProfile(userId, request.getNickname(), request.getBio(), request.getFavoriteClubId());
        UserProfileDTO profile = socialService.getUserProfile(userId, userId);
        return ResponseEntity.ok(profile);
    }

    @PostMapping("/follow/{userId}")
    public ResponseEntity<?> toggleFollow(@PathVariable Long userId, Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        if (currentUserId == null) {
            return ResponseEntity.status(401).body("Not authenticated");
        }

        boolean isFollowing = socialService.toggleFollow(currentUserId, userId);
        Map<String, Object> result = new HashMap<>();
        result.put("isFollowing", isFollowing);
        result.put("message", isFollowing ? "Followed successfully" : "Unfollowed successfully");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/followers/{userId}")
    public ResponseEntity<?> getFollowers(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<UserProfileDTO> result = socialService.getFollowers(userId, page, pageSize);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/following/{userId}")
    public ResponseEntity<?> getFollowing(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<UserProfileDTO> result = socialService.getFollowing(userId, page, pageSize);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/circles")
    public ResponseEntity<?> getAllCircles(Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        List<CircleDTO> circles = socialService.getAllCircles(currentUserId);
        return ResponseEntity.ok(circles);
    }

    @GetMapping("/circles/main")
    public ResponseEntity<?> getMainCircle(Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        CircleDTO circle = socialService.getMainCircle(currentUserId);
        if (circle == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(circle);
    }

    @GetMapping("/circles/{circleId}")
    public ResponseEntity<?> getCircle(@PathVariable Long circleId, Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        CircleDTO circle = socialService.getCircle(circleId, currentUserId);
        if (circle == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(circle);
    }

    @PostMapping("/circles/{circleId}/join")
    public ResponseEntity<?> joinCircle(@PathVariable Long circleId, Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(401).body("Not authenticated");
        }

        boolean isMember = socialService.joinCircle(circleId, userId);
        Map<String, Object> result = new HashMap<>();
        result.put("isMember", isMember);
        result.put("message", isMember ? "Joined circle successfully" : "Left circle successfully");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/circles/{circleId}/posts")
    public ResponseEntity<?> getCirclePosts(
            @PathVariable Long circleId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getCirclePosts(circleId, page, pageSize, currentUserId);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/posts")
    public ResponseEntity<?> createPost(
            @RequestBody CreatePostRequest request,
            Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(401).body("Not authenticated");
        }

        Post post = socialService.createPost(userId, request.getContent(), request.getImageUrls(), request.getClubId(), request.getCircleId());
        return ResponseEntity.ok(post);
    }

    @DeleteMapping("/posts/{postId}")
    public ResponseEntity<?> deletePost(@PathVariable Long postId, Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(401).body("Not authenticated");
        }

        socialService.deletePost(postId, userId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/posts")
    public ResponseEntity<?> getPosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getPosts(page, pageSize, currentUserId);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/posts/user/{userId}")
    public ResponseEntity<?> getUserPosts(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getUserPosts(userId, page, pageSize, currentUserId);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/posts/{postId}")
    public ResponseEntity<?> getPost(@PathVariable Long postId, Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        PostDTO post = socialService.getPost(postId, currentUserId);
        if (post == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(post);
    }

    @PostMapping("/posts/{postId}/like")
    public ResponseEntity<?> toggleLike(@PathVariable Long postId, Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(401).body("Not authenticated");
        }

        boolean isLiked = socialService.toggleLike(postId, userId);
        Map<String, Object> result = new HashMap<>();
        result.put("isLiked", isLiked);
        result.put("message", isLiked ? "Liked successfully" : "Unliked successfully");
        return ResponseEntity.ok(result);
    }

    @PostMapping("/posts/{postId}/favorite")
    public ResponseEntity<?> toggleFavorite(@PathVariable Long postId, Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(401).body("Not authenticated");
        }

        boolean isFavorited = socialService.toggleFavorite(postId, userId);
        Map<String, Object> result = new HashMap<>();
        result.put("isFavorited", isFavorited);
        result.put("message", isFavorited ? "Favorited successfully" : "Unfavorited successfully");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/favorites")
    public ResponseEntity<?> getFavoritePosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long userId = getCurrentUserId(authentication);
        if (userId == null) {
            return ResponseEntity.status(401).body("Not authenticated");
        }

        Page<PostDTO> result = socialService.getFavoritePosts(userId, page, pageSize);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/posts/essence")
    public ResponseEntity<?> getEssencePosts(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getEssencePosts(page, pageSize, currentUserId);
        return ResponseEntity.ok(result);
    }

    @PostMapping("/admin/posts/{postId}/pin")
    public ResponseEntity<?> pinPost(@PathVariable Long postId, @RequestParam boolean pinned, Authentication authentication) {
        if (!isSuperAdmin(authentication)) {
            return ResponseEntity.status(403).body("Not authorized");
        }

        socialService.pinPost(postId, pinned);
        Map<String, Object> result = new HashMap<>();
        result.put("message", pinned ? "Post pinned successfully" : "Post unpinned successfully");
        return ResponseEntity.ok(result);
    }

    @PostMapping("/admin/posts/{postId}/essence")
    public ResponseEntity<?> setEssencePost(@PathVariable Long postId, @RequestParam boolean essence, Authentication authentication) {
        if (!isSuperAdmin(authentication)) {
            return ResponseEntity.status(403).body("Not authorized");
        }

        socialService.setEssencePost(postId, essence);
        Map<String, Object> result = new HashMap<>();
        result.put("message", essence ? "Post marked as essence" : "Post unmarked as essence");
        return ResponseEntity.ok(result);
    }

    @GetMapping("/admin/posts")
    public ResponseEntity<?> getAllPostsForAdmin(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int pageSize,
            Authentication authentication) {
        if (!isSuperAdmin(authentication)) {
            return ResponseEntity.status(403).body("Not authorized");
        }

        Long currentUserId = getCurrentUserId(authentication);
        Page<PostDTO> result = socialService.getAllPostsForAdmin(page, pageSize, currentUserId);
        return ResponseEntity.ok(result);
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
}
