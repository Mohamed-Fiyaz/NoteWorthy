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
    @State private var userName: String = ""
    
    private let sections = ["Favorites", "Your Notes", "AI Generated Notes"]
    
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
            }
            .padding(.vertical)
        }
        .onAppear {
            fetchUserName()
            noteService.fetchNotes()
        }
    }
    
    private func notesFor(_ section: String) -> [Note] {
        switch section {
        case "Favorites":
            return noteService.notes.filter { $0.isFavorite }
        case "AI Generated Notes":
            return noteService.notes.filter { $0.isAIGenerated }
        default:
            return noteService.notes
        }
    }
}

