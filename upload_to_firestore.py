import firebase_admin
from firebase_admin import credentials, firestore
import re
import os

try: 
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)
    db = firestore.client()
except Exception as e:
    print(f"Error initializing Firestore: {e}")
    exit(1)

text_dir = "."

allowed_sports = {"sb_records", "bsb_records"}

patterns = {
    # Special cases - these must come FIRST (most specific patterns first)
    "player_multiple_years": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+),\s*(\d{4}(?:\s*-\s*\d{2,4})?(?:,\s*\d{4}(?:\s*-\s*\d{2,4})?)+)\s*$",
        re.IGNORECASE
    ),
    "player_multiple_years_with_details": re.compile(
        r"^(\d+)\.?\s+([\d\.]+)\s*[–-]\s*([^,]+),\s*(\d{4}(?:\s*-\s*\d{2,4})?(?:,\s*\d{4}(?:\s*-\s*\d{2,4})?)+)\s*\(([^)]+)\)\s*$",
        re.IGNORECASE
    ),
    "game_with_parenthetical_info": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+),\s*(\d{4}(?:\s*-\s*\d{2,4})?)\s*\((.+?)\)\s+(.+)$",
        re.IGNORECASE
    ),
    
    # Game format with opponent that has state in parentheses
    "game_with_state_opponent": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+?)\s+(?:vs\.?|at)\s+([^,]+?\([A-Za-z\.]+\)),?\s*\(([^)]+)\)\s*$",
        re.IGNORECASE
    ),
    
    # Hits game format
    "hits_game_format": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+?)\s+(?:vs\.?|at)\s+([^(]+?)\s*\((\d+-\d+)\),?\s*\(([^)]+)\)\s*$",
        re.IGNORECASE
    ),
    
    # Team game format with value
    "team_game_with_value": re.compile(
        r"^(\d+)\.?\s+(\d+)\s+(?:vs\.?|at)\s*([^,]+),\s*(\d{1,2}/\d{1,2}/\d{2,4})\s*$",
        re.IGNORECASE
    ),
    
    # Team game format with dash (no vs.)
    "team_game_with_dash": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+),\s*(\d{1,2}/\d{1,2}/\d{2,4})\s*$",
        re.IGNORECASE
    ),
    
    "team_vs_format": re.compile(
        r"^(\d+)\.?\s+(\d+)\s+(?:vs\.?|at)\s+([^,]+),\s*\(([^)]+)\)\s*$",
        re.IGNORECASE
    ),
    
    # Year range with possible spaces
    "stat_year_range_with_spaces": re.compile(
        r"^(\d+)\.?\s+([\d\.]+)\s*[–-]\s*(\d{4})\s*-\s*(\d{2,4})\s*$",
        re.IGNORECASE
    ),
    
    "stat_year_only": re.compile(
        r"^(\d+)\.?\s+([\d\.]+)\s*[–-]\s*(\d{4})\s*$",
        re.IGNORECASE
    ),
    
    # Wins with record
    "wins_with_record": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+?),?\s*(\d{4})\s*\((\d+-\d+)\)\s*$",
        re.IGNORECASE
    ),
    
    "simple_player_year_no_value": re.compile(
        r"^(\d+)\s*[–-]\s*([^,]+),\s*(\d{4})\s*$",
        re.IGNORECASE
    ),
    "complex_game_list": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+),\s*(\d{4}),\s*(.+)$",
        re.IGNORECASE
    ),
    
    # Original patterns
    "ratio_stat": re.compile(
        r"^(\d+)\.?\s+(\d+/[\d\.]+)\s*[–-]\s*(.+?)\s*\(([^)]+)\)\s*$",
        re.IGNORECASE
    ),
    "game": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^–]+?)\s+(?:vs\.?|at)\s*([^(]+?)\s*\(([^)]+)\)\s*$",
        re.IGNORECASE
    ),
    "team": re.compile(
        r"^(\d+)\.?\s+(?:vs\.?|at)\s*([^,]+),\s*(\d{1,2}/\d{1,2}/\d{2,4})\s*$",
        re.IGNORECASE
    ),
    
    # Career
    "career": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+),\s*(\d{4}(?:\s*-\s*\d{2,4})?)\s*$",
        re.IGNORECASE
    ),
    
    "player_year": re.compile(
        r"^(\d+)\.?\s+(\d+)\s*[–-]\s*([^,]+),\s*(\d{4})\s*$",
        re.IGNORECASE
    ),
    "stat_with_year_and_details": re.compile(
        r"^(\d+)\.?\s+([\d\.]+)\s*[–-]\s*([^,]+),\s*(\d{4}(?:\s*-\s*\d{2,4})?)\s*\(([^)]+)\)\s*$",
        re.IGNORECASE
    ),
    "stat_with_details": re.compile(
        r"^(\d+)\.?\s+([\d\.]+)\s*[–-]\s*([^,\(]+?)\s*\(([^)]+)\)\s*$",
        re.IGNORECASE
    ),
    "stat_with_year": re.compile(
        r"^(\d+)\.?\s+([\d\.]+)\s*[–-]\s*([^,]+),\s*(\d{4}(?:\s*-\s*\d{2,4})?)\s*$",
        re.IGNORECASE
    ),
    "year_value": re.compile(
        r"^(\d+)\.?\s*[–-]\s*(\d{4})\s*$",
        re.IGNORECASE
    ),
    "simple": re.compile(
        r"^(\d+)\.?\s*[–-]\s*(.+)\s*$",
        re.IGNORECASE
    )
}

