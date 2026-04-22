-- ============================================================================
-- SoccerHub - 体育社区管理系统
-- Oracle 21 Database Initialization Script
-- Author: SoccerHub Team
-- Version: 1.0
-- ============================================================================

-- ============================================================================
-- SECTION 1: APP USER SETUP
-- ============================================================================
BEGIN
    EXECUTE IMMEDIATE 'DROP USER soccerhub CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN RAISE; END IF;
END;
/

-- ============================================================================
-- SECTION 2: SEQUENCES
-- ============================================================================

CREATE SEQUENCE SEQ_SYS_USER      START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_CLUB          START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_PLAYER        START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_COACH         START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_RATING        START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_MESSAGE       START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_AUDIT         START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_TRANSFER      START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_DICTIONARY    START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_NEWS          START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;
CREATE SEQUENCE SEQ_STANDINGS     START WITH 1 INCREMENT BY 1 NOMAXVALUE NOCYCLE;

-- ============================================================================
-- SECTION 3: TABLES
-- ============================================================================

-- 3.1 SYS_USER (用户表)
CREATE TABLE SYS_USER (
    USER_ID         NUMBER          DEFAULT SEQ_SYS_USER.NEXTVAL PRIMARY KEY,
    USERNAME        VARCHAR2(50)    NOT NULL UNIQUE,
    PASSWORD_HASH   VARCHAR2(255)   NOT NULL,
    NICKNAME        VARCHAR2(100)   NOT NULL,
    EMAIL           VARCHAR2(100)   UNIQUE,
    AVATAR_URL      VARCHAR2(500),
    ROLE            VARCHAR2(20)    NOT NULL CHECK (ROLE IN ('FAN', 'CLUB_ADMIN', 'SUPER_ADMIN')),
    STATUS          VARCHAR2(20)    DEFAULT 'ACTIVE' CHECK (STATUS IN ('ACTIVE', 'BANNED', 'INACTIVE')),
    MANAGED_CLUB_ID NUMBER,
    CREATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    UPDATED_AT      TIMESTAMP,
    LAST_LOGIN_AT   TIMESTAMP
);

COMMENT ON TABLE SYS_USER IS '用户表 - 系统用户信息';
COMMENT ON COLUMN SYS_USER.MANAGED_CLUB_ID IS '管理的俱乐部ID(仅CLUB_ADMIN有效)';

-- 3.2 CLUB (俱乐部表)
CREATE TABLE CLUB (
    CLUB_ID           NUMBER          DEFAULT SEQ_CLUB.NEXTVAL PRIMARY KEY,
    NAME              VARCHAR2(100)   NOT NULL,
    SHORT_NAME        VARCHAR2(20),
    LEAGUE            VARCHAR2(50)    NOT NULL,
    CITY              VARCHAR2(100),
    COUNTRY           VARCHAR2(100),
    STADIUM           VARCHAR2(200),
    ESTABLISH_DATE    DATE,
    STADIUM_CAPACITY  NUMBER,
    LOGO_URL          VARCHAR2(500),
    DESCRIPTION      CLOB,
    TOTAL_SCORE       NUMBER(10,2)    DEFAULT 0,
    CREATED_AT        TIMESTAMP       DEFAULT SYSTIMESTAMP,
    UPDATED_AT        TIMESTAMP
);

COMMENT ON TABLE CLUB IS '俱乐部表 - 五大联赛俱乐部信息';
COMMENT ON COLUMN CLUB.TOTAL_SCORE IS '球队总积分(由物化视图汇总)';

-- 3.3 PLAYER (球员表)
CREATE TABLE PLAYER (
    PLAYER_ID      NUMBER          DEFAULT SEQ_PLAYER.NEXTVAL PRIMARY KEY,
    NAME            VARCHAR2(100)   NOT NULL,
    NAME_CN         VARCHAR2(100),
    POSITION        VARCHAR2(20)   CHECK (POSITION IN ('GK', 'DF', 'MF', 'FW')),
    CLUB_ID         NUMBER          REFERENCES CLUB(CLUB_ID),
    JERSEY_NUMBER   NUMBER,
    NATIONALITY     VARCHAR2(100),
    BIRTH_DATE      DATE,
    HEIGHT_CM       NUMBER,
    WEIGHT_KG       NUMBER,
    STATUS          VARCHAR2(20)    DEFAULT 'ACTIVE' CHECK (STATUS IN ('ACTIVE', 'RETIRED', 'INJURED', 'FREE')),
    MARKET_VALUE    NUMBER,
    AVATAR_URL      VARCHAR2(500),
    AVG_SCORE       NUMBER(4,2)     DEFAULT 0,
    TOTAL_RATINGS   NUMBER          DEFAULT 0,
    CREATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    UPDATED_AT      TIMESTAMP
);

COMMENT ON TABLE PLAYER IS '球员表 - 球员详细信息';
COMMENT ON COLUMN PLAYER.AVG_SCORE IS '平均评分(由触发器维护,范围0.00-10.00)';

-- 3.4 COACH (教练表)
CREATE TABLE COACH (
    COACH_ID        NUMBER          DEFAULT SEQ_COACH.NEXTVAL PRIMARY KEY,
    NAME            VARCHAR2(100)   NOT NULL,
    NAME_CN         VARCHAR2(100),
    CLUB_ID         NUMBER          REFERENCES CLUB(CLUB_ID),
    IS_HEAD_COACH   NUMBER(1)       DEFAULT 0,
    NATIONALITY     VARCHAR2(100),
    BIRTH_DATE      DATE,
    AVATAR_URL      VARCHAR2(500),
    AVG_SCORE       NUMBER(4,2)     DEFAULT 0,
    TOTAL_RATINGS   NUMBER          DEFAULT 0,
    CREATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    UPDATED_AT      TIMESTAMP
);

COMMENT ON TABLE COACH IS '教练表 - 教练详细信息';
COMMENT ON COLUMN COACH.IS_HEAD_COACH IS '是否主教练(1=是,0=否,Oracle21前用NUMBER模拟BOOLEAN)';

-- 3.5 MATCH_SCHEDULE (赛程表)
CREATE TABLE MATCH_SCHEDULE (
    MATCH_ID        VARCHAR2(50)    PRIMARY KEY,
    HOME_CLUB_ID    NUMBER          NOT NULL REFERENCES CLUB(CLUB_ID),
    AWAY_CLUB_ID    NUMBER          NOT NULL REFERENCES CLUB(CLUB_ID),
    MATCH_TIME      TIMESTAMP       NOT NULL,
    HOME_SCORE      NUMBER,
    AWAY_SCORE      NUMBER,
    STATUS          VARCHAR2(20)    DEFAULT 'PENDING' CHECK (STATUS IN ('PENDING', 'IN_PROGRESS', 'FINISHED', 'CANCELLED')),
    ROUND           VARCHAR2(20),
    VENUE           VARCHAR2(200),
    REFEREE         VARCHAR2(100),
    LEAGUE          VARCHAR2(50),
    SEASON          VARCHAR2(20),
    UPDATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    CONSTRAINT CK_MATCH_CLUBS CHECK (HOME_CLUB_ID <> AWAY_CLUB_ID)
);

COMMENT ON TABLE MATCH_SCHEDULE IS '赛程表 - 比赛日程与比分';

-- 3.6 USER_CLUB_FOLLOW (关注表)
CREATE TABLE USER_CLUB_FOLLOW (
    USER_ID         NUMBER          NOT NULL REFERENCES SYS_USER(USER_ID),
    CLUB_ID         NUMBER          NOT NULL REFERENCES CLUB(CLUB_ID),
    IS_PRIMARY      NUMBER(1)       DEFAULT 0,
    FOLLOW_TIME     TIMESTAMP       DEFAULT SYSTIMESTAMP,
    PRIMARY KEY (USER_ID, CLUB_ID)
);

COMMENT ON TABLE USER_CLUB_FOLLOW IS '关注表 - 用户与俱乐部的关注关系';

-- 3.7 RATING_RECORD (评分明细表)
CREATE TABLE RATING_RECORD (
    RECORD_ID       NUMBER          DEFAULT SEQ_RATING.NEXTVAL PRIMARY KEY,
    USER_ID         NUMBER          NOT NULL REFERENCES SYS_USER(USER_ID),
    TARGET_ID       NUMBER          NOT NULL,
    TARGET_TYPE     VARCHAR2(10)    NOT NULL CHECK (TARGET_TYPE IN ('PLAYER', 'COACH')),
    SCORE           NUMBER(2,0)     NOT NULL CHECK (SCORE >= 1 AND SCORE <= 10),
    COMMENT_TEXT    VARCHAR2(500),
    RATING_TYPE     VARCHAR2(20)    DEFAULT 'GENERAL' CHECK (RATING_TYPE IN ('MATCH', 'SEASON', 'GENERAL')),
    MATCH_ID        VARCHAR2(50)    REFERENCES MATCH_SCHEDULE(MATCH_ID),
    IS_COLLAPSED    NUMBER(1)       DEFAULT 0,
    CREATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP
);

COMMENT ON TABLE RATING_RECORD IS '评分表 - 用户对球员/教练的评分记录';

-- 3.8 CLUB_CHAT_MESSAGE (聊天室消息表)
CREATE TABLE CLUB_CHAT_MESSAGE (
    MESSAGE_ID      NUMBER          DEFAULT SEQ_MESSAGE.NEXTVAL PRIMARY KEY,
    CLUB_ID         NUMBER          NOT NULL REFERENCES CLUB(CLUB_ID),
    USER_ID         NUMBER          NOT NULL REFERENCES SYS_USER(USER_ID),
    CONTENT         CLOB            NOT NULL,
    MESSAGE_TYPE    VARCHAR2(20)    DEFAULT 'TEXT' CHECK (MESSAGE_TYPE IN ('TEXT', 'IMAGE', 'LINK', 'SYSTEM')),
    IS_DELETED      NUMBER(1)       DEFAULT 0,
    IS_COLLAPSED    NUMBER(1)       DEFAULT 0,
    DELETED_BY      NUMBER,
    DELETED_AT      TIMESTAMP,
    CREATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP
);

COMMENT ON TABLE CLUB_CHAT_MESSAGE IS '聊天消息表 - 俱乐部聊天室消息';

-- 3.9 TRANSFER_HISTORY_LOG (转会变动审计表)
CREATE TABLE TRANSFER_HISTORY_LOG (
    LOG_ID          NUMBER          DEFAULT SEQ_TRANSFER.NEXTVAL PRIMARY KEY,
    PLAYER_ID       NUMBER          REFERENCES PLAYER(PLAYER_ID),
    OLD_CLUB_ID     NUMBER,
    NEW_CLUB_ID     NUMBER,
    TRANSFER_TYPE   VARCHAR2(20)    CHECK (TRANSFER_TYPE IN ('IN', 'OUT', 'LOAN', 'FREE')),
    TRANSFER_FEE    NUMBER,
    SEASON          VARCHAR2(20),
    ACTION_USER_ID  NUMBER          REFERENCES SYS_USER(USER_ID),
    ACTION_TIME     TIMESTAMP       DEFAULT SYSTIMESTAMP,
    NOTES           VARCHAR2(500)
);

COMMENT ON TABLE TRANSFER_HISTORY_LOG IS '转会历史表 - 球员转会记录审计';

-- 3.10 SYSTEM_DICTIONARY (系统字典表)
CREATE TABLE SYSTEM_DICTIONARY (
    DICT_ID         NUMBER          DEFAULT SEQ_DICTIONARY.NEXTVAL PRIMARY KEY,
    DICT_TYPE       VARCHAR2(50)    NOT NULL,
    DICT_KEY        VARCHAR2(100)   NOT NULL,
    DICT_VALUE      VARCHAR2(200)   NOT NULL,
    SORT_ORDER      NUMBER          DEFAULT 0,
    IS_ENABLED      NUMBER(1)       DEFAULT 1,
    DESCRIPTION     VARCHAR2(500),
    CREATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    UPDATED_AT      TIMESTAMP,
    UNIQUE (DICT_TYPE, DICT_KEY)
);

