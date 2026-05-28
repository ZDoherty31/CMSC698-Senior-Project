//
//  LoginView.swift
//  Senior Project
//
//  Created by Zoe Kasules on 10/29/25.
//
import SwiftUI

struct LoginView: View {
    @ObservedObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("LU Athletics Records App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 50)
            
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            Button("Log In") {
                authVM.signIn(email: email, password: password)
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            if !authVM.errorMessage.isEmpty {
                Text(authVM.errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Button("Don't have an account? Sign up") {
                showingSignUp = true
            }
            .padding(.bottom, 40)
            .sheet(isPresented: $showingSignUp) {
                SignUpView(authVM: authVM) 
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
