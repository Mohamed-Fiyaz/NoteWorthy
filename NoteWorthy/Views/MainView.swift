//
//  MainView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 08/01/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct MainView: View {
    @StateObject private var noteService = NoteService()
    @State private var profileImage: UIImage?
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
                    Text("NoteWorthy")
                        .font(.custom("PatrickHand-Regular", size: 28))
                        .foregroundColor(.white)
                    Spacer()
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    } else {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    }
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
                        SettingsView(profileImage: $profileImage)
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
        .onAppear {
            loadProfileImage()
        }
    }
    
    private func loadProfileImage() {
        guard let user = Auth.auth().currentUser else { return }
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("profile_images/\(user.uid).jpg")
        
        imageRef.getData(maxSize: 4 * 1024 * 1024) { data, error in
            if let imageData = data, let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.profileImage = image
                }
            }
        }
    }
}
