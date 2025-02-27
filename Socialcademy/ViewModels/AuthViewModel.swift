//
//  AuthViewModel.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 24/02/25.
//

import Foundation

/// A ViewModel responsible for managing authentication state and providing authentication-related sub-view models.
@MainActor
class AuthViewModel: ObservableObject {
    /// The currently authenticated user, if any.
    @Published var user: User?
    
    /// The authentication service responsible for handling sign-in and account creation.
    private let authService = AuthService()
    
    /// Initializes the authentication ViewModel and binds the user state to `AuthService`.
    init () {
        // Automatically updates `user` whenever `authService.user` changes
        authService.$user.assign(to: &$user)
    }
    
    /// Creates a `SignInViewModel` instance for handling user sign-in.
    /// - Returns: A `SignInViewModel` configured with the sign-in action.
    func makeSignInViewModel() -> SignInViewModel {
        return SignInViewModel(action: authService.signIn(email:password:))
    }
    
    /// Creates a `CreateAccountViewModel` instance for handling user registration.
    /// - Returns: A `CreateAccountViewModel` configured with the create account action.
    func makeCreateAccountViewModel() -> CreateAccountViewModel {
        return CreateAccountViewModel(action: authService.createAccount(name:email:password:))
    }
}

/// Extension providing nested view models for authentication forms.
extension AuthViewModel {
    /// ViewModel for the sign-in form, inheriting from `FormViewModel`.
    class SignInViewModel: FormViewModel<(email: String, password: String)> {
        /// Convenience initializer that sets the initial form values and assigns the authentication action.
        /// - Parameter action: The function to be called for signing in.
        convenience init(action: @escaping Action) {
            self.init(initialValue: (email: "", password: ""), action: action)
        }
    }
    
    /// ViewModel for the create account form, inheriting from `FormViewModel`.
    class CreateAccountViewModel: FormViewModel<(name: String, email: String, password: String)> {
        /// Convenience initializer that sets the initial form values and assigns the account creation action.
        /// - Parameter action: The function to be called for crearing an account.
        convenience init(action: @escaping Action) {
            self.init(initialValue: (name: "", email: "", password: ""), action: action)
        }
    }
}
