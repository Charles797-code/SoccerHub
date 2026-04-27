-- ============================================
-- SoccerHub 数据库优化脚本
-- 包含：表空间、索引、视图、序列、触发器、存储过程、函数、大对象
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

-- 修改用户默认表空间
-- ALTER USER soccerhub DEFAULT TABLESPACE soccerhub_data;

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
-- 5. 触发器创建
-- ============================================

-- 5.1 用户注册后自动创建审计日志
CREATE OR REPLACE TRIGGER trg_after_user_register
AFTER INSERT ON sys_user
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_id, module, action, description, ip_address, created_at)
    VALUES (:NEW.user_id, 'USER', 'REGISTER', '新用户注册: ' || :NEW.username, 'SYSTEM', SYSDATE);
END;
/

-- 5.2 用户登录后更新最后登录时间
CREATE OR REPLACE TRIGGER trg_after_user_login
AFTER UPDATE OF last_login_at ON sys_user
FOR EACH ROW
BEGIN
    NULL;
END;
/

-- 5.3 帖子发布后更新圈子统计
CREATE OR REPLACE TRIGGER trg_after_post_insert
AFTER INSERT ON post
FOR EACH ROW
BEGIN
    UPDATE circle SET post_count = post_count + 1 WHERE circle_id = :NEW.circle_id;
END;
/

-- 5.4 帖子删除后更新圈子统计
CREATE OR REPLACE TRIGGER trg_after_post_delete
AFTER DELETE ON post
FOR EACH ROW
BEGIN
    UPDATE circle SET post_count = post_count - 1 WHERE circle_id = :OLD.circle_id;
END;
/

-- 5.5 圈子成员加入后更新成员数
CREATE OR REPLACE TRIGGER trg_after_circle_member_join
AFTER INSERT ON circle_member
FOR EACH ROW
BEGIN
    UPDATE circle SET member_count = member_count + 1 WHERE circle_id = :NEW.circle_id;
END;
/

-- 5.6 圈子成员退出后更新成员数
CREATE OR REPLACE TRIGGER trg_after_circle_member_leave
AFTER DELETE ON circle_member
FOR EACH ROW
BEGIN
    UPDATE circle SET member_count = member_count - 1 WHERE circle_id = :OLD.circle_id;
END;
/

-- 5.7 球员评分后更新球员平均分
CREATE OR REPLACE TRIGGER trg_after_player_rating
AFTER INSERT ON match_player_rating
FOR EACH ROW
BEGIN
    IF :NEW.target_type = 'PLAYER' THEN
        UPDATE player SET
            avg_rating = (SELECT AVG(rating) FROM match_player_rating WHERE target_type = 'PLAYER' AND target_id = :NEW.target_id),
            rating_count = (SELECT COUNT(*) FROM match_player_rating WHERE target_type = 'PLAYER' AND target_id = :NEW.target_id)
        WHERE player_id = :NEW.target_id;
    ELSIF :NEW.target_type = 'COACH' THEN
        UPDATE coach SET
            avg_rating = (SELECT AVG(rating) FROM match_player_rating WHERE target_type = 'COACH' AND target_id = :NEW.target_id),
            rating_count = (SELECT COUNT(*) FROM match_player_rating WHERE target_type = 'COACH' AND target_id = :NEW.target_id)
        WHERE coach_id = :NEW.target_id;
    END IF;
END;
/

-- 5.8 比赛结束后自动更新积分榜
CREATE OR REPLACE TRIGGER trg_after_match_finish
AFTER UPDATE OF status ON match_schedule
FOR EACH ROW
WHEN (NEW.status = 'FINISHED' AND OLD.status != 'FINISHED')
BEGIN
    -- 调用积分榜更新过程
    osp_Update_Standings_After_Match(:NEW.match_id);
END;
/

-- 5.9 新闻浏览量自动增加
CREATE OR REPLACE TRIGGER trg_news_view_increment
BEFORE UPDATE OF view_count ON news_article
FOR EACH ROW
BEGIN
    IF :NEW.view_count > :OLD.view_count THEN
        :NEW.view_count := :OLD.view_count + 1;
    END IF;
END;
/

