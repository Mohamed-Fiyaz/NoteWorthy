//
//  NoteWorthyApp.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 06/01/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Firestore settings to disable offline persistence
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings
        
        // Clear cached data to force real-time sync
        Firestore.firestore().clearPersistence { error in
            if let error = error {
                print("Error clearing cache: \(error.localizedDescription)")
            } else {
                print("Cache cleared. Restart the app to reload fresh data.")
            }
        }

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct NoteWorthyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tint(.blue)
        }
    }
}
