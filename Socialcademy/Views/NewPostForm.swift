//
//  NewPostForm.swift
//  Socialcademy
//
//  Created by Shankar Balasubramaniam on 13/02/25.
//

import SwiftUI

struct NewPostForm: View {
    @StateObject var viewModel: FormViewModel<Post>
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Title", text: $viewModel.title)
                }
                
                Section {
                    TextEditor(text: $viewModel.content)
                        .multilineTextAlignment(.leading)
                }
                
                Button {
                    viewModel.submit()
                } label: {
                    if viewModel.isWorking {
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
                viewModel.submit()
            }
            .disabled(viewModel.isWorking)
            .navigationTitle("New Post")
            .alert("Cannot Create Post", error: $viewModel.error)
            .onChange(of: viewModel.isWorking) { oldValue, newValue in
                guard !newValue, viewModel.error == nil else { return }
                dismiss()
            }
        }
    }
}

#Preview {
    NewPostForm(viewModel: FormViewModel(initialValue: Post.testPost, action: { _ in }))
}
