//
//  NoteSelectionView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import SwiftUI

struct NoteSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var noteService = NoteService()
    let onNoteSelected: (Note) -> Void
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading Notes...")
                } else if noteService.notes.isEmpty {
                    VStack {
                        Text("No Notes Available")
                            .font(.headline)
                        Text("Create a note first to summarize")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                } else {
                    List(noteService.notes) { note in
                        Button(action: {
                            onNoteSelected(note)
                            dismiss()
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.headline)
                                Text(note.content)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .lineLimit(2)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Select Note")
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
        }
        .onAppear {
            // Create a new instance of NoteService
            noteService.fetchNotes()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
            }
        }
    }
}
