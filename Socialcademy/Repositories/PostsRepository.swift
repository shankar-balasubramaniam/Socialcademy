//
//  PostsRepository.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import Foundation
import FirebaseFirestore

protocol PostsRepositoryProtocol {
    func fetchAllPosts() async throws -> [Post]
    func fetchFavoritePosts() async throws -> [Post]
    func create(_ post: Post) async throws
    func delete(_ post: Post) async throws
    func favorite(_ post: Post) async throws
    func unfavorite(_ post: Post) async throws
}

struct PostsRepository: PostsRepositoryProtocol {
    let postsReference = Firestore.firestore().collection("posts_v1")
    
    func create(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(from: post)
    }
    
    func fetchAllPosts() async throws -> [Post] {
        return try await fetchPosts(from: postsReference
            .order(by: "timestamp", descending: true)
        )
    }
    
    func fetchFavoritePosts() async throws -> [Post] {
        return try await fetchPosts(from: postsReference
            .order(by: "timestamp", descending: true)
            .whereField("isFavorite", isEqualTo: true)
        )
    }
    
    func delete(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.delete()
    }
    
    func favorite(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(["isFavorite": true], merge: true)
    }
    
    func unfavorite(_ post: Post) async throws {
        let document = postsReference.document(post.id.uuidString)
        try await document.setData(["isFavorite": false], merge: true)
    }
    
    private func fetchPosts(from query: Query) async throws -> [Post] {
        let snapshot = try await query.getDocuments()
        let posts = snapshot.documents.compactMap { document in
            try! document.data(as: Post.self)
        }
        
        return posts
    }
}

#if DEBUG
struct PostsRepositoryStub: PostsRepositoryProtocol {
    func fetchAllPosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func fetchFavoritePosts() async throws -> [Post] {
        return try await state.simulate()
    }
    
    func favorite(_ post: Post) async throws {
        
    }
    
    func unfavorite(_ post: Post) async throws {
        
    }
    
    func delete(_ post: Post) async throws {
        
    }
    
    let state: Loadable<[Post]>
    
    func create(_ post: Post) async throws {
    }
}
#endif

private extension DocumentReference {
    func setData<T: Encodable>(from value: T) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            // Method only throws if there's an encoding error, which indicates a problem with our model.
            // We handled this with a force try, while all other errors are passed to the completion handler.
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
