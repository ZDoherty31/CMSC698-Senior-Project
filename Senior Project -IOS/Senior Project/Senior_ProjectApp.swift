//
//  Senior_ProjectApp.swift
//  Senior Project
//
//  Created by Zoe Kasules on 10/16/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import Combine

@main
struct Senior_ProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if authVM.user == nil {
                LoginView(authVM: authVM)
            } else {
                SportsSelectionView(authVM: authVM)
            }
        }
    }
}

