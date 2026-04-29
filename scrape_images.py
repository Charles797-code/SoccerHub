#!/usr/bin/env python3
import os
import sys
import requests
import time
import json
from urllib.parse import quote, unquote

UPLOADS_DIR = r"d:\soccer_community\backend\src\main\resources\static\uploads"
os.makedirs(UPLOADS_DIR, exist_ok=True)

CLUB_IMAGE_DIR = os.path.join(UPLOADS_DIR, "clubs")
PLAYER_IMAGE_DIR = os.path.join(UPLOADS_DIR, "players")
USER_IMAGE_DIR = os.path.join(UPLOADS_DIR, "users")
os.makedirs(CLUB_IMAGE_DIR, exist_ok=True)
os.makedirs(PLAYER_IMAGE_DIR, exist_ok=True)
os.makedirs(USER_IMAGE_DIR, exist_ok=True)

headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
}

def download_image(url, filepath, timeout=30):
    """Download image from URL and save to filepath"""
    if os.path.exists(filepath):
        print(f"  [SKIP] Already exists: {os.path.basename(filepath)}")
        return True
    try:
        response = requests.get(url, headers=headers, timeout=timeout, allow_redirects=True)
        if response.status_code == 200 and len(response.content) > 1000:
            with open(filepath, 'wb') as f:
                f.write(response.content)
            print(f"  [OK] Downloaded: {os.path.basename(filepath)} ({len(response.content)} bytes)")
            return True
        else:
            print(f"  [FAIL] HTTP {response.status_code}: {url}")
            return False
    except Exception as e:
        print(f"  [FAIL] {e}: {url}")
        return False

def get_wikipedia_image_url(club_name):
    """Get club logo URL from Wikipedia"""
    search_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={quote(club_name)}&prop=pageimages&format=json&pithumbsize=500"
    try:
        resp = requests.get(search_url, headers=headers, timeout=10)
        data = resp.json()
        pages = data.get('query', {}).get('pages', {})
        for page in pages.values():
            if 'thumbnail' in page:
                return page['thumbnail']['source']
    except Exception as e:
        print(f"    Wikipedia search error: {e}")
    return None

def get_wikipedia_player_image_url(player_name):
    """Get player image URL from Wikipedia"""
    search_url = f"https://en.wikipedia.org/w/api.php?action=query&titles={quote(player_name)}&prop=pageimages&format=json&pithumbsize=500"
    try:
        resp = requests.get(search_url, headers=headers, timeout=10)
        data = resp.json()
        pages = data.get('query', {}).get('pages', {})
        for page in pages.values():
            if 'thumbnail' in page:
                return page['thumbnail']['source']
    except Exception as e:
        print(f"    Wikipedia search error: {e}")
    return None

CLUBS = [
    (1, "Arsenal FC", "Arsenal"),
    (2, "Manchester City FC", "Manchester City"),
    (3, "Manchester United FC", "Manchester United"),
    (4, "Chelsea FC", "Chelsea"),
    (5, "Liverpool FC", "Liverpool"),
    (6, "FC Barcelona", "Barcelona"),
    (7, "Real Madrid CF", "Real Madrid"),
    (8, "Villarreal CF", "Villarreal"),
    (9, "Atlético Madrid", "Atletico Madrid"),
    (10, "Real Sociedad", "Real Sociedad"),
    (11, "Paris Saint-Germain FC", "Paris Saint-Germain"),
    (12, "Olympique Lyon", "Lyon"),
    (13, "AS Monaco FC", "Monaco"),
    (14, "Olympique de Marseille", "Marseille"),
    (15, "Stade Rennais", "Rennes"),
    (16, "FC Bayern Munich", "Bayern Munich"),
    (17, "Borussia Dortmund", "Dortmund"),
    (18, "RB Leipzig", "Leipzig"),
    (19, "VfB Stuttgart", "Stuttgart"),
    (20, "Eintracht Frankfurt", "Eintracht Frankfurt"),
    (21, "Inter Milan", "Inter Milan"),
    (22, "AC Milan", "AC Milan"),
    (23, "SSC Napoli", "Napoli"),
    (24, "Juventus FC", "Juventus"),
    (25, "Atalanta BC", "Atalanta"),
    (90, "Shandong Taishan FC", "Shandong Taishan"),
    (91, "Beijing Guoan FC", "Beijing Guoan"),
]

