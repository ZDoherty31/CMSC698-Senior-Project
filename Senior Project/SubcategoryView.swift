//
//  SubcategoryView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 11/13/25.
//

import SwiftUI

struct SubcategoryView: View {
    let sportId: String
    
    @EnvironmentObject var authVM: AuthViewModel
    
    private let subcategoryMap: [String: [String]] = [
        "mtrack": ["indoor", "outdoor"],
           "wtrack": ["indoor", "outdoor"],
           "mxc": ["top_times", "accolades"],
           "wxc": ["top_times", "accolades"],
           "baseball": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "accolades"],
           "football": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "team_season_defense", "accolades"],
           "mbb": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "accolades"],
           "wbb": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "accolades"],
           "mtennis": ["individual_career", "individual_season", "accolades"],
           "wtennis": ["individual_career", "individual_season", "accolades"],
           "softball": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "accolades"],
           "vball": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "accolades"],
           "msoc": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "accolades"],
           "wsoc": ["individual_career", "individual_game", "individual_season", "team_game", "team_season", "accolades"],
           "mhoc": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
           "whoc": ["individual_career", "individual_game", "individual_season", "team_game", "team_season"],
       ]
    
    var body: some View {
        let subcategories = subcategoryMap[sportId] ?? []
        
        List {
            ForEach(subcategories, id: \.self) { sub in
                NavigationLink(destination: RecordCategoryView(sportId: sportId, subcategoryId: sub)) {
                    Text(sub.replacingOccurrences(of: "_", with: " ").capitalized)
                        .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("Record Types")
    }
}