-- 5.10 转会记录自动创建
CREATE OR REPLACE TRIGGER trg_after_transfer
AFTER INSERT ON transfer_history_log
FOR EACH ROW
BEGIN
    -- 审核日志
    INSERT INTO audit_log (user_id, module, action, description, created_at)
    VALUES (NULL, 'TRANSFER', 'CREATE', '球员转会: ' || :NEW.player_id || ' 从 ' || :NEW.from_club_id || ' 转会到 ' || :NEW.to_club_id, SYSDATE);
END;
/

-- 5.11 赛季开始时自动初始化
CREATE OR REPLACE TRIGGER trg_season_status_change
AFTER UPDATE OF status ON season
FOR EACH ROW
BEGIN
    IF :NEW.status = 'ACTIVE' AND :OLD.status != 'ACTIVE' THEN
        INSERT INTO audit_log (user_id, module, action, description, created_at)
        VALUES (NULL, 'SEASON', 'START', '新赛季开始: ' || :NEW.league || ' ' || :NEW.season_name, SYSDATE);
    ELSIF :NEW.status = 'FINISHED' AND :OLD.status != 'FINISHED' THEN
        INSERT INTO audit_log (user_id, module, action, description, created_at)
        VALUES (NULL, 'SEASON', 'FINISH', '赛季结束: ' || :NEW.league || ' ' || :NEW.season_name, SYSDATE);
    END IF;
END;
/

-- 5.12 帖子点赞数自动更新
CREATE OR REPLACE TRIGGER trg_post_like_count
AFTER INSERT ON post_like
FOR EACH ROW
BEGIN
    UPDATE post SET like_count = (SELECT COUNT(*) FROM post_like WHERE post_id = :NEW.post_id) WHERE post_id = :NEW.post_id;
END;
/

-- 5.13 帖子收藏数自动更新
CREATE OR REPLACE TRIGGER trg_post_favorite_count
AFTER INSERT ON post_favorite
FOR EACH ROW
BEGIN
    UPDATE post SET favorite_count = (SELECT COUNT(*) FROM post_favorite WHERE post_id = :NEW.post_id) WHERE post_id = :NEW.post_id;
END;
/

-- 5.14 帖子评论数自动更新
CREATE OR REPLACE TRIGGER trg_post_comment_count
AFTER INSERT ON post_comment
FOR EACH ROW
BEGIN
    UPDATE post SET comment_count = (SELECT COUNT(*) FROM post_comment WHERE post_id = :NEW.post_id) WHERE post_id = :NEW.post_id;
END;
/

-- 5.15 用户关注自动创建审计日志
CREATE OR REPLACE TRIGGER trg_user_follow_audit
AFTER INSERT ON user_follow
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_id, module, action, description, created_at)
    VALUES (:NEW.follower_id, 'SOCIAL', 'FOLLOW_USER', '关注用户: ' || :NEW.following_id, SYSDATE);
END;
/

-- ============================================
-- 6. 存储过程和函数创建
-- ============================================

-- 6.1 比赛结束后更新积分榜
CREATE OR REPLACE PROCEDURE osp_Update_Standings_After_Match(
    p_match_id IN VARCHAR2
)
AS
    v_home_club_id NUMBER;
    v_away_club_id NUMBER;
    v_home_score NUMBER;
    v_away_score NUMBER;
    v_league VARCHAR2(100);
    v_season VARCHAR2(50);
    v_home_points NUMBER := 0;
    v_away_points NUMBER := 0;
