//
//  RecordsListView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/13/25.
//

import SwiftUI
import FirebaseFirestore

struct RecordsListView: View {
    let sportId: String
    let categoryId: String
    let subcategoryId: String
    
    @State private var records: [RecordItem] = []
    @State private var isLoading = false
    @State private var errorMessage = ""

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading records...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            } else if records.isEmpty {
                Text("No records found.").foregroundColor(.gray)
            } else {
                List {
                    ForEach(records) { r in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(r.player)
                                    .font(.headline)
                                Spacer()
                                Text("Value: \(r.value)")
                                    .font(.subheadline)
                            }
                            Text("Rank: \(r.rank)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            if let date = r.date {
                                Text("Date: \(date)").font(.caption).foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(subcategoryId.replacingOccurrences(of: "_", with: " "))
        .onAppear(perform: loadRecords)
    }
    private func loadRecords() {
        isLoading = true
        errorMessage = ""
        records.removeAll()
        
        let db = Firestore.firestore()
        let ref = db.collection("sports")
            .document(sportId)
            .collection("categories")
            .document(categoryId)
            .collection("subcategories")
            .document(subcategoryId)
            .collection("records")
        
        
        ref.getDocuments { snap, err in
            DispatchQueue.main.async {
                if let err = err {
                    self.errorMessage = "Failed to load records: \(err.localizedDescription)"
                } else if let snap = snap {
                    var temp: [RecordItem] = []
                    for doc in snap.documents {
                        let d = doc.data()
                        
                        var player = (d["player"] as? String) ?? (d["info"] as? String) ?? "Unknown"
                        if player == "Unknown" {
                            player = subcategoryId.replacingOccurrences(of: "_", with: " ")
                        }
                        let rank = (d["rank"] as? Int) ?? (d["rank"] as? Double).flatMap { Int($0) }
                        
                        let valueStr: String
                        if let v = d["value"] as? Int { valueStr = String(v) }
                        else if let v = d["value"] as? Double { valueStr = String(v) }
                        else if let v = d["value"] as? String { valueStr = v }
                        else if let v = d["ratio"] as? String { valueStr = v }
                        else { valueStr = "-" }
                        
                        let date = d["date"] as? String
                        let opponent = d["opponent"] as? String
                        let type = d["type"] as? String
                        
                        let item = RecordItem(
                            docId: doc.documentID,
                            categoryId: categoryId,
                            subcategoryId: subcategoryId,
                            player: player,
                            value: valueStr,
                            rank: rank,
                            date: date,
                            opponent: opponent,
                            type: type
                        )
                        temp.append(item)
                    }
                    self.records = temp.sorted(by: { $0.rank < $1.rank })
                } else {
                    self.errorMessage = "No records found."
                }
                self.isLoading = false
            }
        }
    }
}
