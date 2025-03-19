//
//  NotesView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 10/01/25.
//

import SwiftUI

struct NotesView: View {
    @StateObject private var noteService = NoteService()
    @State private var isAddingNote = false
    @State private var searchText = ""
    @Environment(\.dismissSearch) private var dismissSearch
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
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
            
            Button(action: { isAddingNote = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
        }
        .navigationTitle("Notes")
        .sheet(isPresented: $isAddingNote) {
            NavigationView {
                AddNoteView(noteService: noteService)
            }
        }
        .onAppear {
            noteService.fetchNotes()
        }
    }
    
    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return noteService.notes
        }
        return noteService.notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        offsets.forEach { index in
            let note = filteredNotes[index]
            noteService.deleteNote(note)
        }
    }
}

