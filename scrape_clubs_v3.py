#!/usr/bin/env python3
import os
import requests
import time
import json
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

def get_wiki_image_list(club_name):
    """Get image list from Wikipedia API for a club"""
    try:
        search_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={club_name}&prop=images&format=json"
        resp = session.get(search_url, timeout=15)
        if resp.status_code == 200:
            data = resp.json()
            pages = data.get('query', {}).get('pages', {})
            for page in pages.values():
                images = page.get('images', [])
                for img in images:
                    title = img.get('title', '')
                    if 'logo' in title.lower() or 'crest' in title.lower() or title.endswith('.svg'):
                        return title
                if images:
                    return images[0].get('title')
    except Exception as e:
        print(f"    Wiki API error: {e}")
    return None

def get_wiki_file_url(file_title):
    """Get direct URL for a wiki file"""
    try:
        clean_title = file_title.replace(' ', '_')
        url = f"https://en.wikipedia.org/w/api.php?action=query&titles={clean_title}&prop=imageinfo&iiprop=url&format=json"
        resp = session.get(url, timeout=15)
        if resp.status_code == 200:
            data = resp.json()
            pages = data.get('query', {}).get('pages', {})
            for page in pages.values():
                imageinfo = page.get('imageinfo', [])
                if imageinfo:
                    return imageinfo[0].get('url')
    except Exception as e:
        print(f"    File URL error: {e}")
    return None

def search_bing_image(query):
    """Search Bing Images for a club logo"""
    try:
        search_url = f"https://www.bing.com/images/search?q={query.replace(' ', '+')}+logo+png"
        resp = session.get(search_url, headers={'User-Agent': headers['User-Agent']}, timeout=15)
        if resp.status_code == 200:
            matches = re.findall(r'src="(https://[^"]*?\.(?:png|jpg))"', resp.text)
            for url in matches[:5]:
                if 'logo' in url.lower() or 'crest' in url.lower():
                    return url
    except Exception as e:
        print(f"    Bing error: {e}")
    return None

MISSING_CLUBS = {
    5: ("Liverpool_F.C.", "Liverpool"),
    8: ("Villarreal_CF", "Villarreal"),
    9: ("Atletico_Madrid", "Atletico Madrid"),
    10: ("Real_Sociedad", "Real Sociedad"),
    12: ("Olympique_Lyon", "Lyon"),
    13: ("AS_Monaco_FC", "Monaco"),
    15: ("Stade_Rennais_FC", "Rennes"),
    20: ("Eintracht_Frankfurt", "Eintracht Frankfurt"),
    25: ("Atalanta_BC", "Atalanta"),
    90: ("Shandong_Taishan_FC", "Shandong"),
    91: ("Beijing_Guoan_FC", "Beijing Guoan"),
}

def download_missing_clubs():
    print("="*60)
    print("Downloading Missing Club Logos (Wikipedia API)")
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

        print(f"  Searching Wikipedia for images...")
        file_title = get_wiki_image_list(wiki_name)
        if file_title:
            print(f"  Found file: {file_title}")
            time.sleep(0.5)
            file_url = get_wiki_file_url(file_title)
            if file_url:
                print(f"  Trying: {file_url[:60]}...")
                if download_image(file_url, filepath):
                    downloaded = True
                time.sleep(0.5)

        if not downloaded:
            print(f"  Trying Bing search...")
            bing_url = search_bing_image(display_name)
            if bing_url:
                print(f"  Found: {bing_url[:60]}...")
                if download_image(bing_url, filepath):
                    downloaded = True
            time.sleep(1)

        if not downloaded:
            print(f"  [FAIL] Could not download logo for {display_name}")
            fail_count += 1
        else:
            success_count += 1

        time.sleep(0.5)

    print(f"\n{'='*60}")
    print(f"Missing Club Logos: {success_count} success, {fail_count} failed")
    print(f"{'='*60}")

    return success_count, fail_count

def update_database():
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
