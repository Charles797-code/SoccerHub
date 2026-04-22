-- ============================================================
-- SoccerHub 触发器脚本
-- 确保系统数据一致性
-- 注意: 每个触发器必须单独执行（用 / 分隔）
-- ============================================================

-- 1. 评分记录变更时，自动更新球员/教练的平均评分和评分次数
-- 使用复合触发器避免 mutating table 问题
CREATE OR REPLACE TRIGGER tr_Calculate_Average_Score
FOR INSERT OR UPDATE OR DELETE ON RATING_RECORD
COMPOUND TRIGGER
    v_target_id   NUMBER;
    v_target_type VARCHAR2(10);
AFTER EACH ROW IS
BEGIN
    IF DELETING THEN
        v_target_id := :OLD.Target_ID;
        v_target_type := :OLD.Target_Type;
    ELSE
        v_target_id := :NEW.Target_ID;
        v_target_type := :NEW.Target_Type;
    END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS
    v_New_Avg     NUMBER(4,2);
    v_Total_Count NUMBER;
BEGIN
    IF v_target_id IS NOT NULL THEN
        IF v_target_type = 'PLAYER' THEN
            SELECT NVL(AVG(Score), 0), COUNT(1) INTO v_New_Avg, v_Total_Count
            FROM RATING_RECORD
            WHERE Target_ID = v_target_id AND Target_Type = 'PLAYER' AND IS_COLLAPSED = 0;
            UPDATE PLAYER SET AVG_SCORE = v_New_Avg, TOTAL_RATINGS = v_Total_Count WHERE PLAYER_ID = v_target_id;
        ELSIF v_target_type = 'COACH' THEN
            SELECT NVL(AVG(Score), 0), COUNT(1) INTO v_New_Avg, v_Total_Count
            FROM RATING_RECORD
            WHERE Target_ID = v_target_id AND Target_Type = 'COACH' AND IS_COLLAPSED = 0;
            UPDATE COACH SET AVG_SCORE = v_New_Avg, TOTAL_RATINGS = v_Total_Count WHERE COACH_ID = v_target_id;
        END IF;
    END IF;
END AFTER STATEMENT;
END tr_Calculate_Average_Score;
/

-- 2. 球员转会时，自动记录转会历史
-- TRANSFER_TYPE 约束: IN, OUT, LOAN, FREE
CREATE OR REPLACE TRIGGER tr_Transfer_History_On_Player_Update
FOR UPDATE OF CLUB_ID ON PLAYER
COMPOUND TRIGGER
    TYPE t_transfer_rec IS RECORD (player_id NUMBER, old_club_id NUMBER, new_club_id NUMBER, new_status VARCHAR2(20));
    TYPE t_transfer_list IS TABLE OF t_transfer_rec INDEX BY PLS_INTEGER;
    v_transfers t_transfer_list;
    v_idx NUMBER := 0;
AFTER EACH ROW IS
BEGIN
    IF :OLD.CLUB_ID != :NEW.CLUB_ID OR (:OLD.STATUS != :NEW.STATUS AND :NEW.STATUS = 'FREE') THEN
        v_idx := v_idx + 1;
        v_transfers(v_idx).player_id := :NEW.PLAYER_ID;
        v_transfers(v_idx).old_club_id := :OLD.CLUB_ID;
        v_transfers(v_idx).new_club_id := :NEW.CLUB_ID;
        v_transfers(v_idx).new_status := :NEW.STATUS;
    END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS
    v_Season VARCHAR2(20);
    v_TransferType VARCHAR2(10);
