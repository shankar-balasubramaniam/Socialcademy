//
//  PostsRepository.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import Foundation
import FirebaseFirestore

/// Protocol defining methods for handling posts-related operations.
protocol PostsRepositoryProtocol {
    var user: User { get }
    
    /// Fetches all posts from the database.
    func fetchAllPosts() async throws -> [Post]
    /// Fetches only the favorite posts from the database.
    func fetchFavoritePosts() async throws -> [Post]
    func fetchPosts(by author: User) async throws -> [Post]
    /// Creates a new post and saves it to Firestore.
    func create(_ post: Post) async throws
    /// Deletes a post from Firestore.
    func delete(_ post: Post) async throws
    /// Marks a post as favorite.
    func favorite(_ post: Post) async throws
    /// Removes the favorite status from a post.
    func unfavorite(_ post: Post) async throws
}

extension PostsRepositoryProtocol {
    func canDelete(_ post: Post) -> Bool {
        post.author.id == user.id
    }
}

/// Concrete implementation of `PostsRepositoryProtocol` using Firestore as the data source.
struct PostsRepository: PostsRepositoryProtocol {
    let user: User
    /// Reference to the "posts_v2" collection in Firestore.
    let postsReference = Firestore.firestore().collection("posts_v2")
    let favoritesReference = Firestore.firestore().collection("favorites")
    
    /// Creates a new post in Firestore.
    func create(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(from: post)
    }
    
    /// Fetches all posts, ordered by timestamp in descending order.
    func fetchAllPosts() async throws -> [Post] {
        return try await fetchPosts(from: postsReference)
    }
    
    /// Fetches only the favorite posts, ordered by timestamp in descending order.
    func fetchFavoritePosts() async throws -> [Post] {
        let favorites = try await fetchFavorites()
        
        guard !favorites.isEmpty else { return [] }
        
        let posts = try await postsReference
            .whereField("id", in: favorites.map(\.uuidString))
            .order(by: "timestamp", descending: true)
            .getDocuments(as: Post.self)
        
        return posts.map { post in
            post.setting(\.isFavorite, to: true)
        }
    }
    
    func fetchPosts(by author: User) async throws -> [Post] {
        return try await fetchPosts(from: postsReference.whereField("author.id", isEqualTo: author.id))
    }
    
    /// Deletes a post from Firestore using its unique ID.
    func delete(_ post: Post) async throws {
        precondition(canDelete(post))
        let document = postsReference.document(post.id.uuidString)
        try await document.delete()
    }
    
    /// Marks a post as favorite in Firestore by updating the `isFavorite` field.
    func favorite(_ post: Post) async throws {
        let favorite = Favourite(postID: post.id, userID: user.id)
        let document = favoritesReference.document(favorite.id)
        try await document.setData(from: favorite)
    }
    
    /// Unmarks a post as favorite in Firestore by updating the `isFavorite` field.
    func unfavorite(_ post: Post) async throws {
        let favorite = Favourite(postID: post.id, userID: user.id)
        let document = favoritesReference.document(favorite.id)
        try await document.delete()
    }
}

#if DEBUG
/// A stub implementation of `PostsRepositoryProtocol` for use in testing and previews.
struct PostsRepositoryStub: PostsRepositoryProtocol {
    var user = User.testUser
    
    /// Holds the simulated state of posts.
    let state: Loadable<[Post]>
    
    /// Simulates fetching all posts using the `Loadable` state.
    func fetchAllPosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    /// Simulates fetching favorite posts using the `Loadable` state.
    func fetchFavoritePosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func fetchPosts(by author: User) async throws -> [Post] {
        return try await state.simulate()
    }
    
    /// Simulates marking a post as favorite.
    func favorite(_ post: Post) async throws {
        // No-op for test stubs
    }
    
    /// Simulates removing the favorite status from a post.
    func unfavorite(_ post: Post) async throws {
        // No-op for test stubs
    }
    
    /// Simulates deleting a post.
    func delete(_ post: Post) async throws {
        // No-op for test stubs
    }
    
    /// Simulates creating a post.
    func create(_ post: Post) async throws {
        // No-op for test stubs
    }
}
#endif

/// Extension to simplify setting Firestore document data from an encodable object.
private extension DocumentReference {
    /// Sets Firestore document data from an encodable object.
    /// - Parameter value: The encodable object to be stored.
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // This method only throws if there's an encoding error, which means the model has an issue.
            // Force try is used because encoding errors should be prevented at the model level.
            try! setData(from: value) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume()
            }
        }
    }
}

private extension PostsRepository {
    struct Favourite: Identifiable, Codable {
        var id: String {
            postID.uuidString + "-" + userID
        }
        let postID: Post.ID
        let userID: User.ID
    }
    
    func fetchFavorites() async throws -> [Post.ID] {
        return try await favoritesReference
            .whereField("userID", isEqualTo: user.id)
            .getDocuments(as: Favourite.self)
            .map(\.postID)
    }
    
    /// Helper function to fetch posts from Firestore based on the given query.
    /// - Parameter query: The Firestore query to execute.
    /// - Returns: An array of `Post` objects retrieved from Firestore.
    private func fetchPosts(from query: Query) async throws -> [Post] {
        let (posts, favorites) = try await (
            query.order(by: "timestamp", descending: true).getDocuments(as: Post.self),
            fetchFavorites()
        )
        return posts.map { post in
            post.setting(\.isFavorite, to: favorites.contains(post.id))
        }
    }
}

private extension Post {
    func setting<T>(_ property: WritableKeyPath<Post, T>, to newValue: T) -> Post {
        var post = self
        post[keyPath: property] = newValue
        return post
    }
}

private extension Query {
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        return snapshot.documents.compactMap { document in
            try! document.data(as: type)
        }
    }
}
