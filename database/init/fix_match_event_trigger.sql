-- ============================================================
-- 修复 TR_UPDATE_MATCH_EVENT_COUNT 触发器
-- 使用复合触发器避免 ORA-04091 变异表错误
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

-- 创建新的复合触发器
CREATE OR REPLACE TRIGGER TR_UPDATE_MATCH_EVENT_COUNT
FOR INSERT OR UPDATE OR DELETE ON MATCH_EVENT
COMPOUND TRIGGER
    TYPE t_event_rec IS RECORD (
        match_id VARCHAR2(20),
        event_type VARCHAR2(20),
        player_id NUMBER,
        club_id NUMBER
    );
    TYPE t_event_list IS TABLE OF t_event_rec INDEX BY PLS_INTEGER;
    v_events t_event_list;
    v_idx NUMBER := 0;
    
AFTER EACH ROW IS
BEGIN
    v_idx := v_idx + 1;
    IF DELETING THEN
        v_events(v_idx).match_id := :OLD.MATCH_ID;
        v_events(v_idx).event_type := :OLD.EVENT_TYPE;
        v_events(v_idx).player_id := :OLD.PLAYER_ID;
        v_events(v_idx).club_id := :OLD.CLUB_ID;
    ELSE
        v_events(v_idx).match_id := :NEW.MATCH_ID;
        v_events(v_idx).event_type := :NEW.EVENT_TYPE;
        v_events(v_idx).player_id := :NEW.PLAYER_ID;
        v_events(v_idx).club_id := :NEW.CLUB_ID;
    END IF;
END AFTER EACH ROW;

AFTER STATEMENT IS
    v_goal_count NUMBER;
    v_assist_count NUMBER;
    v_yellow_count NUMBER;
    v_red_count NUMBER;
    v_home_score NUMBER;
    v_away_score NUMBER;
    v_home_club_id NUMBER;
    v_away_club_id NUMBER;
BEGIN
    FOR i IN 1..v_events.COUNT LOOP
        -- 更新比赛事件计数
        SELECT COUNT(*) INTO v_goal_count
        FROM MATCH_EVENT
        WHERE MATCH_ID = v_events(i).match_id AND EVENT_TYPE IN ('GOAL', 'PENALTY');
        
        SELECT COUNT(*) INTO v_assist_count
        FROM MATCH_EVENT
        WHERE MATCH_ID = v_events(i).match_id AND EVENT_TYPE = 'ASSIST';
        
        SELECT COUNT(*) INTO v_yellow_count
        FROM MATCH_EVENT
        WHERE MATCH_ID = v_events(i).match_id AND EVENT_TYPE = 'YELLOW_CARD';
        
        SELECT COUNT(*) INTO v_red_count
        FROM MATCH_EVENT
        WHERE MATCH_ID = v_events(i).match_id AND EVENT_TYPE = 'RED_CARD';
        
        -- 更新MATCH_SCHEDULE中的比分
        BEGIN
            SELECT HOME_CLUB_ID, AWAY_CLUB_ID INTO v_home_club_id, v_away_club_id
            FROM MATCH_SCHEDULE WHERE MATCH_ID = v_events(i).match_id;
            
            SELECT COUNT(*) INTO v_home_score
            FROM MATCH_EVENT me
            WHERE me.MATCH_ID = v_events(i).match_id 
              AND me.EVENT_TYPE IN ('GOAL', 'PENALTY')
              AND me.CLUB_ID = v_home_club_id;
              
            SELECT COUNT(*) INTO v_away_score
            FROM MATCH_EVENT me
            WHERE me.MATCH_ID = v_events(i).match_id 
              AND me.EVENT_TYPE IN ('GOAL', 'PENALTY')
              AND me.CLUB_ID = v_away_club_id;
              
            UPDATE MATCH_SCHEDULE 
            SET HOME_SCORE = v_home_score, AWAY_SCORE = v_away_score
            WHERE MATCH_ID = v_events(i).match_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END LOOP;
END AFTER STATEMENT;
END TR_UPDATE_MATCH_EVENT_COUNT;
/

COMMIT;
