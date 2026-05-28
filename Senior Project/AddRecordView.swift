//
//  AddRecordView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 5/20/26.
//

import SwiftUI
import FirebaseFirestore

struct AddRecordView: View {
    let sportId: String
    let subcategoryId: String
    let recordCategoryId: String
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var playerName = ""
    @State private var value = ""
    @State private var rank = ""
    @State private var years = ""
    @State private var date = ""
    @State private var opponent = ""
    @State private var isSaving = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Info")) {
                    TextField("Player Name", text: $playerName)
                    TextField("Value", text: $value)
                    TextField("Rank", text: $rank)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Additional Info (Optional)")) {
                    TextField("Years (e.g. 2022-25)", text: $years)
                    TextField("Date (e.g. 2024-04-06)", text: $date)
                    TextField("Opponent", text: $opponent)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            .navigationTitle("Add Record")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveRecord() }
                        .disabled(playerName.isEmpty || value.isEmpty || rank.isEmpty || isSaving)
                }
            }
        }
    }

    private func saveRecord() {
        guard !playerName.isEmpty, !value.isEmpty, let rankInt = Int(rank) else {
            errorMessage = "Please fill in player name, value and rank."
            return
        }

        isSaving = true
        let db = Firestore.firestore()
        let ref = db.collection("\(sportId)_records")
            .document(subcategoryId)
            .collection("records")
            .document(recordCategoryId)
            .collection("entries")

        // Fetch all existing records first
        ref.getDocuments { snap, err in
            if let err = err {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load records: \(err.localizedDescription)"
                    self.isSaving = false
                }
                return
            }

            guard let snap = snap else { return }

            let batch = db.batch()

            // Shift all records with rank >= new rank up by 1
            for doc in snap.documents {
                let d = doc.data()
                if let existingRank = d["rank"] as? Int, existingRank >= rankInt {
                    batch.updateData(["rank": existingRank + 1], forDocument: doc.reference)
                }
            }

            // Generate new doc ID based on count
            let count = snap.documents.count + 1
            let docId = "record_\(String(format: "%02d", count))"

            // Build new record data
            var data: [String: Any] = [
                "name": playerName,
                "value": value,
                "rank": rankInt,
                "record_name": recordCategoryId,
                "record_type": subcategoryId,
            ]
            if !years.isEmpty { data["years"] = years }
            if !date.isEmpty { data["date"] = date }
            if !opponent.isEmpty { data["opponent"] = opponent }

            // Add new record to batch
            let newDocRef = ref.document(docId)
            batch.setData(data, forDocument: newDocRef)

            // Commit batch — updates existing ranks AND adds new record in one operation
            batch.commit { err in
                DispatchQueue.main.async {
                    self.isSaving = false
                    if let err = err {
                        self.errorMessage = "Failed to save: \(err.localizedDescription)"
                    } else {
                        self.onSave()
                        self.dismiss()
                    }
                }
            }
        }
    }
}
