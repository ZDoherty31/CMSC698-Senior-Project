//
//  SportsSelectionView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 10/16/25.
//

import SwiftUI
import FirebaseAuth

struct SportsSelectionView: View {
    @ObservedObject var authVM: AuthViewModel
    
    private let sports: [(id: String, display: String)] = [
        ("baseball", "Baseball"),
        ("softball", "Softball"),
        ("football", "Football"),
        ("mbb", "Men's Basketball"),
        ("wbb", "Women's Basketball"),
        ("mtennis", "Men's Tennis"),
        ("wtennis", "Women's Tennis"),
        ("vball", "Volleyball"),
        ("msoc", "Men's Soccer"),
        ("wsoc", "Women's Soccer"),
        ("mhoc", "Men's Hockey"),
        ("whoc", "Women's Hockey"),
        ("mtrack", "Men's Track"),
        ("wtrack", "Women's Track"),
        ("mxc", "Men's Cross Country"),
        ("wxc", "Women's Cross Country"),
    ]
    
    var body: some View {
        NavigationView {
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
                
                List(sports, id: \.id) { sport in
                    NavigationLink(destination: RecordsHomeView(sportId: sport.id)) {
                        Text(sport.display)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Sports")
        }
    }
}
