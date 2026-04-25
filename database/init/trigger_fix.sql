CREATE OR REPLACE TRIGGER TR_UPDATE_MATCH_EVENT_COUNT
AFTER INSERT OR UPDATE OR DELETE ON MATCH_EVENT
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    v_home_score NUMBER;
    v_away_score NUMBER;
    v_home_club_id NUMBER;
    v_away_club_id NUMBER;
    v_match_id VARCHAR2(50);
BEGIN
    IF DELETING THEN
        v_match_id := :OLD.MATCH_ID;
    ELSE
        v_match_id := :NEW.MATCH_ID;
    END IF;

    BEGIN
        SELECT HOME_CLUB_ID, AWAY_CLUB_ID INTO v_home_club_id, v_away_club_id
        FROM MATCH_SCHEDULE WHERE MATCH_ID = v_match_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN;
    END;

    SELECT COUNT(*) INTO v_home_score
    FROM MATCH_EVENT
    WHERE MATCH_ID = v_match_id
      AND EVENT_TYPE IN ('GOAL', 'PENALTY')
      AND CLUB_ID = v_home_club_id;

    SELECT COUNT(*) INTO v_away_score
    FROM MATCH_EVENT
    WHERE MATCH_ID = v_match_id
      AND EVENT_TYPE IN ('GOAL', 'PENALTY')
      AND CLUB_ID = v_away_club_id;

    UPDATE MATCH_SCHEDULE
    SET HOME_SCORE = NVL(v_home_score, 0), AWAY_SCORE = NVL(v_away_score, 0)
    WHERE MATCH_ID = v_match_id;

    COMMIT;
END;
/

SHOW ERRORS TRIGGER TR_UPDATE_MATCH_EVENT_COUNT
