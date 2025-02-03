//
//  HomeView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 10/01/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject private var noteService = NoteService()
    @StateObject private var collectionService = CollectionService()
    @State private var userName: String = ""
    
    private let sections = ["Favorites", "Your Notes"]
    
    func fetchUserName() {
        if let user = Auth.auth().currentUser {
            userName = user.displayName ?? user.email ?? "User"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                UserGreetingView(userName: userName)
                
                ForEach(sections, id: \.self) { section in
                    NoteSectionView(
                        section: section,
                        notes: notesFor(section),
                        noteService: noteService
                    )
                }
                
                CollectionSectionView(
                    noteService: noteService,
                    collectionService: collectionService
                )
            }
            .padding(.vertical)
        }
        .onAppear {
            fetchUserName()
            noteService.fetchNotes()
            collectionService.fetchCollections()
        }
    }
    
    private func notesFor(_ section: String) -> [Note] {
        switch section {
        case "Favorites":
            return noteService.notes.filter { $0.isFavorite }
        default:
            return noteService.notes
        }
    }
}
