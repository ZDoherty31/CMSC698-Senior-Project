import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate('/Users/zoekasules/Desktop/Senior Projects/senior-projects-e4df3-firebase-adminsdk-fbsvc-c28468482d.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

def renumber_entries(sport_id, subcategory_id, record_category_id):
    ref = db.collection(f'{sport_id}_records') \
            .document(subcategory_id) \
            .collection('records') \
            .document(record_category_id) \
            .collection('entries')

    docs = sorted(ref.get(), key=lambda d: d.to_dict().get('rank', 999))
    
    print(f"Found {len(docs)} documents")
    
    for i, doc in enumerate(docs, start=1):
        new_id = f"record_{str(i).zfill(2)}"
        if doc.id != new_id:
            print(f"Renaming {doc.id} → {new_id}")
            # Create new doc with correct ID
            ref.document(new_id).set(doc.to_dict())
            # Delete old doc
            doc.reference.delete()
        else:
            print(f"  {doc.id} already correct")

    print("Done!")

# Change these to match what you want to fix
renumber_entries('softball', 'individual_career', 'walks')