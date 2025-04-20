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
    @State private var showLoadingOverlay = false
    @State private var hasInitiallyLoaded = false
    
    private let sections = ["Favorites", "Your Notes", "AI Generated Notes"]
    
    func fetchUserName() {
        if let user = Auth.auth().currentUser {
            userName = user.displayName ?? user.email ?? "User"
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    UserGreetingView(userName: userName)
                    
                    if !noteService.notes.isEmpty {
                        ForEach(sections, id: \.self) { section in
                            NoteSectionView(
                                section: section,
                                notes: notesFor(section),
                                noteService: noteService
                            )
                        }
                    }
                    else if noteService.isLoading {
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Loading notes...")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    }
                    else {
                        VStack(spacing: 20) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No notes available")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                showLoadingOverlay = true
                                noteService.forceRefresh {
                                    showLoadingOverlay = false
                                }
                            }) {
                                Text("Refresh")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                                    .cornerRadius(8)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 80)
                    }
                }
                .padding(.vertical)
            }
            .overlay(
                Group {
                    if showLoadingOverlay {
                        LoadingOverlay()
                    }
                }
            )
        }
        .onAppear {
            fetchUserName()
            
            if !hasInitiallyLoaded {
                noteService.isLoading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    noteService.fetchNotes()
                    hasInitiallyLoaded = true
                }
            }
        }
        .refreshable {
            return await withCheckedContinuation { continuation in
                showLoadingOverlay = true
                noteService.forceRefresh {
                    showLoadingOverlay = false
                    continuation.resume()
                }
            }
        }
    }
    
    private func notesFor(_ section: String) -> [Note] {
        switch section {
        case "Favorites":
            return noteService.notes.filter { $0.isFavorite }
        case "AI Generated Notes":
            return noteService.notes.filter { $0.isAIGenerated }
        case "Your Notes":
            return noteService.notes
        default:
            return []
        }
    }
}

// Simple full-screen loading overlay
struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 15) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                
                Text("Loading notes...")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.7))
            )
        }
    }
}
