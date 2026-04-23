-- 更新球员赛季统计数据，确保进球数与积分榜一致
-- 使用存储过程来精确分配进球数

BEGIN
    FOR club_rec IN (
        SELECT c.CLUB_ID, c.NAME, ls.GOALS_FOR, c.LEAGUE
        FROM CLUB c
        JOIN LEAGUE_STANDINGS ls ON c.CLUB_ID = ls.CLUB_ID 
        WHERE ls.SEASON = '2025-2026'
    ) LOOP
        DECLARE
            v_Total_Goals NUMBER := club_rec.GOALS_FOR;
            v_Fw_Count NUMBER;
            v_Mid_Count NUMBER;
            v_Df_Count NUMBER;
            v_Gk_Count NUMBER;
            v_Fw_Goals NUMBER;
            v_Mid_Goals NUMBER;
            v_Df_Goals NUMBER;
            v_Remainder NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_Fw_Count FROM PLAYER WHERE CLUB_ID = club_rec.CLUB_ID AND POSITION = 'FW' AND STATUS = 'ACTIVE';
            SELECT COUNT(*) INTO v_Mid_Count FROM PLAYER WHERE CLUB_ID = club_rec.CLUB_ID AND POSITION = 'MID' AND STATUS = 'ACTIVE';
            SELECT COUNT(*) INTO v_Df_Count FROM PLAYER WHERE CLUB_ID = club_rec.CLUB_ID AND POSITION = 'DF' AND STATUS = 'ACTIVE';
            SELECT COUNT(*) INTO v_Gk_Count FROM PLAYER WHERE CLUB_ID = club_rec.CLUB_ID AND POSITION = 'GK' AND STATUS = 'ACTIVE';

            v_Fw_Goals := FLOOR(v_Total_Goals * 0.55);
            v_Mid_Goals := FLOOR(v_Total_Goals * 0.30);
            v_Df_Goals := FLOOR(v_Total_Goals * 0.05);
            v_Remainder := v_Total_Goals - v_Fw_Goals - v_Mid_Goals - v_Df_Goals;
            v_Fw_Goals := v_Fw_Goals + v_Remainder;

            IF v_Fw_Count > 0 THEN
                FOR fw_rec IN (
                    SELECT PLAYER_ID FROM PLAYER 
                    WHERE CLUB_ID = club_rec.CLUB_ID AND POSITION = 'FW' AND STATUS = 'ACTIVE'
                    ORDER BY DBMS_RANDOM.VALUE
                ) LOOP
                    DECLARE
                        v_Player_Goals NUMBER;
                        v_Player_Assists NUMBER;
                    BEGIN
                        IF v_Fw_Goals > 0 THEN
                            v_Player_Goals := LEAST(v_Fw_Goals, FLOOR(v_Fw_Goals / v_Fw_Count) + 1);
                            IF v_Player_Goals < 1 THEN v_Player_Goals := 1; END IF;
                            v_Fw_Goals := v_Fw_Goals - v_Player_Goals;
                            v_Fw_Count := v_Fw_Count - 1;
                        ELSE
                            v_Player_Goals := 0;
                        END IF;
                        v_Player_Assists := FLOOR(v_Player_Goals * 0.6);
                        UPDATE PLAYER_SEASON_STATS 
                        SET GOALS = v_Player_Goals, ASSISTS = v_Player_Assists
                        WHERE PLAYER_ID = fw_rec.PLAYER_ID;
                    END;
                END LOOP;
            END IF;

            IF v_Mid_Count > 0 THEN
                FOR mid_rec IN (
                    SELECT PLAYER_ID FROM PLAYER 
                    WHERE CLUB_ID = club_rec.CLUB_ID AND POSITION = 'MID' AND STATUS = 'ACTIVE'
                    ORDER BY DBMS_RANDOM.VALUE
                ) LOOP
                    DECLARE
                        v_Player_Goals NUMBER;
                        v_Player_Assists NUMBER;
                    BEGIN
                        IF v_Mid_Goals > 0 THEN
                            v_Player_Goals := LEAST(v_Mid_Goals, FLOOR(v_Mid_Goals / v_Mid_Count) + 1);
                            IF v_Player_Goals < 1 THEN v_Player_Goals := 1; END IF;
                            v_Mid_Goals := v_Mid_Goals - v_Player_Goals;
                            v_Mid_Count := v_Mid_Count - 1;
                        ELSE
                            v_Player_Goals := 0;
                        END IF;
                        v_Player_Assists := FLOOR(v_Player_Goals * 0.8 + DBMS_RANDOM.VALUE(0, 3));
                        UPDATE PLAYER_SEASON_STATS 
                        SET GOALS = v_Player_Goals, ASSISTS = v_Player_Assists
                        WHERE PLAYER_ID = mid_rec.PLAYER_ID;
                    END;
                END LOOP;
            END IF;

            IF v_Df_Count > 0 THEN
                FOR df_rec IN (
                    SELECT PLAYER_ID FROM PLAYER 
                    WHERE CLUB_ID = club_rec.CLUB_ID AND POSITION = 'DF' AND STATUS = 'ACTIVE'
                    ORDER BY DBMS_RANDOM.VALUE
                ) LOOP
                    DECLARE
                        v_Player_Goals NUMBER;
                        v_Player_Assists NUMBER;
                    BEGIN
                        IF v_Df_Goals > 0 THEN
                            v_Player_Goals := LEAST(v_Df_Goals, FLOOR(v_Df_Goals / v_Df_Count) + 1);
                            IF v_Player_Goals < 1 THEN v_Player_Goals := 1; END IF;
                            v_Df_Goals := v_Df_Goals - v_Player_Goals;
                            v_Df_Count := v_Df_Count - 1;
                        ELSE
                            v_Player_Goals := 0;
                        END IF;
                        v_Player_Assists := FLOOR(DBMS_RANDOM.VALUE(0, 2));
                        UPDATE PLAYER_SEASON_STATS 
                        SET GOALS = v_Player_Goals, ASSISTS = v_Player_Assists
                        WHERE PLAYER_ID = df_rec.PLAYER_ID;
                    END;
                END LOOP;
            END IF;

        END;
    END LOOP;
END;
/

COMMIT;
