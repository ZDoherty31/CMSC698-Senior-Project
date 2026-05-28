//
//  AccoladesListView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 05/20/2026.
//

import SwiftUI
import FirebaseFirestore

struct AccoladesListView: View {
    let sportId: String
    let subcategory: String

    @EnvironmentObject var authVM: AuthViewModel
    @State private var accolades: [AccoladeItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var showingAddAccolade = false

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            } else if accolades.isEmpty {
                Text("No accolades found.").foregroundColor(.gray)
            } else {
                List {
                    ForEach(accolades, id: \.id) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.playerName)
                                .font(.headline)
                            Text(item.accolade)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Year: \(item.year)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .onDelete(perform: { offsets in
                        if authVM.isAdmin {
                            deleteAccolade(at: offsets)
                        }
                    })

                    if authVM.isAdmin {
                        Button(action: { showingAddAccolade = true }) {
                            Label("Add Accolade", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(subcategory.replacingOccurrences(of: "_", with: " ").capitalized)
        .id(subcategory)
        .sheet(isPresented: $showingAddAccolade) {
            AddAccoladeView(
                sportId: sportId,
                subcategory: subcategory
            ) {
                loadAccolades()
            }
        }
        .onAppear {
            loadAccolades()
        }
    }

    private func deleteAccolade(at offsets: IndexSet) {
        let db = Firestore.firestore()
        for index in offsets {
            let accolade = accolades[index]
            db.collection("\(sportId)_records")
                .document("accolades")
                .collection(subcategory)
                .document(accolade.id)
                .delete { err in
                    if let err = err {
                        print("Error deleting: \(err.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.accolades.remove(at: index)
                        }
                    }
                }
        }
    }

    private func loadAccolades() {
        isLoading = true
        errorMessage = ""
        accolades.removeAll()

        let db = Firestore.firestore()
        db.collection("\(sportId)_records")
            .document("accolades")
            .collection(subcategory)
            .getDocuments { snap, err in
                DispatchQueue.main.async {
                    if let err = err {
                        self.errorMessage = "Failed to load: \(err.localizedDescription)"
                    } else if let snap = snap {
                        self.accolades = snap.documents.compactMap { doc in
                            let d = doc.data()
                            guard let player = d["player_name"] as? String,
                                  let accolade = d["accolade"] as? String,
                                  let year = d["year"] as? String else { return nil }
                            return AccoladeItem(
                                id: doc.documentID,
                                playerName: player,
                                accolade: accolade,
                                year: year
                            )
                        }
                        .filter { $0.id != "info" }
                        .sorted { $0.year > $1.year }
                    } else {
                        self.errorMessage = "No accolades found."
                    }
                    self.isLoading = false
                }
            }
    }
}

struct AddAccoladeView: View {
    let sportId: String
    let subcategory: String
    let onSave: () -> Void

    @Environment(\.dismiss) var dismiss
    @State private var playerName = ""
    @State private var accolade = ""
    @State private var year = ""
    @State private var isSaving = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Accolade Info")) {
                    TextField("Player Name", text: $playerName)
                    TextField("Accolade (e.g. All-Midwest Conference – First Team)", text: $accolade)
                    TextField("Year (e.g. 2024 or 2023-24)", text: $year)
                        .keyboardType(.numbersAndPunctuation)
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage).foregroundColor(.red)
                }
            }
            .navigationTitle("Add Accolade")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { saveAccolade() }
                        .disabled(playerName.isEmpty || accolade.isEmpty || year.isEmpty || isSaving)
                }
            }
        }
    }

    private func saveAccolade() {
        guard !playerName.isEmpty, !accolade.isEmpty, !year.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        isSaving = true
        let db = Firestore.firestore()
        let ref = db.collection("\(sportId)_records")
            .document("accolades")
            .collection(subcategory)

        ref.getDocuments { snap, _ in
            let count = (snap?.documents.filter { $0.documentID != "info" }.count ?? 0) + 1
            let docId = "accolade_\(String(format: "%03d", count))"

            let data: [String: Any] = [
                "player_name": playerName,
                "accolade": accolade,
                "year": year,
                "sport": sportId,
                "subcategory": subcategory
            ]

            ref.document(docId).setData(data) { err in
                DispatchQueue.main.async {
                    isSaving = false
                    if let err = err {
                        errorMessage = "Failed to save: \(err.localizedDescription)"
                    } else {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AccoladeItem {
    let id: String
    let playerName: String
    let accolade: String
    let year: String
}
