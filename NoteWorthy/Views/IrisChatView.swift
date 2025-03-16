//
//  IrisChatView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 16/03/25.
//

import SwiftUI
import FirebaseAuth

struct IrisChatView: View {
    @StateObject private var viewModel = IrisViewModel()
    @State private var messageText = ""
    @State private var showingAttachmentOptions = false
    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @State private var showingNoteSelection = false
    @State private var attachedNote: Note?
    @EnvironmentObject private var noteService: NoteService
    
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
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
            DocumentPicker(viewModel: viewModel)
                .onDisappear {
                    if viewModel.currentAnalysis != nil {
                        handleAnalysisResult()
                    }
                }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(viewModel: viewModel)
                .onDisappear {
                    if viewModel.currentAnalysis != nil {
                        handleAnalysisResult()
                    }
                }
        }
        .sheet(isPresented: $showingNoteSelection) {
            NoteSelectionView { note in
                attachedNote = note
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .overlay(
            Group {
                if viewModel.isProcessing {
                    LoadingPopupView(isVisible: .constant(true))
                }
            }
        )
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
        var contentToProcess = messageText
        
        // If there's an attached note, include its content
        if let note = attachedNote {
            contentToProcess += "\n\nReferenced Note: \(note.title)\n\(note.content)"
        }
        
        // Clear message field and attachment
        messageText = ""
        attachedNote = nil
        
        // Process the message
        Task {
            await viewModel.processMessage(contentToProcess)
        }
    }
    
    private func handleAnalysisResult() {
        if let analysis = viewModel.currentAnalysis {
            // Add assistant message with analysis
            let analysisMessage = ChatMessage(
                id: UUID().uuidString,
                content: "Here's my analysis of your document:\n\n**Summary**\n\(analysis.summary)\n\n**Key Points**\n" + analysis.keyConcepts.map { "• \($0)" }.joined(separator: "\n"),
                type: .assistant,
                timestamp: Date()
            )
            viewModel.addMessage(analysisMessage)
            viewModel.clearAnalysis()
        }
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.type == .assistant {
                Image(systemName: "brain")
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
