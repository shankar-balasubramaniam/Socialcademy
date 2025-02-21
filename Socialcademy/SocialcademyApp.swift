//
//  SocialcademyApp.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import SwiftUI
import Firebase

@main
struct SocialcademyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}