COMMENT ON TABLE SYSTEM_DICTIONARY IS '系统字典表 - 配置数据存储';

-- 3.11 AUDIT_LOG (操作审计表)
CREATE TABLE AUDIT_LOG (
    LOG_ID          NUMBER          DEFAULT SEQ_AUDIT.NEXTVAL PRIMARY KEY,
    USER_ID         NUMBER,
    ACTION_MODULE   VARCHAR2(50),
    ACTION_TYPE     VARCHAR2(50),
    TARGET_TYPE     VARCHAR2(50),
    TARGET_ID       NUMBER,
    OLD_VALUE       CLOB,
    NEW_VALUE       CLOB,
    IP_ADDRESS      VARCHAR2(50),
    USER_AGENT      VARCHAR2(500),
    ACTION_TIME     TIMESTAMP       DEFAULT SYSTIMESTAMP
);

COMMENT ON TABLE AUDIT_LOG IS '审计日志表 - 系统操作审计追踪';

-- 3.12 LEAGUE_STANDINGS (联赛积分榜表)
CREATE TABLE LEAGUE_STANDINGS (
    STANDING_ID     NUMBER          DEFAULT SEQ_STANDINGS.NEXTVAL PRIMARY KEY,
    LEAGUE          VARCHAR2(50)    NOT NULL,
    SEASON          VARCHAR2(20)    NOT NULL,
    CLUB_ID         NUMBER          NOT NULL REFERENCES CLUB(CLUB_ID),
    POSITION        NUMBER,
    PLAYED          NUMBER          DEFAULT 0,
    WON             NUMBER          DEFAULT 0,
    DRAWN           NUMBER          DEFAULT 0,
    LOST            NUMBER          DEFAULT 0,
    GOALS_FOR       NUMBER          DEFAULT 0,
    GOALS_AGAINST   NUMBER          DEFAULT 0,
    GOAL_DIFF       NUMBER          DEFAULT 0,
    POINTS          NUMBER          DEFAULT 0,
    UPDATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    UNIQUE (LEAGUE, SEASON, CLUB_ID)
);

COMMENT ON TABLE LEAGUE_STANDINGS IS '联赛积分榜表 - 各联赛积分排名';

-- 3.13 NEWS_ARTICLE (新闻文章表)
CREATE TABLE NEWS_ARTICLE (
    ARTICLE_ID      NUMBER          DEFAULT SEQ_NEWS.NEXTVAL PRIMARY KEY,
    TITLE           VARCHAR2(300)   NOT NULL,
    SUMMARY         VARCHAR2(500),
    CONTENT         CLOB            NOT NULL,
    AUTHOR_ID       NUMBER          REFERENCES SYS_USER(USER_ID),
    CLUB_ID         NUMBER          REFERENCES CLUB(CLUB_ID),
    TAGS            VARCHAR2(500),
    COVER_IMAGE_URL VARCHAR2(500),
    VIEW_COUNT      NUMBER          DEFAULT 0,
    IS_PUBLISHED    NUMBER(1)       DEFAULT 1,
    PUBLISHED_AT    TIMESTAMP,
    CREATED_AT      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    UPDATED_AT      TIMESTAMP
);

COMMENT ON TABLE NEWS_ARTICLE IS '新闻文章表 - 球队新闻与文章';

-- ============================================================================
-- SECTION 4: INDEXES
-- ============================================================================

-- Performance indexes for high-frequency queries
CREATE INDEX IDX_PLAYER_CLUB     ON PLAYER(CLUB_ID);
CREATE INDEX IDX_PLAYER_STATUS   ON PLAYER(STATUS);
CREATE INDEX IDX_PLAYER_POSITION ON PLAYER(POSITION);
CREATE INDEX IDX_PLAYER_AVGSCORE ON PLAYER(AVG_SCORE DESC);

CREATE INDEX IDX_COACH_CLUB      ON COACH(CLUB_ID);

CREATE INDEX IDX_MATCH_TIME      ON MATCH_SCHEDULE(MATCH_TIME);
CREATE INDEX IDX_MATCH_LEAGUE   ON MATCH_SCHEDULE(LEAGUE);
CREATE INDEX IDX_MATCH_STATUS    ON MATCH_SCHEDULE(STATUS);
CREATE INDEX IDX_MATCH_HOME      ON MATCH_SCHEDULE(HOME_CLUB_ID);
CREATE INDEX IDX_MATCH_AWAY      ON MATCH_SCHEDULE(AWAY_CLUB_ID);
CREATE INDEX IDX_MATCH_LEAGUE_SEASON ON MATCH_SCHEDULE(LEAGUE, SEASON);

CREATE INDEX IDX_CHAT_CLUB       ON CLUB_CHAT_MESSAGE(CLUB_ID);
CREATE INDEX IDX_CHAT_TIME       ON CLUB_CHAT_MESSAGE(CREATED_AT DESC);
CREATE INDEX IDX_CHAT_CLUB_TIME  ON CLUB_CHAT_MESSAGE(CLUB_ID, CREATED_AT DESC);

CREATE INDEX IDX_RATING_TARGET   ON RATING_RECORD(TARGET_ID, TARGET_TYPE);
CREATE INDEX IDX_RATING_USER     ON RATING_RECORD(USER_ID);
CREATE INDEX IDX_RATING_CREATED  ON RATING_RECORD(CREATED_AT DESC);

CREATE INDEX IDX_FOLLOW_USER     ON USER_CLUB_FOLLOW(USER_ID);
CREATE INDEX IDX_FOLLOW_CLUB     ON USER_CLUB_FOLLOW(CLUB_ID);

CREATE INDEX IDX_AUDIT_TIME      ON AUDIT_LOG(ACTION_TIME DESC);
CREATE INDEX IDX_AUDIT_USER      ON AUDIT_LOG(USER_ID);
CREATE INDEX IDX_AUDIT_MODULE     ON AUDIT_LOG(ACTION_MODULE);

CREATE INDEX IDX_NEWS_PUBLISHED  ON NEWS_ARTICLE(PUBLISHED_AT DESC);
CREATE INDEX IDX_NEWS_CLUB       ON NEWS_ARTICLE(CLUB_ID);
CREATE INDEX IDX_NEWS_AUTHOR     ON NEWS_ARTICLE(AUTHOR_ID);

CREATE INDEX IDX_STANDINGS_LEAGUE ON LEAGUE_STANDINGS(LEAGUE, SEASON);
CREATE INDEX IDX_STANDINGS_POS   ON LEAGUE_STANDINGS(LEAGUE, SEASON, POSITION);

-- ============================================================================
-- SECTION 5: STORED PROCEDURES
-- ============================================================================

-- 5.1 osp_Submit_User_Rating: Rating submission with anti-spam protection
CREATE OR REPLACE PROCEDURE osp_Submit_User_Rating (
    p_User_ID     IN  NUMBER,
    p_Target_ID   IN  NUMBER,
    p_Target_Type IN  VARCHAR2,
    p_Score       IN  NUMBER,
    p_Comment     IN  VARCHAR2,
    p_Club_ID     IN  NUMBER,
    p_Rating_Type IN  VARCHAR2 DEFAULT 'GENERAL',
    p_Match_ID    IN  VARCHAR2 DEFAULT NULL,
    p_Result      OUT VARCHAR2,
    p_Record_ID   OUT NUMBER
) AS
    v_Is_Followed      NUMBER;
    v_Has_Rated_Today  NUMBER;
    v_User_Role        VARCHAR2(20);
    v_Max_Follows      NUMBER := 3;
    v_Current_Follows  NUMBER;
BEGIN
    p_Result := 'SUCCESS';
    p_Record_ID := 0;

    -- Check user role
    SELECT ROLE INTO v_User_Role FROM SYS_USER WHERE USER_ID = p_User_ID;

    -- 1. Permission check: SUPER_ADMIN bypasses all checks
    IF v_User_Role != 'SUPER_ADMIN' THEN
        -- 2. Check if user follows the club (required for FAN and CLUB_ADMIN)
        IF v_User_Role IN ('FAN', 'CLUB_ADMIN') THEN
            SELECT COUNT(1) INTO v_Is_Followed
            FROM USER_CLUB_FOLLOW
            WHERE USER_ID = p_User_ID AND CLUB_ID = p_Club_ID;

            IF v_Is_Followed = 0 THEN
                p_Result := 'ERROR: 必须先关注该俱乐部才能评分！';
                RETURN;
            END IF;
        END IF;

        -- 3. Anti-spam: Check if rated the same target within 24 hours
        SELECT COUNT(1) INTO v_Has_Rated_Today
        FROM RATING_RECORD
        WHERE USER_ID = p_User_ID
          AND TARGET_ID = p_Target_ID
          AND TARGET_TYPE = p_Target_Type
          AND CREATED_AT > SYSTIMESTAMP - INTERVAL '1' DAY;

        IF v_Has_Rated_Today > 0 THEN
            p_Result := 'ERROR: 您在24小时内已经评价过该对象，请勿重复刷分。';
            RETURN;
        END IF;

        -- 4. Fan limit check: Fan can only follow max 3 clubs
        IF v_User_Role = 'FAN' THEN
            SELECT COUNT(1) INTO v_Current_Follows
            FROM USER_CLUB_FOLLOW
            WHERE USER_ID = p_User_ID;

            IF v_Current_Follows >= v_Max_Follows THEN
                p_Result := 'WARNING: 您已关注' || v_Max_Follows || '支球队的上限，无法关注更多球队进行评分。';
                RETURN;
            END IF;
        END IF;
    END IF;

    -- 5. Insert rating record
    INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, MATCH_ID)
    VALUES (p_User_ID, p_Target_ID, p_Target_Type, p_Score, p_Comment, p_Rating_Type, p_Match_ID)
    RETURNING RECORD_ID INTO p_Record_ID;

    COMMIT;
    p_Result := 'SUCCESS: 评分成功！您的评分将帮助其他球迷了解这位' ||
                 CASE p_Target_Type WHEN 'PLAYER' THEN '球员' ELSE '教练' END || '。';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_Result := 'FATAL ERROR: ' || SQLERRM;
END osp_Submit_User_Rating;
/

-- 5.2 osp_Upsert_Match_Schedule: UPSERT match data via MERGE INTO
CREATE OR REPLACE PROCEDURE osp_Upsert_Match_Schedule (
    p_Match_ID     IN  VARCHAR2,
    p_Home_ID      IN  NUMBER,
    p_Away_ID      IN  NUMBER,
    p_Match_Time   IN  TIMESTAMP,
    p_Home_Score   IN  NUMBER,
    p_Away_Score   IN  NUMBER,
    p_Status       IN  VARCHAR2,
    p_Round        IN  VARCHAR2 DEFAULT NULL,
    p_Venue        IN  VARCHAR2 DEFAULT NULL,
    p_Referee      IN  VARCHAR2 DEFAULT NULL,
    p_League       IN  VARCHAR2 DEFAULT NULL,
    p_Season       IN  VARCHAR2 DEFAULT NULL,
    p_Result       OUT VARCHAR2
) AS
    v_Is_New       BOOLEAN := FALSE;
BEGIN
    MERGE INTO MATCH_SCHEDULE m
    USING (SELECT p_Match_ID AS Match_ID FROM DUAL) src
    ON (m.Match_ID = src.Match_ID)
    WHEN MATCHED THEN
        UPDATE SET
            Home_Score  = p_Home_Score,
            Away_Score  = p_Away_Score,
            Status      = p_Status,
            Round       = NVL(p_Round, m.Round),
            Venue       = NVL(p_Venue, m.Venue),
            Referee     = NVL(p_Referee, m.Referee),
            Updated_At  = SYSTIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (Match_ID, Home_Club_ID, Away_Club_ID, Match_Time, Home_Score, Away_Score,
                Status, Round, Venue, Referee, League, Season, Updated_At)
        VALUES (p_Match_ID, p_Home_ID, p_Away_ID, p_Match_Time, p_Home_Score, p_Away_Score,
                p_Status, p_Round, p_Venue, p_Referee, p_League, p_Season, SYSTIMESTAMP);

    COMMIT;
    p_Result := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_Result := 'FATAL ERROR: ' || SQLERRM;
