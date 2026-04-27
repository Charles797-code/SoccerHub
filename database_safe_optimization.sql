-- ============================================
-- SoccerHub 数据库安全优化脚本
-- 仅包含：表空间、序列、索引、视图
-- 不会影响现有系统功能和数据
-- ============================================

-- ============================================
-- 1. 表空间创建
-- ============================================

-- 创建数据表空间
CREATE TABLESPACE soccerhub_data
    DATAFILE 'soccerhub_data.dbf'
    SIZE 100M
    AUTOEXTEND ON NEXT 10M
    MAXSIZE 1G
    LOGGING
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

-- 创建索引表空间
CREATE TABLESPACE soccerhub_idx
    DATAFILE 'soccerhub_idx.dbf'
    SIZE 50M
    AUTOEXTEND ON NEXT 5M
    MAXSIZE 500M
    LOGGING
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

-- 创建临时表空间
CREATE TEMPORARY TABLESPACE soccerhub_temp
    TEMPFILE 'soccerhub_temp.dbf'
    SIZE 20M
    AUTOEXTEND ON NEXT 5M
    MAXSIZE 200M
    EXTENT MANAGEMENT LOCAL;

-- 创建撤销表空间
CREATE UNDO TABLESPACE soccerhub_undo
    DATAFILE 'soccerhub_undo.dbf'
    SIZE 30M
    AUTOEXTEND ON NEXT 5M
    MAXSIZE 300M
    EXTENT MANAGEMENT LOCAL;

-- ============================================
-- 2. 序列创建
-- ============================================

-- 用户ID序列
CREATE SEQUENCE seq_sys_user_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 20
    ORDER;

-- 俱乐部ID序列
CREATE SEQUENCE seq_club_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 20
    ORDER;

-- 球员ID序列
CREATE SEQUENCE seq_player_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 50
    ORDER;

-- 教练ID序列
CREATE SEQUENCE seq_coach_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 20
    ORDER;

-- 赛季ID序列
CREATE SEQUENCE seq_season_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 10
    ORDER;

-- 积分榜ID序列
CREATE SEQUENCE seq_standing_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 30
    ORDER;

-- 球员赛季统计ID序列
CREATE SEQUENCE seq_stats_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 50
    ORDER;

-- 帖子ID序列
CREATE SEQUENCE seq_post_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 100
    ORDER;

-- 评论ID序列
CREATE SEQUENCE seq_comment_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 100
    ORDER;

-- 新闻ID序列
CREATE SEQUENCE seq_news_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 20
    ORDER;

-- 圈子ID序列
CREATE SEQUENCE seq_circle_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 20
    ORDER;

-- 审计日志ID序列
CREATE SEQUENCE seq_audit_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 100
    ORDER;

-- 聊天消息ID序列
CREATE SEQUENCE seq_chat_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 200
    ORDER;

-- ============================================
-- 3. 索引创建
-- ============================================

-- 用户表索引
CREATE INDEX idx_user_username ON sys_user(username) TABLESPACE soccerhub_idx;
CREATE INDEX idx_user_email ON sys_user(email) TABLESPACE soccerhub_idx;
CREATE INDEX idx_user_role ON sys_user(role) TABLESPACE soccerhub_idx;
CREATE INDEX idx_user_status ON sys_user(status) TABLESPACE soccerhub_idx;
CREATE INDEX idx_user_club ON sys_user(managed_club_id) TABLESPACE soccerhub_idx;

-- 俱乐部表索引
CREATE INDEX idx_club_league ON club(league) TABLESPACE soccerhub_idx;
CREATE INDEX idx_club_name ON club(name) TABLESPACE soccerhub_idx;
CREATE INDEX idx_club_status ON club(status) TABLESPACE soccerhub_idx;

