//
//  AddNotesView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import SwiftUI
import FirebaseAuth

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var noteService: NoteService
    @State private var title = ""
    @State private var content = ""
    @State private var selectedColor = "#FFE4E1"
    @State private var showingDiscardAlert = false
    
    let colors = [
        "#FFE4E1", "#E6E6FA", "#F0FFF0", "#FFE5B4",
        "#E0FFFF", "#FFF0F5", "#F0F8FF", "#F5F5DC",
        "#FFDAB9", "#98FB98", "#DDA0DD", "#B0E0E6"
    ]
    
    var hasChanges: Bool {
        !title.isEmpty || !content.isEmpty || selectedColor != "#FFE4E1"
    }
    
    var body: some View {
        Form {
            Section(header: Text("Note Details")) {
                TextField("Title", text: $title)
                TextEditor(text: $content)
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
                                    .stroke(color == selectedColor ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }
        }
        .navigationTitle("New Note")
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
                    saveNote()
                }
                .disabled(title.isEmpty)
            }
        }
        .alert("Discard Note?", isPresented: $showingDiscardAlert) {
            Button("Discard", role: .destructive) { dismiss() }
            Button("Keep Editing", role: .cancel) { }
        }
    }
    
    private func saveNote() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let note = Note(
            title: title,
            content: content,
            colorHex: selectedColor,
            userId: userId
        )
        
        noteService.addNote(note)
        dismiss()
    }
}