def sanitize(name):
    return (
        str(name)
        .replace("/", "_")
        .replace("\\", "_")
        .replace(".", "_")
        .replace("#", "_")
        .replace("$", "_")
        .replace("[", "_")
        .replace("]", "_")
        .strip()
    )

def is_major_category(line):
    if not line:
        return False
    clean = line.replace(" ", "").replace("_", "")
    return line.isupper() and len(line.split()) >= 2 and clean.isalpha()

def is_subcategory(line):
    if not line:
        return False
    if not line or line[0].isdigit():
        return False
    if line.isupper():
        return False
    if not line[0].isalpha():
        return False
    if len(line) > 100:
        return False
    return True

def is_record(line):
    if not line:
        return False
    return bool(re.match(r'^\d+\.?\s', line))

try: 
    for filename in os.listdir(text_dir):
        if not filename.endswith(".txt"):
            continue
        
        sport_name = os.path.splitext(filename)[0]
        if sport_name not in allowed_sports:
            continue

        print(f"\nProcessing file {filename}...")

        with open(os.path.join(text_dir, filename), "r", encoding = 'utf-8') as f:
            lines = [line.strip() for line in f.readlines() if line.strip()]

        sport_ref = db.collection('sports').document(sport_name)
        sport_ref.set({"sport_name": sport_name}, merge = True)

        major_category = None
        sub_category = None
        data_structure = {}

        for line in lines[1:]:
            if is_major_category(line):
                major_category = line.replace(" ", "_")
                data_structure[major_category] = {}
                sub_category = None
                continue

            if is_subcategory(line):
                sub_category = line.replace(" ", "_")
                if major_category:
                    data_structure[major_category][sub_category] = []
                continue

            if not (major_category and sub_category):
                continue

            if is_record(line):
                matched = False

                for ptype, pattern in patterns.items():
                    m = pattern.match(line)
                    if not m:
                        continue 
                    
                    matched = True
                    groups = m.groups()
                    record = {"type": ptype, "raw_text": line}

                    if ptype == "player_multiple_years":
                        rank, value, player, years = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "years": years.strip()
                        })
                    
                    elif ptype == "player_multiple_years_with_details":
                        rank, value, player, years, details = groups
                        record.update({
                            "rank": int(rank),
                            "value": value.strip(),
                            "player": player.strip(),
                            "years": years.strip(),
                            "details": details.strip()
                        })
                    
                    elif ptype == "game_with_parenthetical_info":
                        rank, value, player, years, game_info, additional = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "years": years.strip(),
                            "game_info": game_info.strip(),
                            "additional": additional.strip()
                        })
                    
                    elif ptype == "game_with_state_opponent":
                        rank, value, player, opponent, date = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "opponent": opponent.strip(),
                            "date": date.strip()
                        })
                    
                    elif ptype == "hits_game_format":
                        rank, value, player, opponent, hit_record, date = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "opponent": opponent.strip(),
                            "hit_record": hit_record.strip(),
                            "date": date.strip()
                        })
                    
                    elif ptype == "team_game_with_value":
                        rank, value, opponent, date = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "opponent": opponent.strip(),
                            "date": date.strip()
                        })
                    
                    elif ptype == "team_game_with_dash":
                        rank, value, opponent, date = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "opponent": opponent.strip(),
                            "date": date.strip()
                        })
                    
                    elif ptype == "team_vs_format":
                        rank, value, opponent, date = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "opponent": opponent.strip(),
                            "date": date.strip()
                        })
                    
                    elif ptype == "stat_year_range_with_spaces":
                        rank, value, year_start, year_end = groups
                        record.update({
                            "rank": int(rank),
                            "value": value.strip(),
                            "years": f"{year_start}-{year_end}"
                        })
                    
                    elif ptype == "stat_year_only":
                        rank, value, year = groups
                        record.update({
                            "rank": int(rank),
                            "value": value.strip(),
                            "year": year.strip()
                        })
                    
                    elif ptype == "wins_with_record":
                        rank, value, player, year, win_record = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "year": year.strip(),
                            "win_record": win_record.strip()
                        })
                    
                    elif ptype == "simple_player_year_no_value":
                        rank, player, year = groups
                        record.update({
                            "rank": int(rank),
                            "player": player.strip(),
                            "year": year.strip()
                        })
                    
                    elif ptype == "complex_game_list":
                        rank, value, player, year, game_details = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "year": year.strip(),
                            "game_details": game_details.strip()
                        })
                    
                    elif ptype == "ratio_stat":
                        rank, ratio, info, details = groups
                        record.update({
                            "rank": int(rank),
                            "ratio": ratio.strip(),
                            "info": info.strip(),
                            "details": details.strip()
                        })
                    
                    elif ptype == "game":
                        rank, value, player, opponent, date = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "opponent": opponent.strip(),
                            "date": date.strip()
                        })
                    
                    elif ptype == "career":
                        rank, value, player, years = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "years": years.strip()
                        })

                    elif ptype == "team":
                        rank, opponent, date = groups
                        record.update({
                            "rank": int(rank),
                            "opponent": opponent.strip(), 
                            "date": date.strip()
                        })
                    
                    elif ptype == "player_year":
                        rank, value, player, year = groups
                        record.update({
                            "rank": int(rank),
                            "value": int(value),
                            "player": player.strip(),
                            "year": year.strip()
                        })
                    
                    elif ptype == "stat_with_year_and_details":
                        rank, value, player, year, details = groups
                        record.update({
                            "rank": int(rank),
                            "value": value.strip(),
                            "player": player.strip(),
                            "year": year.strip(),
                            "details": details.strip()
                        })
                    
                    elif ptype == "stat_with_details":
                        rank, value, player, details = groups
                        record.update({
                            "rank": int(rank),
                            "value": value.strip(),
                            "player": player.strip(),
                            "details": details.strip()
                        })
                    
                    elif ptype == "stat_with_year":
                        rank, value, player, year = groups
                        record.update({
                            "rank": int(rank),
                            "value": value.strip(),
                            "player": player.strip(),
                            "year": year.strip()
                        })
                    
                    elif ptype == "year_value":
                        rank, year = groups
                        record.update({
                            "rank": int(rank),
                            "year": year.strip()
                        })
                    
                    elif ptype == "simple":
                        rank, info = groups
                        record.update({
                            "rank": int(rank),
                            "info": info.strip()
                        })
                    
                    data_structure[major_category][sub_category].append(record)
                    break

                if not matched:
                    data_structure[major_category][sub_category].append({"type": "raw", "text": line})
                
        for major_cat, subcats in data_structure.items():
            safe_major = sanitize(major_cat)
            major_ref = sport_ref.collection("categories").document(safe_major)
            major_ref.set({"major_category": major_cat}, merge = True)

            for subcat, records in subcats.items():
                safe_subcat = sanitize(subcat)
                sub_ref = major_ref.collection("subcategories").document(safe_subcat)
                sub_ref.set({"subcategory_name": subcat}, merge = True)

                for i, record in enumerate(records, start = 1):
                    if "rank" not in record:
                        record["rank"] = i
                    sub_ref.collection("records").document(f"record_{i:03}").set(record)
                
                print(f" {major_cat} / {subcat}: {len(records)} records uploaded")

        print(f"Finished uploading {filename}")

    print("\nAll Baseball + Softball records uploaded successfully!!")

except Exception as e:
    print(f"\nError occurred: {e}")
    import traceback
    traceback.print_exc()

        