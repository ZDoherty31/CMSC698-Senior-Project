//
//  AuthViewModel.swift
//  Senior Project
//
//  Created by Zoe Kasules on 10/29/25.
//
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAdmin: Bool = false
    @Published var errorMessage: String = ""

    init() {
        self.user = Auth.auth().currentUser
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
            if let user = user {
                self.fetchAdminStatus(uid: user.uid)
            } else {
                self.isAdmin = false
            }
        }
    }

    private func fetchAdminStatus(uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { snap, err in
            DispatchQueue.main.async {
                if let data = snap?.data() {
                    self.isAdmin = data["isAdmin"] as? Bool ?? false
                    print("isAdmin value: \(self.isAdmin)")
                    print("Raw data: \(data)")
                } else {
                    self.isAdmin = false
                    print("No user document found for uid: \(uid)")
                    print("Error: \(String(describing: err))")
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.user = result?.user
                self.errorMessage = ""
                if let uid = result?.user.uid {
                    self.fetchAdminStatus(uid: uid)
                }
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
            } else {
                self.user = result?.user
                self.errorMessage = ""
                // New users are not admins by default
                if let uid = result?.user.uid {
                    let db = Firestore.firestore()
                    db.collection("users").document(uid).setData([
                        "email": email,
                        "isAdmin": false
                    ])
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isAdmin = false
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}

