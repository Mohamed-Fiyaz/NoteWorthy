//
//  HomeView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 10/01/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var userName: String = ""
    
    func fetchUserName() {
        if let user = Auth.auth().currentUser {
            userName = user.displayName ?? user.email ?? "User"
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Hi, \(userName)")
                    .font(.system(size: 24, weight: .regular, design: .default))
                    .onAppear {
                        fetchUserName()
                    }
                    .padding(.leading)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)

            Spacer()
        }
    }
}

#Preview {
    HomeView()
}

