//
//  RecordCategoryView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/13/25.
//

import SwiftUI
import FirebaseFirestore

struct RecordCategoryView: View {
    let sportId: String
    let subcategoryId: String

    @State private var categories: [String] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            } else {
                ForEach(categories, id: \.self) { cat in
                    if subcategoryId == "accolades" {
                        NavigationLink(destination: AccoladesListView(sportId: sportId, subcategory: cat)) {
                            Text(cat.replacingOccurrences(of: "_", with: " ").capitalized)
                                .padding(.vertical, 8)
                        }
                    } else {
                        NavigationLink(destination: RecordsListView(sportId: sportId, subcategoryId: subcategoryId, recordCategoryId: cat)) {
                            Text(cat.replacingOccurrences(of: "_", with: " ").capitalized)
                                .padding(.vertical, 8)
                        }
                    }
                }
            }
        }
        .navigationTitle(subcategoryId.replacingOccurrences(of: "_", with: " ").capitalized)
        .onAppear(perform: loadCategories)
    }

    private func loadCategories() {
        isLoading = true
        errorMessage = ""
        categories.removeAll()

        let db = Firestore.firestore()

        if subcategoryId == "accolades" {
            let knownSubcategories = [
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
            let group = DispatchGroup()
            var found: [String] = []

            for subcat in knownSubcategories {
                group.enter()
                db.collection("\(sportId)_records")
                    .document("accolades")
                    .collection(subcat)
                    .limit(to: 1)
                    .getDocuments { snap, _ in
                        if let snap = snap, !snap.documents.isEmpty {
                            found.append(subcat)
                        }
                        group.leave()
                    }
            }

            group.notify(queue: .main) {
                self.categories = knownSubcategories.filter { found.contains($0) }
                self.isLoading = false
            }

        } else {
            db.collection("\(sportId)_records")
                .document(subcategoryId)
                .collection("records")
                .getDocuments { snap, err in
                    DispatchQueue.main.async {
                        if let err = err {
                            self.errorMessage = "Failed to load: \(err.localizedDescription)"
                        } else if let snap = snap {
                            self.categories = snap.documents.map { $0.documentID }.sorted()
                        } else {
                            self.errorMessage = "Nothing found."
                        }
                        self.isLoading = false
                    }
                }
        }
    }
}
