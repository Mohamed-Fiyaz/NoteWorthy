//
//  AddNoteToCollectionView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 03/02/25.
//

import SwiftUI

struct AddNoteToCollectionView: View {
    let collection: Collection
    let notes: [Note]
    @ObservedObject var noteService: NoteService
    @ObservedObject var collectionService: CollectionService
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            List(filteredNotes) { note in
                Button(action: { addNoteToCollection(note) }) {
                    NoteRow(noteService: noteService, note: note)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Add Note to Collection")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
    
    private func addNoteToCollection(_ note: Note) {
        collectionService.addNoteToCollection(note, collection: collection)
        dismiss()
    }
}
