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
                    if noteService.isLoading {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 150, height: 120)
                                .overlay(
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                )
                        }
                    } else if notes.isEmpty {
                        getEmptyStateView(for: section)
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
                                    showAIGeneratedOnly: section == "AI Generated Notes",
                                    title: section
                                )
                            ) {
                                Text("More")
                                    .foregroundColor(Color(hex: "#8DB4E1"))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(hex: "#8DB4E1"), lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func getEmptyStateView(for section: String) -> some View {
        let message: String
        let systemImage: String
        
        switch section {
        case "Favorites":
            message = "No favorites yet"
            systemImage = "star"
        case "AI Generated Notes":
            message = "No AI generated notes"
            systemImage = "wand.and.stars"
        default:
            message = "No notes yet"
            systemImage = "doc.text"
        }
        
        return HStack {
            Image(systemName: systemImage)
                .foregroundColor(.gray)
                .font(.system(size: 18))
            
            Text(message)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}
