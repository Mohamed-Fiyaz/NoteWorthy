//
//  AllCollectionView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 03/02/25.
//

import SwiftUI

struct AllCollectionsView: View {
    @ObservedObject var noteService: NoteService
    @ObservedObject var collectionService: CollectionService
    @State private var searchText = ""
    
    var filteredCollections: [Collection] {
        if searchText.isEmpty {
            return collectionService.collections
        }
        return collectionService.collections.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        List {
            ForEach(filteredCollections) { collection in
                NavigationLink(
                    destination: CollectionDetailView(
                        collection: collection,
                        noteService: noteService,
                        collectionService: collectionService
                    )
                ) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(collection.name)
                            .font(.headline)
                        let notes = noteService.notes.filter { collection.noteIds.contains($0.id) }
                        Text("\(notes.count) notes")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onDelete(perform: deleteCollections)
        }
        .searchable(text: $searchText)
        .navigationTitle("Collections")
    }
    
    private func deleteCollections(at offsets: IndexSet) {
        offsets.forEach { index in
            let collection = filteredCollections[index]
            collectionService.deleteCollection(collection)
        }
    }
}
