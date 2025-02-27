//
//  Post.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import Foundation

/// A model representing a social media post
struct Post: Identifiable, Equatable {
    /// The title of the post
    var title: String
    /// The main content/body of the post
    var content: String
    /// The author of the post, represented as a `User` object
    var author: User
    /// A Boolean value indicating whether the post is marked as a favorite
    var isFavorite = false
    /// The timestamp indicating when the post was created
    var timestamp = Date()
    /// A unique identifier for the post, automatically generated using `UUID()`
    var id = UUID()
    
    /// Checks if the given string is present in the post's title, content, or author's name.
    /// - Parameter string: The search query.
    /// - Returns: `true` if the string is found in any of the properties; otherwise `false`.
    func contains(_ string: String) -> Bool {
        // Convert title, content, and author's name to lowercase for case-insensitive search
        let properties = [title, content, author.name].map { $0.lowercased() }
        let query = string.lowercased()
        
        // Check if any of the properties contain the search query
        let matches = properties.filter { $0.contains(query) }
        return !matches.isEmpty
    }
}

extension Post: Codable {
    enum CodingKeys: CodingKey {
        case title, content, author, timestamp, id
    }
}

extension Post {
    /// A sample post for testing and preview purposes.
    static let testPost = Post(
        title: "Lorem ipsum",
        content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
        author: User.testUser
    )
}
