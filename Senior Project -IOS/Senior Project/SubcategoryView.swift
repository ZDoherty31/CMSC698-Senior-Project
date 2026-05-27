//
//  SubcategoryView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/13/25.
//

import SwiftUI
import FirebaseFirestore

struct SubcategoryView: View {
    let sportId: String
    let categoryId: String
    
    @State private var subcategories: [String] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading subcategories...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            } else {
                ForEach(subcategories, id: \.self) { sub in
                    NavigationLink(destination: RecordsListView(sportId: sportId, categoryId: categoryId, subcategoryId: sub)) {
                        Text(sub.replacingOccurrences(of: "_", with: " "))
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle(categoryId.replacingOccurrences(of: "_", with: " "))
        .onAppear(perform: loadSubcategories)
    }
    
    private func loadSubcategories() {
        isLoading = true
        errorMessage = ""
        subcategories.removeAll()
        
        let db = Firestore.firestore()
        let ref = db.collection("sports")
            .document(sportId)
            .collection("categories")
            .document(categoryId)
            .collection("subcategories")
        
        ref.getDocuments { snap, err in
            DispatchQueue.main.async {
                if let err = err {
                    self.errorMessage = "Failed to load subcategories: \(err.localizedDescription)"
                } else if let snap = snap {
                    self.subcategories = snap.documents.map { $0.documentID }
                } else {
                    self.errorMessage = "No subcategories found."
                }
                self.isLoading = false
            }
        }
    }
}
