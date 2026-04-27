-- Fix club logo paths: change .png to .svg for SVG files
UPDATE CLUB SET LOGO_URL = '/uploads/clubs/club_1.svg' WHERE CLUB_ID = 1 AND LOGO_URL = '/uploads/clubs/club_1.png';
UPDATE CLUB SET LOGO_URL = '/uploads/clubs/club_2.svg' WHERE CLUB_ID = 2 AND LOGO_URL = '/uploads/clubs/club_2.png';
UPDATE CLUB SET LOGO_URL = '/uploads/clubs/club_3.svg' WHERE CLUB_ID = 3 AND LOGO_URL = '/uploads/clubs/club_3.png';
UPDATE CLUB SET LOGO_URL = '/uploads/clubs/club_11.svg' WHERE CLUB_ID = 11 AND LOGO_URL = '/uploads/clubs/club_11.png';
UPDATE CLUB SET LOGO_URL = '/uploads/clubs/club_17.svg' WHERE CLUB_ID = 17 AND LOGO_URL = '/uploads/clubs/club_17.png';
COMMIT;