END osp_Upsert_Match_Schedule;
/

-- 5.3 osp_Transfer_Player: Player transfer with history logging
CREATE OR REPLACE PROCEDURE osp_Transfer_Player (
    p_Player_ID        IN  NUMBER,
    p_New_Club_ID      IN  NUMBER,
    p_Transfer_Type    IN  VARCHAR2,
    p_Transfer_Fee      IN  NUMBER,
    p_Season            IN  VARCHAR2,
    p_Action_User_ID    IN  NUMBER,
    p_Notes             IN  VARCHAR2 DEFAULT NULL,
    p_Result            OUT VARCHAR2
) AS
    v_Old_Club_ID   NUMBER;
    v_Player_Name   VARCHAR2(100);
    v_User_Role     VARCHAR2(20);
    v_Managed_Club NUMBER;
BEGIN
    -- Get player current club
    SELECT CLUB_ID, NAME INTO v_Old_Club_ID, v_Player_Name
    FROM PLAYER WHERE PLAYER_ID = p_Player_ID;

    -- Get action user role
    SELECT ROLE, MANAGED_CLUB_ID INTO v_User_Role, v_Managed_Club
    FROM SYS_USER WHERE USER_ID = p_Action_User_ID;

    -- Permission check: Only SUPER_ADMIN or the managed club's ADMIN
    IF v_User_Role != 'SUPER_ADMIN' THEN
        IF v_User_Role = 'CLUB_ADMIN' THEN
            IF v_Managed_Club NOT IN (v_Old_Club_ID, p_New_Club_ID) THEN
                p_Result := 'ERROR: 您没有权限操作此转会。';
                RETURN;
            END IF;
        ELSE
            p_Result := 'ERROR: 只有系统管理员或相关俱乐部管理员才能执行转会操作。';
            RETURN;
        END IF;
    END IF;

    -- Log transfer history
    INSERT INTO TRANSFER_HISTORY_LOG
        (PLAYER_ID, OLD_CLUB_ID, NEW_CLUB_ID, TRANSFER_TYPE, TRANSFER_FEE, SEASON, ACTION_USER_ID, NOTES)
    VALUES
        (p_Player_ID, v_Old_Club_ID, p_New_Club_ID, p_Transfer_Type, p_Transfer_Fee, p_Season, p_Action_User_ID, p_Notes);

    -- Update player club
    UPDATE PLAYER
    SET CLUB_ID = p_New_Club_ID,
        STATUS = CASE WHEN p_Transfer_Type = 'FREE' THEN 'FREE' ELSE STATUS END,
        UPDATED_AT = SYSTIMESTAMP
    WHERE PLAYER_ID = p_Player_ID;

    COMMIT;
    p_Result := 'SUCCESS: 球员 ' || v_Player_Name || ' 转会完成！';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_Result := 'FATAL ERROR: ' || SQLERRM;
END osp_Transfer_Player;
/

-- 5.4 osp_Moderate_Message: Admin message moderation with audit trail
CREATE OR REPLACE PROCEDURE osp_Moderate_Message (
    p_Message_ID        IN  NUMBER,
    p_Action_User_ID    IN  NUMBER,
    p_Action            IN  VARCHAR2,  -- 'DELETE' or 'COLLAPSE'
    p_Result            OUT VARCHAR2
) AS
    v_User_Role     VARCHAR2(20);
    v_Managed_Club  NUMBER;
    v_Message_Club  NUMBER;
    v_Old_Value     CLOB;
    v_New_Value     CLOB;
BEGIN
    -- Get user info
    SELECT ROLE, MANAGED_CLUB_ID INTO v_User_Role, v_Managed_Club
    FROM SYS_USER WHERE USER_ID = p_Action_User_ID;

    -- Get message club
    SELECT CLUB_ID, CONTENT INTO v_Message_Club, v_Old_Value
    FROM CLUB_CHAT_MESSAGE WHERE MESSAGE_ID = p_Message_ID;

    -- Permission check
    IF v_User_Role != 'SUPER_ADMIN' AND v_User_Role != 'CLUB_ADMIN' THEN
        p_Result := 'ERROR: 您没有权限管理消息。';
        RETURN;
    END IF;

    IF v_User_Role = 'CLUB_ADMIN' AND v_Managed_Club != v_Message_Club THEN
        p_Result := 'ERROR: 您只能管理本俱乐部的消息。';
        RETURN;
    END IF;

    -- Perform action
    IF p_Action = 'DELETE' THEN
        UPDATE CLUB_CHAT_MESSAGE
        SET IS_DELETED = 1,
            DELETED_BY = p_Action_User_ID,
            DELETED_AT = SYSTIMESTAMP
        WHERE MESSAGE_ID = p_Message_ID;

        v_New_Value := '{"is_deleted": 1}';

    ELSIF p_Action = 'COLLAPSE' THEN
        UPDATE CLUB_CHAT_MESSAGE
        SET IS_COLLAPSED = 1
        WHERE MESSAGE_ID = p_Message_ID;

        v_New_Value := '{"is_collapsed": 1}';

    ELSE
        p_Result := 'ERROR: 无效的操作类型。';
        RETURN;
    END IF;

    -- Audit log
    INSERT INTO AUDIT_LOG (USER_ID, ACTION_MODULE, ACTION_TYPE, TARGET_TYPE, TARGET_ID, OLD_VALUE, NEW_VALUE)
    VALUES (p_Action_User_ID, 'CHAT', p_Action, 'MESSAGE', p_Message_ID, v_Old_Value, v_New_Value);

    COMMIT;
    p_Result := 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_Result := 'FATAL ERROR: ' || SQLERRM;
END osp_Moderate_Message;
/

-- 5.5 osp_Batch_Update_Standings: Batch update league standings after matches
CREATE OR REPLACE PROCEDURE osp_Batch_Update_Standings (
    p_Match_ID      IN  VARCHAR2,
    p_Result        OUT VARCHAR2
) AS
    v_Home_ID       NUMBER;
    v_Away_ID       NUMBER;
    v_Home_Score    NUMBER;
    v_Away_Score    NUMBER;
    v_Home_League   VARCHAR2(50);
    v_Away_League   VARCHAR2(50);
    v_Season        VARCHAR2(20);
