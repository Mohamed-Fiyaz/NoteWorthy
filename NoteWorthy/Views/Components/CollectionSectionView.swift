//
//  CollectionSectionView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 03/02/25.
//

import SwiftUI

struct CollectionSectionView: View {
    @ObservedObject var noteService: NoteService
    @ObservedObject var collectionService: CollectionService
    @State private var showingCreateSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Collections")
                    .font(.headline)
                Spacer()
                Button(action: { showingCreateSheet = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Color(hex: "#8DB4E1"))
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if collectionService.collections.isEmpty {
                        Text("No collections")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.leading)
                    } else {
                        ForEach(collectionService.collections.prefix(5)) { collection in
                            NavigationLink(
                                destination: CollectionDetailView(
                                    collection: collection,
                                    noteService: noteService,
                                    collectionService: collectionService
                                )
                            ) {
                                CollectionPreviewCard(
                                    collection: collection,
                                    noteService: noteService,
                                    collectionService: collectionService
                                )
                            }
                        }
                        if collectionService.collections.count > 5 {
                            NavigationLink(
                                destination: AllCollectionsView(
                                    noteService: noteService,
                                    collectionService: collectionService
                                )
                            ) {
                                Text("More")
                                    .foregroundColor(Color(hex: "#8DB4E1"))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateCollectionView(collectionService: collectionService)
        }
    }
}
