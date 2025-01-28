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
    @State private var processingDocument = false
    @EnvironmentObject private var noteService: NoteService
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HeaderView()
                
                // Action Buttons
                ActionButtonsView(
                    showingDocumentPicker: $showingDocumentPicker,
                    showingImagePicker: $showingImagePicker,
                    selectedNote: $selectedNote,
                    viewModel: viewModel
                )
                .environmentObject(noteService) 
                
                // Results Section
                if let analysis = viewModel.currentAnalysis {
                    AnalysisResultView(analysis: analysis)
                }
                
                // Processing Indicator
                if processingDocument {
                    ProgressView("Processing document...")
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(viewModel: viewModel)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(viewModel: viewModel)
        }
        .sheet(item: $selectedNote) { note in
            NoteSummaryView(note: note, viewModel: viewModel)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

