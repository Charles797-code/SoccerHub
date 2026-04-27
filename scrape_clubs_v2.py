#!/usr/bin/env python3
import os
import requests
import time
import re

UPLOADS_DIR = r"d:\soccer_community\backend\src\main\resources\static\uploads"
CLUB_IMAGE_DIR = os.path.join(UPLOADS_DIR, "clubs")
os.makedirs(CLUB_IMAGE_DIR, exist_ok=True)

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
}

session = requests.Session()
session.headers.update(headers)

def download_image(url, filepath, timeout=30):
    if os.path.exists(filepath) and os.path.getsize(filepath) > 1000:
        print(f"  [SKIP] Already exists")
        return True
    try:
        response = session.get(url, timeout=timeout, allow_redirects=True)
        if response.status_code == 200 and len(response.content) > 1000:
            with open(filepath, 'wb') as f:
                f.write(response.content)
            print(f"  [OK] Downloaded ({len(response.content)} bytes)")
            return True
        print(f"  [FAIL] HTTP {response.status_code}")
        return False
    except Exception as e:
        print(f"  [FAIL] {e}")
        return False

def search_google_image(query, site=''):
    """Try to find image URL via Google search (simplified)"""
    try:
        if site:
            search_url = f"https://www.google.com/search?q={query}+site:{site}&tbm=isch"
        else:
            search_url = f"https://www.google.com/search?q={query}+logo&tbm=isch"

        resp = session.get(search_url, timeout=10)
        if resp.status_code == 200:
            matches = re.findall(r'src="(https://[^"]*?\.(?:png|jpg|jpeg|svg))"', resp.text)
            for url in matches[:5]:
                if 'logo' in url.lower() or 'crest' in url.lower():
                    return url
            if matches:
                return matches[0]
    except:
        pass
    return None

def get_worldfootball_club_image(club_name):
    """Get club image from worldfootball.net"""
    try:
        search_url = f"https://www.worldfootball.net/report/{club_name.lower().replace(' ', '-')}"
        resp = session.get(search_url, timeout=10)
        if resp.status_code == 200:
            matches = re.findall(r'<img[^>]*src="(https://[^"]*?logo[^"]*\.(?:png|jpg))"', resp.text, re.I)
            if matches:
                return matches[0]
    except:
        pass
    return None

def get_fotballdatabase_image(club_name):
    """Get club image from football database"""
    try:
        search_url = f"https://www.football-data.org/search?q={club_name.replace(' ', '%20')}"
        resp = session.get(search_url, timeout=10)
        if resp.status_code == 200:
            matches = re.findall(r'"crest":"([^"]+)"', resp.text)
            if matches:
                return matches[0].replace('\\/', '/')
    except:
        pass
    return None

MISSING_CLUBS = {
    5: ("Liverpool FC", "Liverpool"),
    8: ("Villarreal CF", "Villarreal"),
    9: ("Atlético Madrid", "Atletico Madrid"),
    10: ("Real Sociedad", "Real Sociedad"),
    12: ("Olympique Lyon", "Lyon"),
    13: ("AS Monaco FC", "Monaco"),
    15: ("Stade Rennais", "Rennes"),
    20: ("Eintracht Frankfurt", "Eintracht Frankfurt"),
    25: ("Atalanta BC", "Atalanta"),
    90: ("Shandong Taishan", "Shandong"),
    91: ("Beijing Guoan", "Beijing Guoan"),
}

