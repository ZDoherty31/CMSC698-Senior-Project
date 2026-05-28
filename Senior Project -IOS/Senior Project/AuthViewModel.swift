//
//  AuthViewModel.swift
//  Senior Project
//
//  Created by Zoe Kasules on 10/29/25.
//
import Foundation
import Combine
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String = ""
    
    init() {
        self.user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
    
    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) {result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.user = result?.user
                self.errorMessage = ""
            }
        }
    }
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) {result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.user = result?.user
                self.errorMessage = ""
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