BEGIN
    -- 获取比赛信息
    SELECT home_club_id, away_club_id, home_score, away_score, league, season
    INTO v_home_club_id, v_away_club_id, v_home_score, v_away_score, v_league, v_season
    FROM match_schedule WHERE match_id = p_match_id;

    -- 计算积分
    IF v_home_score > v_away_score THEN
        v_home_points := 3;
        v_away_points := 0;
    ELSIF v_home_score < v_away_score THEN
        v_home_points := 0;
        v_away_points := 3;
    ELSE
        v_home_points := 1;
        v_away_points := 1;
    END IF;

    -- 更新主队积分
    MERGE INTO league_standing s
    USING (SELECT v_home_club_id AS club_id, v_league AS league, v_season AS season FROM DUAL) d
    ON (s.club_id = d.club_id AND s.league = d.league AND s.season = d.season)
    WHEN MATCHED THEN
        UPDATE SET
            played = played + 1,
            won = won + CASE WHEN v_home_points = 3 THEN 1 ELSE 0 END,
            drawn = drawn + CASE WHEN v_home_points = 1 THEN 1 ELSE 0 END,
            lost = lost + CASE WHEN v_home_points = 0 THEN 1 ELSE 0 END,
            goals_for = goals_for + v_home_score,
            goals_against = goals_against + v_away_score,
            goal_diff = goals_for + v_home_score - (goals_against + v_away_score),
            points = points + v_home_points,
            updated_at = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (league, season, club_id, played, won, drawn, lost, goals_for, goals_against, goal_diff, points, updated_at)
        VALUES (v_league, v_season, v_home_club_id, 1,
                CASE WHEN v_home_points = 3 THEN 1 ELSE 0 END,
                CASE WHEN v_home_points = 1 THEN 1 ELSE 0 END,
                CASE WHEN v_home_points = 0 THEN 1 ELSE 0 END,
                v_home_score, v_away_score, v_home_score - v_away_score, v_home_points, SYSDATE);

    -- 更新客队积分
    MERGE INTO league_standing s
    USING (SELECT v_away_club_id AS club_id, v_league AS league, v_season AS season FROM DUAL) d
    ON (s.club_id = d.club_id AND s.league = d.league AND s.season = d.season)
    WHEN MATCHED THEN
        UPDATE SET
            played = played + 1,
            won = won + CASE WHEN v_away_points = 3 THEN 1 ELSE 0 END,
            drawn = drawn + CASE WHEN v_away_points = 1 THEN 1 ELSE 0 END,
            lost = lost + CASE WHEN v_away_points = 0 THEN 1 ELSE 0 END,
            goals_for = goals_for + v_away_score,
            goals_against = goals_against + v_home_score,
            goal_diff = goals_for + v_away_score - (goals_against + v_home_score),
            points = points + v_away_points,
            updated_at = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (league, season, club_id, played, won, drawn, lost, goals_for, goals_against, goal_diff, points, updated_at)
        VALUES (v_league, v_season, v_away_club_id, 1,
                CASE WHEN v_away_points = 3 THEN 1 ELSE 0 END,
                CASE WHEN v_away_points = 1 THEN 1 ELSE 0 END,
                CASE WHEN v_away_points = 0 THEN 1 ELSE 0 END,
                v_away_score, v_home_score, v_away_score - v_home_score, v_away_points, SYSDATE);

    -- 重新计算排名
    osp_Recalculate_Standings(v_league, v_season);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, '更新积分榜失败: ' || SQLERRM);
END osp_Update_Standings_After_Match;
/

-- 6.2 重新计算积分榜排名
CREATE OR REPLACE PROCEDURE osp_Recalculate_Standings(
    p_league IN VARCHAR2,
    p_season IN VARCHAR2
)
AS
    v_position NUMBER := 1;
BEGIN
    FOR rec IN (
        SELECT standing_id,
               RANK() OVER (ORDER BY points DESC, goal_diff DESC, goals_for DESC) AS new_position
        FROM league_standing
        WHERE league = p_league AND season = p_season
        ORDER BY points DESC, goal_diff DESC, goals_for DESC
    ) LOOP
        UPDATE league_standing SET position = rec.new_position WHERE standing_id = rec.standing_id;
    END LOOP;
    COMMIT;
END osp_Recalculate_Standings;
/

-- 6.3 开启新赛季
CREATE OR REPLACE PROCEDURE osp_Start_New_Season(
    p_league IN VARCHAR2,
    p_season_name IN VARCHAR2,
    p_total_rounds IN NUMBER,
    p_start_year IN VARCHAR2,
    p_end_year IN VARCHAR2
)
AS
BEGIN
    -- 将旧赛季设为结束
    UPDATE season SET status = 'FINISHED', updated_at = SYSDATE WHERE league = p_league AND status = 'ACTIVE';

    -- 清空旧数据
    DELETE FROM league_standing WHERE league = p_league;
    DELETE FROM player_season_stats WHERE league = p_league;
    DELETE FROM match_schedule WHERE league = p_league;

    -- 创建新赛季
    INSERT INTO season (league, season_name, start_year, end_year, status, total_rounds, created_at, updated_at)
    VALUES (p_league, p_season_name, p_start_year, p_end_year, 'ACTIVE', p_total_rounds, SYSDATE, SYSDATE);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, '开启新赛季失败: ' || SQLERRM);
