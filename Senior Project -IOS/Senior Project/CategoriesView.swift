//
//  CategoriesView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/4/25.
//

import SwiftUI
import FirebaseFirestore


struct CategoriesView: View {
    let sportId: String
    @State private var categories: [String] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    
    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading categories...")
            } else if !errorMessage.isEmpty {
                Text(errorMessage).foregroundColor(.red)
            } else {
                ForEach(categories, id: \.self) { categoryId in
                    NavigationLink(destination : SubcategoryView(sportId: sportId, categoryId: categoryId)) {
                        Text(categoryId.replacingOccurrences(of: "_", with: " "))
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .navigationTitle("Categories")
        .onAppear(perform: loadCategories)
    }
    
    private func loadCategories() {
        isLoading = true
        errorMessage = ""
        categories.removeAll()
        
        let db = Firestore.firestore()
        let ref = db.collection("sports").document(sportId).collection("categories")
        ref.getDocuments { snap, err in
            DispatchQueue.main.async {
                if let err = err {
                    self.errorMessage = "Failed to load categories: \(err.localizedDescription)"
                } else if let snap = snap {
                    self.categories = snap.documents.map { $0.documentID }
                } else {
                    self.errorMessage = "No categories found. "
                }
                self.isLoading = false
            }
        }
    }
}
   
     