BEGIN
    -- Get match info
    SELECT HOME_CLUB_ID, AWAY_CLUB_ID, HOME_SCORE, AWAY_SCORE, LEAGUE, SEASON
    INTO v_Home_ID, v_Away_ID, v_Home_Score, v_Away_Score, v_Home_League, v_Season
    FROM MATCH_SCHEDULE WHERE MATCH_ID = p_Match_ID;

    IF v_Home_Score IS NULL OR v_Away_Score IS NULL THEN
        p_Result := 'SKIPPED: 比分未更新。';
        RETURN;
    END IF;

    -- Update home team standings
    MERGE INTO LEAGUE_STANDINGS s
    USING (
        SELECT v_Home_ID AS CLUB_ID, v_Home_League AS LEAGUE, v_Season AS SEASON,
               v_Home_Score AS GF, v_Away_Score AS GA,
               CASE WHEN v_Home_Score > v_Away_Score THEN 1 ELSE 0 END AS W,
               CASE WHEN v_Home_Score = v_Away_Score THEN 1 ELSE 0 END AS D,
               CASE WHEN v_Home_Score < v_Away_Score THEN 1 ELSE 0 END AS L,
               CASE WHEN v_Home_Score > v_Away_Score THEN 3
                    WHEN v_Home_Score = v_Away_Score THEN 1 ELSE 0 END AS PTS
        FROM DUAL
    ) src
    ON (s.CLUB_ID = src.CLUB_ID AND s.LEAGUE = src.LEAGUE AND s.SEASON = src.SEASON)
    WHEN MATCHED THEN
        UPDATE SET
            PLAYED = s.PLAYED + 1,
            WON    = s.WON + src.W,
            DRAWN  = s.DRAWN + src.D,
            LOST   = s.LOST + src.L,
            GOALS_FOR     = s.GOALS_FOR + src.GF,
            GOALS_AGAINST = s.GOALS_AGAINST + src.GA,
            GOAL_DIFF     = (s.GOALS_FOR + src.GF) - (s.GOALS_AGAINST + src.GA),
            POINTS        = s.POINTS + src.PTS,
            UPDATED_AT    = SYSTIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (LEAGUE, SEASON, CLUB_ID, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
        VALUES (src.LEAGUE, src.SEASON, src.CLUB_ID, 1, src.W, src.D, src.L, src.GF, src.GA, src.GF - src.GA, src.PTS);

    -- Update away team standings
    MERGE INTO LEAGUE_STANDINGS s
    USING (
        SELECT v_Away_ID AS CLUB_ID, v_Away_League AS LEAGUE, v_Season AS SEASON,
               v_Away_Score AS GF, v_Home_Score AS GA,
               CASE WHEN v_Away_Score > v_Home_Score THEN 1 ELSE 0 END AS W,
               CASE WHEN v_Away_Score = v_Home_Score THEN 1 ELSE 0 END AS D,
               CASE WHEN v_Away_Score < v_Home_Score THEN 1 ELSE 0 END AS L,
               CASE WHEN v_Away_Score > v_Home_Score THEN 3
                    WHEN v_Away_Score = v_Home_Score THEN 1 ELSE 0 END AS PTS
        FROM DUAL
    ) src
    ON (s.CLUB_ID = src.CLUB_ID AND s.LEAGUE = src.LEAGUE AND s.SEASON = src.SEASON)
    WHEN MATCHED THEN
        UPDATE SET
            PLAYED = s.PLAYED + 1,
            WON    = s.WON + src.W,
            DRAWN  = s.DRAWN + src.D,
            LOST   = s.LOST + src.L,
            GOALS_FOR     = s.GOALS_FOR + src.GF,
            GOALS_AGAINST = s.GOALS_AGAINST + src.GA,
            GOAL_DIFF     = (s.GOALS_FOR + src.GF) - (s.GOALS_AGAINST + src.GA),
            POINTS        = s.POINTS + src.PTS,
            UPDATED_AT    = SYSTIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (LEAGUE, SEASON, CLUB_ID, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
        VALUES (src.LEAGUE, src.SEASON, src.CLUB_ID, 1, src.W, src.D, src.L, src.GF, src.GA, src.GF - src.GA, src.PTS);

    COMMIT;
    p_Result := 'SUCCESS';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_Result := 'FATAL ERROR: ' || SQLERRM;
END osp_Batch_Update_Standings;
/

-- 5.6 osp_Collapse_Rating: Admin collapse malicious ratings
CREATE OR REPLACE PROCEDURE osp_Collapse_Rating (
    p_Record_ID        IN  NUMBER,
    p_Action_User_ID   IN  NUMBER,
    p_Result           OUT VARCHAR2
) AS
    v_User_Role     VARCHAR2(20);
BEGIN
    SELECT ROLE INTO v_User_Role FROM SYS_USER WHERE USER_ID = p_Action_User_ID;

    IF v_User_Role NOT IN ('CLUB_ADMIN', 'SUPER_ADMIN') THEN
        p_Result := 'ERROR: 只有管理员才能折叠评分。';
        RETURN;
    END IF;

    UPDATE RATING_RECORD
    SET IS_COLLAPSED = 1
    WHERE RECORD_ID = p_Record_ID;

    INSERT INTO AUDIT_LOG (USER_ID, ACTION_MODULE, ACTION_TYPE, TARGET_TYPE, TARGET_ID)
    VALUES (p_Action_User_ID, 'RATING', 'COLLAPSE', 'RATING_RECORD', p_Record_ID);

    COMMIT;
    p_Result := 'SUCCESS';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_Result := 'FATAL ERROR: ' || SQLERRM;
END osp_Collapse_Rating;
/

-- ============================================================================
-- SECTION 6: TRIGGERS
-- ============================================================================

-- 6.1 tr_Calculate_Average_Score: Auto-calculate player/coach average scores
CREATE OR REPLACE TRIGGER tr_Calculate_Average_Score
AFTER INSERT OR UPDATE OR DELETE ON RATING_RECORD
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_New_Avg     NUMBER(4,2);
    v_Total_Count NUMBER;
BEGIN
    IF DELETING THEN
        -- Calculate after deletion
        SELECT NVL(AVG(Score), 0), COUNT(1) INTO v_New_Avg, v_Total_Count
        FROM RATING_RECORD
        WHERE Target_ID = :OLD.Target_ID
          AND Target_Type = :OLD.Target_Type
          AND IS_COLLAPSED = 0;

        IF :OLD.Target_Type = 'PLAYER' THEN
            UPDATE PLAYER
            SET AVG_SCORE = v_New_Avg, TOTAL_RATINGS = v_Total_Count
            WHERE PLAYER_ID = :OLD.Target_ID;
        ELSIF :OLD.Target_Type = 'COACH' THEN
            UPDATE COACH
            SET AVG_SCORE = v_New_Avg, TOTAL_RATINGS = v_Total_Count
            WHERE COACH_ID = :OLD.Target_ID;
        END IF;
    ELSE
        -- Calculate after insert/update
        IF :NEW.IS_COLLAPSED = 0 THEN
            SELECT NVL(AVG(Score), 0), COUNT(1) INTO v_New_Avg, v_Total_Count
            FROM RATING_RECORD
            WHERE Target_ID = :NEW.Target_ID
              AND Target_Type = :NEW.Target_TYPE
              AND IS_COLLAPSED = 0;

            IF :NEW.Target_Type = 'PLAYER' THEN
                UPDATE PLAYER
                SET AVG_SCORE = v_New_Avg, TOTAL_RATINGS = v_Total_Count
                WHERE PLAYER_ID = :NEW.Target_ID;
            ELSIF :NEW.Target_Type = 'COACH' THEN
                UPDATE COACH
                SET AVG_SCORE = v_New_Avg, TOTAL_RATINGS = v_Total_Count
                WHERE COACH_ID = :NEW.Target_ID;
            END IF;
        END IF;
    END IF;

    COMMIT;
END tr_Calculate_Average_Score;
/

-- 6.2 tr_Transfer_History_On_Player_Update: Log club changes automatically
CREATE OR REPLACE TRIGGER tr_Transfer_History_On_Player_Update
AFTER UPDATE OF CLUB_ID ON PLAYER
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_Season VARCHAR2(20);
BEGIN
    v_Season := TO_CHAR(SYSDATE, 'YYYY');
    IF :OLD.CLUB_ID != :NEW.CLUB_ID OR (:OLD.STATUS != :NEW.STATUS AND :NEW.STATUS = 'FREE') THEN
        INSERT INTO TRANSFER_HISTORY_LOG
            (PLAYER_ID, OLD_CLUB_ID, NEW_CLUB_ID, TRANSFER_TYPE, SEASON)
        VALUES
            (:NEW.PLAYER_ID, :OLD.CLUB_ID, :NEW.CLUB_ID,
             CASE WHEN :NEW.STATUS = 'FREE' THEN 'FREE' ELSE 'TRANSFER' END,
             v_Season);
    END IF;
    COMMIT;
END tr_Transfer_History_On_Player_Update;
/

-- 6.3 tr_Audit_User_Rating: Log all rating changes to audit table
CREATE OR REPLACE TRIGGER tr_Audit_User_Rating
AFTER INSERT OR UPDATE OR DELETE ON RATING_RECORD
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF DELETING THEN
        INSERT INTO AUDIT_LOG (USER_ID, ACTION_MODULE, ACTION_TYPE, TARGET_TYPE, TARGET_ID, OLD_VALUE)
        VALUES (:OLD.USER_ID, 'RATING', 'DELETE', :OLD.TARGET_TYPE, :OLD.RECORD_ID,
                '{"score": ' || :OLD.SCORE || ', "comment": "' || NVL(:OLD.COMMENT_TEXT, '') || '"}');
    ELSIF UPDATING THEN
        INSERT INTO AUDIT_LOG (USER_ID, ACTION_MODULE, ACTION_TYPE, TARGET_TYPE, TARGET_ID, OLD_VALUE, NEW_VALUE)
        VALUES (:NEW.USER_ID, 'RATING', 'UPDATE', :NEW.TARGET_TYPE, :NEW.RECORD_ID,
                '{"score": ' || :OLD.SCORE || '}', '{"score": ' || :NEW.SCORE || '}');
    ELSE
        INSERT INTO AUDIT_LOG (USER_ID, ACTION_MODULE, ACTION_TYPE, TARGET_TYPE, TARGET_ID, NEW_VALUE)
        VALUES (:NEW.USER_ID, 'RATING', 'INSERT', :NEW.TARGET_TYPE, :NEW.RECORD_ID,
                '{"score": ' || :NEW.SCORE || ', "comment": "' || NVL(:NEW.COMMENT_TEXT, '') || '"}');
    END IF;
    COMMIT;
END tr_Audit_User_Rating;
/

-- 6.4 tr_Maintain_Club_Total_Score: Maintain club total score from player/coach averages
CREATE OR REPLACE TRIGGER tr_Maintain_Club_Total_Score
AFTER INSERT OR UPDATE OR DELETE ON PLAYER
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_Club_ID  NUMBER;
    v_New_Total NUMBER;
BEGIN
    IF DELETING THEN
        v_Club_ID := :OLD.CLUB_ID;
    ELSIF INSERTING THEN
        v_Club_ID := :NEW.CLUB_ID;
    ELSE
        v_Club_ID := :NEW.CLUB_ID;
    END IF;

    IF v_Club_ID IS NOT NULL THEN
        SELECT NVL(SUM(AVG_SCORE), 0) INTO v_New_Total
        FROM PLAYER
        WHERE CLUB_ID = v_Club_ID AND STATUS = 'ACTIVE';

        UPDATE CLUB SET TOTAL_SCORE = v_New_Total WHERE CLUB_ID = v_Club_ID;
        COMMIT;
    END IF;
END tr_Maintain_Club_Total_Score;
/

-- ============================================================================
-- SECTION 7: VIEWS
-- ============================================================================

-- 7.1 v_Club_Overview: Club dashboard with player count, avg score, top player, head coach
CREATE OR REPLACE VIEW v_Club_Overview AS
SELECT
    c.CLUB_ID,
    c.NAME AS CLUB_NAME,
    c.SHORT_NAME,
    c.LEAGUE,
    c.CITY,
    c.STADIUM,
    c.STADIUM_CAPACITY,
    c.LOGO_URL,
    c.TOTAL_SCORE,
    COUNT(p.PLAYER_ID) AS TOTAL_PLAYERS,
    ROUND(AVG(p.AVG_SCORE), 2) AS TEAM_AVERAGE_SCORE,
    MAX(p.NAME) KEEP (DENSE_RANK FIRST ORDER BY p.AVG_SCORE DESC NULLS LAST) AS TOP_PLAYER_NAME,
    MAX(p.AVG_SCORE) KEEP (DENSE_RANK FIRST ORDER BY p.AVG_SCORE DESC NULLS LAST) AS TOP_PLAYER_SCORE,
    (SELECT ch.NAME FROM COACH ch WHERE ch.CLUB_ID = c.CLUB_ID AND ch.IS_HEAD_COACH = 1 AND ROWNUM = 1) AS HEAD_COACH_NAME,
    (SELECT COUNT(1) FROM USER_CLUB_FOLLOW f WHERE f.CLUB_ID = c.CLUB_ID) AS FOLLOWER_COUNT,
    (SELECT COUNT(1) FROM PLAYER p2 WHERE p2.CLUB_ID = c.CLUB_ID AND p2.POSITION = 'FW' AND p2.STATUS = 'ACTIVE') AS FW_COUNT,
    (SELECT COUNT(1) FROM PLAYER p2 WHERE p2.CLUB_ID = c.CLUB_ID AND p2.POSITION = 'MF' AND p2.STATUS = 'ACTIVE') AS MF_COUNT,
    (SELECT COUNT(1) FROM PLAYER p2 WHERE p2.CLUB_ID = c.CLUB_ID AND p2.POSITION = 'DF' AND p2.STATUS = 'ACTIVE') AS DF_COUNT,
    (SELECT COUNT(1) FROM PLAYER p2 WHERE p2.CLUB_ID = c.CLUB_ID AND p2.POSITION = 'GK' AND p2.STATUS = 'ACTIVE') AS GK_COUNT
FROM CLUB c
LEFT JOIN PLAYER p ON c.CLUB_ID = p.CLUB_ID AND p.STATUS = 'ACTIVE'
GROUP BY c.CLUB_ID, c.NAME, c.SHORT_NAME, c.LEAGUE, c.CITY, c.STADIUM,
         c.STADIUM_CAPACITY, c.LOGO_URL, c.TOTAL_SCORE;

-- 7.2 v_Match_Live_Score: Live match scores for real-time display
CREATE OR REPLACE VIEW v_Match_Live_Score AS
SELECT
    m.MATCH_ID,
    m.MATCH_TIME,
    m.STATUS,
    m.HOME_SCORE,
    m.AWAY_SCORE,
    m.ROUND,
    m.VENUE,
    m.LEAGUE,
    m.SEASON,
    hc.NAME AS HOME_TEAM_NAME,
    hc.SHORT_NAME AS HOME_TEAM_SHORT,
    hc.LOGO_URL AS HOME_TEAM_LOGO,
    ac.NAME AS AWAY_TEAM_NAME,
    ac.SHORT_NAME AS AWAY_TEAM_SHORT,
    ac.LOGO_URL AS AWAY_TEAM_LOGO,
    CASE WHEN m.STATUS = 'IN_PROGRESS' THEN
        TRUNC(EXTRACT(DAY FROM (SYSTIMESTAMP - m.MATCH_TIME)) * 1440 +
              EXTRACT(HOUR FROM (SYSTIMESTAMP - m.MATCH_TIME)) * 60 +
              EXTRACT(MINUTE FROM (SYSTIMESTAMP - m.MATCH_TIME))) || ' min'
    ELSE NULL END AS LIVE_MINUTE,
    CASE WHEN m.STATUS = 'FINISHED' THEN
        (m.MATCH_TIME + NUMTODSINTERVAL(90, 'MINUTE'))
    ELSE NULL END AS FULL_TIME_MARKER
FROM MATCH_SCHEDULE m
JOIN CLUB hc ON m.HOME_CLUB_ID = hc.CLUB_ID
JOIN CLUB ac ON m.AWAY_CLUB_ID = ac.CLUB_ID;

-- 7.3 v_Player_Rankings: Global player rankings by avg score
CREATE OR REPLACE VIEW v_Player_Rankings AS
SELECT
    p.PLAYER_ID,
    p.NAME,
    p.NAME_CN,
    p.POSITION,
    p.CLUB_ID,
    p.JERSEY_NUMBER,
    p.NATIONALITY,
    p.STATUS,
    p.AVG_SCORE,
    p.TOTAL_RATINGS,
    p.AVATAR_URL,
    c.NAME AS CLUB_NAME,
    c.LEAGUE,
    c.SHORT_NAME AS CLUB_SHORT,
    c.LOGO_URL AS CLUB_LOGO,
    ROW_NUMBER() OVER (ORDER BY p.AVG_SCORE DESC NULLS LAST) AS GLOBAL_RANK,
    ROW_NUMBER() OVER (PARTITION BY c.LEAGUE ORDER BY p.AVG_SCORE DESC NULLS LAST) AS LEAGUE_RANK,
    ROW_NUMBER() OVER (PARTITION BY p.POSITION ORDER BY p.AVG_SCORE DESC NULLS LAST) AS POSITION_RANK
FROM PLAYER p
JOIN CLUB c ON p.CLUB_ID = c.CLUB_ID
WHERE p.STATUS = 'ACTIVE' AND p.AVG_SCORE > 0;

-- 7.4 v_League_Standings_View: Full league standings with club logos
CREATE OR REPLACE VIEW v_League_Standings_View AS
SELECT
    ls.STANDING_ID,
    ls.LEAGUE,
    ls.SEASON,
    ls.CLUB_ID,
    c.NAME AS CLUB_NAME,
    c.SHORT_NAME,
    c.LOGO_URL,
    ROW_NUMBER() OVER (PARTITION BY ls.LEAGUE, ls.SEASON ORDER BY ls.POINTS DESC, ls.GOAL_DIFF DESC, ls.GOALS_FOR DESC) AS POSITION,
    ls.PLAYED,
    ls.WON,
    ls.DRAWN,
    ls.LOST,
    ls.GOALS_FOR,
    ls.GOALS_AGAINST,
    ls.GOAL_DIFF,
    ls.POINTS,
    ls.UPDATED_AT
FROM LEAGUE_STANDINGS ls
JOIN CLUB c ON ls.CLUB_ID = c.CLUB_ID;

-- 7.5 v_Chat_Message_History: Chat history with user info (non-deleted)
CREATE OR REPLACE VIEW v_Chat_Message_History AS
SELECT
    m.MESSAGE_ID,
    m.CLUB_ID,
    m.USER_ID,
    u.NICKNAME AS USER_NICKNAME,
    u.AVATAR_URL AS USER_AVATAR,
    u.ROLE AS USER_ROLE,
    m.CONTENT,
    m.MESSAGE_TYPE,
    m.IS_DELETED,
    m.IS_COLLAPSED,
    m.CREATED_AT,
    CASE WHEN m.CREATED_AT > SYSTIMESTAMP - INTERVAL '5' MINUTE THEN 1 ELSE 0 END AS IS_RECENT
FROM CLUB_CHAT_MESSAGE m
JOIN SYS_USER u ON m.USER_ID = u.USER_ID
WHERE m.IS_DELETED = 0;

-- 7.6 v_Coach_Rankings: Coach rankings by average score
CREATE OR REPLACE VIEW v_Coach_Rankings AS
SELECT
    co.COACH_ID,
    co.NAME,
    co.NAME_CN,
    co.CLUB_ID,
    co.IS_HEAD_COACH,
    co.NATIONALITY,
    co.AVG_SCORE,
    co.TOTAL_RATINGS,
    co.AVATAR_URL,
    c.NAME AS CLUB_NAME,
    c.LEAGUE,
    ROW_NUMBER() OVER (ORDER BY co.AVG_SCORE DESC NULLS LAST) AS GLOBAL_RANK
FROM COACH co
JOIN CLUB c ON co.CLUB_ID = c.CLUB_ID
WHERE co.IS_HEAD_COACH = 1 AND co.AVG_SCORE > 0;

-- 7.7 v_User_Dashboard: User dashboard with follow stats
CREATE OR REPLACE VIEW v_User_Dashboard AS
SELECT
    u.USER_ID,
    u.USERNAME,
    u.NICKNAME,
    u.ROLE,
    u.MANAGED_CLUB_ID,
    u.STATUS,
    u.LAST_LOGIN_AT,
    (SELECT COUNT(1) FROM USER_CLUB_FOLLOW f WHERE f.USER_ID = u.USER_ID) AS FOLLOWED_CLUBS,
    (SELECT COUNT(1) FROM RATING_RECORD r WHERE r.USER_ID = u.USER_ID) AS TOTAL_RATINGS,
    (SELECT COUNT(1) FROM CLUB_CHAT_MESSAGE m WHERE m.USER_ID = u.USER_ID) AS TOTAL_MESSAGES,
    c.NAME AS MANAGED_CLUB_NAME
FROM SYS_USER u
LEFT JOIN CLUB c ON u.MANAGED_CLUB_ID = c.CLUB_ID;

-- ============================================================================
-- SECTION 8: SEED DATA - DEMO USERS
-- ============================================================================

-- Bcrypt hash for "password123" - 12 rounds (strength 12, generated by Spring BCrypt)
-- Hash: $2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2
INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS)
VALUES (SEQ_SYS_USER.NEXTVAL, 'admin', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '超级管理员', 'admin@soccerhub.com', 'SUPER_ADMIN', 'ACTIVE');

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS, MANAGED_CLUB_ID)
VALUES (SEQ_SYS_USER.NEXTVAL, 'realmadrid_admin', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '皇马管理员', 'admin@realmadrid.com', 'CLUB_ADMIN', 'ACTIVE', 101);

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS, MANAGED_CLUB_ID)
VALUES (SEQ_SYS_USER.NEXTVAL, 'mancity_admin', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '曼城管理员', 'admin@mancity.com', 'CLUB_ADMIN', 'ACTIVE', 103);

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS)
VALUES (SEQ_SYS_USER.NEXTVAL, 'fan_lionel', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '足球迷_lionel', 'lionel@fan.com', 'FAN', 'ACTIVE');

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS)
VALUES (SEQ_SYS_USER.NEXTVAL, 'fan_messi_jr', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '诺坎普之王', 'messi@fan.com', 'FAN', 'ACTIVE');

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS)
VALUES (SEQ_SYS_USER.NEXTVAL, 'fan_kloop', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        'kop死忠', 'kloop@fan.com', 'FAN', 'ACTIVE');

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS)
VALUES (SEQ_SYS_USER.NEXTVAL, 'fan_bayern_fan', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '南大王铁粉', 'bayern@fan.com', 'FAN', 'ACTIVE');

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS)
VALUES (SEQ_SYS_USER.NEXTVAL, 'fan_interista', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '内拉祖里', 'inter@fan.com', 'FAN', 'ACTIVE');

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS)
VALUES (SEQ_SYS_USER.NEXTVAL, 'fan_om', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '马赛铁血球迷', 'om@fan.com', 'FAN', 'ACTIVE');

