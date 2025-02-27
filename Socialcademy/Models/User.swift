//
//  User.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 25/02/25.
//

import Foundation

struct User: Identifiable, Equatable, Codable {
    var id: String
    var name: String
}

extension User {
    static let testUser = User(id: "", name: "Jamie Harris")
}
