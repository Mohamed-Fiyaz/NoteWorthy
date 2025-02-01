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
            ImagePicker(viewModel: viewModel)
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
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
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
        .onChange(of: viewModel.currentAnalysis) { newValue in
            // Only show document processing for non-note analysis
            if newValue != nil && selectedNote == nil {
                showingDocumentProcessing = true
            }
        }
    }
}