INSERT INTO SYS_USER (USER_ID, USERNAME, PASSWORD_HASH, NICKNAME, EMAIL, ROLE, STATUS)
VALUES (SEQ_SYS_USER.NEXTVAL, 'fan_galaxy', '$2b$12$Fwhfsj1ne3VD.x6l/Bz88OgAdyeiQbzo.wwS/5T3ziwp.4Eu0Shd2',
        '银河战舰粉', 'psg@fan.com', 'FAN', 'ACTIVE');

-- ============================================================================
-- SECTION 9: SEED DATA - CLUBS (10 Clubs from Five Major Leagues)
-- ============================================================================

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (101, 'Real Madrid', 'RMA', 'La Liga', 'Madrid', 'Spain', 'Santiago Bernabeu', TO_DATE('1902-03-06', 'YYYY-MM-DD'), 81044,
        '皇家马德里足球俱乐部是一家位于西班牙首都马德里的足球俱乐部，成立于1902年3月6日，是世界足坛最成功的俱乐部之一，累计夺得15次欧冠冠军，35次西甲冠军。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (102, 'FC Barcelona', 'BAR', 'La Liga', 'Barcelona', 'Spain', 'Camp Nou', TO_DATE('1899-11-29', 'YYYY-MM-DD'), 99354,
        '巴塞罗那足球俱乐部是一家位于西班牙加泰罗尼亚地区的豪门俱乐部，以传控打法闻名，队史夺得27次西甲冠军和5次欧冠冠军。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (103, 'Manchester City', 'MCI', 'Premier League', 'Manchester', 'England', 'Etihad Stadium', TO_DATE('1880-11-28', 'YYYY-MM-DD'), 53400,
        '曼彻斯特城足球俱乐部是英格兰超级联赛豪门，在阿联酋财团入主后成为欧洲足坛劲旅，近年连续夺得英超冠军。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (104, 'Arsenal', 'ARS', 'Premier League', 'London', 'England', 'Emirates Stadium', TO_DATE('1886-10-01', 'YYYY-MM-DD'), 60704,
        '阿森纳足球俱乐部是英格兰足坛传统豪门，以华丽的进攻风格和青训传统著称。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (105, 'Bayern Munich', 'BAY', 'Bundesliga', 'Munich', 'Germany', 'Allianz Arena', TO_DATE('1900-02-27', 'YYYY-MM-DD'), 75024,
        '拜仁慕尼黑足球俱乐部是德国足坛霸主，队史赢得33次德甲冠军和6次欧冠冠军。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (106, 'Borussia Dortmund', 'BVB', 'Bundesliga', 'Dortmund', 'Germany', 'Signal Iduna Park', TO_DATE('1909-12-19', 'YYYY-MM-DD'), 81212,
        '多特蒙德足球俱乐部以激情四射的主场氛围和顶级青训闻名，培养出众多世界级球星。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (107, 'Inter Milan', 'INT', 'Serie A', 'Milan', 'Italy', 'Stadio Giuseppe Meazza', TO_DATE('1908-03-09', 'YYYY-MM-DD'), 75923,
        '国际米兰足球俱乐部是意大利足坛传统豪门，2023-24赛季夺得意甲冠军。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (108, 'AC Milan', 'ACM', 'Serie A', 'Milan', 'Italy', 'Stadio Giuseppe Meazza', TO_DATE('1899-12-16', 'YYYY-MM-DD'), 75923,
        'AC米兰足球俱乐部是意大利足坛历史最成功的俱乐部之一，累计夺得7次欧冠冠军和19次意甲冠军。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (109, 'Paris Saint-Germain', 'PSG', 'Ligue 1', 'Paris', 'France', 'Parc des Princes', TO_DATE('1970-08-03', 'YYYY-MM-DD'), 47929,
        '巴黎圣日耳曼是法甲豪门，在卡塔尔财团入主后成为欧洲足坛新贵。');

INSERT INTO CLUB (CLUB_ID, NAME, SHORT_NAME, LEAGUE, CITY, COUNTRY, STADIUM, ESTABLISH_DATE, STADIUM_CAPACITY, DESCRIPTION)
VALUES (110, 'Olympique Marseille', 'OM', 'Ligue 1', 'Marseille', 'France', 'Stade Velodrome', TO_DATE('1899-09-01', 'YYYY-MM-DD'), 67381,
        '马赛奥林匹克俱乐部是法国足坛历史最悠久的俱乐部之一，也是唯一赢得过欧冠冠军的法国球队。');

-- ============================================================================
-- SECTION 10: SEED DATA - PLAYERS (8 players per club = 80 total)
-- ============================================================================

-- Real Madrid Players (Club 101)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Vinicius Jr', '维尼修斯', 'FW', 101, 7, 'Brazil', TO_DATE('2000-01-22', 'YYYY-MM-DD'), 176, 73, 'ACTIVE', 150000000, 8.72);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Jude Bellingham', '贝林厄姆', 'MF', 101, 5, 'England', TO_DATE('2003-06-29', 'YYYY-MM-DD'), 186, 75, 'ACTIVE', 180000000, 8.85);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Kylian Mbappe', '姆巴佩', 'FW', 101, 9, 'France', TO_DATE('1998-12-20', 'YYYY-MM-DD'), 178, 78, 'ACTIVE', 180000000, 9.10);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Rodrygo', '罗德里戈', 'FW', 101, 11, 'Brazil', TO_DATE('2001-09-05', 'YYYY-MM-DD'), 174, 64, 'ACTIVE', 110000000, 8.15);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Eduardo Camavinga', '卡马文加', 'MF', 101, 6, 'France', TO_DATE('2002-11-10', 'YYYY-MM-DD'), 182, 68, 'ACTIVE', 100000000, 8.05);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Toni Kroos', '克罗斯', 'MF', 101, 8, 'Germany', TO_DATE('1990-01-04', 'YYYY-MM-DD'), 183, 78, 'ACTIVE', 35000000, 8.45);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Thibaut Courtois', '库尔图瓦', 'GK', 101, 1, 'Belgium', TO_DATE('1992-05-11', 'YYYY-MM-DD'), 199, 96, 'ACTIVE', 30000000, 8.62);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Antonio Rudiger', '吕迪格', 'DF', 101, 22, 'Germany', TO_DATE('1993-01-03', 'YYYY-MM-DD'), 190, 85, 'ACTIVE', 40000000, 8.28);

