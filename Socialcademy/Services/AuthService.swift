//
//  AuthService.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 23/02/25.
//

import FirebaseAuth
import Foundation

/// A service class responsible for handling user authentication using Firebase
@MainActor
class AuthService: ObservableObject {
    /// The currently authenticated user, stored as a `User?`
    @Published var user: User?
    
    /// An instance of Firebase Authentication
    private let auth = Auth.auth()
    /// A listener to track authentication state changes.
    private var listener: AuthStateDidChangeListenerHandle?
    
    /// Initializes the authentication service and starts listening for authentication state changes
    init() {
        listener = auth.addStateDidChangeListener({ [weak self] auth, user in
            // Convert the Firebase user to our `User` model and update the `user` property.
            self?.user = user.map(User.init(from:))
        })
    }
    
    /// Creates a new user account with the given name, email, and password.
    /// - Parameters:
    ///     - name: The display name of the user.
    ///     - email: The email address of the user.
    ///     - password: The password for the new account.
    /// - Throws: An error if account creation fails.
    func createAccount(name: String, email: String, password: String) async throws {
        // Create a new user with the given email and password
        let result = try await auth.createUser(withEmail: email, password: password)
        // Update the user's display name in Firebase
        try await result.user.updateProfile(\.displayName, to: name)
        // Update the local user object with the new name
        user?.name = name
    }
    
    /// Signs in an existing user with the provided email and password.
    /// - Parameters:
    ///     - email: The user's email address.
    ///     - password: The user's password.
    /// - Throws: An error if sign-in fails.
    func signIn(email: String, password: String) async throws {
        try await auth.signIn(withEmail: email, password: password)
    }
    
    /// Signs out the currently authenticated user.
    /// - Throws: An error if sign-out fails.
    func signOut() throws {
        try auth.signOut()
    }
}

/// An extension to add helper methods for updating a Firebase user's profile.
private extension FirebaseAuth.User {
    /// Updates a specified profile field for the Firebase user.
    /// - Parameters:
    ///     - keyPath: The property of `UserProfileChangeRequest` to update.
    ///     - newValue: The new value to set for the property.
    /// - Throws: An error if updating the profile fails.
    func updateProfile<T>(_ keyPath: WritableKeyPath<UserProfileChangeRequest, T>, to newValue: T) async throws {
        // Create a profile change request
        var profileChangeRequest = createProfileChangeRequest()
        // Update the specified property
        profileChangeRequest[keyPath: keyPath] = newValue
        // Commit the changes to Firebase
        try await profileChangeRequest.commitChanges()
    }
}

/// An extension to map a `FirebaseAuth.User` to a custom `User` model.
private extension User {
    /// Initializes a `User` model from a `FirebaseAuth.User` instance.
    /// - Parameter firebaseUser: The Firebase user to convert.
    init(from firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.name = firebaseUser.displayName ?? "" // Default to an empty string if no name is available
    }
}