CLUB_DIRECT_URLS = {
    1: "https://upload.wikimedia.org/wikipedia/en/5/53/Arsenal_FC.svg",
    2: "https://upload.wikimedia.org/wikipedia/en/e/eb/Manchester_City_FC_badge.svg",
    3: "https://upload.wikimedia.org/wikipedia/en/7/7a/Manchester_United_FC_crest.svg",
    4: "https://upload.wikimedia.org/wikipedia/en/c/cc/Chelsea_FC.svg",
    5: "https://upload.wikimedia.org/wikipedia/en/0/0c/Liverpool_FC.svg",
    6: "https://upload.wikimedia.org/wikipedia/en/4/47/FC_Barcelona_%28crest%29.svg",
    7: "https://upload.wikimedia.org/wikipedia/en/5/56/Real_Madrid_CF.svg",
    8: "https://upload.wikimedia.org/wikipedia/en/7/7f/Villarreal_CF_%28no_text%29.svg",
    9: "https://upload.wikimedia.org/wikipedia/en/f/f4/Atletico_Madrid_2017_logo.svg",
    10: "https://upload.wikimedia.org/wikipedia/en/2/2d/Real_Sociedad_logo.svg",
    11: "https://upload.wikimedia.org/wikipedia/en/a/a7/Paris_Saint-Germain_F.C..svg",
    12: "https://upload.wikimedia.org/wikipedia/en/6/6d/Olympique_Lyon.svg",
    13: "https://upload.wikimedia.org/wikipedia/en/b/bc/AS_Monaco_FC.svg",
    14: "https://upload.wikimedia.org/wikipedia/en/4/4f/Olympique_de_Marseille_logo.svg",
    15: "https://upload.wikimedia.org/wikipedia/en/8/86/Stade_Rennais_FC.svg",
    16: "https://upload.wikimedia.org/wikipedia/commons/1/1b/FC_Bayern_M%C3%BCnchen_logo_%282017%29.svg",
    17: "https://upload.wikimedia.org/wikipedia/commons/6/67/Borussia_Dortmund_logo.svg",
    18: "https://upload.wikimedia.org/wikipedia/en/0/04/RB_Leipzig_2014_logo.svg",
    19: "https://upload.wikimedia.org/wikipedia/commons/e/eb/VfB_Stuttgart_logo.svg",
    20: "https://upload.wikimedia.org/wikipedia/commons/0/0b/Eintracht_Frankfurt_Logo.svg",
    21: "https://upload.wikimedia.org/wikipedia/commons/e/e9/FC_Internazionale_Milano_2021.svg",
    22: "https://upload.wikimedia.org/wikipedia/en/0/05/AC_Milan.svg",
    23: "https://upload.wikimedia.org/wikipedia/en/2/2d/SSC_Neapolitana_2019_logo.svg",
    24: "https://upload.wikimedia.org/wikipedia/commons/b/bc/Juventus_FC_2017_icon_-_Bishop.svg",
    25: "https://upload.wikimedia.org/wikipedia/en/9/93/Atalanta_BC_2016.svg",
}

CLUB_LOGO_RESULTS = {}

def download_club_logos():
    """Download club logo images"""
    print("\n" + "="*60)
    print("Downloading Club Logos...")
    print("="*60)

    success_count = 0
    fail_count = 0

    for club_id, wiki_name, club_name in CLUBS:
        print(f"\n[{club_id}] {club_name}:")

        if club_id in CLUB_DIRECT_URLS:
            url = CLUB_DIRECT_URLS[club_id]
            filepath = os.path.join(CLUB_IMAGE_DIR, f"club_{club_id}.png")
            if download_image(url, filepath):
                CLUB_LOGO_RESULTS[club_id] = f"/uploads/clubs/club_{club_id}.png"
                success_count += 1
            else:
                print(f"  Trying Wikipedia API...")
                url = get_wikipedia_image_url(wiki_name)
                if url and download_image(url, filepath):
                    CLUB_LOGO_RESULTS[club_id] = f"/uploads/clubs/club_{club_id}.png"
                    success_count += 1
                else:
                    fail_count += 1
        else:
            url = get_wikipedia_image_url(wiki_name)
            if url:
                filepath = os.path.join(CLUB_IMAGE_DIR, f"club_{club_id}.png")
                if download_image(url, filepath):
                    CLUB_LOGO_RESULTS[club_id] = f"/uploads/clubs/club_{club_id}.png"
                    success_count += 1
                else:
                    fail_count += 1
            else:
                print(f"  [FAIL] Could not find image URL")
                fail_count += 1

        time.sleep(0.3)

    print(f"\nClub Logos: {success_count} success, {fail_count} failed")
    return success_count, fail_count