-- Barcelona Players (Club 102)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Pedri', '佩德里', 'MF', 102, 8, 'Spain', TO_DATE('2002-11-25', 'YYYY-MM-DD'), 174, 68, 'ACTIVE', 100000000, 8.55);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Lamine Yamal', '拉明·亚马尔', 'FW', 102, 19, 'Spain', TO_DATE('2007-07-13', 'YYYY-MM-DD'), 180, 67, 'ACTIVE', 150000000, 8.68);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Robert Lewandowski', '莱万多夫斯基', 'FW', 102, 9, 'Poland', TO_DATE('1988-08-21', 'YYYY-MM-DD'), 185, 81, 'ACTIVE', 25000000, 8.12);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Frenkie de Jong', '德容', 'MF', 102, 6, 'Netherlands', TO_DATE('1997-05-12', 'YYYY-MM-DD'), 180, 74, 'ACTIVE', 60000000, 8.22);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Raphinha', '拉菲尼亚', 'FW', 102, 11, 'Brazil', TO_DATE('1996-12-14', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 55000000, 8.08);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Gavi', '加维', 'MF', 102, 18, 'Spain', TO_DATE('2004-08-05', 'YYYY-MM-DD'), 173, 66, 'ACTIVE', 90000000, 8.35);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Marc-Andre ter Stegen', '特尔施特根', 'GK', 102, 1, 'Germany', TO_DATE('1992-04-30', 'YYYY-MM-DD'), 187, 85, 'ACTIVE', 45000000, 8.58);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Ronald Araujo', '阿劳霍', 'DF', 102, 4, 'Uruguay', TO_DATE('1999-03-08', 'YYYY-MM-DD'), 191, 89, 'ACTIVE', 70000000, 8.42);

-- Manchester City Players (Club 103)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Erling Haaland', '哈兰德', 'FW', 103, 9, 'Norway', TO_DATE('2000-07-21', 'YYYY-MM-DD'), 194, 94, 'ACTIVE', 210000000, 9.25);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Kevin De Bruyne', '德布劳内', 'MF', 103, 17, 'Belgium', TO_DATE('1991-06-28', 'YYYY-MM-DD'), 181, 70, 'ACTIVE', 55000000, 9.08);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Phil Foden', '福登', 'MF', 103, 47, 'England', TO_DATE('2000-05-28', 'YYYY-MM-DD'), 178, 68, 'ACTIVE', 150000000, 8.82);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Rodri', '罗德里', 'MF', 103, 16, 'Spain', TO_DATE('1996-06-22', 'YYYY-MM-DD'), 190, 82, 'ACTIVE', 110000000, 8.95);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Jack Grealish', '格拉利什', 'MF', 103, 10, 'England', TO_DATE('1995-09-10', 'YYYY-MM-DD'), 180, 76, 'ACTIVE', 70000000, 7.95);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Bernardo Silva', '贝尔纳多·席尔瓦', 'MF', 103, 20, 'Portugal', TO_DATE('1994-08-10', 'YYYY-MM-DD'), 173, 64, 'ACTIVE', 80000000, 8.65);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Ederson', '埃德森', 'GK', 103, 31, 'Brazil', TO_DATE('1993-08-17', 'YYYY-MM-DD'), 188, 86, 'ACTIVE', 45000000, 8.48);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Kyle Walker', '凯尔·沃克', 'DF', 103, 2, 'England', TO_DATE('1990-05-28', 'YYYY-MM-DD'), 178, 83, 'ACTIVE', 15000000, 8.02);

-- Arsenal Players (Club 104)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Bukayo Saka', '萨卡', 'FW', 104, 7, 'England', TO_DATE('2001-09-05', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 140000000, 8.78);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Martin Odegaard', '厄德高', 'MF', 104, 8, 'Norway', TO_DATE('1998-12-17', 'YYYY-MM-DD'), 180, 68, 'ACTIVE', 115000000, 8.68);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Declan Rice', '赖斯', 'MF', 104, 41, 'England', TO_DATE('1999-01-14', 'YYYY-MM-DD'), 185, 80, 'ACTIVE', 120000000, 8.52);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'William Saliba', '萨利巴', 'DF', 104, 2, 'France', TO_DATE('2001-03-24', 'YYYY-MM-DD'), 192, 90, 'ACTIVE', 90000000, 8.62);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Gabriel Martinelli', '马丁内利', 'FW', 104, 11, 'Brazil', TO_DATE('2001-06-21', 'YYYY-MM-DD'), 178, 72, 'ACTIVE', 85000000, 8.35);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Kai Havertz', '哈弗茨', 'MF', 104, 29, 'Germany', TO_DATE('1999-06-11', 'YYYY-MM-DD'), 193, 82, 'ACTIVE', 65000000, 7.98);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'David Raya', '拉亚', 'GK', 104, 22, 'Spain', TO_DATE('1995-09-15', 'YYYY-MM-DD'), 185, 78, 'ACTIVE', 35000000, 8.15);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Ben White', '本·怀特', 'DF', 104, 4, 'England', TO_DATE('1997-10-08', 'YYYY-MM-DD'), 186, 77, 'ACTIVE', 55000000, 8.02);

-- Bayern Munich Players (Club 105)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Harry Kane', '凯恩', 'FW', 105, 9, 'England', TO_DATE('1993-07-28', 'YYYY-MM-DD'), 188, 86, 'ACTIVE', 120000000, 9.12);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Jamal Musiala', '穆西亚拉', 'MF', 105, 42, 'Germany', TO_DATE('2003-02-03', 'YYYY-MM-DD'), 176, 70, 'ACTIVE', 130000000, 8.78);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Leroy Sane', '萨内', 'FW', 105, 10, 'Germany', TO_DATE('1996-01-11', 'YYYY-MM-DD'), 183, 80, 'ACTIVE', 70000000, 8.28);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Joshua Kimmich', '基米希', 'MF', 105, 6, 'Germany', TO_DATE('1995-02-08', 'YYYY-MM-DD'), 176, 75, 'ACTIVE', 65000000, 8.55);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Leon Goretzka', '格雷茨卡', 'MF', 105, 8, 'Germany', TO_DATE('1995-02-06', 'YYYY-MM-DD'), 189, 82, 'ACTIVE', 45000000, 8.12);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Alphonso Davies', '阿方索·戴维斯', 'DF', 105, 19, 'Canada', TO_DATE('2000-06-02', 'YYYY-MM-DD'), 183, 75, 'ACTIVE', 70000000, 8.35);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Manuel Neuer', '诺伊尔', 'GK', 105, 1, 'Germany', TO_DATE('1986-03-27', 'YYYY-MM-DD'), 193, 92, 'ACTIVE', 12000000, 8.48);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Kim Min-jae', '金玟哉', 'DF', 105, 3, 'South Korea', TO_DATE('1996-11-15', 'YYYY-MM-DD'), 190, 88, 'ACTIVE', 65000000, 8.22);

-- Borussia Dortmund Players (Club 106)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Jadon Sancho', '桑乔', 'FW', 106, 10, 'England', TO_DATE('2000-03-25', 'YYYY-MM-DD'), 180, 74, 'ACTIVE', 55000000, 8.05);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Julian Brandt', '布兰特', 'MF', 106, 8, 'Germany', TO_DATE('1996-05-02', 'YYYY-MM-DD'), 185, 77, 'ACTIVE', 50000000, 8.15);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Niclas Fullkrug', '菲尔克鲁格', 'FW', 106, 9, 'Germany', TO_DATE('1993-02-09', 'YYYY-MM-DD'), 191, 87, 'ACTIVE', 35000000, 8.08);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Gregor Kobel', '科贝尔', 'GK', 106, 1, 'Switzerland', TO_DATE('1997-12-27', 'YYYY-MM-DD'), 192, 86, 'ACTIVE', 40000000, 8.18);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Mats Hummels', '胡梅尔斯', 'DF', 106, 15, 'Germany', TO_DATE('1988-12-16', 'YYYY-MM-DD'), 191, 92, 'ACTIVE', 15000000, 8.25);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Julian Ryomen', '朱利安·赖斯', 'MF', 106, 6, 'Japan', TO_DATE('1998-11-10', 'YYYY-MM-DD'), 178, 70, 'ACTIVE', 45000000, 8.02);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Karim Adeyemi', '阿德耶米', 'FW', 106, 11, 'Germany', TO_DATE('2002-01-18', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 50000000, 7.88);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Ian Maatsen', '马特森', 'DF', 106, 25, 'Netherlands', TO_DATE('2002-12-19', 'YYYY-MM-DD'), 176, 68, 'ACTIVE', 40000000, 7.92);

-- Inter Milan Players (Club 107)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Lautaro Martinez', '劳塔罗', 'FW', 107, 10, 'Argentina', TO_DATE('1997-08-10', 'YYYY-MM-DD'), 174, 72, 'ACTIVE', 115000000, 8.95);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Nicolo Barella', '巴雷拉', 'MF', 107, 23, 'Italy', TO_DATE('1997-02-07', 'YYYY-MM-DD'), 172, 69, 'ACTIVE', 85000000, 8.68);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Hakan Calhanoglu', '恰尔汗奥卢', 'MF', 107, 20, 'Turkey', TO_DATE('1994-02-08', 'YYYY-MM-DD'), 178, 78, 'ACTIVE', 55000000, 8.42);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Alessandro Bastoni', '巴斯托尼', 'DF', 107, 15, 'Italy', TO_DATE('1999-04-13', 'YYYY-MM-DD'), 190, 80, 'ACTIVE', 75000000, 8.58);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Marcelo Brozovic', '布罗佐维奇', 'MF', 107, 77, 'Croatia', TO_DATE('1992-11-16', 'YYYY-MM-DD'), 180, 78, 'ACTIVE', 50000000, 8.25);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Marcus Thuram', '图拉姆', 'FW', 107, 9, 'France', TO_DATE('1997-08-06', 'YYYY-MM-DD'), 192, 88, 'ACTIVE', 65000000, 8.15);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Yann Sommer', '索默', 'GK', 107, 1, 'Switzerland', TO_DATE('1988-12-17', 'YYYY-MM-DD'), 183, 80, 'ACTIVE', 18000000, 8.28);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Benjamin Pavard', '帕瓦尔', 'DF', 107, 2, 'France', TO_DATE('1996-01-28', 'YYYY-MM-DD'), 186, 75, 'ACTIVE', 40000000, 8.08);

-- AC Milan Players (Club 108)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Rafael Leao', '莱奥', 'FW', 108, 10, 'Portugal', TO_DATE('1999-06-10', 'YYYY-MM-DD'), 188, 82, 'ACTIVE', 95000000, 8.78);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Mike Maignan', '迈尼昂', 'GK', 108, 16, 'France', TO_DATE('1995-07-03', 'YYYY-MM-DD'), 191, 86, 'ACTIVE', 50000000, 8.55);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Theo Hernandez', '特奥·埃尔南德斯', 'DF', 108, 19, 'France', TO_DATE('1997-10-06', 'YYYY-MM-DD'), 184, 78, 'ACTIVE', 65000000, 8.65);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Christian Pulisic', '普利西奇', 'FW', 108, 11, 'USA', TO_DATE('1998-09-18', 'YYYY-MM-DD'), 178, 73, 'ACTIVE', 45000000, 7.98);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Tijjani Reijnders', '赖因德斯', 'MF', 108, 14, 'Netherlands', TO_DATE('1998-07-30', 'YYYY-MM-DD'), 182, 74, 'ACTIVE', 50000000, 8.08);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Yunus Musah', '穆萨', 'MF', 108, 80, 'USA', TO_DATE('2002-11-29', 'YYYY-MM-DD'), 185, 77, 'ACTIVE', 35000000, 7.85);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Alvaro Morata', '莫拉塔', 'FW', 108, 7, 'Spain', TO_DATE('1992-10-10', 'YYYY-MM-DD'), 196, 84, 'ACTIVE', 25000000, 7.92);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Fikayo Tomori', '托莫里', 'DF', 108, 23, 'England', TO_DATE('1997-12-19', 'YYYY-MM-DD'), 185, 85, 'ACTIVE', 40000000, 8.12);

