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
                Text(viewModel.authorName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
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
                
                Button(role: .destructive) {
                    showConfirmationDialog = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
        .padding(.vertical)
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

#Preview {
    List {
        PostRow(viewModel: PostRowViewModel(post: Post.testPost, deleteAction: {}, favoriteAction: {}))
    }
}
