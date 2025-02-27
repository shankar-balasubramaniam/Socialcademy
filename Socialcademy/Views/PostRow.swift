//
//  PostRow.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import SwiftUI

struct PostRow: View {
    @ObservedObject var viewModel: PostRowViewModel
    
    @State private var showConfirmationDialog = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                AuthorView(author: viewModel.author)
                
                Spacer()
                
                Text(viewModel.timestamp.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
            }
            .foregroundStyle(.gray)
            
            Text(viewModel.title)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(viewModel.content)
            
            HStack {
                FavouriteButton(isFavorite: viewModel.isFavorite) {
                    viewModel.favoritePost()
                }
                
                Spacer()
                
                if viewModel.canDeletePost {
                    Button(role: .destructive) {
                        showConfirmationDialog = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
            .labelStyle(.iconOnly)
        }
        .padding()
        .confirmationDialog("Are you sure you want to delete this post?", isPresented: $showConfirmationDialog, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                viewModel.deletePost()
            }
        }
        .alert("Error", error: $viewModel.error)
    }
}

private extension PostRow {
    struct FavouriteButton: View {
        var isFavorite: Bool
        var action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                if isFavorite {
                    Label("Remove from Favorites", systemImage: "heart.fill")
                } else {
                    Label("Add to Favorites", systemImage: "heart")
                }
            }
            .foregroundStyle(isFavorite ? .red : .gray)
            .animation(.default, value: isFavorite)
        }
    }
}

private extension PostRow {
    struct AuthorView: View {
        let author: User
        
        @EnvironmentObject private var factory: ViewModelFactory
        
        var body: some View {
            NavigationLink {
                PostsList(viewModel: factory.makePostsViewModel(filter: .author(author)))
            } label: {
                Text(author.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
    }
}

#Preview {
    PostRow(viewModel: PostRowViewModel(post: Post.testPost, deleteAction: {}, favoriteAction: {}))
}
