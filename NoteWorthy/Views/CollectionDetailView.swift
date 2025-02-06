//
//  CollectionDetailView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 03/02/25.
//

import SwiftUI

struct CollectionDetailView: View {
    let collection: Collection
    @ObservedObject var noteService: NoteService
    @ObservedObject var collectionService: CollectionService
    @State private var showingAddNote = false
    @State private var showingDeleteAlert = false
    @State private var editMode: EditMode = .inactive
    @Environment(\.dismiss) private var dismiss
    
    var collectionNotes: [Note] {
        noteService.notes.filter { collection.noteIds.contains($0.id) }
    }
    
    var notesToAdd: [Note] {
        noteService.notes.filter { !collection.noteIds.contains($0.id) }
    }
    
    var body: some View {
        List {
            ForEach(collectionNotes) { note in
                if editMode.isEditing {
                    Button(action: {
                        collectionService.removeNoteFromCollection(note, collection: collection)
                    }) {
                        HStack {
                            NoteRow(noteService: noteService, note: note)
                            Spacer()
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                                .imageScale(.large)
                                .padding(.trailing, 8)
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                } else {
                    NavigationLink(
                        destination: NoteDetailView(note: note, noteService: noteService)
                            .navigationBarBackButtonHidden(true)
                    ) {
                        NoteRow(noteService: noteService, note: note)
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(collection.name)
        .navigationBarItems(
            trailing: HStack(spacing: 16) {
                if editMode.isEditing {
                    Button("Done") {
                        withAnimation {
                            editMode = .inactive
                        }
                    }
                } else {
                    Menu {
                        Button(action: { showingAddNote = true }) {
                            Label("Add Notes", systemImage: "plus")
                        }
                        
                        Button(action: {
                            withAnimation {
                                editMode = .active
                            }
                        }) {
                            Label("Edit Notes", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Collection", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
        )
        .environment(\.editMode, $editMode)
        .sheet(isPresented: $showingAddNote) {
            AddNoteToCollectionView(
                collection: collection,
                notes: notesToAdd,
                noteService: noteService,
                collectionService: collectionService
            )
        }
        .alert("Delete Collection", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                collectionService.deleteCollection(collection)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this collection? This action cannot be undone.")
        }
    }
}
