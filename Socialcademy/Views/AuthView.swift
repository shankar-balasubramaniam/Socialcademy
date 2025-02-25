//
//  AuthView.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 24/02/25.
//

import SwiftUI

struct AuthView: View {
    @StateObject var viewModel = AuthViewModel()
    
    var body: some View {
        if viewModel.isAuthenticated {
            MainTabView()
        } else {
            NavigationView {
                SignInForm(viewModel: viewModel.makeSignInViewModel()) {
                    NavigationLink("Create Account") {
                        CreateAccountForm(viewModel: viewModel.makeCreateAccountViewModel())
                    }
                }
            }
        }
    }
}

#Preview {
    AuthView()
}

private extension AuthView {
    struct CreateAccountForm: View {
        @StateObject var viewModel: AuthViewModel.CreateAccountViewModel
        
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            Form {
                TextField("Name", text: $viewModel.name)
                    .textContentType(.name)
                
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.newPassword)
            } footer: {
                Button("Create Account", action: viewModel.submit)
                    .buttonStyle(.primary)
                
                Button("Sign In", action: dismiss.callAsFunction)
                    .padding()
            }
            .onSubmit {
                viewModel.submit()
            }
            .disabled(viewModel.isWorking)
            .alert("Cannot Create Account", error: $viewModel.error)
            .navigationTitle("Create Account")
        }
    }
    
    struct SignInForm<Footer: View>: View {
        @StateObject var viewModel: AuthViewModel.SignInViewModel
        @ViewBuilder let footer: () -> Footer
        
        var body: some View {
            Form(content: {
                TextField("Email", text: $viewModel.email)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $viewModel.password)
                    .textContentType(.password)
            }, footer: {
                Button("Sign In", action: viewModel.submit)
                    .buttonStyle(.primary)
                
                footer()
                    .padding()
            })
            .onSubmit {
                viewModel.submit()
            }
            .disabled(viewModel.isWorking)
            .alert("Cannot Sign In", error: $viewModel.error)
        }
    }
}

private struct Form<Content: View, Footer: View>: View {
    @ViewBuilder let content: () -> Content
    @ViewBuilder let footer: () -> Footer
    
    var body: some View {
        VStack {
            Text("Socialcademy")
                .font(.title.bold())
            
            content()
                .padding()
                .background(Color.secondary.opacity(0.15))
                .clipShape(.rect(cornerRadius: 10))
            
            footer()
        }
        .padding()
    }
}