BEGIN
    v_Season := TO_CHAR(SYSDATE, 'YYYY');
    FOR i IN 1..v_transfers.COUNT LOOP
        IF v_transfers(i).new_status = 'FREE' THEN
            v_TransferType := 'FREE';
        ELSIF v_transfers(i).old_club_id IS NULL THEN
            v_TransferType := 'IN';
        ELSE
            v_TransferType := 'OUT';
        END IF;
        INSERT INTO TRANSFER_HISTORY_LOG (PLAYER_ID, OLD_CLUB_ID, NEW_CLUB_ID, TRANSFER_TYPE, SEASON)
        VALUES (v_transfers(i).player_id, v_transfers(i).old_club_id, v_transfers(i).new_club_id, v_TransferType, v_Season);
    END LOOP;
END AFTER STATEMENT;
END tr_Transfer_History_On_Player_Update;
/

-- 3. 评分记录变更时，自动写入审计日志
CREATE OR REPLACE TRIGGER tr_Audit_User_Rating
FOR INSERT OR UPDATE OR DELETE ON RATING_RECORD
COMPOUND TRIGGER
    TYPE t_audit_rec IS RECORD (
        user_id NUMBER, target_id NUMBER, target_type VARCHAR2(10),
        old_score VARCHAR2(100), new_score VARCHAR2(100), action_type VARCHAR2(10)
    );
    TYPE t_audit_list IS TABLE OF t_audit_rec INDEX BY PLS_INTEGER;
    v_audits t_audit_list;
    v_idx NUMBER := 0;
AFTER EACH ROW IS
BEGIN
    v_idx := v_idx + 1;
    IF DELETING THEN
        v_audits(v_idx).user_id := :OLD.User_ID;
        v_audits(v_idx).target_id := :OLD.Target_ID;
        v_audits(v_idx).target_type := :OLD.Target_Type;
        v_audits(v_idx).old_score := TO_CHAR(:OLD.Score);
        v_audits(v_idx).new_score := NULL;
        v_audits(v_idx).action_type := 'DELETE';
    ELSIF UPDATING THEN
        v_audits(v_idx).user_id := :NEW.User_ID;
        v_audits(v_idx).target_id := :NEW.Target_ID;
        v_audits(v_idx).target_type := :NEW.Target_Type;
        v_audits(v_idx).old_score := TO_CHAR(:OLD.Score);
        v_audits(v_idx).new_score := TO_CHAR(:NEW.Score);
        v_audits(v_idx).action_type := 'UPDATE';
    ELSE
        v_audits(v_idx).user_id := :NEW.User_ID;
        v_audits(v_idx).target_id := :NEW.Target_ID;
        v_audits(v_idx).target_type := :NEW.Target_Type;
        v_audits(v_idx).old_score := NULL;
        v_audits(v_idx).new_score := TO_CHAR(:NEW.Score);
        v_audits(v_idx).action_type := 'INSERT';
    END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS
BEGIN
    FOR i IN 1..v_audits.COUNT LOOP
        INSERT INTO AUDIT_LOG (USER_ID, ACTION_MODULE, ACTION_TYPE, TARGET_TYPE, TARGET_ID, OLD_VALUE, NEW_VALUE, ACTION_TIME)
        VALUES (v_audits(i).user_id, 'RATING', v_audits(i).action_type, v_audits(i).target_type,
            v_audits(i).target_id, v_audits(i).old_score, v_audits(i).new_score, SYSTIMESTAMP);
    END LOOP;
END AFTER STATEMENT;
END tr_Audit_User_Rating;
/

-- 4. 球员评分变更时，自动更新俱乐部总分
CREATE OR REPLACE TRIGGER tr_Maintain_Club_Total_Score
FOR INSERT OR UPDATE OR DELETE ON PLAYER
COMPOUND TRIGGER
    TYPE t_club_rec IS RECORD (club_id NUMBER);
    TYPE t_club_list IS TABLE OF t_club_rec INDEX BY PLS_INTEGER;
    v_clubs t_club_list;
    v_idx NUMBER := 0;
