-- ============================================
-- SoccerHub 数据库优化脚本（兼容版）
-- 仅包含：序列、索引、视图
-- 基于实际表结构编写
-- ============================================

-- ============================================
-- 1. 序列创建
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

-- 帖子ID序列
CREATE SEQUENCE seq_post_id
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

-- 转会记录ID序列
CREATE SEQUENCE seq_transfer_id
    START WITH 1
    INCREMENT BY 1
    MINVALUE 1
    MAXVALUE 999999999999
    CACHE 20
    ORDER;

-- ============================================
-- 2. 索引创建
-- 使用默认表空间，避免表空间不存在问题
-- ============================================

-- 用户表索引
CREATE INDEX idx_user_username ON sys_user(username);
CREATE INDEX idx_user_email ON sys_user(email);
CREATE INDEX idx_user_role ON sys_user(role);
CREATE INDEX idx_user_status ON sys_user(status);

-- 俱乐部表索引
CREATE INDEX idx_club_league ON club(league);
CREATE INDEX idx_club_name ON club(name);

-- 球员表索引
CREATE INDEX idx_player_club ON player(club_id);
CREATE INDEX idx_player_league ON player(league);
CREATE INDEX idx_player_position ON player(position);
CREATE INDEX idx_player_status ON player(status);
CREATE INDEX idx_player_name ON player(name);
CREATE INDEX idx_player_name_cn ON player(name_cn);

-- 教练表索引
CREATE INDEX idx_coach_club ON coach(club_id);
CREATE INDEX idx_coach_league ON coach(league);

-- 赛程表索引
CREATE INDEX idx_match_league ON match_schedule(league);
CREATE INDEX idx_match_season ON match_schedule(season);
CREATE INDEX idx_match_status ON match_schedule(status);
CREATE INDEX idx_match_round ON match_schedule(round);
CREATE INDEX idx_match_home_club ON match_schedule(home_club_id);
CREATE INDEX idx_match_away_club ON match_schedule(away_club_id);
CREATE INDEX idx_match_time ON match_schedule(match_time);
CREATE INDEX idx_match_league_season ON match_schedule(league, season);

-- 球员评分表索引
CREATE INDEX idx_rating_target ON match_player_rating(target_type, target_id);
CREATE INDEX idx_rating_match ON match_player_rating(match_id);
CREATE INDEX idx_rating_user ON match_player_rating(user_id);
CREATE INDEX idx_rating_created ON match_player_rating(created_at);

-- 比赛评论表索引
CREATE INDEX idx_match_comment_match ON match_comment(match_id);
CREATE INDEX idx_match_comment_user ON match_comment(user_id);
CREATE INDEX idx_match_comment_time ON match_comment(created_at);

-- 聊天室消息表索引
CREATE INDEX idx_chat_club ON club_chat_message(club_id);
CREATE INDEX idx_chat_user ON club_chat_message(user_id);
CREATE INDEX idx_chat_time ON club_chat_message(created_at);

-- 新闻表索引
CREATE INDEX idx_news_club ON news_article(club_id);
CREATE INDEX idx_news_author ON news_article(author_id);
CREATE INDEX idx_news_time ON news_article(published_at);
CREATE INDEX idx_news_title ON news_article(title);

-- 新闻评论表索引（如果有）
CREATE INDEX idx_news_comment_article ON news_comment(article_id);
CREATE INDEX idx_news_comment_user ON news_comment(user_id);
CREATE INDEX idx_news_comment_time ON news_comment(created_at);

-- 帖子表索引
CREATE INDEX idx_post_user ON post(user_id);
CREATE INDEX idx_post_circle ON post(circle_id);
CREATE INDEX idx_post_time ON post(created_at);
CREATE INDEX idx_post_pinned ON post(is_pinned);

-- 帖子评论表索引
CREATE INDEX idx_post_comment_post ON post_comment(post_id);
CREATE INDEX idx_post_comment_user ON post_comment(user_id);
CREATE INDEX idx_post_comment_time ON post_comment(created_at);

-- 帖子点赞表索引
CREATE INDEX idx_post_like_post ON post_like(post_id);
CREATE INDEX idx_post_like_user ON post_like(user_id);

-- 帖子收藏表索引
CREATE INDEX idx_post_fav_post ON post_favorite(post_id);
CREATE INDEX idx_post_fav_user ON post_favorite(user_id);

-- 用户关注表索引
CREATE INDEX idx_user_follow_follower ON user_follow(follower_id);
CREATE INDEX idx_user_follow_following ON user_follow(following_id);

-- 用户俱乐部关注表索引
CREATE INDEX idx_club_follow_user ON user_club_follow(user_id);
CREATE INDEX idx_club_follow_club ON user_club_follow(club_id);

-- 圈子表索引
CREATE INDEX idx_circle_club ON circle(club_id);
CREATE INDEX idx_circle_status ON circle(status);