PLAYERS = []

def load_players():
    """Load player data from database"""
    global PLAYERS
    print("Loading player data from database...")

    try:
        import subprocess
        result = subprocess.run([
            'docker', 'exec', 'soccer_oracle21', 'bash', '-c',
            'sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @/dev/stdin <<\'EOF\'\n'
            'SET PAGESIZE 500\n'
            'SET LINESIZE 200\n'
            'SPOOL /tmp/players.txt\n'
            'SELECT PLAYER_ID || \',\' || NAME || \',\' || NVL(NAME_CN, \'\') || \',\' || CLUB_ID FROM PLAYER ORDER BY PLAYER_ID;\n'
            'SPOOL OFF\n'
            'EXIT;\n'
            'EOF'
        ], capture_output=True, text=True, cwd=r"d:\soccer_community")

        if os.path.exists(r'd:\soccer_community\tmp\players.txt'):
            os.remove(r'd:\soccer_community\tmp\players.txt')

        result = subprocess.run([
            'docker', 'exec', 'soccer_oracle21', 'bash', '-c',
            'sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1 @/dev/stdin <<\'EOF\'\n'
            'SET PAGESIZE 500\n'
            'SPOOL /tmp/players.txt\n'
            'SELECT PLAYER_ID || \',\' || NAME || \',\' || NVL(NAME_CN, \'\') || \',\' || CLUB_ID FROM PLAYER ORDER BY PLAYER_ID;\n'
            'SPOOL OFF\n'
            'EXIT;\n'
            'EOF'
        ], capture_output=True, text=True, cwd=r"d:\soccer_community")

        spool_result = subprocess.run([
            'docker', 'exec', 'soccer_oracle21', 'cat', '/tmp/players.txt'
        ], capture_output=True, text=True)

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
                        PLAYERS.append({
                            'player_id': player_id,
                            'name': name,
                            'name_cn': name_cn,
                            'club_id': club_id
                        })
                    except:
                        pass

        print(f"Loaded {len(PLAYERS)} players")

    except Exception as e:
        print(f"Error loading players: {e}")
        sys.exit(1)