AFTER EACH ROW IS
BEGIN
    IF DELETING THEN
        IF :OLD.CLUB_ID IS NOT NULL THEN
            v_idx := v_idx + 1;
            v_clubs(v_idx).club_id := :OLD.CLUB_ID;
        END IF;
    ELSIF INSERTING THEN
        IF :NEW.CLUB_ID IS NOT NULL THEN
            v_idx := v_idx + 1;
            v_clubs(v_idx).club_id := :NEW.CLUB_ID;
        END IF;
    ELSE
        IF :OLD.CLUB_ID IS NOT NULL THEN
            v_idx := v_idx + 1;
            v_clubs(v_idx).club_id := :OLD.CLUB_ID;
        END IF;
        IF :NEW.CLUB_ID IS NOT NULL AND (:OLD.CLUB_ID IS NULL OR :OLD.CLUB_ID != :NEW.CLUB_ID) THEN
            v_idx := v_idx + 1;
            v_clubs(v_idx).club_id := :NEW.CLUB_ID;
        END IF;
        IF :OLD.CLUB_ID IS NOT NULL AND :NEW.CLUB_ID IS NOT NULL AND :OLD.CLUB_ID = :NEW.CLUB_ID THEN
            v_idx := v_idx + 1;
            v_clubs(v_idx).club_id := :NEW.CLUB_ID;
        END IF;
    END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS
    v_New_Total NUMBER;
    v_Done VARCHAR2(200);
BEGIN
    v_Done := '|';
    FOR i IN 1..v_clubs.COUNT LOOP
        IF INSTR(v_Done, '|' || v_clubs(i).club_id || '|') = 0 THEN
            v_Done := v_Done || v_clubs(i).club_id || '|';
            SELECT NVL(SUM(AVG_SCORE), 0) INTO v_New_Total FROM PLAYER WHERE CLUB_ID = v_clubs(i).club_id AND STATUS = 'ACTIVE';
            UPDATE CLUB SET TOTAL_SCORE = v_New_Total WHERE CLUB_ID = v_clubs(i).club_id;
        END IF;
    END LOOP;
END AFTER STATEMENT;
END tr_Maintain_Club_Total_Score;
/

-- 5. 比赛结果更新时，自动同步积分榜
CREATE OR REPLACE TRIGGER tr_Update_Standings_On_Match_Result
FOR UPDATE OF HOME_SCORE, AWAY_SCORE, STATUS ON MATCH_SCHEDULE
COMPOUND TRIGGER
    TYPE t_match_rec IS RECORD (
        match_id VARCHAR2(20), home_club_id NUMBER, away_club_id NUMBER,
        home_score NUMBER, away_score NUMBER, status VARCHAR2(20),
        old_status VARCHAR2(20), league VARCHAR2(50), season VARCHAR2(20)
    );
    TYPE t_match_list IS TABLE OF t_match_rec INDEX BY PLS_INTEGER;
    v_matches t_match_list;
    v_idx NUMBER := 0;
BEFORE EACH ROW IS
BEGIN
    IF :NEW.STATUS = 'FINISHED' AND (:OLD.STATUS != 'FINISHED' OR :OLD.STATUS IS NULL) THEN
        IF :NEW.HOME_SCORE IS NOT NULL AND :NEW.AWAY_SCORE IS NOT NULL THEN
            v_idx := v_idx + 1;
            v_matches(v_idx).match_id := :NEW.MATCH_ID;
            v_matches(v_idx).home_club_id := :NEW.HOME_CLUB_ID;
            v_matches(v_idx).away_club_id := :NEW.AWAY_CLUB_ID;
            v_matches(v_idx).home_score := :NEW.HOME_SCORE;
            v_matches(v_idx).away_score := :NEW.AWAY_SCORE;
            v_matches(v_idx).status := :NEW.STATUS;
            v_matches(v_idx).old_status := :OLD.STATUS;
            v_matches(v_idx).league := :NEW.LEAGUE;
            v_matches(v_idx).season := :NEW.SEASON;
        END IF;
    END IF;
