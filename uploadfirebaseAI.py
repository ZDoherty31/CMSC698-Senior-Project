

import json
import os
import sys
from collections import defaultdict
import firebase_admin
from firebase_admin import credentials, firestore

SERVICE_ACCOUNT_KEY_PATH = "/Users/zoekasules/Desktop/Senior Projects/senior-projects-e4df3-firebase-adminsdk-fbsvc-c28468482d.json"
FIRESTORE_PROJECT_ID     = "senior-projects-e4df3"  
JSON_DIR                 = "."                        

SPORT_FILES = {
    "lu_wxc_records":    "wxc_records"
    
    # add new sports here when you finish the JSON files 
    # I add them as I clean the data. 
  
}
 
def safe_id(text: str) -> str:
    """Make a Firestore-safe document/collection ID."""
    for ch in r'\/.*[]~':
        text = text.replace(ch, "_")
    return text[:500]
 
 
# Firebase initialisation
 
def init_firebase():
    if not os.path.exists(SERVICE_ACCOUNT_KEY_PATH):
        print(f"\n[ERROR] Service account key not found: '{SERVICE_ACCOUNT_KEY_PATH}'")
        print("  Download it from Firebase Console → Project Settings → Service Accounts.")
        sys.exit(1)
 
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred, {"projectId": FIRESTORE_PROJECT_ID})
    return firestore.client()
 
 
# Load one JSON file
 
def load_json(filename: str) -> list:
    path = os.path.join(JSON_DIR, filename + ".json")
    if not os.path.exists(path):
        print(f"  [WARN] File not found, skipping: '{path}'")
        return []
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)
 
 
# Upload one sport
 
def upload_sport(db, collection: str, records: list) -> tuple:
    success, failure = 0, 0
 
    # Counter: (record_type, record_name) - next position number
    position_counters = defaultdict(int)
 
    for record in records:
        record_type = record.get("record_type")
        record_name = record.get("record_name")
 
        if not record_type or not record_name:
            print(f"    [SKIP] Missing record_type or record_name: {record}")
            failure += 1
            continue
 
        # Increment position for this group
        group_key = (safe_id(record_type), safe_id(record_name))
        position_counters[group_key] += 1
        doc_id = f"record_{str(position_counters[group_key]).zfill(2)}"
 
        # Ensure the record_type document exists (visible in the console)
        type_doc_ref = (
            db.collection(collection)
              .document(safe_id(record_type))
        )
        type_doc_ref.set({"record_type": record_type}, merge=True)
 
        # Ensure the record_name document exists inside the records subcollection
        name_doc_ref = (
            type_doc_ref
              .collection("records")
              .document(safe_id(record_name))
        )
        name_doc_ref.set({"record_name": record_name}, merge=True)
 
        # Write the actual record entry
        entry_ref = (
            name_doc_ref
              .collection("entries")
              .document(doc_id)
        )
 
        try:
            entry_ref.set(dict(record), merge=True)
            success += 1
        except Exception as exc:
            print(f"    [ERR] {collection}/{record_type}/{record_name}/{doc_id}: {exc}")
            failure += 1
 
    return success, failure
 
 
# Main
 
def main():
    print("=" * 60)
    print("  LU Sports Records → Firebase Firestore")
    print("=" * 60)
 
    print("\nInitialising Firebase…")
    db = init_firebase()
    print(f"Connected to project: {FIRESTORE_PROJECT_ID}\n")
 
    total_success = 0
    total_failure = 0
 
    for filename, collection in SPORT_FILES.items():
        records = load_json(filename)
        if not records:
            continue
 
        print(f"Uploading {collection:25s}  ({len(records):>4} records)…", end=" ", flush=True)
        ok, err = upload_sport(db, collection, records)
        total_success += ok
        total_failure += err
 
        status = f"{ok} ok" + (f", {err} errors" if err else "")
        print(status)
 
    print("\n" + "=" * 60)
    print(f"  Done — {total_success} uploaded, {total_failure} failed")
    print("=" * 60)
 
 
if __name__ == "__main__":
    main()