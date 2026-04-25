package com.soccerhub.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.soccerhub.dto.DashboardStats;
import com.soccerhub.entity.*;
import com.soccerhub.mapper.*;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final SysUserMapper userMapper;
    private final ClubMapper clubMapper;
    private final PlayerMapper playerMapper;
    private final MatchScheduleMapper matchMapper;
    private final RatingRecordMapper ratingMapper;
    private final AuditLogMapper auditLogMapper;
    private final SystemDictionaryMapper dictionaryMapper;
    private final LeagueStandingMapper standingMapper;
    private final NewsArticleMapper newsMapper;
    private final CircleMapper circleMapper;
    private final JdbcTemplate jdbcTemplate;

    public DashboardStats getDashboardStats() {
        DashboardStats stats = new DashboardStats();
        stats.setTotalUsers(userMapper.selectCount(null));
        stats.setTotalClubs(clubMapper.selectCount(null));
        stats.setTotalPlayers(playerMapper.selectCount(null));
        stats.setTotalMatches(matchMapper.selectCount(null));
        stats.setTotalRatings(ratingMapper.selectCount(null));

        // Today's matches
        QueryWrapper<MatchSchedule> todayWrapper = new QueryWrapper<>();
        todayWrapper.apply("TRUNC(MATCH_TIME) = TRUNC(SYSDATE)");
        stats.setTodayMatches(matchMapper.selectCount(todayWrapper));

        // Live matches
        QueryWrapper<MatchSchedule> liveWrapper = new QueryWrapper<>();
        liveWrapper.eq("STATUS", "IN_PROGRESS");
        stats.setLiveMatches(matchMapper.selectCount(liveWrapper));

        return stats;
    }

    public Page<SysUser> listUsers(int page, int pageSize, String role, String keyword) {
        Page<SysUser> p = new Page<>(page, pageSize);
        QueryWrapper<SysUser> wrapper = new QueryWrapper<>();
        if (role != null && !role.isEmpty()) wrapper.eq("ROLE", role);
        if (keyword != null && !keyword.isEmpty()) {
            wrapper.and(w -> w.like("USERNAME", keyword).or().like("NICKNAME", keyword));
        }
        wrapper.orderByDesc("CREATED_AT");
        return userMapper.selectPage(p, wrapper);
    }

    @Transactional
    public SysUser updateUserRole(Long userId, String newRole) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) throw new RuntimeException("User not found");
        user.setRole(newRole);
        user.setUpdatedAt(java.time.LocalDateTime.now());
        userMapper.updateById(user);
        return user;
    }

    @Transactional
    public void updateUserStatus(Long userId, String status) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) throw new RuntimeException("User not found");
        user.setStatus(status);
        user.setUpdatedAt(java.time.LocalDateTime.now());
        userMapper.updateById(user);
    }

    public Page<AuditLog> listAuditLogs(int page, int pageSize, String module, Long userId) {
        Page<AuditLog> p = new Page<>(page, pageSize);
        QueryWrapper<AuditLog> wrapper = new QueryWrapper<>();
        if (module != null && !module.isEmpty()) wrapper.eq("ACTION_MODULE", module);
        if (userId != null) wrapper.eq("USER_ID", userId);
        wrapper.orderByDesc("ACTION_TIME");
        return auditLogMapper.selectPage(p, wrapper);
    }

    public Page<SystemDictionary> listDictionary(int page, int pageSize, String dictType) {
        Page<SystemDictionary> p = new Page<>(page, pageSize);
        QueryWrapper<SystemDictionary> wrapper = new QueryWrapper<>();
        if (dictType != null && !dictType.isEmpty()) wrapper.eq("DICT_TYPE", dictType);
        wrapper.orderByAsc("DICT_TYPE", "SORT_ORDER");
        return dictionaryMapper.selectPage(p, wrapper);
    }

    @Transactional
    public SystemDictionary createDictionaryEntry(SystemDictionary entry) {
        entry.setCreatedAt(java.time.LocalDateTime.now());
        dictionaryMapper.insert(entry);
        return entry;
    }

    @Transactional
    public SystemDictionary updateDictionaryEntry(Long dictId, SystemDictionary entry) {
        SystemDictionary existing = dictionaryMapper.selectById(dictId);
        if (existing == null) throw new RuntimeException("Dictionary entry not found");
        entry.setDictId(dictId);
        entry.setUpdatedAt(java.time.LocalDateTime.now());
        dictionaryMapper.updateById(entry);
        return dictionaryMapper.selectById(dictId);
    }

    @Transactional
    public void deleteDictionaryEntry(Long dictId) {
        dictionaryMapper.deleteById(dictId);
    }

    public Page<LeagueStanding> getStandings(String league, String season, int page, int pageSize) {
        Page<LeagueStanding> p = new Page<>(page, pageSize);
        QueryWrapper<LeagueStanding> wrapper = new QueryWrapper<>();
        if (league != null && !league.isEmpty()) wrapper.eq("LEAGUE", league);
        if (season != null && !season.isEmpty()) wrapper.eq("SEASON", season);
        wrapper.orderByAsc("POSITION");
        return standingMapper.selectPage(p, wrapper);
    }

    @Transactional
    public LeagueStanding upsertStanding(LeagueStanding standing) {
        if (standing.getStandingId() != null) {
            standingMapper.updateById(standing);
        } else {
            standingMapper.insert(standing);
        }
        return standing;
    }

    @Transactional
    public void deleteStanding(Long id) {
        standingMapper.deleteById(id);
    }

    public Page<NewsArticle> listNews(int page, int pageSize, Long clubId, String keyword) {
        Page<NewsArticle> p = new Page<>(page, pageSize);
        QueryWrapper<NewsArticle> wrapper = new QueryWrapper<>();
        if (clubId != null) wrapper.eq("CLUB_ID", clubId);
        if (keyword != null && !keyword.isEmpty()) wrapper.like("TITLE", keyword);
        wrapper.eq("IS_PUBLISHED", 1);
        wrapper.orderByDesc("PUBLISHED_AT");
        return newsMapper.selectPage(p, wrapper);
    }

    @Transactional
    public NewsArticle createNews(NewsArticle article) {
        article.setCreatedAt(java.time.LocalDateTime.now());
        article.setIsPublished(1);
        article.setPublishedAt(java.time.LocalDateTime.now());
        newsMapper.insert(article);
        return article;
    }

    @Transactional
    public NewsArticle updateNews(Long articleId, NewsArticle article) {
        NewsArticle existing = newsMapper.selectById(articleId);
        if (existing == null) throw new RuntimeException("Article not found");
        article.setArticleId(articleId);
        article.setUpdatedAt(java.time.LocalDateTime.now());
        newsMapper.updateById(article);
        return newsMapper.selectById(articleId);
    }

    @Transactional
    public void deleteNews(Long articleId) {
        newsMapper.deleteById(articleId);
    }

    @Transactional
    public SysUser assignManagedClub(Long userId, Long managedClubId) {
        SysUser user = userMapper.selectById(userId);
        if (user == null) throw new RuntimeException("User not found");
        user.setManagedClubId(managedClubId);
        user.setUpdatedAt(java.time.LocalDateTime.now());
        userMapper.updateById(user);
        return user;
    }

    @Transactional
    public Club createClub(Club club) {
        club.setCreatedAt(java.time.LocalDateTime.now());
        clubMapper.insert(club);

        Circle circle = new Circle();
        circle.setClubId(club.getClubId());
        circle.setName(club.getShortName() != null ? club.getShortName() + "球迷圈" : club.getName() + "球迷圈");
        circle.setDescription("欢迎加入" + (club.getShortName() != null ? club.getShortName() : club.getName()) + "球迷圈子讨论！");
        circle.setMemberCount(0);
        circle.setPostCount(0);
        circle.setStatus("1");
        circle.setCreatedAt(java.time.LocalDateTime.now());
        circleMapper.insert(circle);

        // Auto-create standings for the club's league
        if (club.getLeague() != null && !club.getLeague().isEmpty()) {
            LeagueStanding standing = new LeagueStanding();
            standing.setLeague(club.getLeague());
            standing.setSeason(getCurrentSeason());
            standing.setClubId(club.getClubId());
            standing.setPlayed(0);
            standing.setWon(0);
            standing.setDrawn(0);
            standing.setLost(0);
            standing.setGoalsFor(0);
            standing.setGoalsAgainst(0);
            standing.setGoalDiff(0);
            standing.setPoints(0);
            standing.setPosition(999);
            standingMapper.insert(standing);
        }

        return club;
    }

    private String getCurrentSeason() {
        int year = java.time.LocalDate.now().getYear();
        return year + "-" + (year + 1);
    }

    @Transactional
    public Club updateClub(Long id, Club club) {
        Club existing = clubMapper.selectById(id);
        if (existing == null) throw new RuntimeException("Club not found");
        club.setClubId(id);
        club.setUpdatedAt(java.time.LocalDateTime.now());
        clubMapper.updateById(club);
        return clubMapper.selectById(id);
    }

    @Transactional
    public void deleteClub(Long id) {
        // 1. Delete circle member relationships first
        jdbcTemplate.update("DELETE FROM CIRCLE_MEMBER WHERE CIRCLE_ID IN (SELECT CIRCLE_ID FROM CIRCLE WHERE CLUB_ID = ?)", id);
        // 2. Delete circles associated with this club
        jdbcTemplate.update("DELETE FROM CIRCLE WHERE CLUB_ID = ?", id);
        // 3. Update users who have this club as favorite to remove reference
        jdbcTemplate.update("UPDATE SYS_USER SET FAVORITE_CLUB_ID = NULL WHERE FAVORITE_CLUB_ID = ?", id);
        // 4. Update users who manage this club to remove reference
        jdbcTemplate.update("UPDATE SYS_USER SET MANAGED_CLUB_ID = NULL WHERE MANAGED_CLUB_ID = ?", id);
        // 5. Delete user follows
        jdbcTemplate.update("DELETE FROM USER_FOLLOW WHERE FOLLOWING_ID = ? OR FOLLOWER_ID = ?", id, id);
        // 6. Update player club references (set to null)
        jdbcTemplate.update("UPDATE PLAYER SET CLUB_ID = NULL WHERE CLUB_ID = ?", id);
        // 7. Update coach club references (set to null)
        jdbcTemplate.update("UPDATE COACH SET CLUB_ID = NULL WHERE CLUB_ID = ?", id);
        // 8. Update news club references
        jdbcTemplate.update("UPDATE NEWS_ARTICLE SET CLUB_ID = NULL WHERE CLUB_ID = ?", id);
        // 9. Update standings
        jdbcTemplate.update("DELETE FROM LEAGUE_STANDINGS WHERE CLUB_ID = ?", id);
        // 10. Finally delete the club
        clubMapper.deleteById(id);
    }
}
