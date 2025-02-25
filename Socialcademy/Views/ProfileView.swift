//
//  ProfileView.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 24/02/25.
//

import FirebaseAuth
import SwiftUI

struct ProfileView: View {
    var body: some View {
        Button("Sign Out") {
            try! Auth.auth().signOut()
        }
    }
}

#Preview {
    ProfileView()
}
