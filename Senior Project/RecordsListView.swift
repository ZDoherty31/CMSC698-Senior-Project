//
//  RecordsListView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 05/15/26.
//

import SwiftUI
import FirebaseFirestore

struct RecordRowView: View {
    let record: RecordItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.player)
                    .font(.headline)
                Spacer()
                Text("Value: \(record.value)")
                    .font(.subheadline)
            }
            Text("Rank: \(record.rank)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            if let years = record.years {
                Text("Years: \(years)").font(.caption).foregroundColor(.secondary)
            }
            if let date = record.date {
                Text("Date: \(date)").font(.caption).foregroundColor(.secondary)
            }
            if let opponent = record.opponent {
                Text("Opponent: \(opponent)").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct RecordsListView: View {
    let sportId: String
    let subcategoryId: String
    let recordCategoryId: String

    @EnvironmentObject var authVM: AuthViewModel
    @State private var records: [RecordItem] = []
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showingAddRecord = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading records...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            } else if records.isEmpty {
                Text("No records found.").foregroundColor(.gray)
            } else {
                let _ = print("RecordsListView isAdmin: \(authVM.isAdmin)")
                List {
                    ForEach(records, id: \.docId) { r in
                        RecordRowView(record: r)
                    }
                    .onDelete(perform: { offsets in
                        if authVM.isAdmin {
                            deleteRecord(at: offsets)
                        }
                    })
                    if authVM.isAdmin {
                        Button(action: { showingAddRecord = true }) {
                            Label("Add Record", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .id(authVM.isAdmin)
        .navigationTitle(recordCategoryId.replacingOccurrences(of: "_", with: " ").capitalized)
        .sheet(isPresented: $showingAddRecord) {
            AddRecordView(
                sportId: sportId,
                subcategoryId: subcategoryId,
                recordCategoryId: recordCategoryId
            ) {
                loadRecords()
            }
        }
        .onAppear(perform: loadRecords)
    }
    private func deleteRecord(at offsets: IndexSet) {
        let db = Firestore.firestore()
        let ref = db.collection("\(sportId)_records")
            .document(subcategoryId)
            .collection("records")
            .document(recordCategoryId)
            .collection("entries")

        for index in offsets {
            let record = records[index]
            let deletedRank = record.rank

            // Fetch all records to shift ranks down
            ref.getDocuments { snap, _ in
                guard let snap = snap else { return }

                let batch = db.batch()

                // Delete the record
                batch.deleteDocument(ref.document(record.docId))

                // Shift all records with rank > deleted rank down by 1
                for doc in snap.documents {
                    let d = doc.data()
                    if let existingRank = d["rank"] as? Int, existingRank > deletedRank {
                        batch.updateData(["rank": existingRank - 1], forDocument: doc.reference)
                    }
                }

                batch.commit { err in
                    if let err = err {
                        print("Error deleting: \(err.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.records.remove(at: index)
                            // Reload to get updated ranks
                            self.loadRecords()
                        }
                    }
                }
            }
        }
    }
    private func loadRecords() {
        isLoading = true
        errorMessage = ""
        records.removeAll()

        let db = Firestore.firestore()
        let ref = db.collection("\(sportId)_records")
            .document(subcategoryId)
            .collection("records")
            .document(recordCategoryId)
            .collection("entries")

        ref.getDocuments { snap, err in
            DispatchQueue.main.async {
                if let err = err {
                    self.errorMessage = "Failed to load records: \(err.localizedDescription)"
                } else if let snap = snap {
                    var temp: [RecordItem] = []
                    for doc in snap.documents {
                        let d = doc.data()
                        let player = (d["name"] as? String) ?? "Unknown"
                        let rank = (d["rank"] as? Int) ?? (d["rank"] as? Double).flatMap { Int($0) }
                        let valueStr: String
                        if let v = d["value"] as? Int { valueStr = String(v) }
                        else if let v = d["value"] as? Double { valueStr = String(v) }
                        else if let v = d["value"] as? String { valueStr = v }
                        else { valueStr = "-" }

                        let item = RecordItem(
                            docId: doc.documentID,
                            subcategoryId: subcategoryId,
                            recordCategoryId: recordCategoryId,
                            player: player,
                            value: valueStr,
                            rank: rank,
                            years: (d["years"] as? String) ?? (d["year"] as? String) ?? (d["career_years"] as? String) ?? (d["year"] as? Int).map { String($0) },
                            date: d["date"] as? String,
                            opponent: d["opponent"] as? String
                        )
                        temp.append(item)
                    }
                    self.records = temp.sorted { $0.rank < $1.rank }
                } else {
                    self.errorMessage = "No records found."
                }
                self.isLoading = false
            }
        }
    }
}
