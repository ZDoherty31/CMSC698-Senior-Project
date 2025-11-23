//
//  RecordsHomeView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/6/25.
//

import SwiftUI

struct RecordsHomeView: View {
    let sportId: String
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Records for \(sportId)")
                    .font(.title2)
                    .padding(.top)
                
                NavigationLink(destination: CategoriesView(sportId: sportId)) {
                    Label("Browse by Category", systemImage: "list.bullet")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: PlayerSearchView(sportId: sportId)) {
                    Label("Search by Player", systemImage: "magnifyingglass")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Records")
        }
    }
}
