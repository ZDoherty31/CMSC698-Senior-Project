//
//  PlayerSearchView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/7/25.
//

import SwiftUI
import FirebaseFirestore

struct PlayerSearchView: View {
    let sportId: String
    @State private var playerName = ""
    @State private var recordResults: [RecordItem] = []
    @State private var accoladeResults: [AccoladeItem] = []
    @State private var isLoading = false
    @State private var info: String = ""

    private let subcategoryMap: [String: [String]] = [
        "mtrack": ["indoor", "outdoor"],
        "wtrack": ["indoor", "outdoor"],
        "mxc": ["top_times"],
        "wxc": ["top_times"],
        "baseball": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
        "football": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "team_season_defense"],
        "mbb": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
        "wbb": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
        "mtennis": ["individual_career", "individual_season"],
        "wtennis": ["individual_career", "individual_season"],
        "softball": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
        "vball": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
        "msoc": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
        "wsoc": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
        "mhoc": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
        "whoc": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
    ]

    private let accoladeSubcategories = [
        "all_conference",
        "all_american",
        "all_region",
        "conference_champions",
        "scholar_athletes",
        "coach_of_the_year",
        "newcomer_of_the_year",
        "ncaa_championship",
        "other"
    ]

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

            List {
                if !recordResults.isEmpty {
                    Section(header: Text("Records")) {
                        ForEach(recordResults, id: \.docId) { r in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(r.player).font(.headline)
                                    Spacer()
                                    Text("Value: \(r.value)").font(.subheadline)
                                }
                                Text("Record: \(r.recordCategoryId.replacingOccurrences(of: "_", with: " "))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Rank: \(r.rank)").font(.caption).foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                if !accoladeResults.isEmpty {
                    Section(header: Text("Accolades")) {
                        ForEach(accoladeResults, id: \.id) { a in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(a.playerName).font(.headline)
                                Text(a.accolade)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Year: \(a.year)").font(.caption).foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("Search by Player")
    }

    private func performSearch() {
        let query = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }
        recordResults.removeAll()
        accoladeResults.removeAll()
        isLoading = true
        info = ""

        let db = Firestore.firestore()
        let lowerQuery = query.lowercased()
        let group = DispatchGroup()

        // Search Records
        var foundRecords: [RecordItem] = []
        let subcategories = subcategoryMap[sportId] ?? []

        for subId in subcategories {
            group.enter()
            db.collection("\(sportId)_records")
                .document(subId)
                .collection("records")
                .getDocuments { snap, _ in
                    guard let snap = snap else { group.leave(); return }
                    let inner = DispatchGroup()
                    for doc in snap.documents {
                        let recordCatId = doc.documentID
                        inner.enter()
                        db.collection("\(sportId)_records")
                            .document(subId)
                            .collection("records")
                            .document(recordCatId)
                            .collection("entries")
                            .getDocuments { entrySnap, _ in
                                if let entrySnap = entrySnap {
                                    for entry in entrySnap.documents {
                                        let d = entry.data()
                                        let name = (d["name"] as? String) ?? ""
                                        if name.lowercased().contains(lowerQuery) {
                                            let rank = (d["rank"] as? Int) ?? (d["rank"] as? Double).flatMap { Int($0) }
                                            let valueStr: String
                                            if let v = d["value"] as? Int { valueStr = String(v) }
                                            else if let v = d["value"] as? Double { valueStr = String(v) }
                                            else if let v = d["value"] as? String { valueStr = v }
                                            else { valueStr = "-" }

                                            let item = RecordItem(
                                                docId: entry.documentID,
                                                subcategoryId: subId,
                                                recordCategoryId: recordCatId,
                                                player: name,
                                                value: valueStr,
                                                rank: rank,
                                                years: (d["years"] as? String) ?? (d["year"] as? String) ?? (d["career_years"] as? String) ?? (d["year"] as? Int).map { String($0) },
                                                date: d["date"] as? String,
                                                opponent: d["opponent"] as? String
                                            )
                                            foundRecords.append(item)
                                        }
                                    }
                                }
                                inner.leave()
                            }
                    }
                    inner.notify(queue: .main) { group.leave() }
                }
        }

        // Search Accolades
        var foundAccolades: [AccoladeItem] = []

        for subcat in accoladeSubcategories {
            group.enter()
            db.collection("\(sportId)_records")
                .document("accolades")
                .collection(subcat)
                .getDocuments { snap, _ in
                    if let snap = snap {
                        for doc in snap.documents {
                            let d = doc.data()
                            let name = (d["player_name"] as? String) ?? ""
                            if name.lowercased().contains(lowerQuery) {
                                let accolade = (d["accolade"] as? String) ?? ""
                                let year = (d["year"] as? String) ?? ""
                                foundAccolades.append(AccoladeItem(
                                    id: "\(subcat)_\(doc.documentID)",
                                    playerName: name,
                                    accolade: accolade,
                                    year: year
                                ))
                            }
                        }
                    }
                    group.leave()
                }
        }

        // Notify
        group.notify(queue: .main) {
            self.isLoading = false
            self.recordResults = foundRecords.sorted { $0.rank < $1.rank }

            // Deduplicate accolades by player + accolade + year
            var seen = Set<String>()
            self.accoladeResults = foundAccolades.filter { item in
                let key = "\(item.playerName)|\(item.accolade)|\(item.year)"
                return seen.insert(key).inserted
            }.sorted { $0.year > $1.year }

            let total = foundRecords.count + self.accoladeResults.count
            if total == 0 {
                self.info = "No results found for '\(query)'"
            } else {
                self.info = "\(foundRecords.count) record(s), \(self.accoladeResults.count) accolade(s) found"
            }
        }
    }
}
