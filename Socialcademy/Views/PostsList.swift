//
//  PostsList.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import SwiftUI

struct PostsList: View {
    @State private var searchText: String = ""
    @State private var showNewPostForm = false
    
    @StateObject var viewModel = PostsViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                switch viewModel.posts {
                case .loading:
                    ProgressView()
                case .error(let error):
                    EmptyListView(title: "Cannot Load Posts", message: error.localizedDescription) {
                        viewModel.fetchPosts()
                    }
                case .empty:
                    EmptyListView(title: "No Posts", message: "There aren't any posts yet.")
                case .loaded(let posts):
                    List(posts) { post in
                        if searchText.isEmpty || post.contains(searchText) {
                            PostRow(viewModel: viewModel.makePostRowViewModel(for: post))
                        }
                    }
                    .animation(.default, value: posts)
                    .searchable(text: $searchText)
                }
            }
            .navigationTitle(viewModel.title)
            .toolbar {
                Button {
                    showNewPostForm = true
                } label: {
                    Label("New Post", systemImage: "square.and.pencil")
                }
            }
            .sheet(isPresented: $showNewPostForm) {
                NewPostForm(createAction: viewModel.makeCreateAction())
            }
        }
        .onAppear {
            viewModel.fetchPosts()
        }
    }
}

@MainActor
private struct ListPreview: View {
    let state: Loadable<[Post]>
    
    var body: some View {
        let postsRepository = PostsRepositoryStub(state: state)
        let viewModel = PostsViewModel(postsRepository: postsRepository)
        PostsList(viewModel: viewModel)
    }
}
#Preview {
#if DEBUG
    ListPreview(state: .loaded([Post.testPost]))
#endif
}

#Preview {
#if DEBUG
    ListPreview(state: .empty)
#endif
}

#Preview {
#if DEBUG
    ListPreview(state: .error)
#endif
}

#Preview {
#if DEBUG
    ListPreview(state: .loading)
#endif
}
