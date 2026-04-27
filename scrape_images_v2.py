#!/usr/bin/env python3
import os
import sys
import requests
import time
import json
import re
from urllib.parse import quote

UPLOADS_DIR = r"d:\soccer_community\backend\src\main\resources\static\uploads"
os.makedirs(UPLOADS_DIR, exist_ok=True)

CLUB_IMAGE_DIR = os.path.join(UPLOADS_DIR, "clubs")
PLAYER_IMAGE_DIR = os.path.join(UPLOADS_DIR, "players")
os.makedirs(CLUB_IMAGE_DIR, exist_ok=True)
os.makedirs(PLAYER_IMAGE_DIR, exist_ok=True)

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-US,en;q=0.5',
}

session = requests.Session()
session.headers.update(headers)

def download_image(url, filepath, timeout=30):
    if os.path.exists(filepath):
        size = os.path.getsize(filepath)
        if size > 1000:
            print(f"  [SKIP] Already exists: {os.path.basename(filepath)} ({size} bytes)")
            return True
    try:
        response = session.get(url, timeout=timeout, allow_redirects=True)
        if response.status_code == 200 and len(response.content) > 1000:
            content_type = response.headers.get('Content-Type', '')
            if 'image' in content_type or response.content[:4] == b'\xff\xd8\xff':
                with open(filepath, 'wb') as f:
                    f.write(response.content)
                print(f"  [OK] Downloaded: {os.path.basename(filepath)} ({len(response.content)} bytes)")
                return True
        print(f"  [FAIL] HTTP {response.status_code}: {url}")
        return False
    except Exception as e:
        print(f"  [FAIL] {e}: {url}")
        return False

def get_transfermarkt_player_image(player_name):
    """Get player image from Transfermarkt"""
    try:
        search_url = f"https://www.transfermarkt.com/schnellsuche/ergebnis/schnellsuche?query={quote(player_name)}"
        resp = session.get(search_url, timeout=15)
        if resp.status_code == 200:
            matches = re.findall(r'href="(/[^\s"]*/profil/spieler/\d+)"[^>]*>.*?<img[^>]*src="([^"]+)"', resp.text, re.DOTALL)
            for match in matches[:2]:
                img_url = match[1]
                if img_url and 'placeholder' not in img_url.lower():
                    return img_url
    except Exception as e:
        print(f"    Transfermarkt error: {e}")
    return None

def get_sofifa_player_image(player_name):
    """Get player image from Sofifa"""
    try:
        search_url = f"https://sofifa.com/search?q={quote(player_name)}"
        resp = session.get(search_url, timeout=15)
        if resp.status_code == 200:
            match = re.search(r'<img[^>]*class="player-img"[^>]*src="([^"]+)"', resp.text)
            if match:
                return match.group(1)
            matches = re.findall(r'<img[^>]*src="(https://cdn\.sofifa\.com/[^"]+)"', resp.text)
            for img_url in matches[:2]:
                if 'player' in img_url.lower():
                    return img_url
    except Exception as e:
        print(f"    Sofifa error: {e}")
    return None

def get_football_index_image(player_name):
    """Get player image from Football Index"""
    try:
        search_url = f"https://www.fotmob.com/search?term={quote(player_name)}"
        resp = session.get(search_url, timeout=15)
        if resp.status_code == 200:
            matches = re.findall(r'"imageUrl":"([^"]+)"', resp.text)
            for img_url in matches[:3]:
                if img_url and 'player' in img_url.lower():
                    return img_url.replace('\\/', '/')
    except Exception as e:
        print(f"    Fotmob error: {e}")
    return None

def get_wikipedia_player_image(player_name):
    """Get player image from Wikipedia"""
    try:
        search_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={quote(player_name)}&prop=pageimages&format=json&pithumbsize=500"
        resp = session.get(search_url, timeout=15)
        if resp.status_code == 200:
            data = resp.json()
            pages = data.get('query', {}).get('pages', {})
            for page in pages.values():
                if 'thumbnail' in page:
                    return page['thumbnail']['source']
    except Exception as e:
        print(f"    Wikipedia error: {e}")
    return None

def get_wikipedia_club_image(club_name):
    """Get club logo from Wikipedia"""
    try:
        search_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={quote(club_name)}&prop=pageimages&format=json&pithumbsize=500"
        resp = session.get(search_url, timeout=15)
        if resp.status_code == 200:
            data = resp.json()
            pages = data.get('query', {}).get('pages', {})
            for page in pages.values():
                if 'thumbnail' in page:
                    return page['thumbnail']['source']
    except Exception as e:
        print(f"    Wikipedia error: {e}")
    return None

def get_transfermarkt_club_image(club_name):
    """Get club logo from Transfermarkt"""
    try:
        search_url = f"https://www.transfermarkt.com/schnellsuche/ergebnis/schnellsuche?query={quote(club_name)}"
        resp = session.get(search_url, timeout=15)
        if resp.status_code == 200:
            matches = re.findall(r'href="(/[^\s"]*/startseite/verein/\d+)"[^>]*>.*?<img[^>]*src="([^"]+)"', resp.text, re.DOTALL)
            for match in matches[:2]:
                img_url = match[1]
                if img_url and 'logo' in img_url.lower() and 'placeholder' not in img_url.lower():
                    return img_url
    except Exception as e:
        print(f"    Transfermarkt error: {e}")
    return None