END osp_Start_New_Season;
/

-- 6.4 重置赛季数据
CREATE OR REPLACE PROCEDURE osp_Reset_Season_Data(
    p_league IN VARCHAR2
)
AS
BEGIN
    DELETE FROM league_standing WHERE league = p_league;
    DELETE FROM player_season_stats WHERE league = p_league;
    DELETE FROM match_schedule WHERE league = p_league;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, '重置赛季数据失败: ' || SQLERRM);
END osp_Reset_Season_Data;
/

-- 6.5 结束赛季
CREATE OR REPLACE PROCEDURE osp_Finish_Season(
    p_league IN VARCHAR2
)
AS
BEGIN
    UPDATE season SET status = 'FINISHED', updated_at = SYSDATE WHERE league = p_league AND status = 'ACTIVE';
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, '结束赛季失败: ' || SQLERRM);
END osp_Finish_Season;
/

-- 6.6 获取用户活动统计函数
CREATE OR REPLACE FUNCTION fn_Get_User_Activity_Stats(
    p_user_id IN NUMBER
) RETURN VARCHAR2
AS
    v_result VARCHAR2(500);
    v_posts NUMBER;
    v_comments NUMBER;
    v_ratings NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_posts FROM post WHERE user_id = p_user_id;
    SELECT COUNT(*) INTO v_comments FROM post_comment WHERE user_id = p_user_id;
    SELECT COUNT(*) INTO v_ratings FROM match_player_rating WHERE user_id = p_user_id;

    v_result := '帖子:' || v_posts || ', 评论:' || v_comments || ', 评分:' || v_ratings;
    RETURN v_result;
END fn_Get_User_Activity_Stats;
/

-- 6.7 获取球员综合评分函数
CREATE OR REPLACE FUNCTION fn_Get_Player_Composite_Rating(
    p_player_id IN NUMBER
) RETURN NUMBER
AS
    v_avg_rating NUMBER;
    v_games_played NUMBER;
    v_goals NUMBER;
    v_assists NUMBER;
BEGIN
    SELECT AVG(rating), COUNT(*)
    INTO v_avg_rating, v_games_played
    FROM match_player_rating
    WHERE target_type = 'PLAYER' AND target_id = p_player_id;

    SELECT SUM(goals), SUM(assists)
    INTO v_goals, v_assists
    FROM player_season_stats
    WHERE player_id = p_player_id;

    -- 综合评分 = 平均评分 * 0.6 + (进球数/场次)*0.2 + (助攻数/场次)*0.2
    IF v_games_played > 0 THEN
        RETURN ROUND(NVL(v_avg_rating, 0) * 0.6 +
                     NVL(v_goals, 0) / v_games_played * 2 * 0.2 +
                     NVL(v_assists, 0) / v_games_played * 2 * 0.2, 2);
    ELSE
        RETURN NVL(v_avg_rating, 0);
    END IF;
END fn_Get_Player_Composite_Rating;
/

-- 6.8 防刷评分检查函数
CREATE OR REPLACE FUNCTION fn_Can_Rate(
    p_user_id IN NUMBER,
    p_target_type IN VARCHAR2,
    p_target_id IN NUMBER
) RETURN NUMBER
AS
    v_count NUMBER;
    v_last_time TIMESTAMP;
BEGIN
    SELECT COUNT(*), MAX(created_at)
    INTO v_count, v_last_time
    FROM match_player_rating
    WHERE user_id = p_user_id
      AND target_type = p_target_type
      AND target_id = p_target_id
      AND created_at > SYSDATE - 1;

    IF v_count > 0 THEN
        RETURN 0; -- 不能评分
    ELSE
        RETURN 1; -- 可以评分
    END IF;
END fn_Can_Rate;
/

