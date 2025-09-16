//
//  MainView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 08/01/25.
//

import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject private var noteService = NoteService()
    @EnvironmentObject private var appState: AppState
    @State private var selectedTab: Int = 0
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1))
                .edgesIgnoringSafeArea(.top)

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("NoteWorthy")
                        .font(.custom("PatrickHand-Regular", size: 34))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .background(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))

                TabView(selection: $selectedTab) {
                    NavigationView {
                        HomeView()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)

                    NavigationView {
                        NotesView()
                    }
                    .tabItem {
                        Label("Notes", systemImage: "note.text")
                    }
                    .tag(1)

                    NavigationView {
                        IrisView()
                            .environmentObject(noteService)
                    }
                    .tabItem {
                        Label("Iris", systemImage: "eye.fill")
                    }
                    .tag(2)

                    NavigationView {
                        SettingsView()
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
                }
                .tint(.blue)
                .background(Color.white)
                .environmentObject(noteService)
            }
        }
    }
}

