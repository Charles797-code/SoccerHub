-- 使用PL/SQL精确分配球员进球数 - 修正版
DECLARE
    v_Club_Goals NUMBER;
    v_Club_Id NUMBER;
    v_Club_Name VARCHAR2(100);
    v_League VARCHAR2(50);
    v_Fw_Count NUMBER;
    v_Mid_Count NUMBER;
    v_Df_Count NUMBER;
    v_Gk_Count NUMBER;
    v_Fw_Goals NUMBER;
    v_Mid_Goals NUMBER;
    v_Df_Goals NUMBER;
    v_Remainder NUMBER;
    v_Player_Goals NUMBER;
    v_Player_Assists NUMBER;
    v_Yellow NUMBER;
    v_Red NUMBER;
    v_Appearances NUMBER;
    v_Minutes NUMBER;
    v_Assigned_Goals NUMBER;
    v_Players_Left NUMBER;
BEGIN
    FOR club_rec IN (
        SELECT c.CLUB_ID, c.NAME, ls.GOALS_FOR, c.LEAGUE
        FROM CLUB c
        JOIN LEAGUE_STANDINGS ls ON c.CLUB_ID = ls.CLUB_ID 
        WHERE ls.SEASON = '2025-2026'
        ORDER BY c.CLUB_ID
    ) LOOP
        v_Club_Id := club_rec.CLUB_ID;
        v_Club_Name := club_rec.NAME;
        v_Club_Goals := club_rec.GOALS_FOR;
        v_League := club_rec.LEAGUE;
        
        SELECT COUNT(CASE WHEN POSITION = 'FW' THEN 1 END),
               COUNT(CASE WHEN POSITION = 'MID' THEN 1 END),
               COUNT(CASE WHEN POSITION = 'DF' THEN 1 END),
               COUNT(CASE WHEN POSITION = 'GK' THEN 1 END)
        INTO v_Fw_Count, v_Mid_Count, v_Df_Count, v_Gk_Count
        FROM PLAYER WHERE CLUB_ID = v_Club_Id AND STATUS = 'ACTIVE';
        
        v_Fw_Goals := FLOOR(v_Club_Goals * 0.60);
        v_Mid_Goals := FLOOR(v_Club_Goals * 0.25);
        v_Df_Goals := FLOOR(v_Club_Goals * 0.05);
        v_Remainder := v_Club_Goals - v_Fw_Goals - v_Mid_Goals - v_Df_Goals;
        v_Fw_Goals := v_Fw_Goals + v_Remainder;
        
        v_Assigned_Goals := 0;
        v_Players_Left := v_Fw_Count;
        
        FOR fw_rec IN (
            SELECT PLAYER_ID FROM PLAYER 
            WHERE CLUB_ID = v_Club_Id AND POSITION = 'FW' AND STATUS = 'ACTIVE'
            ORDER BY DBMS_RANDOM.VALUE
        ) LOOP
            IF v_Players_Left > 1 THEN
                v_Player_Goals := FLOOR((v_Fw_Goals - v_Assigned_Goals) / v_Players_Left);
                IF v_Player_Goals < 1 THEN v_Player_Goals := 1; END IF;
            ELSE
                v_Player_Goals := v_Fw_Goals - v_Assigned_Goals;
            END IF;
            v_Assigned_Goals := v_Assigned_Goals + v_Player_Goals;
            v_Players_Left := v_Players_Left - 1;
            
            v_Player_Assists := FLOOR(v_Player_Goals * 0.5 + DBMS_RANDOM.VALUE(0, 5));
            v_Yellow := FLOOR(DBMS_RANDOM.VALUE(0, 3));
            v_Red := FLOOR(DBMS_RANDOM.VALUE(0, 2));
            v_Appearances := FLOOR(DBMS_RANDOM.VALUE(20, 35));
            v_Minutes := FLOOR(DBMS_RANDOM.VALUE(1200, 2800));
            
            UPDATE PLAYER_SEASON_STATS 
            SET GOALS = v_Player_Goals, 
                ASSISTS = v_Player_Assists,
                YELLOW_CARDS = v_Yellow,
                RED_CARDS = v_Red,
                APPEARANCES = v_Appearances,
                MINUTES_PLAYED = v_Minutes
            WHERE PLAYER_ID = fw_rec.PLAYER_ID;
        END LOOP;
        
        v_Assigned_Goals := 0;
        v_Players_Left := v_Mid_Count;
        
        FOR mid_rec IN (
            SELECT PLAYER_ID FROM PLAYER 
            WHERE CLUB_ID = v_Club_Id AND POSITION = 'MID' AND STATUS = 'ACTIVE'
            ORDER BY DBMS_RANDOM.VALUE
        ) LOOP
            IF v_Players_Left > 1 THEN
                v_Player_Goals := FLOOR((v_Mid_Goals - v_Assigned_Goals) / v_Players_Left);
                IF v_Player_Goals < 0 THEN v_Player_Goals := 0; END IF;
            ELSE
                v_Player_Goals := v_Mid_Goals - v_Assigned_Goals;
                IF v_Player_Goals < 0 THEN v_Player_Goals := 0; END IF;
            END IF;
            v_Assigned_Goals := v_Assigned_Goals + v_Player_Goals;
            v_Players_Left := v_Players_Left - 1;
            
            v_Player_Assists := FLOOR(v_Player_Goals * 0.8 + DBMS_RANDOM.VALUE(0, 4));
            v_Yellow := FLOOR(DBMS_RANDOM.VALUE(2, 6));
            v_Red := FLOOR(DBMS_RANDOM.VALUE(0, 2));
            v_Appearances := FLOOR(DBMS_RANDOM.VALUE(18, 32));
            v_Minutes := FLOOR(DBMS_RANDOM.VALUE(1000, 2500));
            
            UPDATE PLAYER_SEASON_STATS 
            SET GOALS = v_Player_Goals, 
                ASSISTS = v_Player_Assists,
                YELLOW_CARDS = v_Yellow,
                RED_CARDS = v_Red,
                APPEARANCES = v_Appearances,
                MINUTES_PLAYED = v_Minutes
            WHERE PLAYER_ID = mid_rec.PLAYER_ID;
        END LOOP;
        
        v_Assigned_Goals := 0;
        v_Players_Left := v_Df_Count;
        
        FOR df_rec IN (
            SELECT PLAYER_ID FROM PLAYER 
            WHERE CLUB_ID = v_Club_Id AND POSITION = 'DF' AND STATUS = 'ACTIVE'
            ORDER BY DBMS_RANDOM.VALUE
        ) LOOP
            IF v_Players_Left > 1 THEN
                v_Player_Goals := FLOOR((v_Df_Goals - v_Assigned_Goals) / v_Players_Left);
                IF v_Player_Goals < 0 THEN v_Player_Goals := 0; END IF;
            ELSE
                v_Player_Goals := v_Df_Goals - v_Assigned_Goals;
                IF v_Player_Goals < 0 THEN v_Player_Goals := 0; END IF;
            END IF;
            v_Assigned_Goals := v_Assigned_Goals + v_Player_Goals;
            v_Players_Left := v_Players_Left - 1;
            
            v_Player_Assists := FLOOR(DBMS_RANDOM.VALUE(0, 3));
            v_Yellow := FLOOR(DBMS_RANDOM.VALUE(3, 7));
            v_Red := FLOOR(DBMS_RANDOM.VALUE(0, 2));
            v_Appearances := FLOOR(DBMS_RANDOM.VALUE(18, 32));
            v_Minutes := FLOOR(DBMS_RANDOM.VALUE(1000, 2500));
            
            UPDATE PLAYER_SEASON_STATS 
            SET GOALS = v_Player_Goals, 
                ASSISTS = v_Player_Assists,
                YELLOW_CARDS = v_Yellow,
                RED_CARDS = v_Red,
                APPEARANCES = v_Appearances,
                MINUTES_PLAYED = v_Minutes
            WHERE PLAYER_ID = df_rec.PLAYER_ID;
        END LOOP;
        
        FOR gk_rec IN (
            SELECT PLAYER_ID FROM PLAYER 
            WHERE CLUB_ID = v_Club_Id AND POSITION = 'GK' AND STATUS = 'ACTIVE'
        ) LOOP
            v_Player_Goals := 0;
            v_Player_Assists := FLOOR(DBMS_RANDOM.VALUE(0, 2));
            v_Yellow := FLOOR(DBMS_RANDOM.VALUE(0, 3));
            v_Red := 0;
            v_Appearances := FLOOR(DBMS_RANDOM.VALUE(28, 35));
            v_Minutes := FLOOR(DBMS_RANDOM.VALUE(2500, 3150));
            
            UPDATE PLAYER_SEASON_STATS 
            SET GOALS = v_Player_Goals, 
                ASSISTS = v_Player_Assists,
                YELLOW_CARDS = v_Yellow,
                RED_CARDS = v_Red,
                APPEARANCES = v_Appearances,
                MINUTES_PLAYED = v_Minutes
            WHERE PLAYER_ID = gk_rec.PLAYER_ID;
        END LOOP;
    END LOOP;
    
    COMMIT;
END;
/