CLUBS_MISSING = {
    5: ("Liverpool FC", "Liverpool"),
    7: ("Real Madrid CF", "Real Madrid"),
    8: ("Villarreal CF", "Villarreal"),
    9: ("Atlético Madrid", "Atletico Madrid"),
    10: ("Real Sociedad", "Real Sociedad"),
    12: ("Olympique Lyon", "Lyon"),
    13: ("AS Monaco FC", "Monaco"),
    15: ("Stade Rennais", "Rennes"),
    20: ("Eintracht Frankfurt", "Eintracht Frankfurt"),
    22: ("AC Milan", "AC Milan"),
    24: ("Juventus FC", "Juventus"),
    25: ("Atalanta BC", "Atalanta"),
    90: ("Shandong Taishan FC", "Shandong Taishan"),
    91: ("Beijing Guoan FC", "Beijing Guoan"),
}

CLUB_DIRECT_URLS_V2 = {
    5: "https://upload.wikimedia.org/wikipedia/commons/0/0c/Liverpool_FC.svg",
    7: "https://upload.wikimedia.org/wikipedia/commons/5/56/Real_Madrid_CF.svg",
    8: "https://upload.wikimedia.org/wikipedia/commons/7/7f/Villarreal_CF_%28no_text%29.svg",
    9: "https://upload.wikimedia.org/wikipedia/commons/f/f4/Atletico_Madrid_2017_logo.svg",
    10: "https://upload.wikimedia.org/wikipedia/commons/2/2d/Real_Sociedad_logo.svg",
    12: "https://upload.wikimedia.org/wikipedia/commons/6/6d/Olympique_Lyon.svg",
    13: "https://upload.wikimedia.org/wikipedia/commons/b/bc/AS_Monaco_FC.svg",
    15: "https://upload.wikimedia.org/wikipedia/commons/8/86/Stade_Rennais_FC.svg",
    20: "https://upload.wikimedia.org/wikipedia/commons/0/0b/Eintracht_Frankfurt_Logo.svg",
    22: "https://upload.wikimedia.org/wikipedia/commons/0/05/AC_Milan.svg",
    24: "https://upload.wikimedia.org/wikipedia/commons/b/bc/Juventus_FC_2017_icon_-_Bishop.svg",
    25: "https://upload.wikimedia.org/wikipedia/commons/9/93/Atalanta_BC_2016.svg",
}

def download_missing_club_logos():
    print("\n" + "="*60)
    print("Downloading Missing Club Logos...")
    print("="*60)

    success_count = 0
    fail_count = 0

    for club_id, (wiki_name, display_name) in CLUBS_MISSING.items():
        filepath = os.path.join(CLUB_IMAGE_DIR, f"club_{club_id}.png")

        if os.path.exists(filepath) and os.path.getsize(filepath) > 1000:
            print(f"\n[{club_id}] {display_name}: Already exists")
            continue

        print(f"\n[{club_id}] {display_name}:")

        downloaded = False

        if club_id in CLUB_DIRECT_URLS_V2:
            url = CLUB_DIRECT_URLS_V2[club_id]
            print(f"  Trying direct URL...")
            if download_image(url, filepath):
                success_count += 1
                downloaded = True
            time.sleep(1)

        if not downloaded:
            print(f"  Trying Wikipedia...")
            url = get_wikipedia_club_image(wiki_name)
            if url and download_image(url, filepath):
                success_count += 1
                downloaded = True
            time.sleep(1)

        if not downloaded:
            print(f"  Trying Transfermarkt...")
            url = get_transfermarkt_club_image(wiki_name)
            if url and download_image(url, filepath):
                success_count += 1
                downloaded = True
            time.sleep(1)

        if not downloaded:
            print(f"  [FAIL] Could not download logo for {display_name}")
            fail_count += 1

        time.sleep(0.5)

    print(f"\nMissing Club Logos: {success_count} success, {fail_count} failed")
    return success_count, fail_count

def get_all_players_without_avatars():
    """Get players that don't have avatars yet"""
    import subprocess

    result = subprocess.run([
        'docker', 'exec', 'soccer_oracle21', 'bash', '-c',
        'sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @/dev/stdin <<\'EOF\'\n'
        'SET PAGESIZE 500\n'
        'SPOOL /tmp/players_no_avatar.txt\n'
        'SELECT PLAYER_ID || \',\' || NAME || \',\' || NVL(NAME_CN, \'\') || \',\' || CLUB_ID FROM PLAYER WHERE AVATAR_URL IS NULL OR AVATAR_URL = \'\' ORDER BY PLAYER_ID;\n'
        'SPOOL OFF\n'
        'EXIT;\n'
        'EOF'
    ], capture_output=True, text=True, cwd=r"d:\soccer_community")

    spool_result = subprocess.run([
        'docker', 'exec', 'soccer_oracle21', 'cat', '/tmp/players_no_avatar.txt'
    ], capture_output=True, text=True)

    players = []
    if spool_result.returncode == 0:
        lines = spool_result.stdout.strip().split('\n')
        for line in lines:
            parts = line.strip().split(',')
            if len(parts) >= 4:
                try:
                    player_id = int(parts[0])
                    name = parts[1]
                    name_cn = parts[2] if len(parts) > 2 else ''
                    club_id = int(parts[3]) if parts[3] else 0
                    players.append({
                        'player_id': player_id,
                        'name': name,
                        'name_cn': name_cn,
                        'club_id': club_id
                    })
                except:
                    pass

    return players

