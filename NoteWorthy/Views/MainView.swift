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
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 92/255, green: 122/255, blue: 153/255, alpha: 1.0)
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 92/255, green: 122/255, blue: 153/255, alpha: 1.0)]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
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

                TabView {
                    NavigationView {
                        HomeView()
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }

                    NavigationView {
                        NotesView()
                    }
                    .tabItem {
                        Label("Notes", systemImage: "note.text")
                    }

                    NavigationView {
                        IrisView()
                            .environmentObject(noteService)
                    }
                    .tabItem {
                        Label("Iris", systemImage: "eye.fill")
                    }

                    NavigationView {
                        SettingsView()
                    }
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                }
                .accentColor(.white)
                .background(Color.white)
                .environmentObject(noteService)
            }
        }
    }
}
