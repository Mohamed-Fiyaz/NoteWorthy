//
//  MainView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 08/01/25.
//

import SwiftUI

struct MainView: View {
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1))) // Background color
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 92/255, green: 122/255, blue: 153/255, alpha: 1.0) // Unselected tab icon color
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white // Selected tab icon color
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 92/255, green: 122/255, blue: 153/255, alpha: 1.0)] // Unselected text color
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white] // Selected text color

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        ZStack {
            // Blue background that stays at the top and bottom
            Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1))
                .edgesIgnoringSafeArea(.top) // Make sure it covers the top

            VStack(spacing: 0) {
                HStack {
                    Text("NoteWorthy")
                        .font(.custom("PatrickHand-Regular", size: 28))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .background(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1))) // Blue background for top part

                // TabView without the blue background around it
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
                    }
                    .tabItem {
                        Label("Iris", systemImage: "eye.fill")
                    }

                    NavigationView {
                        GroupsView()
                    }
                    .tabItem {
                        Label("Group", systemImage: "person.3.fill")
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
            }
        }
    }
}

#Preview {
    MainView()
}