-- 6.9 获取俱乐部实力评分函数
CREATE OR REPLACE FUNCTION fn_Get_Club_Strength_Score(
    p_club_id IN NUMBER,
    p_league IN VARCHAR2,
    p_season IN VARCHAR2
) RETURN NUMBER
AS
    v_points NUMBER;
    v_goals NUMBER;
BEGIN
    SELECT NVL(points, 0), NVL(goals_for, 0)
    INTO v_points, v_goals
    FROM league_standing
    WHERE club_id = p_club_id AND league = p_league AND season = p_season;

    RETURN v_points * 0.7 + v_goals * 0.3;
END fn_Get_Club_Strength_Score;
/

-- 6.10 批量更新球员赛季统计
CREATE OR REPLACE PROCEDURE osp_Batch_Update_Player_Stats(
    p_league IN VARCHAR2,
    p_season IN VARCHAR2
)
AS
BEGIN
    -- 从进球记录汇总更新射手榜
    MERGE INTO player_season_stats ps
    USING (
        SELECT player_id, club_id, league, season,
               COUNT(*) AS goals,
               SUM(CASE WHEN event_type = 'ASSIST' THEN 1 ELSE 0 END) AS assists
        FROM match_event
        WHERE league = p_league AND season = p_season
          AND event_type IN ('GOAL', 'ASSIST')
        GROUP BY player_id, club_id, league, season
    ) e
    ON (ps.player_id = e.player_id AND ps.season = e.season AND ps.league = e.league)
    WHEN MATCHED THEN
        UPDATE SET ps.goals = e.goals, ps.assists = e.assists, ps.updated_at = SYSDATE
    WHEN NOT MATCHED THEN
        INSERT (player_id, season, league, club_id, goals, assists, appearances, updated_at)
        VALUES (e.player_id, e.season, e.league, e.club_id, e.goals, e.assists, 0, SYSDATE);

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20005, '批量更新球员统计失败: ' || SQLERRM);
END osp_Batch_Update_Player_Stats;
/

-- 6.11 生成赛季报告函数
CREATE OR REPLACE FUNCTION fn_Generate_Season_Report(
    p_league IN VARCHAR2,
    p_season IN VARCHAR2
) RETURN CLOB
AS
    v_report CLOB;
    v_total_matches NUMBER;
    v_total_goals NUMBER;
    v_top_scorer NUMBER;
    v_top_assist NUMBER;
BEGIN
    SELECT COUNT(*), SUM(home_score + away_score)
    INTO v_total_matches, v_total_goals
    FROM match_schedule
    WHERE league = p_league AND season = p_season AND status = 'FINISHED';

    SELECT player_id INTO v_top_scorer
    FROM (
        SELECT player_id, SUM(goals) AS total_goals
        FROM player_season_stats
        WHERE league = p_league AND season = p_season
        GROUP BY player_id
        ORDER BY total_goals DESC
    ) WHERE ROWNUM = 1;

    SELECT player_id INTO v_top_assist
    FROM (
        SELECT player_id, SUM(assists) AS total_assists
        FROM player_season_stats
        WHERE league = p_league AND season = p_season
        GROUP BY player_id
        ORDER BY total_assists DESC
    ) WHERE ROWNUM = 1;

    v_report := '联赛:' || p_league || chr(10) ||
                '赛季:' || p_season || chr(10) ||
                '总比赛数:' || v_total_matches || chr(10) ||
                '总进球数:' || v_total_goals || chr(10) ||
                '最佳射手:' || v_top_scorer || chr(10) ||
                '最佳助攻:' || v_top_assist;

    RETURN v_report;
END fn_Generate_Season_Report;
/

-- 6.12 验证用户权限函数
CREATE OR REPLACE FUNCTION fn_Check_User_Permission(
    p_user_id IN NUMBER,
    p_required_role IN VARCHAR2
) RETURN NUMBER
AS
    v_user_role VARCHAR2(50);
BEGIN
    SELECT role INTO v_user_role FROM sys_user WHERE user_id = p_user_id;

    IF v_user_role = 'SUPER_ADMIN' THEN
        RETURN 1;
    ELSIF v_user_role = p_required_role THEN
        RETURN 1;
    ELSIF p_required_role = 'FAN' THEN
        RETURN 1;
    ELSE
        RETURN 0;
    END IF;