-- 球员表索引
CREATE INDEX idx_player_club ON player(club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_player_league ON player(league) TABLESPACE soccerhub_idx;
CREATE INDEX idx_player_position ON player(position) TABLESPACE soccerhub_idx;
CREATE INDEX idx_player_status ON player(status) TABLESPACE soccerhub_idx;
CREATE INDEX idx_player_name ON player(name) TABLESPACE soccerhub_idx;
CREATE INDEX idx_player_name_cn ON player(name_cn) TABLESPACE soccerhub_idx;

-- 教练表索引
CREATE INDEX idx_coach_club ON coach(club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_coach_league ON coach(league) TABLESPACE soccerhub_idx;

-- 赛程表索引
CREATE INDEX idx_match_league ON match_schedule(league) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_season ON match_schedule(season) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_status ON match_schedule(status) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_round ON match_schedule(round) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_home_club ON match_schedule(home_club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_away_club ON match_schedule(away_club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_time ON match_schedule(match_time) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_league_season ON match_schedule(league, season) TABLESPACE soccerhub_idx;

-- 球员评分表索引
CREATE INDEX idx_rating_target ON match_player_rating(target_type, target_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_rating_match ON match_player_rating(match_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_rating_user ON match_player_rating(user_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_rating_created ON match_player_rating(created_at) TABLESPACE soccerhub_idx;

-- 比赛评论表索引
CREATE INDEX idx_match_comment_match ON match_comment(match_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_comment_user ON match_comment(user_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_match_comment_time ON match_comment(created_at) TABLESPACE soccerhub_idx;

-- 聊天室消息表索引
CREATE INDEX idx_chat_club ON club_chat_message(club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_chat_user ON club_chat_message(user_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_chat_time ON club_chat_message(created_at) TABLESPACE soccerhub_idx;

-- 新闻表索引
CREATE INDEX idx_news_club ON news_article(club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_news_category ON news_article(category) TABLESPACE soccerhub_idx;
CREATE INDEX idx_news_time ON news_article(published_at) TABLESPACE soccerhub_idx;
CREATE INDEX idx_news_title ON news_article(title) TABLESPACE soccerhub_idx;

-- 新闻评论表索引
CREATE INDEX idx_news_comment_article ON news_comment(article_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_news_comment_user ON news_comment(user_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_news_comment_time ON news_comment(created_at) TABLESPACE soccerhub_idx;

-- 帖子表索引
CREATE INDEX idx_post_user ON post(user_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_post_circle ON post(circle_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_post_time ON post(created_at) TABLESPACE soccerhub_idx;
CREATE INDEX idx_post_pinned ON post(is_pinned) TABLESPACE soccerhub_idx;

-- 帖子评论表索引
CREATE INDEX idx_post_comment_post ON post_comment(post_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_post_comment_user ON post_comment(user_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_post_comment_time ON post_comment(created_at) TABLESPACE soccerhub_idx;

-- 帖子点赞表索引
CREATE INDEX idx_post_like_post ON post_like(post_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_post_like_user ON post_like(user_id) TABLESPACE soccerhub_idx;

-- 帖子收藏表索引
CREATE INDEX idx_post_fav_post ON post_favorite(post_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_post_fav_user ON post_favorite(user_id) TABLESPACE soccerhub_idx;

-- 用户关注表索引
CREATE INDEX idx_user_follow_follower ON user_follow(follower_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_user_follow_following ON user_follow(following_id) TABLESPACE soccerhub_idx;

-- 用户俱乐部关注表索引
CREATE INDEX idx_club_follow_user ON user_club_follow(user_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_club_follow_club ON user_club_follow(club_id) TABLESPACE soccerhub_idx;

-- 圈子表索引
CREATE INDEX idx_circle_club ON circle(club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_circle_status ON circle(status) TABLESPACE soccerhub_idx;

-- 圈子成员表索引
CREATE INDEX idx_circle_member_circle ON circle_member(circle_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_circle_member_user ON circle_member(user_id) TABLESPACE soccerhub_idx;

-- 积分榜表索引
CREATE INDEX idx_standing_league ON league_standing(league) TABLESPACE soccerhub_idx;
CREATE INDEX idx_standing_season ON league_standing(season) TABLESPACE soccerhub_idx;
CREATE INDEX idx_standing_club ON league_standing(club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_standing_points ON league_standing(points) TABLESPACE soccerhub_idx;
CREATE INDEX idx_standing_position ON league_standing(position) TABLESPACE soccerhub_idx;
CREATE INDEX idx_standing_league_season ON league_standing(league, season) TABLESPACE soccerhub_idx;

-- 球员赛季统计表索引
CREATE INDEX idx_stats_player ON player_season_stats(player_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_stats_league ON player_season_stats(league) TABLESPACE soccerhub_idx;
CREATE INDEX idx_stats_season ON player_season_stats(season) TABLESPACE soccerhub_idx;
CREATE INDEX idx_stats_club ON player_season_stats(club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_stats_goals ON player_season_stats(goals) TABLESPACE soccerhub_idx;
CREATE INDEX idx_stats_assists ON player_season_stats(assists) TABLESPACE soccerhub_idx;

-- 转会记录表索引
CREATE INDEX idx_transfer_player ON transfer_history_log(player_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_transfer_from ON transfer_history_log(from_club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_transfer_to ON transfer_history_log(to_club_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_transfer_season ON transfer_history_log(season) TABLESPACE soccerhub_idx;
CREATE INDEX idx_transfer_time ON transfer_history_log(transfer_date) TABLESPACE soccerhub_idx;

-- 审计日志表索引
CREATE INDEX idx_audit_user ON audit_log(user_id) TABLESPACE soccerhub_idx;
CREATE INDEX idx_audit_module ON audit_log(module) TABLESPACE soccerhub_idx;
CREATE INDEX idx_audit_action ON audit_log(action) TABLESPACE soccerhub_idx;
CREATE INDEX idx_audit_time ON audit_log(created_at) TABLESPACE soccerhub_idx;

-- 赛季表索引
CREATE INDEX idx_season_league ON season(league) TABLESPACE soccerhub_idx;
CREATE INDEX idx_season_status ON season(status) TABLESPACE soccerhub_idx;
CREATE INDEX idx_season_name ON season(season_name) TABLESPACE soccerhub_idx;

-- 字典表索引
CREATE INDEX idx_dict_type ON system_dictionary(dict_type) TABLESPACE soccerhub_idx;
CREATE INDEX idx_dict_code ON system_dictionary(dict_code) TABLESPACE soccerhub_idx;

-- ============================================
-- 4. 视图创建
-- ============================================

-- 4.1 用户详情视图
CREATE OR REPLACE VIEW v_user_details AS
SELECT
    u.user_id,
    u.username,
    u.email,
    u.nickname,
    u.avatar_url,
    u.role,
    u.status,
    u.favorite_club_id,
    c.name AS favorite_club_name,
    u.bio,
    u.created_at,
    u.last_login_at,
    (SELECT COUNT(*) FROM user_follow WHERE follower_id = u.user_id) AS followers_count,
    (SELECT COUNT(*) FROM user_follow WHERE following_id = u.user_id) AS following_count,
    (SELECT COUNT(*) FROM user_club_follow WHERE user_id = u.user_id) AS clubs_followed_count
FROM sys_user u
LEFT JOIN club c ON u.favorite_club_id = c.club_id;

-- 4.2 球员完整信息视图
CREATE OR REPLACE VIEW v_player_full_info AS
SELECT
    p.player_id,
    p.name,
    p.name_cn,
    p.avatar_url,
    p.jersey_number,
    p.position,
    p.nationality,
    p.height,
    p.weight,
    p.birth_date,
    p.market_value,
    p.status,
    p.club_id,
    c.name AS club_name,
    c.short_name AS club_short_name,
    c.league,
    p.created_at,
    p.updated_at,
    TRUNC(MONTHS_BETWEEN(SYSDATE, p.birth_date) / 12) AS age,
    (SELECT AVG(rating) FROM match_player_rating WHERE target_type = 'PLAYER' AND target_id = p.player_id) AS avg_rating,
    (SELECT COUNT(*) FROM match_player_rating WHERE target_type = 'PLAYER' AND target_id = p.player_id) AS rating_count
FROM player p
LEFT JOIN club c ON p.club_id = c.club_id;

-- 4.3 俱乐部完整信息视图
CREATE OR REPLACE VIEW v_club_full_info AS
SELECT
    c.club_id,
    c.name,
    c.short_name,
    c.logo_url,
    c.league,
    c.city,
    c.country,
    c.venue,
    c.stadium_capacity,
    c.founded_year,
    c.status,
    c.created_at,
    (SELECT COUNT(*) FROM player WHERE club_id = c.club_id AND status = 'ACTIVE') AS active_players_count,
    (SELECT COUNT(*) FROM coach WHERE club_id = c.club_id) AS coaches_count,
    (SELECT COUNT(*) FROM user_club_follow WHERE club_id = c.club_id) AS followers_count,
    (SELECT COUNT(*) FROM post WHERE circle_id IN (SELECT circle_id FROM circle WHERE club_id = c.club_id)) AS posts_count
FROM club c;

-- 4.4 比赛详情视图
CREATE OR REPLACE VIEW v_match_details AS
SELECT
    m.match_id,
    m.league,
    m.season,
    m.round,
    m.match_time,
    m.home_club_id,
    hc.name AS home_club_name,
    hc.short_name AS home_club_short,
    hc.logo_url AS home_club_logo,
    m.away_club_id,
    ac.name AS away_club_name,
    ac.short_name AS away_club_short,
    ac.logo_url AS away_club_logo,
    m.home_score,
    m.away_score,
    m.status,
    m.venue,
    m.referee,
    m.created_at,
    m.updated_at,
    CASE
        WHEN m.status = 'FINISHED' THEN '已结束'
        WHEN m.status = 'IN_PROGRESS' THEN '进行中'
        WHEN m.status = 'PENDING' THEN '未开始'
        WHEN m.status = 'CANCELLED' THEN '已取消'
        ELSE m.status
    END AS status_text
FROM match_schedule m
LEFT JOIN club hc ON m.home_club_id = hc.club_id
LEFT JOIN club ac ON m.away_club_id = ac.club_id;

-- 4.5 积分榜完整视图
CREATE OR REPLACE VIEW v_standings_full AS
SELECT
    ls.standing_id,
    ls.league,
    ls.season,
    ls.club_id,
    c.name AS club_name,
    c.short_name AS club_short_name,
    c.logo_url AS club_logo,
    ls.position,
    ls.played,
    ls.won,
    ls.drawn,
    ls.lost,
    ls.goals_for,
    ls.goals_against,
    ls.goal_diff,
    ls.points,
    ls.updated_at,
    CASE
        WHEN ls.position <= 4 THEN '欧冠区'
        WHEN ls.position <= 6 THEN '欧联区'
        WHEN ls.position >= ls.played - 3 AND ls.played >= 10 THEN '降级区'
        ELSE '无'
    END AS zone
FROM league_standing ls
LEFT JOIN club c ON ls.club_id = c.club_id
ORDER BY ls.league, ls.season, ls.position;

-- 4.6 射手榜完整视图
CREATE OR REPLACE VIEW v_scorers_full AS
SELECT
    ps.stats_id,
    ps.player_id,
    p.name AS player_name,
    p.name_cn AS player_name_cn,
    p.avatar_url,
    p.jersey_number,
    p.position,
    ps.club_id,
    c.name AS club_name,
    c.logo_url AS club_logo,
    ps.league,
    ps.season,
    ps.goals,
    ps.assists,
    ps.appearances,
    ps.minutes_played,
    ps.updated_at,
    RANK() OVER (PARTITION BY ps.league, ps.season ORDER BY ps.goals DESC, ps.assists DESC) AS rank
FROM player_season_stats ps
LEFT JOIN player p ON ps.player_id = p.player_id
LEFT JOIN club c ON ps.club_id = c.club_id
WHERE ps.goals > 0;

-- 4.7 帖子完整信息视图
CREATE OR REPLACE VIEW v_post_full AS
SELECT
    p.post_id,
    p.user_id,
    u.username,
    u.nickname,
    u.avatar_url AS user_avatar,
    u.favorite_club_id,
    fc.name AS favorite_club_name,
    p.circle_id,
    c.name AS circle_name,
    c.club_id AS circle_club_id,
    p.content,
    p.like_count,
    p.comment_count,
    p.favorite_count,
    p.is_pinned,
    p.is_essence,
    p.status,
    p.created_at,
    p.updated_at
FROM post p
LEFT JOIN sys_user u ON p.user_id = u.user_id
LEFT JOIN club fc ON u.favorite_club_id = fc.club_id
LEFT JOIN circle c ON p.circle_id = c.circle_id;

-- 4.8 新闻完整信息视图
CREATE OR REPLACE VIEW v_news_full AS
SELECT
    na.article_id,
    na.title,
    na.summary,
    na.content,
    na.cover_image_url,
    na.author_id,
    u.username AS author_name,
    u.nickname AS author_nickname,
    na.club_id,
    c.name AS club_name,
    na.category,
    na.tags,
    na.view_count,
    na.like_count,
    na.comment_count,
    na.source_url,
    na.published_at,
    na.created_at,
    na.updated_at
FROM news_article na
LEFT JOIN sys_user u ON na.author_id = u.user_id
LEFT JOIN club c ON na.club_id = c.club_id;

-- 4.9 用户活动统计视图
CREATE OR REPLACE VIEW v_user_activity AS
SELECT
    u.user_id,
    u.username,
    u.nickname,
    u.role,
    u.created_at,
    (SELECT COUNT(*) FROM post WHERE user_id = u.user_id) AS posts_count,
    (SELECT COUNT(*) FROM post_comment WHERE user_id = u.user_id) AS comments_count,
    (SELECT COUNT(*) FROM post_like WHERE user_id = u.user_id) AS likes_count,
    (SELECT COUNT(*) FROM match_comment WHERE user_id = u.user_id) AS match_comments_count,
    (SELECT COUNT(*) FROM match_player_rating WHERE user_id = u.user_id) AS ratings_count,
    (SELECT COUNT(*) FROM user_follow WHERE follower_id = u.user_id) AS following_count,
    (SELECT COUNT(*) FROM user_follow WHERE following_id = u.user_id) AS followers_count
FROM sys_user u;

-- 4.10 俱乐部排行榜视图
CREATE OR REPLACE VIEW v_club_rankings AS
SELECT
    c.club_id,
    c.name,
    c.short_name,
    c.logo_url,
    c.league,
    (SELECT COUNT(*) FROM player WHERE club_id = c.club_id AND status = 'ACTIVE') AS squad_size,
    (SELECT COUNT(*) FROM user_club_follow WHERE club_id = c.club_id) AS followers_count,
    (SELECT AVG(ps.goals) FROM player_season_stats ps WHERE ps.club_id = c.club_id) AS avg_team_goals,
    (SELECT MAX(ls.points) FROM league_standing ls WHERE ls.club_id = c.club_id) AS max_season_points,
    (SELECT MAX(ls.position) FROM league_standing ls WHERE ls.club_id = c.club_id AND ls.points = (SELECT MAX(points) FROM league_standing WHERE league = ls.league AND season = ls.season)) AS best_position
FROM club c
ORDER BY c.league, followers_count DESC;

-- 4.11 聊天室统计视图
CREATE OR REPLACE VIEW v_chat_stats AS
SELECT
    c.club_id,
    c.name AS club_name,
    (SELECT COUNT(*) FROM club_chat_message WHERE club_id = c.club_id) AS total_messages,
    (SELECT COUNT(DISTINCT user_id) FROM club_chat_message WHERE club_id = c.club_id) AS unique_users,
    (SELECT MAX(created_at) FROM club_chat_message WHERE club_id = c.club_id) AS last_message_time,
    (SELECT COUNT(*) FROM club_chat_message WHERE club_id = c.club_id AND created_at > SYSDATE - 7) AS messages_last_7_days
FROM club c;

-- 4.12 赛季汇总视图
CREATE OR REPLACE VIEW v_season_summary AS
SELECT
    s.season_id,
    s.league,
    s.season_name,
    s.start_year,
    s.end_year,
    s.status,
    s.total_rounds,
    (SELECT COUNT(DISTINCT club_id) FROM league_standing WHERE league = s.league AND season = s.season_name) AS teams_count,
    (SELECT COUNT(*) FROM match_schedule WHERE league = s.league AND season = s.season_name) AS total_matches,
    (SELECT COUNT(*) FROM match_schedule WHERE league = s.league AND season = s.season_name AND status = 'FINISHED') AS finished_matches,
    (SELECT SUM(home_score + away_score) FROM match_schedule WHERE league = s.league AND season = s.season_name AND status = 'FINISHED') AS total_goals,
    (SELECT MAX(round) FROM match_schedule WHERE league = s.league AND season = s.season_name) AS max_round_played,
    s.created_at,
    s.updated_at
FROM season s;

-- ============================================
-- 执行完成
-- ============================================
