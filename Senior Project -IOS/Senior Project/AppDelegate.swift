//
//  AppDelegate.swift
//  Senior Project
//
//  Created by Zoe Kasules on 10/29/25.
//
import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase configured in AppDelegate")
        return true
    }
}