-- PSG Players (Club 109)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Ousmane Dembele', '登贝莱', 'FW', 109, 10, 'France', TO_DATE('1997-05-15', 'YYYY-MM-DD'), 178, 67, 'ACTIVE', 90000000, 8.55);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Bradley Barcola', '巴尔科拉', 'FW', 109, 29, 'France', TO_DATE('2002-09-02', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 60000000, 8.22);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Vitinha', '维蒂尼亚', 'MF', 109, 17, 'Portugal', TO_DATE('2000-04-12', 'YYYY-MM-DD'), 174, 66, 'ACTIVE', 75000000, 8.42);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Warren Zaire-Emery', '扎伊尔-埃梅里', 'MF', 109, 33, 'France', TO_DATE('2006-03-08', 'YYYY-MM-DD'), 180, 75, 'ACTIVE', 55000000, 8.15);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Goncalo Ramos', '贡萨洛·拉莫斯', 'FW', 109, 9, 'Portugal', TO_DATE('2001-06-01', 'YYYY-MM-DD'), 185, 78, 'ACTIVE', 55000000, 8.05);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Marquinhos', '马尔基尼奥斯', 'DF', 109, 5, 'Brazil', TO_DATE('1994-04-14', 'YYYY-MM-DD'), 183, 75, 'ACTIVE', 55000000, 8.32);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Gianluigi Donnarumma', '多纳鲁马', 'GK', 109, 1, 'Italy', TO_DATE('1999-02-25', 'YYYY-MM-DD'), 196, 93, 'ACTIVE', 65000000, 8.58);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Achraf Hakimi', '阿什拉夫', 'DF', 109, 2, 'Morocco', TO_DATE('1998-11-04', 'YYYY-MM-DD'), 181, 73, 'ACTIVE', 60000000, 8.25);

-- Olympique Marseille Players (Club 110)
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Pierre-Emerick Aubameyang', '奥巴梅扬', 'FW', 110, 10, 'Gabon', TO_DATE('1989-06-18', 'YYYY-MM-DD'), 187, 80, 'ACTIVE', 12000000, 8.02);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Luis Henrique', '路易斯·恩里克', 'FW', 110, 11, 'Brazil', TO_DATE('2001-01-16', 'YYYY-MM-DD'), 180, 72, 'ACTIVE', 35000000, 7.85);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Geoffrey Kondogbia', '孔多比亚', 'MF', 110, 6, 'Central African Republic', TO_DATE('1993-02-15', 'YYYY-MM-DD'), 187, 87, 'ACTIVE', 25000000, 7.98);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Mason Greenwood', '格林伍德', 'FW', 110, 10, 'England', TO_DATE('2001-10-01', 'YYYY-MM-DD'), 181, 75, 'ACTIVE', 30000000, 8.12);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Pau Lopez', '保罗·洛佩斯', 'GK', 110, 16, 'Spain', TO_DATE('1994-12-13', 'YYYY-MM-DD'), 194, 86, 'ACTIVE', 18000000, 7.92);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Leonardo Balerdi', '巴莱尔迪', 'DF', 110, 5, 'Argentina', TO_DATE('1999-01-26', 'YYYY-MM-DD'), 187, 82, 'ACTIVE', 22000000, 7.88);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Jonathan Rowe', '乔纳森·罗', 'FW', 110, 9, 'England', TO_DATE('2003-03-15', 'YYYY-MM-DD'), 175, 68, 'ACTIVE', 40000000, 7.78);
INSERT INTO PLAYER (PLAYER_ID, NAME, NAME_CN, POSITION, CLUB_ID, JERSEY_NUMBER, NATIONALITY, BIRTH_DATE, HEIGHT_CM, WEIGHT_KG, STATUS, MARKET_VALUE, AVG_SCORE) VALUES
(SEQ_PLAYER.NEXTVAL, 'Amine Harit', '阿明·哈里特', 'MF', 110, 18, 'Morocco', TO_DATE('1997-06-25', 'YYYY-MM-DD'), 177, 68, 'ACTIVE', 20000000, 7.95);

-- ============================================================================
-- SECTION 11: SEED DATA - COACHES (3 coaches per club = 30 total)
-- ============================================================================

-- Real Madrid Coaches (101)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Carlo Ancelotti', '安切洛蒂', 101, 1, 'Italy', TO_DATE('1959-06-10', 'YYYY-MM-DD'), 9.05);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Hebe Sopacua', '索帕夸', 101, 0, 'Spain', TO_DATE('1985-03-15', 'YYYY-MM-DD'), 7.85);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Gianni Bagnoli', '巴尼奥利', 101, 0, 'Italy', TO_DATE('1980-07-22', 'YYYY-MM-DD'), 7.72);

-- Barcelona Coaches (102)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Hansi Flick', '弗里克', 102, 1, 'Germany', TO_DATE('1965-02-12', 'YYYY-MM-DD'), 8.78);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Irene Jimenez', '希门尼斯', 102, 0, 'Spain', TO_DATE('1983-09-05', 'YYYY-MM-DD'), 7.95);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Toni Clavero', '克拉维罗', 102, 0, 'Spain', TO_DATE('1981-04-18', 'YYYY-MM-DD'), 7.68);

-- Manchester City Coaches (103)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Pep Guardiola', '瓜迪奥拉', 103, 1, 'Spain', TO_DATE('1971-01-18', 'YYYY-MM-DD'), 9.42);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Carlos Corberan', '科贝兰', 103, 0, 'Spain', TO_DATE('1978-04-08', 'YYYY-MM-DD'), 8.12);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Rodolfo D''Onofrio', '多诺福里奥', 103, 0, 'Italy', TO_DATE('1979-11-30', 'YYYY-MM-DD'), 7.88);

-- Arsenal Coaches (104)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Mikel Arteta', '阿尔特塔', 104, 1, 'Spain', TO_DATE('1982-03-26', 'YYYY-MM-DD'), 8.68);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Nicolas Jover', '乔弗', 104, 0, 'France', TO_DATE('1987-04-29', 'YYYY-MM-DD'), 8.05);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Carlos Cagsig', '卡西格', 104, 0, 'Brazil', TO_DATE('1984-06-15', 'YYYY-MM-DD'), 7.75);

-- Bayern Munich Coaches (105)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Thomas Tuchel', '图赫尔', 105, 1, 'Germany', TO_DATE('1973-08-12', 'YYYY-MM-DD'), 8.82);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Luca Bucci', '布奇', 105, 0, 'Italy', TO_DATE('1980-02-28', 'YYYY-MM-DD'), 7.98);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Milan Gubic', '古比奇', 105, 0, 'Serbia', TO_DATE('1983-09-12', 'YYYY-MM-DD'), 7.82);

-- Borussia Dortmund Coaches (106)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Edin Terzic', '泰尔齐奇', 106, 1, 'Germany', TO_DATE('1982-10-30', 'YYYY-MM-DD'), 8.42);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Peter Krawietz', '克拉维茨', 106, 0, 'Germany', TO_DATE('1972-01-20', 'YYYY-MM-DD'), 7.88);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Sebastian Gassen', '加森', 106, 0, 'Germany', TO_DATE('1985-03-08', 'YYYY-MM-DD'), 7.65);

-- Inter Milan Coaches (107)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Simone Inzaghi', '小因扎吉', 107, 1, 'Italy', TO_DATE('1976-04-16', 'YYYY-MM-DD'), 8.75);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Massimo Madonna', '马东娜', 107, 0, 'Italy', TO_DATE('1978-08-22', 'YYYY-MM-DD'), 7.92);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Michele Funes', '富内斯', 107, 0, 'Italy', TO_DATE('1982-05-14', 'YYYY-MM-DD'), 7.78);

-- AC Milan Coaches (108)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Sergio Conceicao', '孔塞桑', 108, 1, 'Portugal', TO_DATE('1974-11-15', 'YYYY-MM-DD'), 8.35);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Michele Marcolini', '马科利尼', 108, 0, 'Italy', TO_DATE('1979-02-03', 'YYYY-MM-DD'), 7.85);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Roberto Gagliardini', '加利亚尔迪尼', 108, 0, 'Italy', TO_DATE('1985-11-19', 'YYYY-MM-DD'), 7.62);

-- PSG Coaches (109)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Luis Enrique', '路易斯·恩里克', 109, 1, 'Spain', TO_DATE('1970-05-08', 'YYYY-MM-DD'), 8.65);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Toni Clavero Garcia', '克拉维罗·加西亚', 109, 0, 'Spain', TO_DATE('1983-01-28', 'YYYY-MM-DD'), 7.95);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'David Pradas', '普拉达斯', 109, 0, 'Spain', TO_DATE('1986-09-15', 'YYYY-MM-DD'), 7.72);

-- Olympique Marseille Coaches (110)
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Jorge Sampaoli', '桑保利', 110, 1, 'Argentina', TO_DATE('1960-03-13', 'YYYY-MM-DD'), 8.28);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Fabian Bucci', '布奇', 110, 0, 'Argentina', TO_DATE('1982-07-19', 'YYYY-MM-DD'), 7.82);
INSERT INTO COACH (COACH_ID, NAME, NAME_CN, CLUB_ID, IS_HEAD_COACH, NATIONALITY, BIRTH_DATE, AVG_SCORE) VALUES
(SEQ_COACH.NEXTVAL, 'Pablo Fernandez', '费尔南德斯', 110, 0, 'Argentina', TO_DATE('1985-11-02', 'YYYY-MM-DD'), 7.68);

