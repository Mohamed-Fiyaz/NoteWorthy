//
//  IrisChatView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 16/03/25.
//

import SwiftUI
import FirebaseAuth
import PhotosUI

struct IrisChatView: View {
    @StateObject private var viewModel = IrisViewModel()
    @State private var messageText = ""
    @State private var showingAttachmentOptions = false
    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @State private var showingNoteSelection = false
    @State private var attachedNote: Note?
    @StateObject private var noteService = NoteService()
    
    var body: some View {
        VStack {
            // Chat messages area
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.chatMessages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .onChange(of: viewModel.chatMessages.count) { _ in
                    withAnimation {
                        if let lastMessage = viewModel.chatMessages.last {
                            scrollProxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Attached note indicator
            if let note = attachedNote {
                AttachedNoteView(note: note) {
                    attachedNote = nil
                    viewModel.clearAttachedDocument()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // Attachment indicator for documents and images
            if viewModel.attachedDocumentType != nil && attachedNote == nil {
                AttachmentIndicatorView(type: viewModel.attachedDocumentType ?? "") {
                    viewModel.clearAttachedDocument()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            // Input area
            HStack(alignment: .bottom) {
                Button(action: {
                    showingAttachmentOptions = true
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 22))
                        .foregroundColor(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                        .padding(8)
                }
                
                TextField("Ask Iris...", text: $messageText, axis: .vertical)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...5)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(
                            messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color(.systemGray3)
                            : Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1))
                        )
                        .padding(.leading, 4)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isChatProcessing)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color(.systemGray4)),
                alignment: .top
            )
        }
        .navigationTitle("Iris Assistant")
        .confirmationDialog(
            "Attach Content",
            isPresented: $showingAttachmentOptions,
            titleVisibility: .visible
        ) {
            Button("Upload PDF") {
                showingDocumentPicker = true
            }
            
            Button("Upload Image") {
                showingImagePicker = true
            }
            
            Button("Select Note") {
                showingNoteSelection = true
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPickerChat(viewModel: viewModel)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerViewChat(viewModel: viewModel)
        }
        .sheet(isPresented: $showingNoteSelection) {
            NoteSelectionView { note in
                attachedNote = note
                viewModel.attachNote(note)
                
                // Add assistant message about attached note
                let attachMessage = ChatMessage(
                    id: UUID().uuidString,
                    content: "I've attached the note \"**\(note.title)**\". You can now ask questions about it.",
                    type: .assistant,
                    timestamp: Date()
                )
                viewModel.addMessage(attachMessage)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .overlay(
            Group {
                if viewModel.isChatProcessing {
                    ChatLoadingView()
                }
            }
        )
        .onAppear {
            noteService.fetchNotes()
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message to chat
        let userMessage = ChatMessage(
            id: UUID().uuidString,
            content: messageText,
            type: .user,
            timestamp: Date()
        )
        viewModel.addMessage(userMessage)
        
        // Create content to process
        let contentToProcess = messageText
        
        // Clear message field - moved inside a MainActor to ensure UI update
        DispatchQueue.main.async {
            messageText = ""
        }
        
        // Process the message
        Task {
            await viewModel.processMessage(contentToProcess)
        }
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.type == .assistant {
                Image(systemName: "eye")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                    .clipShape(Circle())
                    .padding(.trailing, 4)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.formattedContent)
                    .padding(12)
                    .background(
                        message.type == .user
                        ? Color(.systemGray5)
                        : Color(#colorLiteral(red: 0.9, green: 0.95, blue: 1.0, alpha: 1))
                    )
                    .cornerRadius(16)
                
                Text(message.formattedTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
            }
            
            Spacer()
            
            if message.type == .user {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color(.systemGray3))
                    .font(.system(size: 30))
                    .padding(.leading, 4)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AttachedNoteView: View {
    let note: Note
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "doc.text.fill")
                .foregroundColor(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Attached Note")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(note.title)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct AttachmentIndicatorView: View {
    let type: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: type == "PDF" ? "doc.fill" : "photo.fill")
                .foregroundColor(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Attached \(type)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Content ready for reference")
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct DocumentPickerChat: UIViewControllerRepresentable {
    @ObservedObject var viewModel: IrisViewModel
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerChat
        
        init(_ parent: DocumentPickerChat) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            // Start security-scoped resource access
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security scoped resource")
                return
            }
            
            Task {
                await parent.viewModel.processPDF(url)
                
                // Add assistant message about attachment
                await MainActor.run {
                    let attachMessage = ChatMessage(
                        id: UUID().uuidString,
                        content: "I've attached your PDF document. You can now ask questions about it.",
                        type: .assistant,
                        timestamp: Date()
                    )
                    parent.viewModel.addMessage(attachMessage)
                }
                
                // Stop security-scoped resource access
                url.stopAccessingSecurityScopedResource()
            }
        }
    }
}

struct ImagePickerViewChat: UIViewControllerRepresentable {
    @ObservedObject var viewModel: IrisViewModel
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePickerViewChat
        
        init(_ parent: ImagePickerViewChat) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let result = results.first else { return }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                Task {
                    await self.parent.viewModel.processImage(image)
                    
                    // Add assistant message about attachment
                    await MainActor.run {
                        let attachMessage = ChatMessage(
                            id: UUID().uuidString,
                            content: "I've attached your image. You can now ask questions about the content in it.",
                            type: .assistant,
                            timestamp: Date()
                        )
                        self.parent.viewModel.addMessage(attachMessage)
                    }
                }
            }
        }
    }
}

struct ChatLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                VStack(spacing: 12) {
                    // Typing indicator with 3 dots
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                                .frame(width: 8, height: 8)
                                .scaleEffect(isAnimating ? 1.0 : 0.5)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: isAnimating
                                )
                        }
                    }
                    
                    Text("Iris is typing...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding()
                
                Spacer()
            }
            
            Spacer()
        }
        .background(Color.black.opacity(0.01))
        .onAppear {
            isAnimating = true
        }
    }
}
