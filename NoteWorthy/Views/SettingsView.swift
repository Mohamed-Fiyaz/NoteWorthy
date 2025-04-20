//
//  SettingsView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 10/01/25.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State private var showingEditNameSheet = false
    @State private var showTerms = false
    @State private var showingLogoutAlert = false
    @State private var userName: String = "User"
    @State private var userEmail: String = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(red: 0.36, green: 0.58, blue: 0.89))

                    VStack(spacing: 5) {
                        Text(userName)
                            .font(.title2)
                            .bold()
                        
                        Text(userEmail)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 30)
                
                SectionView(title: "Account") {
                    SettingsRow(icon: "square.and.pencil", title: "Edit profile") {
                        showingEditNameSheet = true
                    }
                    .background(Color(red: 0.937, green: 0.965, blue: 0.988))
                }
                
                SectionView(title: "Support and About") {
                    SettingsRow(icon: "questionmark.circle", title: "Help and Support") {
                        
                    }
                    .background(Color(red: 0.937, green: 0.965, blue: 0.988))
                    
                    SettingsRow(icon: "doc.text", title: "Terms and Conditions") {
                        showTerms = true
                    }
                    .background(Color(red: 0.937, green: 0.965, blue: 0.988))
                    
                    SettingsRow(icon: "info.circle", title: "About") {
                        
                    }
                    .background(Color(red: 0.937, green: 0.965, blue: 0.988))
                    
                    SettingsRow(icon: "arrow.right.square", title: "Log out", textColor: .red) {
                        showingLogoutAlert = true
                    }
                    .background(Color(red: 0.937, green: 0.965, blue: 0.988))
                }
                .padding(.top, 10)
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingEditNameSheet) {
            EditNameView(userName: $userName)
        }
        .sheet(isPresented: $showTerms) {
            TermsView(showTerms: $showTerms)
        }
        .onAppear {
            loadUserData()
        }
        .alert("Are you sure you want to log out?", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) { handleLogout() }
        }
        .overlay(
            Group {
                if isLoading {
                    LoadingView()
                }
            }
        )
    }
    
    private func loadUserData() {
        guard let user = Auth.auth().currentUser else { return }
        userEmail = user.email ?? ""
        userName = user.displayName ?? "User"
    }
    
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            appState.routes = [.login]
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(10)
        }
        .padding(.vertical, 8)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var textColor: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(textColor)
                
                Text(title)
                    .foregroundColor(textColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct EditNameView: View {
    @Binding var userName: String
    @Environment(\.dismiss) private var dismiss
    @State private var newName: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter New Name")) {
                    TextField("Name", text: $newName)
                }
            }
            .navigationTitle("Edit Name")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    updateName()
                }
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
            .onAppear {
                newName = userName
            }
        }
    }
    
    private func updateName() {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty,
              let user = Auth.auth().currentUser else {
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = trimmedName
        
        changeRequest.commitChanges { error in
            if error == nil {
                userName = trimmedName
            }
            dismiss()
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
                .padding(30)
                .background(Color(.systemBackground))
                .cornerRadius(10)
        }
    }
}

struct TermsView: View {
    @Binding var showTerms: Bool
    
    var body: some View {
        VStack {
            Text("Terms and Conditions")
                .font(.title)
                .padding()
            
            ScrollView {
                Text(loadTermsContent())
                    .padding()
            }
            
            Button(action: {
                showTerms = false
            }) {
                Text("Close")
                    .font(.system(size: 18, weight: .bold, design: .default))
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
    
    private func loadTermsContent() -> String {
        if let rtfURL = Bundle.main.url(forResource: "Terms", withExtension: "rtf"),
           let attributedString = try? NSAttributedString(url: rtfURL, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            return attributedString.string
        }
        return "Terms and Conditions content could not be loaded."
    }
}
