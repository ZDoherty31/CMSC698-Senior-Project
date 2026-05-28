//
// ContentView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 10/16/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth


struct SportsSelectionView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var sports: [String] = []
    @State private var errorMessage: String = ""
    @State private var isLoading = true
    
    var body: some View {
        NavigationView{
            VStack {
                Text("Select a Sport")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Button("Sign Out") {
                    do {
                        try Auth.auth().signOut()
                        authVM.user = nil
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }
                }
                .padding()
                
                if isLoading {
                    ProgressView("Loading sports...")
                        .padding()
                } else if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(sports, id: \.self) { sport in
                        NavigationLink(destination: RecordsHomeView(sportId: sport)) {
                            Text(sport.capitalized)
                                .font(.headline)
                        }
                    }
                }
                
            }
            .onAppear(perform: fetchSports)
        }
    }
    
    private func fetchSports() {
        let db = Firestore.firestore()
        db.collection("sports").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Error loading sports: \(error.localizedDescription)"
                isLoading = false
                return
            }
            guard let documents = snapshot?.documents else {
                errorMessage = "No sports found."
                isLoading = false
                return
            }
            sports = documents.map { $0.documentID }
            isLoading = false
        }
    }
}