PLAYER_DIRECT_URLS = {
    1: "https://upload.wikimedia.org/wikipedia/commons/4/41/Bukayo_Saka_2021.jpg",
    2: "https://upload.wikimedia.org/wikipedia/commons/a/ae/Martin_%C3%98degaard_2021.jpg",
    3: "https://upload.wikimedia.org/wikipedia/commons/4/49/Declan_Rice_2023.jpg",
    4: "https://upload.wikimedia.org/wikipedia/commons/4/4a/William_Saliba_2022.jpg",
    5: "https://upload.wikimedia.org/wikipedia/commons/e/eb/Gabriel_Martinelli_2021.jpg",
    6: "https://upload.wikimedia.org/wikipedia/commons/6/6a/Kai_Havertz_2021.jpg",
    7: "https://upload.wikimedia.org/wikipedia/commons/2/28/David_Raya_2023.jpg",
    8: "https://upload.wikimedia.org/wikipedia/commons/3/33/Ben_White_2022.jpg",
    9: "https://upload.wikimedia.org/wikipedia/commons/b/b4/Erling_Haaland_2020.jpg",
    10: "https://upload.wikimedia.org/wikipedia/commons/a/a9/Kevin_De_Bruyne_2020.jpg",
    11: "https://upload.wikimedia.org/wikipedia/commons/a/a1/Phil_Foden_2021.jpg",
    12: "https://upload.wikimedia.org/wikipedia/commons/4/4d/Rodri_2021.jpg",
    13: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Jack_Grealish_2021.jpg",
    14: "https://upload.wikimedia.org/wikipedia/commons/1/1a/Bernardo_Silva_2021.jpg",
    15: "https://upload.wikimedia.org/wikipedia/commons/a/ab/Ederson_2021.jpg",
    16: "https://upload.wikimedia.org/wikipedia/commons/f/f8/Kyle_Walker_2022.jpg",
    17: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Harry_Maguire_2020.jpg",
    18: "https://upload.wikimedia.org/wikipedia/commons/a/a4/Mason_Mount_2021.jpg",
    19: "https://upload.wikimedia.org/wikipedia/commons/6/64/Marcus_Rashford_2022.jpg",
    20: "https://upload.wikimedia.org/wikipedia/commons/f/f9/Jadon_Sancho_2021.jpg",
    21: "https://upload.wikimedia.org/wikipedia/commons/8/80/Vinicius_Jr_2020.jpg",
    22: "https://upload.wikimedia.org/wikipedia/commons/4/43/Jude_Bellingham_2023.jpg",
    23: "https://upload.wikimedia.org/wikipedia/commons/6/6c/Kylian_Mbapp%C3%A9_2023.jpg",
    24: "https://upload.wikimedia.org/wikipedia/commons/a/a7/Rodrygo_2022.jpg",
    25: "https://upload.wikimedia.org/wikipedia/commons/4/49/Eduardo_Camavinga_2021.jpg",
    26: "https://upload.wikimedia.org/wikipedia/commons/f/f2/Toni_Kroos_2020.jpg",
    27: "https://upload.wikimedia.org/wikipedia/commons/3/3e/Thibaut_Courtois_2022.jpg",
    28: "https://upload.wikimedia.org/wikipedia/commons/4/4f/Antonio_R%C3%BCdiger_2022.jpg",
    29: "https://upload.wikimedia.org/wikipedia/commons/4/47/Pedri_2021.jpg",
    30: "https://upload.wikimedia.org/wikipedia/commons/4/42/Lamine_Yamal_2023.jpg",
    31: "https://upload.wikimedia.org/wikipedia/commons/9/90/Lewandowski_2021.jpg",
    32: "https://upload.wikimedia.org/wikipedia/commons/4/4e/Frenkie_de_Jong_2021.jpg",
    33: "https://upload.wikimedia.org/wikipedia/commons/b/b2/Raphinha_2022.jpg",
    34: "https://upload.wikimedia.org/wikipedia/commons/4/45/Gavi_2022.jpg",
    35: "https://upload.wikimedia.org/wikipedia/commons/4/49/Marc-Andr%C3%A9_ter_Stegen_2020.jpg",
    36: "https://upload.wikimedia.org/wikipedia/commons/8/89/Ronald_Araujo_2022.jpg",
    37: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Lautaro_Martinez_2021.jpg",
    38: "https://upload.wikimedia.org/wikipedia/commons/c/c7/Havertz_2022.jpg",
    39: "https://upload.wikimedia.org/wikipedia/commons/4/4f/Osimhen_2022.jpg",
    40: "https://upload.wikimedia.org/wikipedia/commons/9/94/Ciro_Immobile_2021.jpg",
    41: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Berardi_2021.jpg",
    42: "https://upload.wikimedia.org/wikipedia/commons/4/46/Raspadori_2022.jpg",
    43: "https://upload.wikimedia.org/wikipedia/commons/6/60/Sander_Bergen_2022.jpg",
    44: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Giroud_2021.jpg",
    45: "https://upload.wikimedia.org/wikipedia/commons/4/45/Thuram_2021.jpg",
    46: "https://upload.wikimedia.org/wikipedia/commons/9/93/Anthony_Martial_2022.jpg",
    47: "https://upload.wikimedia.org/wikipedia/commons/6/65/Coman_2021.jpg",
    48: "https://upload.wikimedia.org/wikipedia/commons/a/a8/Koopmeiners_2022.jpg",
    49: "https://upload.wikimedia.org/wikipedia/commons/4/42/Teun_Zubimendi_2022.jpg",
    50: "https://upload.wikimedia.org/wikipedia/commons/6/64/Merino_2021.jpg",
    51: "https://upload.wikimedia.org/wikipedia/commons/4/47/Le_Normand_2022.jpg",
    52: "https://upload.wikimedia.org/wikipedia/commons/4/43/Cucurella_2021.jpg",
    53: "https://upload.wikimedia.org/wikipedia/commons/4/49/Kepa_Arrizabalaga_2021.jpg",
    54: "https://upload.wikimedia.org/wikipedia/commons/9/9f/Not_Yours_2022.jpg",
    55: "https://upload.wikimedia.org/wikipedia/commons/8/8a/City_Players_2022.jpg",
    56: "https://upload.wikimedia.org/wikipedia/commons/6/64/Ederson_2021.jpg",
    57: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Gvardiol_2023.jpg",
    58: "https://upload.wikimedia.org/wikipedia/commons/9/90/Gundogan_2021.jpg",
    59: "https://upload.wikimedia.org/wikipedia/commons/4/47/Kovacic_2021.jpg",
    60: "https://upload.wikimedia.org/wikipedia/commons/4/49/Silva_2021.jpg",
    61: "https://upload.wikimedia.org/wikipedia/commons/4/4a/Bruno_Fernandes_2020.jpg",
    62: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Fernandes_2022.jpg",
    63: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Maguire_2021.jpg",
    64: "https://upload.wikimedia.org/wikipedia/commons/9/93/Martial_2022.jpg",
    65: "https://upload.wikimedia.org/wikipedia/commons/6/65/Rashford_2022.jpg",
    66: "https://upload.wikimedia.org/wikipedia/commons/4/45/Mount_2021.jpg",
    67: "https://upload.wikimedia.org/wikipedia/commons/f/f9/Sancho_2021.jpg",
    68: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Hojlund_2023.jpg",
    69: "https://upload.wikimedia.org/wikipedia/commons/6/60/Antony_2022.jpg",
    70: "https://upload.wikimedia.org/wikipedia/commons/9/94/Onana_2023.jpg",
    71: "https://upload.wikimedia.org/wikipedia/commons/4/42/Casemiro_2021.jpg",
    72: "https://upload.wikimedia.org/wikipedia/commons/4/4f/Varane_2021.jpg",
    73: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Licha_2022.jpg",
    74: "https://upload.wikimedia.org/wikipedia/commons/4/46/Shaw_2021.jpg",
    75: "https://upload.wikimedia.org/wikipedia/commons/4/49/Dalot_2022.jpg",
    76: "https://upload.wikimedia.org/wikipedia/commons/8/80/Vinicius_2020.jpg",
    77: "https://upload.wikimedia.org/wikipedia/commons/4/43/Bellingham_2023.jpg",
    78: "https://upload.wikimedia.org/wikipedia/commons/6/6c/Mbappe_2023.jpg",
    79: "https://upload.wikimedia.org/wikipedia/commons/a/a7/Rodrygo_2022.jpg",
    80: "https://upload.wikimedia.org/wikipedia/commons/4/49/Camavinga_2021.jpg",
    81: "https://upload.wikimedia.org/wikipedia/commons/f/f2/Toni_Kroos_2020.jpg",
    82: "https://upload.wikimedia.org/wikipedia/commons/3/3e/Thibaut_Courtois_2022.jpg",
    83: "https://upload.wikimedia.org/wikipedia/commons/4/4f/Antonio_Rudiger_2022.jpg",
    84: "https://upload.wikimedia.org/wikipedia/commons/4/47/Pedri_2021.jpg",
    85: "https://upload.wikimedia.org/wikipedia/commons/4/42/Lamine_Yamal_2023.jpg",
    86: "https://upload.wikimedia.org/wikipedia/commons/9/90/Lewandowski_2021.jpg",
    87: "https://upload.wikimedia.org/wikipedia/commons/4/4e/Frenkie_de_Jong_2021.jpg",
    88: "https://upload.wikimedia.org/wikipedia/commons/b/b2/Raphinha_2022.jpg",
    89: "https://upload.wikimedia.org/wikipedia/commons/4/45/Gavi_2022.jpg",
    90: "https://upload.wikimedia.org/wikipedia/commons/4/49/Marc-Andre-ter_Stegen_2020.jpg",
    91: "https://upload.wikimedia.org/wikipedia/commons/8/89/Ronald_Araujo_2022.jpg",
    92: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Lautaro_Martinez_2021.jpg",
    93: "https://upload.wikimedia.org/wikipedia/commons/c/c7/Havertz_2022.jpg",
    94: "https://upload.wikimedia.org/wikipedia/commons/4/4f/Osimhen_2022.jpg",
    95: "https://upload.wikimedia.org/wikipedia/commons/9/94/Ciro_Immobile_2021.jpg",
    96: "https://upload.wikimedia.org/wikipedia/commons/4/4c/Berardi_2021.jpg",
    97: "https://upload.wikimedia.org/wikipedia/commons/4/46/Raspadori_2022.jpg",
    98: "https://upload.wikimedia.org/wikipedia/commons/6/60/Sander_Bergen_2022.jpg",
    99: "https://upload.wikimedia.org/wikipedia/commons/8/8a/Giroud_2021.jpg",
    100: "https://upload.wikimedia.org/wikipedia/commons/4/45/Thuram_2021.jpg",
}

