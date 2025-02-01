//
//  SettingsView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 10/01/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage

struct SettingsView: View {
    @Binding var profileImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingEditNameSheet = false
    @State private var showingLogoutAlert = false
    @State private var inputImage: UIImage?
    @State private var userName: String = "User"
    @State private var userEmail: String = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Profile Section
                VStack(spacing: 20) {
                    // Profile Image with Edit Icon
                    ZStack(alignment: .bottomTrailing) {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .offset(x: -3, y: -3)
                    }
                    
                    // User Name and Email
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
                
                // Account Section
                SectionView(title: "Account") {
                    SettingsRow(icon: "square.and.pencil", title: "Edit profile") {
                        showingEditNameSheet = true
                    }
                    
                    SettingsRow(icon: "arrow.right.square", title: "Log out", textColor: .red) {
                        showingLogoutAlert = true
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { newImage in
            if let image = newImage {
                uploadProfileImage(image)
            }
        }
        .sheet(isPresented: $showingEditNameSheet) {
            EditNameView(userName: $userName)
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
        
        // Load profile image
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
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        
        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("profile_images/\(user.uid).jpg")
        
        // Delete old profile image before uploading a new one
        imageRef.delete { error in
            if let error = error {
                print("Failed to delete old profile image: \(error.localizedDescription)")
            }
            
            // Upload new profile image
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                isLoading = false
                return
            }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            imageRef.putData(imageData, metadata: metadata) { _, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if error == nil {
                        self.profileImage = image
                    }
                }
            }
        }
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
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        @Environment(\.presentationMode) var presentationMode
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.allowsEditing = true
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }
        
        class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
            let parent: ImagePicker
            
            init(_ parent: ImagePicker) {
                self.parent = parent
            }
            
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let editedImage = info[.editedImage] as? UIImage {
                    parent.image = editedImage
                }
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }

