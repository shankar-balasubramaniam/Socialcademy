//
//  NewPostForm.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import SwiftUI

struct NewPostForm: View {
    typealias CreateAction = (Post) async throws -> Void
    
    let createAction: CreateAction
    
    @State private var post = Post(title: "", content: "", authorName: "")
    @State private var state = FormState.idle
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $post.title)
                    
                    TextField("Author Name", text: $post.authorName)
                }
                
                Section {
                    TextEditor(text: $post.content)
                        .multilineTextAlignment(.leading)
                }
                
                Button {
                    createPost()
                } label: {
                    if state == .working {
                        ProgressView()
                    } else {
                        Text("Create Post")
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.white)
                .padding()
                .listRowBackground(Color.accentColor)
            }
            .onSubmit {
                createPost()
            }
            .disabled(state == .working)
            .navigationTitle("New Post")
            .alert("Cannot Create Post", isPresented: $state.isError, actions: {}) {
                Text("Sorry, something went wrong.")
            }
        }
    }
    
    private func createPost() {
        Task {
            state = .working
            do {
                try await createAction(post)
                dismiss()
            } catch {
                print("[NewPostForm Cannot create post: \(error)]")
                state = .error
            }
        }
    }
}

private extension NewPostForm {
    enum FormState {
        case idle, working, error
        
        var isError: Bool {
            get {
                self == .error
            }
            set {
                guard !newValue else { return }
                self = .idle
            }
        }
    }
}

#Preview {
    NewPostForm { _ in }
}
