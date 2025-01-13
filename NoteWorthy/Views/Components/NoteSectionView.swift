//
//  NoteSectionView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import SwiftUI

struct NoteSectionView: View {
    let section: String
    let notes: [Note]
    let noteService: NoteService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(section)
                .font(.headline)
                .padding(.leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    if notes.isEmpty && section == "Favorites" {
                        Text("No favorites")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.leading)
                    }
                    if notes.isEmpty && section == "Your Notes" {
                        Text("No Notes")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                            .padding(.leading)
                    } else {
                        ForEach(notes.prefix(5)) { note in
                            NavigationLink(
                                destination: NoteDetailView(note: note, noteService: noteService)
                                .navigationBarBackButtonHidden(true)
                            ) {
                                NotePreviewCard(
                                    noteService: noteService, note: note,
                                    isCompact: true,
                                    showStar: section == "Favorites"
                                )
                            }
                        }
                        if notes.count > 5 {
                            NavigationLink(
                                destination: FilteredNotesView(
                                    noteService: noteService,
                                    showFavoritesOnly: section == "Favorites",
                                    title: section
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
    }
}