-- ============================================================================
-- SECTION 12: SEED DATA - MATCH SCHEDULES (20+ sample matches)
-- ============================================================================

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, HOME_SCORE, AWAY_SCORE, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_001', 101, 102, TO_TIMESTAMP('2026-04-20 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1, 'FINISHED', 'Round 30', 'Santiago Bernabeu', 'La Liga', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, HOME_SCORE, AWAY_SCORE, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_002', 103, 104, TO_TIMESTAMP('2026-04-20 18:30:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 2, 'FINISHED', 'Round 30', 'Etihad Stadium', 'Premier League', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, HOME_SCORE, AWAY_SCORE, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_003', 105, 106, TO_TIMESTAMP('2026-04-19 17:30:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 1, 'FINISHED', 'Round 29', 'Allianz Arena', 'Bundesliga', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, HOME_SCORE, AWAY_SCORE, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_004', 107, 108, TO_TIMESTAMP('2026-04-19 20:45:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1, 'FINISHED', 'Round 32', 'Stadio Giuseppe Meazza', 'Serie A', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, HOME_SCORE, AWAY_SCORE, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_005', 109, 110, TO_TIMESTAMP('2026-04-19 21:00:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 0, 'FINISHED', 'Round 29', 'Parc des Princes', 'Ligue 1', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_006', 101, 105, TO_TIMESTAMP('2026-04-25 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PENDING', 'Round 31', 'Santiago Bernabeu', 'La Liga', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_007', 103, 102, TO_TIMESTAMP('2026-04-26 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PENDING', 'Round 31', 'Etihad Stadium', 'Premier League', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_008', 104, 107, TO_TIMESTAMP('2026-04-27 18:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PENDING', 'Round 31', 'Emirates Stadium', 'Premier League', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_009', 106, 101, TO_TIMESTAMP('2026-04-27 17:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'PENDING', 'Round 30', 'Signal Iduna Park', 'Bundesliga', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_010', 108, 109, TO_TIMESTAMP('2026-04-26 20:45:00', 'YYYY-MM-DD HH24:MI:SS'), 'PENDING', 'Round 33', 'Stadio Giuseppe Meazza', 'Serie A', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, HOME_SCORE, AWAY_SCORE, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_011', 102, 104, TO_TIMESTAMP('2026-04-13 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 'FINISHED', 'Round 29', 'Camp Nou', 'La Liga', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, HOME_SCORE, AWAY_SCORE, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_012', 110, 103, TO_TIMESTAMP('2026-04-12 21:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 4, 'FINISHED', 'Round 28', 'Stade Velodrome', 'Ligue 1', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_013', 101, 103, TO_TIMESTAMP('2026-05-03 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PENDING', 'Round 32', 'Santiago Bernabeu', 'La Liga', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_014', 105, 107, TO_TIMESTAMP('2026-05-02 17:30:00', 'YYYY-MM-DD HH24:MI:SS'), 'PENDING', 'Round 30', 'Allianz Arena', 'Bundesliga', '2025-26');

INSERT INTO MATCH_SCHEDULE (MATCH_ID, HOME_CLUB_ID, AWAY_CLUB_ID, MATCH_TIME, STATUS, ROUND, VENUE, LEAGUE, SEASON)
VALUES ('MATCH_2026_015', 104, 101, TO_TIMESTAMP('2026-05-04 19:00:00', 'YYYY-MM-DD HH24:MI:SS'), 'PENDING', 'Round 33', 'Emirates Stadium', 'Premier League', '2025-26');

-- ============================================================================
-- SECTION 13: SEED DATA - LEAGUE STANDINGS
-- ============================================================================

-- La Liga Standings 2025-26
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('La Liga', '2025-26', 101, 1, 30, 22, 5, 3, 65, 22, 43, 71);
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('La Liga', '2025-26', 102, 2, 30, 20, 6, 4, 58, 28, 30, 66);
-- Premier League Standings 2025-26
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('Premier League', '2025-26', 103, 1, 30, 23, 4, 3, 78, 25, 53, 73);
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('Premier League', '2025-26', 104, 2, 30, 21, 6, 3, 68, 22, 46, 69);
-- Bundesliga Standings 2025-26
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('Bundesliga', '2025-26', 105, 1, 29, 22, 4, 3, 82, 28, 54, 70);
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('Bundesliga', '2025-26', 106, 2, 29, 18, 7, 4, 62, 35, 27, 61);
-- Serie A Standings 2025-26
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('Serie A', '2025-26', 107, 1, 32, 24, 5, 3, 72, 22, 50, 77);
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('Serie A', '2025-26', 108, 2, 32, 20, 7, 5, 58, 30, 28, 67);
-- Ligue 1 Standings 2025-26
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('Ligue 1', '2025-26', 109, 1, 29, 22, 5, 2, 68, 18, 50, 71);
INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
VALUES ('Ligue 1', '2025-26', 110, 2, 29, 16, 8, 5, 48, 28, 20, 56);

-- ============================================================================
-- SECTION 14: SEED DATA - USER FOLLOWS
-- ============================================================================

INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (4, 101, 1, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (4, 103, 0, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (5, 102, 1, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (5, 104, 0, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (6, 104, 1, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (7, 105, 1, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (7, 106, 0, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (8, 107, 1, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (9, 110, 1, SYSTIMESTAMP);
INSERT INTO USER_CLUB_FOLLOW (USER_ID, CLUB_ID, IS_PRIMARY, FOLLOW_TIME) VALUES (10, 109, 1, SYSTIMESTAMP);

-- ============================================================================
-- SECTION 15: SEED DATA - SAMPLE RATINGS
-- ============================================================================

INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, CREATED_AT)
VALUES (4, 1, 'PLAYER', 9, '维尼修斯本场表现无可挑剔！', 'MATCH', SYSTIMESTAMP - 1);
INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, CREATED_AT)
VALUES (4, 2, 'PLAYER', 9, '贝林厄姆中场指挥官！', 'MATCH', SYSTIMESTAMP - 1);
INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, CREATED_AT)
VALUES (5, 9, 'PLAYER', 9, '哈兰德禁区杀手！', 'MATCH', SYSTIMESTAMP - 2);
INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, CREATED_AT)
VALUES (5, 10, 'PLAYER', 10, '德布劳内传球如画！', 'MATCH', SYSTIMESTAMP - 2);
INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, CREATED_AT)
VALUES (7, 41, 'PLAYER', 10, '凯恩进球机器！', 'MATCH', SYSTIMESTAMP - 3);
INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, CREATED_AT)
VALUES (8, 57, 'PLAYER', 9, '劳塔罗门前把握能力超强！', 'MATCH', SYSTIMESTAMP - 4);
INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, CREATED_AT)
VALUES (3, 1, 'COACH', 9, '安切洛蒂战术大师！', 'GENERAL', SYSTIMESTAMP - 5);
INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, CREATED_AT)
VALUES (3, 13, 'COACH', 10, '瓜迪奥拉战术之神！', 'GENERAL', SYSTIMESTAMP - 5);

-- ============================================================================
-- SECTION 16: SEED DATA - SAMPLE CHAT MESSAGES
-- ============================================================================

INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (101, 4, 'Hala Madrid！今晚的比赛太精彩了！', 'TEXT', SYSTIMESTAMP - INTERVAL '30' MINUTE);
INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (101, 4, '维尼修斯这赛季的表现简直是现象级的', 'TEXT', SYSTIMESTAMP - INTERVAL '20' MINUTE);
INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (103, 4, '曼城这场比赛踢得太漂亮了！', 'TEXT', SYSTIMESTAMP - INTERVAL '2' HOUR);
INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (102, 5, 'Camp Nou永远是我们的主场！', 'TEXT', SYSTIMESTAMP - INTERVAL '3' HOUR);
INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (104, 6, 'COYG! Arsenal forever!', 'TEXT', SYSTIMESTAMP - INTERVAL '1' HOUR);
INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (105, 7, 'Mia San Mia! 拜仁最强！', 'TEXT', SYSTIMESTAMP - INTERVAL '4' HOUR);
INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (107, 8, 'Forza Inter! 内拉祖里永远支持你！', 'TEXT', SYSTIMESTAMP - INTERVAL '5' HOUR);
INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (110, 9, 'OM! 加油马赛！', 'TEXT', SYSTIMESTAMP - INTERVAL '6' HOUR);
INSERT INTO CLUB_CHAT_MESSAGE (CLUB_ID, USER_ID, CONTENT, MESSAGE_TYPE, CREATED_AT)
VALUES (109, 10, 'Paris Saint-Germain! 我们的骄傲！', 'TEXT', SYSTIMESTAMP - INTERVAL '7' HOUR);

-- ============================================================================
-- SECTION 17: SEED DATA - SYSTEM DICTIONARY
-- ============================================================================

INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('LEAGUE', 'La Liga', '西班牙足球甲级联赛', 1, '西班牙顶级联赛');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('LEAGUE', 'Premier League', '英格兰足球超级联赛', 2, '英格兰顶级联赛');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('LEAGUE', 'Bundesliga', '德国足球甲级联赛', 3, '德国顶级联赛');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('LEAGUE', 'Serie A', '意大利足球甲级联赛', 4, '意大利顶级联赛');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('LEAGUE', 'Ligue 1', '法国足球甲级联赛', 5, '法国顶级联赛');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('POSITION', 'GK', '门将', 1, '守门员');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('POSITION', 'DF', '后卫', 2, '后卫');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('POSITION', 'MF', '中场', 3, '中场');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('POSITION', 'FW', '前锋', 4, '前锋');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('PLAYER_STATUS', 'ACTIVE', '现役', 1, '现役球员');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('PLAYER_STATUS', 'INJURED', '伤病', 2, '伤病中');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('PLAYER_STATUS', 'RETIRED', '退役', 3, '已退役');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('PLAYER_STATUS', 'FREE', '自由身', 4, '自由球员');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('MATCH_STATUS', 'PENDING', '未开始', 1, '比赛未开始');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('MATCH_STATUS', 'IN_PROGRESS', '进行中', 2, '比赛进行中');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('MATCH_STATUS', 'FINISHED', '已结束', 3, '比赛已结束');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('MATCH_STATUS', 'CANCELLED', '已取消', 4, '比赛已取消');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('USER_ROLE', 'FAN', '普通球迷', 1, '普通用户');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('USER_ROLE', 'CLUB_ADMIN', '俱乐部管理员', 2, '俱乐部管理员');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('USER_ROLE', 'SUPER_ADMIN', '超级管理员', 3, '系统管理员');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('TRANSFER_TYPE', 'IN', '转入', 1, '转入');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('TRANSFER_TYPE', 'OUT', '转出', 2, '转出');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('TRANSFER_TYPE', 'LOAN', '租借', 3, '租借');
INSERT INTO SYSTEM_DICTIONARY (DICT_TYPE, DICT_KEY, DICT_VALUE, SORT_ORDER, DESCRIPTION) VALUES ('TRANSFER_TYPE', 'FREE', '自由转会', 4, '自由转会');

-- ============================================================================
-- SECTION 18: SEED DATA - SAMPLE NEWS ARTICLES
-- ============================================================================

INSERT INTO NEWS_ARTICLE (TITLE, SUMMARY, CONTENT, AUTHOR_ID, CLUB_ID, TAGS, COVER_IMAGE_URL, IS_PUBLISHED, PUBLISHED_AT)
VALUES ('皇马4-1大胜巴萨，国家德比主场告捷',
        '北京时间4月20日，西甲第30轮迎来国家德比，皇马主场4-1大胜巴萨',
        '皇家马德里主场迎战巴塞罗那，最终以4-1的比分大胜对手。本场比赛维尼修斯表现出色...',
        2, 101, '国家德比,皇马,巴萨,西甲', 'https://example.com/realmadrid_barca.jpg', 1, SYSTIMESTAMP - 1);

INSERT INTO NEWS_ARTICLE (TITLE, SUMMARY, CONTENT, AUTHOR_ID, CLUB_ID, TAGS, COVER_IMAGE_URL, IS_PUBLISHED, PUBLISHED_AT)
VALUES ('哈兰德帽子戏法！曼城3-2逆转阿森纳',
        '英超第30轮焦点战，曼城在主场完成惊天逆转',
        '曼城主场迎战阿森纳，哈兰德上演帽子戏法，帮助球队3-2逆转取胜...',
        3, 103, '曼城,阿森纳,英超,哈兰德', 'https://example.com/mancity_arsenal.jpg', 1, SYSTIMESTAMP - 2);

INSERT INTO NEWS_ARTICLE (TITLE, SUMMARY, CONTENT, AUTHOR_ID, CLUB_ID, TAGS, COVER_IMAGE_URL, IS_PUBLISHED, PUBLISHED_AT)
VALUES ('凯恩4球！拜仁4-1大胜多特蒙德',
        '德甲国家德比，凯恩独中四元助拜仁大胜',
        '德甲联赛第29轮迎来国家德比，拜仁慕尼黑主场4-1大胜多特蒙德...',
        2, 105, '拜仁,多特,德甲,凯恩', 'https://example.com/bayern_dortmund.jpg', 1, SYSTIMESTAMP - 3);

-- ============================================================================
-- SECTION 19: FINAL COMMIT
-- ============================================================================
COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- SELECT 'Tables Created: ' || COUNT(*) FROM USER_TABLES;
-- SELECT 'Sequences Created: ' || COUNT(*) FROM USER_SEQUENCES;
-- SELECT 'Views Created: ' || COUNT(*) FROM USER_VIEWS;
-- SELECT 'Procedures Created: ' || COUNT(*) FROM USER_PROCEDURES WHERE OBJECT_TYPE = 'PROCEDURE';
-- SELECT 'Triggers Created: ' || COUNT(*) FROM USER_TRIGGERS;
-- SELECT 'Clubs Loaded: ' || COUNT(*) FROM CLUB;
-- SELECT 'Players Loaded: ' || COUNT(*) FROM PLAYER;
-- SELECT 'Coaches Loaded: ' || COUNT(*) FROM COACH;
-- SELECT 'Users Loaded: ' || COUNT(*) FROM SYS_USER;
