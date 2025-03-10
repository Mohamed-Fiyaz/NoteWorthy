//
//  NoteDetailView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var noteService: NoteService
    let note: Note
    @State private var editedTitle: String
    @State private var editedContent: String
    @State private var editedColor: String
    @State private var showingDiscardAlert = false
    @State private var showingDeleteAlert = false
    
    let colors = [
        "#F8F8F8", // Light Gray
        "#FFFBF2", // Light Cream
        "#FFE4E1", // Misty Rose
        "#E6F7FF", // Light Sky Blue
        "#E5EAF5", // Lavender Blue
        "#F2F2D9", // Light Pastel Yellow
        "#DCE9E2", // Mint Green
        "#EADFF7", // Light Lilac
        "#D7CCC8", // Light Taupe
        "#C8E6C9", // Pale Green
        "#B2DFDB", // Aquamarine
        "#B3CDE3"  // Dusty Blue
    ]
    
    init(note: Note, noteService: NoteService) {
        self.note = note
        self.noteService = noteService
        _editedTitle = State(initialValue: note.title)
        _editedContent = State(initialValue: note.content)
        _editedColor = State(initialValue: note.colorHex)
    }
    
    var hasChanges: Bool {
        editedTitle != note.title ||
        editedContent != note.content ||
        editedColor != note.colorHex
    }
    
    var body: some View {
        Form {
            Section(header: Text("Note Details")) {
                TextField("Title", text: $editedTitle)
                TextEditor(text: $editedContent)
                    .frame(height: 200)
            }
            
            Section(header: Text("Note Color")) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: 10) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(color == editedColor ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                editedColor = color
                            }
                    }
                }
            }
            
            Section {
                Button(role: .destructive, action: { showingDeleteAlert = true }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete Note")
                    }
                }
            }
        }
        .navigationTitle("Edit Note")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    if hasChanges {
                        showingDiscardAlert = true
                    } else {
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveChanges()
                }
                .disabled(!hasChanges)
            }
        }
        .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Keep Editing", role: .cancel) { }
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                noteService.deleteNote(note)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this note?")
        }
    }
    
    private func saveChanges() {
        var updatedNote = note
        updatedNote.title = editedTitle
        updatedNote.content = editedContent
        updatedNote.colorHex = editedColor
        noteService.updateNote(updatedNote)
        dismiss()
    }
}