END BEFORE EACH ROW;
AFTER STATEMENT IS
BEGIN
    FOR i IN 1..v_matches.COUNT LOOP
        MERGE INTO LEAGUE_STANDINGS s
        USING (SELECT v_matches(i).home_club_id AS CLUB_ID, v_matches(i).league AS LEAGUE, v_matches(i).season AS SEASON,
                   v_matches(i).home_score AS GF, v_matches(i).away_score AS GA,
                   CASE WHEN v_matches(i).home_score > v_matches(i).away_score THEN 1 ELSE 0 END AS W,
                   CASE WHEN v_matches(i).home_score = v_matches(i).away_score THEN 1 ELSE 0 END AS D,
                   CASE WHEN v_matches(i).home_score < v_matches(i).away_score THEN 1 ELSE 0 END AS L,
                   CASE WHEN v_matches(i).home_score > v_matches(i).away_score THEN 3
                        WHEN v_matches(i).home_score = v_matches(i).away_score THEN 1 ELSE 0 END AS PTS
            FROM DUAL) src
        ON (s.CLUB_ID = src.CLUB_ID AND s.LEAGUE = src.LEAGUE AND s.SEASON = src.SEASON)
        WHEN MATCHED THEN
            UPDATE SET PLAYED = s.PLAYED + 1, WON = s.WON + src.W, DRAWN = s.DRAWN + src.D,
                LOST = s.LOST + src.L, GOALS_FOR = s.GOALS_FOR + src.GF,
                GOALS_AGAINST = s.GOALS_AGAINST + src.GA,
                GOAL_DIFF = (s.GOALS_FOR + src.GF) - (s.GOALS_AGAINST + src.GA),
                POINTS = s.POINTS + src.PTS, UPDATED_AT = SYSTIMESTAMP
        WHEN NOT MATCHED THEN
            INSERT (LEAGUE, SEASON, CLUB_ID, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
            VALUES (src.LEAGUE, src.SEASON, src.CLUB_ID, 1, src.W, src.D, src.L, src.GF, src.GA, src.GF - src.GA, src.PTS);
        MERGE INTO LEAGUE_STANDINGS s
        USING (SELECT v_matches(i).away_club_id AS CLUB_ID, v_matches(i).league AS LEAGUE, v_matches(i).season AS SEASON,
                   v_matches(i).away_score AS GF, v_matches(i).home_score AS GA,
                   CASE WHEN v_matches(i).away_score > v_matches(i).home_score THEN 1 ELSE 0 END AS W,
                   CASE WHEN v_matches(i).away_score = v_matches(i).home_score THEN 1 ELSE 0 END AS D,
                   CASE WHEN v_matches(i).away_score < v_matches(i).home_score THEN 1 ELSE 0 END AS L,
                   CASE WHEN v_matches(i).away_score > v_matches(i).home_score THEN 3
                        WHEN v_matches(i).away_score = v_matches(i).home_score THEN 1 ELSE 0 END AS PTS
            FROM DUAL) src
        ON (s.CLUB_ID = src.CLUB_ID AND s.LEAGUE = src.LEAGUE AND s.SEASON = src.SEASON)
        WHEN MATCHED THEN
            UPDATE SET PLAYED = s.PLAYED + 1, WON = s.WON + src.W, DRAWN = s.DRAWN + src.D,
                LOST = s.LOST + src.L, GOALS_FOR = s.GOALS_FOR + src.GF,
                GOALS_AGAINST = s.GOALS_AGAINST + src.GA,
                GOAL_DIFF = (s.GOALS_FOR + src.GF) - (s.GOALS_AGAINST + src.GA),
                POINTS = s.POINTS + src.PTS, UPDATED_AT = SYSTIMESTAMP
        WHEN NOT MATCHED THEN
            INSERT (LEAGUE, SEASON, CLUB_ID, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
            VALUES (src.LEAGUE, src.SEASON, src.CLUB_ID, 1, src.W, src.D, src.L, src.GF, src.GA, src.GF - src.GA, src.PTS);
    END LOOP;
END AFTER STATEMENT;
END tr_Update_Standings_On_Match_Result;
/

-- 6. 插入比赛时，验证两队属于同一联赛
CREATE OR REPLACE TRIGGER tr_Validate_Match_League
BEFORE INSERT ON MATCH_SCHEDULE
FOR EACH ROW
DECLARE
    v_Home_League VARCHAR2(50);
    v_Away_League VARCHAR2(50);
BEGIN
    SELECT LEAGUE INTO v_Home_League FROM CLUB WHERE CLUB_ID = :NEW.HOME_CLUB_ID;
    SELECT LEAGUE INTO v_Away_League FROM CLUB WHERE CLUB_ID = :NEW.AWAY_CLUB_ID;
    IF v_Home_League != v_Away_League THEN
        RAISE_APPLICATION_ERROR(-20001, 'Match teams must be in same league');
    END IF;
    IF :NEW.LEAGUE IS NULL THEN
        :NEW.LEAGUE := v_Home_League;
    END IF;
END tr_Validate_Match_League;
/

-- 7. 教练评分变更时，自动更新俱乐部总分（球员+教练）
CREATE OR REPLACE TRIGGER tr_Maintain_Club_Total_Score_Coach
FOR UPDATE OF AVG_SCORE ON COACH
COMPOUND TRIGGER
    TYPE t_coach_rec IS RECORD (club_id NUMBER);
    TYPE t_coach_list IS TABLE OF t_coach_rec INDEX BY PLS_INTEGER;
    v_clubs t_coach_list;
    v_idx NUMBER := 0;
AFTER EACH ROW IS
BEGIN
    IF :NEW.CLUB_ID IS NOT NULL THEN
        v_idx := v_idx + 1;
        v_clubs(v_idx).club_id := :NEW.CLUB_ID;
    END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS
    v_Player_Sum NUMBER;
    v_Coach_Sum NUMBER;
    v_New_Total NUMBER;
    v_Done VARCHAR2(200);
BEGIN
    v_Done := '|';
    FOR i IN 1..v_clubs.COUNT LOOP
        IF INSTR(v_Done, '|' || v_clubs(i).club_id || '|') = 0 THEN
            v_Done := v_Done || v_clubs(i).club_id || '|';
            SELECT NVL(SUM(AVG_SCORE), 0) INTO v_Player_Sum FROM PLAYER WHERE CLUB_ID = v_clubs(i).club_id AND STATUS = 'ACTIVE';
            SELECT NVL(SUM(AVG_SCORE), 0) INTO v_Coach_Sum FROM COACH WHERE CLUB_ID = v_clubs(i).club_id;
            v_New_Total := v_Player_Sum + v_Coach_Sum;
            UPDATE CLUB SET TOTAL_SCORE = v_New_Total WHERE CLUB_ID = v_clubs(i).club_id;
        END IF;
    END LOOP;
END AFTER STATEMENT;
END tr_Maintain_Club_Total_Score_Coach;
/

-- 8. 新俱乐部创建时自动初始化积分榜
CREATE OR REPLACE TRIGGER tr_Init_Standings_On_New_Club
AFTER INSERT ON CLUB
FOR EACH ROW
DECLARE
    v_Current_Season VARCHAR2(20);
    v_Count NUMBER;
BEGIN
    v_Current_Season := TO_CHAR(SYSDATE, 'YYYY') || '-' || TO_CHAR(ADD_MONTHS(SYSDATE, 12), 'YYYY');

    SELECT COUNT(1) INTO v_Count
    FROM LEAGUE_STANDINGS
    WHERE LEAGUE = :NEW.LEAGUE
      AND SEASON = v_Current_Season
      AND CLUB_ID = :NEW.CLUB_ID;

    IF v_Count = 0 THEN
        INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
        VALUES (:NEW.LEAGUE, v_Current_Season, :NEW.CLUB_ID, NULL, 0, 0, 0, 0, 0, 0, 0, 0);
    END IF;

    DECLARE
        v_Max_Pos NUMBER;
    BEGIN
        SELECT NVL(MAX(POSITION), 0) INTO v_Max_Pos
        FROM LEAGUE_STANDINGS
        WHERE LEAGUE = :NEW.LEAGUE AND SEASON = v_Current_Season;

        UPDATE LEAGUE_STANDINGS
        SET POSITION = v_Max_Pos + 1
        WHERE LEAGUE = :NEW.LEAGUE
          AND SEASON = v_Current_Season
          AND CLUB_ID = :NEW.CLUB_ID;
    END;
END tr_Init_Standings_On_New_Club;
/

-- 9. 俱乐部联赛变更时自动更新积分榜
CREATE OR REPLACE TRIGGER tr_Update_Standings_On_Club_League_Change
FOR UPDATE OF LEAGUE ON CLUB
COMPOUND TRIGGER
    TYPE t_change_rec IS RECORD (club_id NUMBER, old_league VARCHAR2(50), new_league VARCHAR2(50));
    TYPE t_change_list IS TABLE OF t_change_rec INDEX BY PLS_INTEGER;
    v_changes t_change_list;
    v_idx NUMBER := 0;
AFTER EACH ROW IS
BEGIN
    IF :OLD.LEAGUE != :NEW.LEAGUE THEN
        v_idx := v_idx + 1;
        v_changes(v_idx).club_id := :NEW.CLUB_ID;
        v_changes(v_idx).old_league := :OLD.LEAGUE;
        v_changes(v_idx).new_league := :NEW.LEAGUE;
    END IF;
END AFTER EACH ROW;
AFTER STATEMENT IS
    v_Current_Season VARCHAR2(20);
    v_Count NUMBER;
    v_Max_Pos NUMBER;
BEGIN
    v_Current_Season := TO_CHAR(SYSDATE, 'YYYY') || '-' || TO_CHAR(ADD_MONTHS(SYSDATE, 12), 'YYYY');

    FOR i IN 1..v_changes.COUNT LOOP
        UPDATE LEAGUE_STANDINGS
        SET LEAGUE = v_changes(i).new_league
        WHERE CLUB_ID = v_changes(i).club_id
          AND LEAGUE = v_changes(i).old_league
          AND SEASON = v_Current_Season;

        SELECT COUNT(1) INTO v_Count
        FROM LEAGUE_STANDINGS
        WHERE LEAGUE = v_changes(i).new_league
          AND SEASON = v_Current_Season
          AND CLUB_ID = v_changes(i).club_id;

        IF v_Count = 0 THEN
            INSERT INTO LEAGUE_STANDINGS (LEAGUE, SEASON, CLUB_ID, POSITION, PLAYED, WON, DRAWN, LOST, GOALS_FOR, GOALS_AGAINST, GOAL_DIFF, POINTS)
            VALUES (v_changes(i).new_league, v_Current_Season, v_changes(i).club_id, NULL, 0, 0, 0, 0, 0, 0, 0, 0);

            SELECT NVL(MAX(POSITION), 0) INTO v_Max_Pos
            FROM LEAGUE_STANDINGS
            WHERE LEAGUE = v_changes(i).new_league AND SEASON = v_Current_SeASON;

            UPDATE LEAGUE_STANDINGS
            SET POSITION = v_Max_Pos + 1
            WHERE LEAGUE = v_changes(i).new_league
              AND SEASON = v_Current_Season
              AND CLUB_ID = v_changes(i).club_id;
        END IF;
    END LOOP;
END AFTER STATEMENT;
END tr_Update_Standings_On_Club_League_Change;
/

COMMIT;