RELIABLE_CLUB_URLS = {
    5: [
        "https://upload.wikimedia.org/wikipedia/commons/0/0c/Liverpool_FC.svg",
        "https://resources.escienceglobal.com/media/images/liverpool-fc-logo.png",
        "https://ssl.gstatic.com/onebox/media/sports/logos/4e9n8-6n5Xh_XEzmMYp1qw_96x96.png",
    ],
    8: [
        "https://upload.wikimedia.org/wikipedia/commons/7/7f/Villarreal_CF_%28no_text%29.svg",
        "https://ssl.gstatic.com/onebox/media/sports/logos/4e9n8-6n5Xh_XEzmMYp1qw_96x96.png",
    ],
    9: [
        "https://upload.wikimedia.org/wikipedia/commons/f/f4/Atletico_Madrid_2017_logo.svg",
        "https://ssl.gstatic.com/onebox/media/sports/logos/3f3iU8-05qH_v2vLAqBJNA_96x96.png",
    ],
    10: [
        "https://upload.wikimedia.org/wikipedia/commons/2/2d/Real_Sociedad_logo.svg",
    ],
    12: [
        "https://upload.wikimedia.org/wikipedia/commons/6/6d/Olympique_Lyon.svg",
        "https://ssl.gstatic.com/onebox/media/sports/logos/3a5N8-65nqH_v2vLAqBJNA_96x96.png",
    ],
    13: [
        "https://upload.wikimedia.org/wikipedia/commons/b/bc/AS_Monaco_FC.svg",
        "https://ssl.gstatic.com/onebox/media/sports/logos/5a6N8-65nqH_v2vLAqBJNA_96x96.png",
    ],
    15: [
        "https://upload.wikimedia.org/wikipedia/commons/8/86/Stade_Rennais_FC.svg",
    ],
    20: [
        "https://upload.wikimedia.org/wikipedia/commons/0/0b/Eintracht_Frankfurt_Logo.svg",
        "https://ssl.gstatic.com/onebox/media/sports/logos/3c4N8-65nqH_v2vLAqBJNA_96x96.png",
    ],
    25: [
        "https://upload.wikimedia.org/wikipedia/commons/9/93/Atalanta_BC_2016.svg",
        "https://ssl.gstatic.com/onebox/media/sports/logos/4d5N8-65nqH_v2vLAqBJNA_96x96.png",
    ],
    90: [
        "https://upload.wikimedia.org/wikipedia/commons/4/47/Shandong_Taishan_FC_logo.svg",
        "https://ssl.gstatic.com/onebox/media/sports/logos/5e6N8-65nqH_v2vLAqBJNA_96x96.png",
    ],
    91: [
        "https://upload.wikimedia.org/wikipedia/commons/4/42/Beijing_Guoan_FC_logo.svg",
        "https://ssl.gstatic.com/onebox/media/sports/logos/5f6N8-65nqH_v2vLAqBJNA_96x96.png",
    ],
}

def download_missing_clubs():
    print("="*60)
    print("Downloading Missing Club Logos (Reliable Sources)")
    print("="*60)

    success_count = 0
    fail_count = 0

    for club_id, (wiki_name, display_name) in MISSING_CLUBS.items():
        filepath = os.path.join(CLUB_IMAGE_DIR, f"club_{club_id}.png")

        print(f"\n[{club_id}] {display_name}:")

        if os.path.exists(filepath) and os.path.getsize(filepath) > 1000:
            print(f"  [SKIP] Already exists")
            continue

        downloaded = False

        if club_id in RELIABLE_CLUB_URLS:
            for url in RELIABLE_CLUB_URLS[club_id]:
                print(f"  Trying: {url[:60]}...")
                if download_image(url, filepath):
                    downloaded = True
                    break
                time.sleep(0.5)

        if not downloaded:
            print(f"  [FAIL] Could not download logo for {display_name}")
            fail_count += 1
        else:
            success_count += 1

        time.sleep(0.3)

    print(f"\n{'='*60}")
    print(f"Missing Club Logos: {success_count} success, {fail_count} failed")
    print(f"{'='*60}")

    return success_count, fail_count

def update_database():
    """Update club logo URLs in database"""
    import subprocess

    print("\nUpdating database...")

    for club_id in MISSING_CLUBS.keys():
        filepath = os.path.join(CLUB_IMAGE_DIR, f"club_{club_id}.png")
        if os.path.exists(filepath) and os.path.getsize(filepath) > 1000:
            url = f"/uploads/clubs/club_{club_id}.png"
            sql = f"UPDATE CLUB SET LOGO_URL = '{url}' WHERE CLUB_ID = {club_id};"
            print(f"  Club {club_id}: {url}")
            subprocess.run([
                'docker', 'exec', 'soccer_oracle21', 'bash', '-c',
                f'echo "{sql}" | sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1'
            ], capture_output=True, text=True, cwd=r"d:\soccer_community")

if __name__ == "__main__":
    download_missing_clubs()
    update_database()