def download_missing_player_images():
    """Download player images from multiple sources"""
    print("\n" + "="*60)
    print("Downloading Missing Player Images...")
    print("="*60)

    players = get_all_players_without_avatars()
    print(f"Found {len(players)} players without avatars")

    if not players:
        print("All players already have avatars!")
        return {}

    success_count = 0
    fail_count = 0
    results = {}

    for i, player in enumerate(players):
        player_id = player['player_id']
        name = player['name']
        name_cn = player['name_cn']

        if (i + 1) % 10 == 0:
            print(f"\nProgress: {i + 1}/{len(players)} players processed...")

        filepath = os.path.join(PLAYER_IMAGE_DIR, f"player_{player_id}.jpg")

        print(f"\n[{player_id}] {name} ({name_cn}):")

        downloaded = False
        sources_tried = []

        print(f"  Trying Sofifa...")
        sources_tried.append("Sofifa")
        url = get_sofifa_player_image(name)
        if url and download_image(url, filepath):
            results[player_id] = f"/uploads/players/player_{player_id}.jpg"
            success_count += 1
            downloaded = True
        time.sleep(0.5)

        if not downloaded:
            print(f"  Trying Transfermarkt...")
            sources_tried.append("Transfermarkt")
            url = get_transfermarkt_player_image(name)
            if url and download_image(url, filepath):
                results[player_id] = f"/uploads/players/player_{player_id}.jpg"
                success_count += 1
                downloaded = True
            time.sleep(0.5)

        if not downloaded:
            print(f"  Trying Fotmob...")
            sources_tried.append("Fotmob")
            url = get_football_index_image(name)
            if url and download_image(url, filepath):
                results[player_id] = f"/uploads/players/player_{player_id}.jpg"
                success_count += 1
                downloaded = True
            time.sleep(0.5)

        if not downloaded:
            print(f"  Trying Wikipedia...")
            sources_tried.append("Wikipedia")
            url = get_wikipedia_player_image(name)
            if url and download_image(url, filepath):
                results[player_id] = f"/uploads/players/player_{player_id}.jpg"
                success_count += 1
                downloaded = True
            time.sleep(1)

        if not downloaded:
            print(f"  [FAIL] Could not find image for {name} (tried: {', '.join(sources_tried)})")
            fail_count += 1

        time.sleep(0.3)

    print(f"\nMissing Player Images: {success_count} success, {fail_count} failed")
    return results

def update_database(results, table_name, url_column):
    """Update database with image URLs"""
    print(f"\nUpdating {table_name} {url_column} in database...")

    import subprocess

    count = 0
    for item_id, url in results.items():
        if table_name == 'PLAYER':
            sql = f"UPDATE PLAYER SET AVATAR_URL = '{url}' WHERE PLAYER_ID = {item_id};"
        else:
            sql = f"UPDATE CLUB SET LOGO_URL = '{url}' WHERE CLUB_ID = {item_id};"

        count += 1
        if count % 20 == 0:
            print(f"  Updated {count}/{len(results)}...")

        subprocess.run([
            'docker', 'exec', 'soccer_oracle21', 'bash', '-c',
            f'echo "{sql}" | sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1'
        ], capture_output=True, text=True, cwd=r"d:\soccer_community")

    print(f"Updated {count} {table_name} records")

def main():
    print("="*60)
    print("SoccerHub Image Scraper v2 (Multi-Source)")
    print("="*60)
    print(f"Uploads directory: {UPLOADS_DIR}")

    club_success, club_fail = download_missing_club_logos()

    player_results = download_missing_player_images()

    if club_success > 0:
        print("\nUpdating missing club logos in database...")
        club_results = {club_id: f"/uploads/clubs/club_{club_id}.png"
                        for club_id in CLUBS_MISSING.keys()
                        if os.path.exists(os.path.join(CLUB_IMAGE_DIR, f"club_{club_id}.png"))
                        and os.path.getsize(os.path.join(CLUB_IMAGE_DIR, f"club_{club_id}.png")) > 1000}
        update_database(club_results, 'CLUB', 'LOGO_URL')

    if player_results:
        update_database(player_results, 'PLAYER', 'AVATAR_URL')

    print("\n" + "="*60)
    print("Image Scraping Complete!")
    print("="*60)
    print(f"Club Logos: {club_success} new success")
    print(f"Player Images: {len(player_results)} new success")

if __name__ == "__main__":
    main()