def download_player_images():
    """Download player headshot images"""
    print("\n" + "="*60)
    print("Downloading Player Images...")
    print("="*60)

    success_count = 0
    fail_count = 0
    results = {}

    for i, player in enumerate(PLAYERS):
        player_id = player['player_id']
        name = player['name']
        name_cn = player['name_cn']

        if (i + 1) % 10 == 0:
            print(f"\nProgress: {i + 1}/{len(PLAYERS)} players processed...")

        print(f"\n[{player_id}] {name} ({name_cn}):")

        if player_id in PLAYER_DIRECT_URLS:
            url = PLAYER_DIRECT_URLS[player_id]
            filepath = os.path.join(PLAYER_IMAGE_DIR, f"player_{player_id}.jpg")
            if download_image(url, filepath):
                results[player_id] = f"/uploads/players/player_{player_id}.jpg"
                success_count += 1
            else:
                url = get_wikipedia_player_image_url(name)
                if url:
                    filepath = os.path.join(PLAYER_IMAGE_DIR, f"player_{player_id}.jpg")
                    if download_image(url, filepath):
                        results[player_id] = f"/uploads/players/player_{player_id}.jpg"
                        success_count += 1
                    else:
                        fail_count += 1
                else:
                    fail_count += 1
        else:
            url = get_wikipedia_player_image_url(name)
            if url:
                filepath = os.path.join(PLAYER_IMAGE_DIR, f"player_{player_id}.jpg")
                if download_image(url, filepath):
                    results[player_id] = f"/uploads/players/player_{player_id}.jpg"
                    success_count += 1
                else:
                    fail_count += 1
            else:
                print(f"  [SKIP] Could not find image URL for {name}")
                fail_count += 1

        time.sleep(0.2)

    print(f"\nPlayer Images: {success_count} success, {fail_count} failed")
    return results

