import oracledb
import os

conn = oracledb.connect(
    user="system",
    password="oracle",
    dsn="localhost:1521/FREE"
)
cursor = conn.cursor()

updates = [
    ("/uploads/clubs/club_1.svg", "/uploads/clubs/club_1.png", 1),
    ("/uploads/clubs/club_2.svg", "/uploads/clubs/club_2.png", 2),
    ("/uploads/clubs/club_3.svg", "/uploads/clubs/club_3.png", 3),
    ("/uploads/clubs/club_11.svg", "/uploads/clubs/club_11.png", 11),
    ("/uploads/clubs/club_17.svg", "/uploads/clubs/club_17.png", 17),
]

for new_path, old_path, club_id in updates:
    cursor.execute(
        "UPDATE CLUB SET LOGO_URL = :new_path WHERE CLUB_ID = :club_id AND LOGO_URL = :old_path",
        {"new_path": new_path, "old_path": old_path, "club_id": club_id}
    )
    print(f"Updated club {club_id}: {old_path} -> {new_path}")

conn.commit()
print("Done!")
cursor.close()
conn.close()