-- 圈子成员表索引
CREATE INDEX idx_circle_member_circle ON circle_member(circle_id);
CREATE INDEX idx_circle_member_user ON circle_member(user_id);

-- 球员赛季统计表索引
CREATE INDEX idx_stats_player ON player_season_stats(player_id);
CREATE INDEX idx_stats_league ON player_season_stats(league);
CREATE INDEX idx_stats_season ON player_season_stats(season);
CREATE INDEX idx_stats_club ON player_season_stats(club_id);
CREATE INDEX idx_stats_goals ON player_season_stats(goals);
CREATE INDEX idx_stats_assists ON player_season_stats(assists);

-- 转会记录表索引（使用实际列名）
CREATE INDEX idx_transfer_player ON transfer_history_log(player_id);
CREATE INDEX idx_transfer_old_club ON transfer_history_log(old_club_id);
CREATE INDEX idx_transfer_new_club ON transfer_history_log(new_club_id);
CREATE INDEX idx_transfer_season ON transfer_history_log(season);
CREATE INDEX idx_transfer_time ON transfer_history_log(action_time);

-- 审计日志表索引（使用实际列名）
CREATE INDEX idx_audit_user ON audit_log(user_id);
CREATE INDEX idx_audit_module ON audit_log(action_module);
CREATE INDEX idx_audit_type ON audit_log(action_type);
CREATE INDEX idx_audit_time ON audit_log(action_time);

-- 赛季表索引
CREATE INDEX idx_season_league ON season(league);
CREATE INDEX idx_season_status ON season(status);
CREATE INDEX idx_season_name ON season(season_name);

-- ============================================
-- 3. 视图创建（基于实际列名）
-- ============================================

-- 3.1 用户详情视图
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

-- 3.2 球员完整信息视图
CREATE OR REPLACE VIEW v_player_full_info AS
SELECT
    p.player_id,
    p.name,
    p.name_cn,
    p.avatar_url,
    p.jersey_number,
    p.position,
    p.nationality,
    p.height_cm,
    p.weight_kg,
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
    p.avg_score AS avg_rating,
    p.total_ratings AS rating_count
FROM player p
LEFT JOIN club c ON p.club_id = c.club_id;

-- 3.3 俱乐部完整信息视图
CREATE OR REPLACE VIEW v_club_full_info AS
SELECT
    c.club_id,
    c.name,
    c.short_name,
    c.logo_url,
    c.league,
    c.city,
    c.country,
    c.stadium,
    c.stadium_capacity,
    c.establish_date,
    c.description,
    c.total_score,
    c.created_at,
    (SELECT COUNT(*) FROM player WHERE club_id = c.club_id AND status = 'ACTIVE') AS active_players_count,
    (SELECT COUNT(*) FROM coach WHERE club_id = c.club_id) AS coaches_count,
    (SELECT COUNT(*) FROM user_club_follow WHERE club_id = c.club_id) AS followers_count,
    (SELECT COUNT(*) FROM post WHERE circle_id IN (SELECT circle_id FROM circle WHERE club_id = c.club_id)) AS posts_count
FROM club c;

-- 3.4 比赛详情视图
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

-- 3.5 射手榜完整视图
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
    ps.yellow_cards,
    ps.red_cards,
    ps.updated_at,
    RANK() OVER (PARTITION BY ps.league, ps.season ORDER BY ps.goals DESC, ps.assists DESC) AS rank
FROM player_season_stats ps
LEFT JOIN player p ON ps.player_id = p.player_id
LEFT JOIN club c ON ps.club_id = c.club_id
WHERE ps.goals > 0;

-- 3.6 帖子完整信息视图
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

-- 3.7 新闻完整信息视图
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
    na.tags,
    na.view_count,
    na.source_url,
    na.source_name,
    na.is_published,
    na.published_at,
    na.created_at,
    na.updated_at
FROM news_article na
LEFT JOIN sys_user u ON na.author_id = u.user_id
LEFT JOIN club c ON na.club_id = c.club_id;

-- 3.8 用户活动统计视图
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

-- 3.9 聊天室统计视图
CREATE OR REPLACE VIEW v_chat_stats AS
SELECT
    c.club_id,
    c.name AS club_name,
    (SELECT COUNT(*) FROM club_chat_message WHERE club_id = c.club_id) AS total_messages,
    (SELECT COUNT(DISTINCT user_id) FROM club_chat_message WHERE club_id = c.club_id) AS unique_users,
    (SELECT MAX(created_at) FROM club_chat_message WHERE club_id = c.club_id) AS last_message_time,
    (SELECT COUNT(*) FROM club_chat_message WHERE club_id = c.club_id AND created_at > SYSDATE - 7) AS messages_last_7_days
FROM club c;

-- 3.10 赛季汇总视图
CREATE OR REPLACE VIEW v_season_summary AS
SELECT
    s.season_id,
    s.league,
    s.season_name,
    s.start_year,
    s.end_year,
    s.status,
    s.total_rounds,
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