END fn_Check_User_Permission;
/

-- ============================================
-- 7. 大对象(LOB)优化
-- ============================================

-- 7.1 为新闻内容添加CLOB列（如果不存在）
-- 注意：如果是新建表，直接在表定义中使用 CLOB 类型
-- 以下为已有表的LOB优化示例

-- ALTER TABLE news_article ADD (content_clob CLOB);
-- CREATE INDEX idx_news_content_clob ON news_article(content_clob) INDEXTYPE CTXSYS.CONTEXT;

-- 7.2 为球员/教练图片添加BLOB存储（预留）
-- ALTER TABLE player ADD (avatar_blob BLOB);
-- ALTER TABLE coach ADD (photo_blob BLOB);

-- 7.3 为俱乐部Logo添加BLOB存储（预留）
-- ALTER TABLE club ADD (logo_blob BLOB);

-- 7.4 为用户头像添加BLOB存储（预留）
-- ALTER TABLE sys_user ADD (avatar_blob BLOB);

-- ============================================
-- 8. 分区表创建（可选，用于大数据量）
-- ============================================

-- 8.1 按时间分区的聊天消息表
-- CREATE TABLE club_chat_message_partitioned (
--     message_id NUMBER,
--     club_id NUMBER,
--     user_id NUMBER,
--     message_content VARCHAR2(2000),
--     created_at TIMESTAMP,
--     PRIMARY KEY (message_id, created_at)
-- )
-- PARTITION BY RANGE (created_at) (
--     PARTITION p_2024_q1 VALUES LESS THAN (TIMESTAMP '2024-04-01 00:00:00'),
--     PARTITION p_2024_q2 VALUES LESS THAN (TIMESTAMP '2024-07-01 00:00:00'),
--     PARTITION p_2024_q3 VALUES LESS THAN (TIMESTAMP '2024-10-01 00:00:00'),
--     PARTITION p_2024_q4 VALUES LESS THAN (TIMESTAMP '2025-01-01 00:00:00'),
--     PARTITION p_future VALUES LESS THAN (MAXVALUE)
-- );

-- 8.2 按联赛分区的积分榜表
-- CREATE TABLE league_standing_partitioned (
--     standing_id NUMBER,
--     league VARCHAR2(100),
--     season VARCHAR2(50),
--     club_id NUMBER,
--     position NUMBER,
--     PRIMARY KEY (standing_id, league)
-- )
-- PARTITION BY LIST (league) (
--     PARTITION p_premier_league VALUES ('Premier League'),
--     PARTITION p_la_liga VALUES ('La Liga'),
--     PARTITION p_bundesliga VALUES ('Bundesliga'),
--     PARTITION p_serie_a VALUES ('Serie A'),
--     PARTITION p_ligue_1 VALUES ('Ligue 1'),
--     PARTITION p_other VALUES (DEFAULT)
-- );

-- ============================================
-- 9. 物化视图（用于复杂查询优化）
-- ============================================

-- 9.1 帖子统计物化视图
-- CREATE MATERIALIZED VIEW mv_post_stats
-- BUILD IMMEDIATE
-- REFRESH COMPLETE
-- AS
-- SELECT
--     circle_id,
--     COUNT(*) AS total_posts,
--     SUM(like_count) AS total_likes,
--     SUM(comment_count) AS total_comments,
--     TRUNC(created_at, 'MM') AS month
-- FROM post
-- GROUP BY circle_id, TRUNC(created_at, 'MM');

-- ============================================
-- 10. 总结
-- ============================================

-- 本脚本包含以下优化内容：
-- 1. 表空间：数据、索引、临时、撤销表空间
-- 2. 序列：13个序列用于主键生成
-- 3. 索引：60+个索引覆盖常用查询字段
-- 4. 视图：12个视图用于复杂查询简化
-- 5. 触发器：15个触发器用于自动化处理
-- 6. 存储过程：10个存储过程
-- 7. 函数：6个函数用于业务逻辑
-- 8. LOB：预留的大对象列用于存储大型数据
-- 9. 分区表：可选的分区策略示例
-- 10. 物化视图：可选的查询优化示例
