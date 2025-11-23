//
//  PlayerSearchView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/7/25.
//

import SwiftUI
import FirebaseFirestore

struct PlayerSearchView: View{
    let sportId: String
    @State private var playerName = ""
    @State private var results: [RecordItem] = []
    @State private var isLoading = false
    @State private var info: String = ""
    
    
    var body: some View {
        VStack(spacing: 12) {
            TextField("Enter player name", text: $playerName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.words)
            
            Button(action: { performSearch() }) {
                Label("Search Records", systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(playerName.isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(playerName.trimmingCharacters(in: .whitespaces).isEmpty)
            
            if isLoading {
                ProgressView("Searching...")
            } else if !info.isEmpty {
                Text(info).foregroundColor(.secondary).padding(.horizontal)
            }
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(results) { r in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(r.player).font(.headline)
                                Spacer()
                                Text("Value: \(r.value)").font(.subheadline)
                            }
                            Text("Record: \(r.subcategoryId.replacingOccurrences(of: "_", with: " "))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Rank: \(r.rank)").font(.caption).foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Search by Player")
    }
    private func performSearch() {
        let query = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        results.removeAll()
        isLoading = true
        info = ""
        
        let db = Firestore.firestore()
        let categoriesRef = db.collection("sports").document(sportId).collection("categories")
        
        categoriesRef.getDocuments { catSnap, catErr in
            if let catErr = catErr {
                DispatchQueue.main.async {
                    self.info = "Failed to load categories: \(catErr.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            guard let catSnap = catSnap else {
                DispatchQueue.main.async {
                    self.info = "No categories found."
                    self.isLoading = false
                }
                return
            }
            
            let lowerQuery = query.lowercased()
            let outer = DispatchGroup()
            var found: [RecordItem] = []
            
            for cat in catSnap.documents {
                let catId = cat.documentID
                let subRef = categoriesRef.document(catId).collection("subcategories")
                outer.enter()
                subRef.getDocuments { subSnap, _ in
                    if let subSnap = subSnap {
                        let inner = DispatchGroup()
                        for subDoc in subSnap.documents {
                            let subId = subDoc.documentID
                            inner.enter()
                            let recordsRef = subRef.document(subId).collection("records")
                            
                            recordsRef.getDocuments { recSnap, _ in
                                if let recSnap = recSnap {
                                    for doc in recSnap.documents {
                                        let d = doc.data()
                                        let player = (d["player"] as? String) ?? (d["info"] as? String) ?? ""
                                        if player.lowercased() == lowerQuery {
                                            let rank = (d["rank"] as? Int) ?? (d["rank"] as? Double).flatMap { Int($0)}
                                            let valueStr: String
                                            if let v = d["value"] as? Int { valueStr = String(v) }
                                            else if let v = d["value"] as? Double { valueStr = String(v) }
                                            else if let v = d["value"] as? String { valueStr = v }
                                            else if let v = d["ratio"] as? String { valueStr = v }
                                            else { valueStr = "-"}
                                            
                                            let item = RecordItem(
                                                docId: doc.documentID,
                                                categoryId: catId,
                                                subcategoryId: subId,
                                                player: player,
                                                value: valueStr,
                                                rank: rank,
                                                date: d["date"] as? String,
                                                opponent: d["opponent"] as? String,
                                                type: d["type"] as? String
                                            )
                                            found.append(item)
                                            
                                        }
                                    }
                                }
                                inner.leave()
                            }
                        }
                        inner.notify(queue: .main) {
                            outer.leave()
                        }
                    } else {
                        outer.leave()
                    }
                }
            }
            
            outer.notify(queue: .main) {
                self.isLoading = false
                self.results = found.sorted { $0.rank < $1.rank }
                if self.results.isEmpty {
                    self.info = "No records found for '\(query)"
                } else {
                    self.info = "\(self.results.count) record(s) found"
                }
            }
        }
    }
}
