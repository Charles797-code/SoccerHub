-- Step 1: Connect as SYSTEM and create the SOCCERHUB user/schema
ALTER SESSION SET CONTAINER = FREE;

-- Drop if exists (for re-initialization)
BEGIN
    EXECUTE IMMEDIATE 'DROP USER soccerhub CASCADE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -1918 THEN RAISE; END IF;
END;
/

-- Create user (Oracle XE 21c uses LOCAL temp tablespaces)
CREATE USER soccerhub
    IDENTIFIED BY soccerhub2026
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP
    QUOTA UNLIMITED ON USERS;

-- Grant roles and privileges
GRANT CONNECT, RESOURCE TO soccerhub;
GRANT CREATE VIEW TO soccerhub;
GRANT CREATE PROCEDURE TO soccerhub;
GRANT CREATE SEQUENCE TO soccerhub;
GRANT CREATE TABLE TO soccerhub;
GRANT CREATE TRIGGER TO soccerhub;
GRANT CREATE JOB TO soccerhub;
GRANT CREATE MATERIALIZED VIEW TO soccerhub;
GRANT UNLIMITED TABLESPACE TO soccerhub;

-- Grant execution on some system packages used by procedures
GRANT EXECUTE ON DBMS_OUTPUT TO soccerhub;
GRANT EXECUTE ON DBMS_LOB TO soccerhub;
GRANT EXECUTE ON DBMS_LOCK TO soccerhub;

EXIT;
