//
//  IrisView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 10/01/25.
//

import SwiftUI
import UIKit

struct IrisView: View {
    @State private var showingChatView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with logo/image
                VStack(spacing: 20) {
                    Image(systemName: "brain")
                        .font(.system(size: 60))
                        .foregroundColor(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                        .padding(.top, 40)
                    
                    Text("Iris")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your intelligent note assistant")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }
                
                // Action buttons
                VStack(spacing: 20) {
                    NavigationLink(destination: IrisChatView()) {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.title2)
                            Text("Chat with Iris")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    ActionButtons()
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

struct ActionButtons: View {
    @EnvironmentObject private var noteService: NoteService
    @State private var showingNoteSelection = false
    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @StateObject private var viewModel = IrisViewModel()
    @State private var showDocumentProcessing = false
    @State private var showLoadingPopup = false
    
    var body: some View {
        VStack(spacing: 15) {
            ActionButton(
                icon: "doc.text.fill",
                title: "Analyze a Note",
                description: "Get insights from your notes"
            ) {
                showingNoteSelection = true
            }
            
            ActionButton(
                icon: "doc.fill",
                title: "Analyze a PDF",
                description: "Upload and process PDF documents"
            ) {
                showingDocumentPicker = true
            }
            
            ActionButton(
                icon: "photo.fill",
                title: "Analyze an Image",
                description: "Process text from images"
            ) {
                showingImagePicker = true
            }
        }
        .sheet(isPresented: $showingNoteSelection) {
            NoteSelectionView { note in
                Task {
                    await viewModel.processNote(note)
                }
            }
            .environmentObject(noteService)
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(viewModel: viewModel)
                .onDisappear {
                    if viewModel.currentAnalysis != nil {
                        showDocumentProcessing = true
                    }
                }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(viewModel: viewModel)
                .onDisappear {
                    if viewModel.currentAnalysis != nil {
                        showDocumentProcessing = true
                    }
                }
        }
        .sheet(isPresented: $showDocumentProcessing) {
            DocumentProcessingView(viewModel: viewModel)
                .environmentObject(noteService)
        }
        .overlay(
            Group {
                if showLoadingPopup {
                    LoadingPopupView(isVisible: $showLoadingPopup)
                }
            }
        )
        .onChange(of: viewModel.isProcessing) { isProcessing in
            showLoadingPopup = isProcessing
        }
        .onChange(of: viewModel.currentAnalysis) { _ in
            if viewModel.currentAnalysis != nil {
                showDocumentProcessing = true
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 30)
                
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

