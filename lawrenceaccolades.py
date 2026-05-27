import json
import os
import sys
from collections import defaultdict
import firebase_admin
from firebase_admin import credentials, firestore

# Configuration

SERVICE_ACCOUNT_KEY_PATH = "/Users/zoekasules/Desktop/Senior Projects/senior-projects-e4df3-firebase-adminsdk-fbsvc-c28468482d.json"
FIRESTORE_PROJECT_ID     = "senior-projects-e4df3"
JSON_FILE                = "lawrence_accolades_complete.json"

# Maps sport names in the JSON to Firestore collection names
SPORT_MAP = {
    "Baseball":               "baseball_records",
    "Football":               "football_records",
    "Men's Basketball":       "mbb_records",
    "Women's Basketball":     "wbb_records",
    "Men's Cross Country":    "mxc_records",
    "Women's Cross Country":  "wxc_records",
    "Men's Track & Field":    "mtrack_records",
    "Women's Track & Field":  "wtrack_records",
    "Men's Soccer":           "msoc_records",
    "Women's Soccer":         "wsoc_records",
    "Men's Hockey":           "mhoc_records",
    "Women's Hockey":         "whoc_records",
    "Men's Tennis":           "mtennis_records",
    "Women's Tennis":         "wtennis_records",
    "Volleyball":             "vball_records",
    "Women's Softball":       "softball_records",
}

def categorize(accolade: str) -> str:
    """Map an accolade string to a Firestore subcategory."""
    a = accolade.lower()
    if any(x in a for x in ["all-american", "nfca all-american", "ncaa all-american", "cosida academic all-american"]):
        return "all_american"
    if any(x in a for x in ["all-midwest conference", "all-mwc", "3-time all-midwest", "4-time all-midwest", "mwc conference champion"]):
        return "all_conference"
    if any(x in a for x in ["all-region", "nfca all-great lakes region"]):
        return "all_region"
    if any(x in a for x in ["scholar athlete", "scholar-athlete", "ita scholar", "nfca scholar", "ustfccca all-academic"]):
        return "scholar_athletes"
    if any(x in a for x in ["coach of the year", "coaching staff of the year"]):
        return "coach_of_the_year"
    if "newcomer of the year" in a:
        return "newcomer_of_the_year"
    if any(x in a for x in ["ncaa championship appearance"]):
        return "ncaa_championship"
    if any(x in a for x in ["individual champion", "conference champion", "team champions", "wisconsin intercollegiate"]):
        return "conference_champions"
    return "other"

# Firebase 

def init_firebase():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"\n[ERROR] Service account key not found: '{SERVICE_ACCOUNT_KEY_PATH}'")
        sys.exit(1)
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred, {"projectId": FIRESTORE_PROJECT_ID})
    return firestore.client()

def load_json(filepath: str) -> list:
    if not os.path.exists(filepath):
        print(f"[ERROR] File not found: '{filepath}'")
        sys.exit(1)
    with open(filepath, "r", encoding="utf-8") as fh:
        return json.load(fh)

# Upload 

def upload_accolades(db, data: list) -> tuple:
    success, failure = 0, 0

    by_sport = defaultdict(lambda: defaultdict(list))
    for entry in data:
        sport = entry.get("sport")
        if not sport or sport not in SPORT_MAP:
            print(f"  [SKIP] Unknown sport: {entry}")
            failure += 1
            continue
        subcat = categorize(entry.get("accolade", ""))
        by_sport[sport][subcat].append(entry)

    for sport, subcats in by_sport.items():
        collection = SPORT_MAP[sport]
        total = sum(len(v) for v in subcats.values())
        print(f"\n  {sport} ({total} accolades):")

        # Ensure the accolades document exists
        accolades_ref = db.collection(collection).document("accolades")
        accolades_ref.set({"type": "accolades"}, merge=True)

        for subcat, entries in subcats.items():
            print(f"    {subcat} ({len(entries)})...", end=" ", flush=True)
            counter = 0
            ok = 0
            err = 0

            # Ensure the subcategory document exists
            subcat_ref = accolades_ref.collection(subcat).document("info")
            subcat_ref.set({"subcategory": subcat}, merge=True)

            for entry in entries:
                counter += 1
                doc_id = f"accolade_{str(counter).zfill(3)}"

                doc_data = {
                    "player_name": entry.get("player_name", ""),
                    "accolade":    entry.get("accolade", ""),
                    "year":        entry.get("year", ""),
                    "sport":       sport,
                    "subcategory": subcat,
                }
                if "conference" in entry:
                    doc_data["conference"] = entry["conference"]

                try:
                    accolades_ref \
                        .collection(subcat) \
                        .document(doc_id) \
                        .set(doc_data)
                    ok += 1
                except Exception as exc:
                    print(f"\n      [ERR] {collection}/accolades/{subcat}/{doc_id}: {exc}")
                    err += 1

            success += ok
            failure += err
            print(f"{ok} ok" + (f", {err} errors" if err else ""))

    return success, failure

# Main

def main():
    print("=" * 60)
    print("  LU Accolades -> Firebase Firestore")
    print("=" * 60)

    print("\nInitialising Firebase...")
    db = init_firebase()
    print(f"Connected to project: {FIRESTORE_PROJECT_ID}\n")

    data = load_json(JSON_FILE)
    print(f"Loaded {len(data)} accolades from {JSON_FILE}")

    ok, err = upload_accolades(db, data)

    print("\n" + "=" * 60)
    print(f"  Done — {ok} uploaded, {err} failed")
    print("=" * 60)

if __name__ == "__main__":
    main()
