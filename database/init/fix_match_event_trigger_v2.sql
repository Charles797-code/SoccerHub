-- ============================================================
-- 修复 TR_UPDATE_MATCH_EVENT_COUNT 触发器
-- 使用自治事务避免 ORA-04091 变异表错误
-- ============================================================

-- 首先删除旧的触发器（如果存在）
BEGIN
    EXECUTE IMMEDIATE 'DROP TRIGGER TR_UPDATE_MATCH_EVENT_COUNT';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4080 THEN
            RAISE;
        END IF;
END;
/

-- 创建使用自治事务的触发器
CREATE OR REPLACE TRIGGER TR_UPDATE_MATCH_EVENT_COUNT
AFTER INSERT OR UPDATE OR DELETE ON MATCH_EVENT
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_goal_count NUMBER;
    v_home_score NUMBER;
    v_away_score NUMBER;
    v_home_club_id NUMBER;
    v_away_club_id NUMBER;
BEGIN
    -- 获取比赛的主客队
    BEGIN
        SELECT HOME_CLUB_ID, AWAY_CLUB_ID INTO v_home_club_id, v_away_club_id
        FROM MATCH_SCHEDULE WHERE MATCH_ID = :NEW.MATCH_ID;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- 如果是删除操作，尝试从OLD获取
            IF DELETING THEN
                BEGIN
                    SELECT HOME_CLUB_ID, AWAY_CLUB_ID INTO v_home_club_id, v_away_club_id
                    FROM MATCH_SCHEDULE WHERE MATCH_ID = :OLD.MATCH_ID;
                EXCEPTION
                    WHEN OTHERS THEN
                        RETURN;
                END;
            ELSE
                RETURN;
            END IF;
    END;

    -- 计算主队进球数（GOAL + PENALTY，不含乌龙球）
    SELECT COUNT(*) INTO v_home_score
    FROM MATCH_EVENT
    WHERE MATCH_ID = (CASE WHEN DELETING THEN :OLD.MATCH_ID ELSE :NEW.MATCH_ID END)
      AND EVENT_TYPE IN ('GOAL', 'PENALTY')
      AND CLUB_ID = v_home_club_id;

    -- 计算客队进球数
    SELECT COUNT(*) INTO v_away_score
    FROM MATCH_EVENT
    WHERE MATCH_ID = (CASE WHEN DELETING THEN :OLD.MATCH_ID ELSE :NEW.MATCH_ID END)
      AND EVENT_TYPE IN ('GOAL', 'PENALTY')
      AND CLUB_ID = v_away_club_id;

    -- 更新MATCH_SCHEDULE中的比分
    UPDATE MATCH_SCHEDULE
    SET HOME_SCORE = v_home_score, AWAY_SCORE = v_away_score
    WHERE MATCH_ID = (CASE WHEN DELETING THEN :OLD.MATCH_ID ELSE :NEW.MATCH_ID END);

    COMMIT;
END TR_UPDATE_MATCH_EVENT_COUNT;
/

COMMIT;
