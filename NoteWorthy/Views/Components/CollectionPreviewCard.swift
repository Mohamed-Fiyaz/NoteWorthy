//
//  CollectionPreviewCard.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 03/02/25.
//

import SwiftUI

struct CollectionPreviewCard: View {
    let collection: Collection
    @ObservedObject var noteService: NoteService
    @ObservedObject var collectionService: CollectionService
    @State private var showingDeleteAlert = false
    
    var collectionNotes: [Note] {
        noteService.notes.filter { collection.noteIds.contains($0.id) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(collection.name)
                    .foregroundColor(.black)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Menu {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            Text("\(collectionNotes.count) notes")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 150, height: 80)
        .padding()
        .background(Color(hex: collection.color))
        .cornerRadius(10)
        .shadow(radius: 2)
        .alert("Delete Collection", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                collectionService.deleteCollection(collection)
            }
        } message: {
            Text("Are you sure you want to delete this collection? This action cannot be undone.")
        }
    }
}
