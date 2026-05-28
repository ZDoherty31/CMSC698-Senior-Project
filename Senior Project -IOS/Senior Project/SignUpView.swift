//
//  SignUpView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 10/29/25.
//
import SwiftUI

struct SignUpView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    
    var body: some View{
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.title)
                .padding(.top, 50)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Sign Up") {
                authVM.signUp(email: email, password: password)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            if !authVM.errorMessage.isEmpty {
                Text(authVM.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
            
            Image("LawrenceLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 300)
                .padding(.bottom, 20)
        }
    }
}
