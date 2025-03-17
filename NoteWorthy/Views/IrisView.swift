//
//  IrisView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 10/01/25.
//
import SwiftUI
import UIKit

struct IrisView: View {
    @StateObject private var viewModel = IrisViewModel()
    @State private var showingDocumentPicker = false
    @State private var showingImagePicker = false
    @State private var selectedNote: Note?
    @State private var showingDocumentProcessing = false
    @State private var showLoadingPopup = false
    @EnvironmentObject private var noteService: NoteService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderView()
                
                ActionButtonsView(
                    showingDocumentPicker: $showingDocumentPicker,
                    showingImagePicker: $showingImagePicker,
                    selectedNote: $selectedNote,
                    viewModel: viewModel,
                    showLoadingPopup: $showLoadingPopup
                )
                .environmentObject(noteService)
                
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
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .padding()
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(viewModel: viewModel)
                .onDisappear {
                    if viewModel.currentAnalysis != nil {
                        showingDocumentProcessing = true
                    }
                }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(viewModel: viewModel)
                .onDisappear {
                    if viewModel.currentAnalysis != nil {
                        showingDocumentProcessing = true
                    }
                }
        }
        .sheet(item: $selectedNote) { note in
            NoteSummaryView(note: note, viewModel: viewModel)
        }
        .sheet(isPresented: $showingDocumentProcessing) {
            DocumentProcessingView(viewModel: viewModel)
                .environmentObject(noteService)
                .onDisappear {
                    // Reset when the document processing view is dismissed
                    viewModel.clearAnalysis()
                    // Ensure loading popup is hidden
                    showLoadingPopup = false
                }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .overlay(
            Group {
                if showLoadingPopup || viewModel.isProcessing {
                    LoadingPopupView(isVisible: .constant(true))
                }
            }
        )
        .onChange(of: viewModel.isProcessing) { isProcessing in
            showLoadingPopup = isProcessing
        }
        .onChange(of: viewModel.currentAnalysis) { newValue in
            if newValue != nil {
                showingDocumentProcessing = true
                showLoadingPopup = false  // Hide loading popup when showing document processing
            }
        }
    }
}
