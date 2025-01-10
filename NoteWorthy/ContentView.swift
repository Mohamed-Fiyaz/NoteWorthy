//
//  ContentView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 06/01/25.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var currentScreen: AppScreen = .launchScreen
    @StateObject private var model = Model()
    @StateObject private var appState = AppState()
    @State private var showMainView = false
    
    enum AppScreen {
        case launchScreen
        case mainView
        case logInView
    }
    
    var body: some View {
        ZStack {
            NavigationStack(path: $appState.routes) {
                ZStack {
                    MainView()
                        .opacity(currentScreen == .mainView ? 1 : 0)
                    
                    LogInView()
                        .opacity(currentScreen == .logInView ? 1 : 0)
                    
                } .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
                
            }
            .opacity(showMainView ? 1 : 0)
            
            if !showMainView {
                LaunchScreenView()
                    .transition(.opacity)
                    .animation(.easeOut(duration: 1.5), value: currentScreen)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    if let currentUser = Auth.auth().currentUser {
                        if currentUser.isEmailVerified {
//                            do {
//                                try Auth.auth().signOut()
//                            } catch {
//                                print(error.localizedDescription)
//                            }
                            currentScreen = .mainView
                            appState.routes = [.main]
                        } else {
                            currentScreen = .logInView
                            appState.routes = [.login]
                        }
                    } else {
                        currentScreen = .logInView
                        appState.routes = [.login]
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showMainView = true
                    }
                }
            }
        }
        .environmentObject(model)
        .environmentObject(appState)
    }
    
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .main:
            MainView()
                .navigationBarBackButtonHidden(true)
        case .login:
            LogInView()
                .navigationBarBackButtonHidden(true)
        case .signUp:
            SignUpView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ContentView()
}