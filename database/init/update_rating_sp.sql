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
    v_Has_Rated_Today  NUMBER;
    v_User_Role        VARCHAR2(20);
BEGIN
    p_Result := 'SUCCESS';
    p_Record_ID := 0;

    SELECT ROLE INTO v_User_Role FROM SYS_USER WHERE USER_ID = p_User_ID;

    IF v_User_Role != 'SUPER_ADMIN' THEN
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
    END IF;

    INSERT INTO RATING_RECORD (USER_ID, TARGET_ID, TARGET_TYPE, SCORE, COMMENT_TEXT, RATING_TYPE, MATCH_ID)
    VALUES (p_User_ID, p_Target_ID, p_Target_Type, p_Score, p_Comment, p_Rating_Type, p_Match_ID)
    RETURNING RECORD_ID INTO p_Record_ID;

    COMMIT;
    p_Result := 'SUCCESS: 评分成功！';

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_Result := 'FATAL ERROR: ' || SQLERRM;
END osp_Submit_User_Rating;
/
