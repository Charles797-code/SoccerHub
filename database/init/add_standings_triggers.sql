-- ============================================================
-- 新增触发器：新俱乐部创建时自动初始化积分榜
-- 当 CLUB 表插入新记录时，自动在 LEAGUE_STANDINGS 中
-- 为当前赛季创建初始积分榜条目
-- ============================================================

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

-- ============================================================
-- 新增触发器：俱乐部联赛变更时自动更新积分榜
-- 当俱乐部的 LEAGUE 字段被修改时，将旧联赛的积分榜记录
-- 移至新联赛（如果新联赛中尚无该俱乐部的记录）
-- ============================================================

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
