//
//  FilteredNotesView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import SwiftUI

struct FilteredNotesView: View {
    @ObservedObject var noteService: NoteService
    let showFavoritesOnly: Bool
    let showAIGeneratedOnly: Bool
    let title: String
    @State private var searchText = ""
    
    var filteredNotes: [Note] {
        var notes = noteService.notes
        
        if showFavoritesOnly {
            notes = notes.filter { $0.isFavorite }
        }
        
        if showAIGeneratedOnly {
            notes = notes.filter { $0.isAIGenerated }
        }
            
        if searchText.isEmpty {
            return notes
        }
        return notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            ForEach(filteredNotes) { note in
                NavigationLink(
                    destination: NoteDetailView(note: note, noteService: noteService)
                        .navigationBarBackButtonHidden(true)
                ) {
                    NoteRow(noteService: noteService, note: note)
                }
            }
            .onDelete(perform: deleteNotes)
        }
        .searchable(text: $searchText)
        .navigationTitle(title)
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        offsets.forEach { index in
            let note = filteredNotes[index]
            noteService.deleteNote(note)
        }
    }
}