def update_database_club_logos(results):
    """Update club logo URLs in database"""
    print("\n" + "="*60)
    print("Updating Club Logo URLs in Database...")
    print("="*60)

    import subprocess

    for club_id, url in results.items():
        sql = f"UPDATE CLUB SET LOGO_URL = '{url}' WHERE CLUB_ID = {club_id};"
        print(f"  Club {club_id}: {url}")

        result = subprocess.run([
            'docker', 'exec', 'soccer_oracle21', 'bash', '-c',
            f'echo "{sql}" | sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1'
        ], capture_output=True, text=True, cwd=r"d:\soccer_community")

    print(f"Updated {len(results)} club logo URLs")

def update_database_player_avatars(results):
    """Update player avatar URLs in database"""
    print("\n" + "="*60)
    print("Updating Player Avatar URLs in Database...")
    print("="*60)

    import subprocess

    count = 0
    for player_id, url in results.items():
        sql = f"UPDATE PLAYER SET AVATAR_URL = '{url}' WHERE PLAYER_ID = {player_id};"
        count += 1

        if count % 20 == 0:
            print(f"  Updated {count}/{len(results)} players...")

        result = subprocess.run([
            'docker', 'exec', 'soccer_oracle21', 'bash', '-c',
            f'echo "{sql}" | sqlplus soccerhub/soccerhub2026@localhost:1521/XEPDB1'
        ], capture_output=True, text=True, cwd=r"d:\soccer_community")

    print(f"Updated {count} player avatar URLs")

def main():
    print("="*60)
    print("SoccerHub Image Scraper")
    print("="*60)
    print(f"Uploads directory: {UPLOADS_DIR}")

    load_players()

    club_success, club_fail = download_club_logos()
    player_results = download_player_images()

    update_database_club_logos(CLUB_LOGO_RESULTS)
    update_database_player_avatars(player_results)

    print("\n" + "="*60)
    print("Image Scraping Complete!")
    print("="*60)
    print(f"Club Logos: {club_success} success, {club_fail} failed")
    print(f"Player Images: {len(player_results)} success")

    with open(r'd:\soccer_community\image_results.json', 'w') as f:
        json.dump({
            'clubs': CLUB_LOGO_RESULTS,
            'players': player_results
        }, f, indent=2)
    print(f"\nResults saved to image_results.json")

if __name__ == "__main__":
    main()
