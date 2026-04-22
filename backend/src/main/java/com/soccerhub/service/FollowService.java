package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.entity.UserClubFollow;
import com.soccerhub.mapper.UserClubFollowMapper;
import com.soccerhub.mapper.ClubMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FollowService {

    private final UserClubFollowMapper followMapper;
    private final ClubMapper clubMapper;
    private static final int MAX_FOLLOWS = 3;

    public List<UserClubFollow> getUserFollows(Long userId) {
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId);
        wrapper.orderByDesc("IS_PRIMARY", "FOLLOW_TIME");
        return followMapper.selectList(wrapper);
    }

    public boolean isFollowing(Long userId, Long clubId) {
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId);
        wrapper.eq("CLUB_ID", clubId);
        return followMapper.selectCount(wrapper) > 0;
    }

    @Transactional
    public void followClub(Long userId, Long clubId, boolean isPrimary) {
        // Check max follows
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId);
        long currentFollows = followMapper.selectCount(wrapper);
        if (currentFollows >= MAX_FOLLOWS) {
            throw new RuntimeException("您最多只能关注 " + MAX_FOLLOWS + " 支球队！");
        }

        // Check if already following
        if (isFollowing(userId, clubId)) {
            throw new RuntimeException("您已经关注了该俱乐部！");
        }

        UserClubFollow follow = new UserClubFollow();
        follow.setUserId(userId);
        follow.setClubId(clubId);
        follow.setIsPrimary(isPrimary ? 1 : 0);
        follow.setFollowTime(LocalDateTime.now());
        followMapper.insert(follow);
    }

    @Transactional
    public void unfollowClub(Long userId, Long clubId) {
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("USER_ID", userId);
        wrapper.eq("CLUB_ID", clubId);
        followMapper.delete(wrapper);
    }

    public Long getClubFollowerCount(Long clubId) {
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", clubId);
        return followMapper.selectCount(wrapper);
    }

    public Page<UserClubFollow> getClubFollowers(Long clubId, int page, int pageSize) {
        Page<UserClubFollow> p = new Page<>(page, pageSize);
        QueryWrapper<UserClubFollow> wrapper = new QueryWrapper<>();
        wrapper.eq("CLUB_ID", clubId);
        wrapper.orderByDesc("FOLLOW_TIME");
        return followMapper.selectPage(p, wrapper);
    }
}
