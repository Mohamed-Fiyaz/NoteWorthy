//
//  ActionButtonsView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import SwiftUI

struct ActionButtonsView: View {
    @Binding var showingDocumentPicker: Bool
    @Binding var showingImagePicker: Bool
    @Binding var selectedNote: Note?
    @ObservedObject var viewModel: IrisViewModel
    @Binding var showLoadingPopup: Bool
    @EnvironmentObject var noteService: NoteService
    @State private var showingNoteSelector = false
    @State private var showingCameraSheet = false
    
    var body: some View {
        VStack(spacing: 15) {
            CustomButton(
                icon: "doc.text",
                title: "Summarize Note",
                description: "Get insights from your notes",
                action: {
                    viewModel.clearAnalysis()
                    showingNoteSelector = true
                }
            )
            
            CustomButton(
                icon: "camera",
                title: "Scan Document",
                description: "Capture and process text from images",
                action: {
                    viewModel.clearAnalysis()
                    showLoadingPopup = true // Show loading popup before camera opens
                    showingCameraSheet = true
                }
            )
            
            CustomButton(
                icon: "doc.badge.plus",
                title: "Upload PDF",
                description: "Process PDF documents for analysis",
                action: {
                    viewModel.clearAnalysis()
                    showLoadingPopup = true // Show loading popup before document picker opens
                    showingDocumentPicker = true
                }
            )
        }
        .sheet(isPresented: $showingNoteSelector) {
            NoteSelectionView { note in
                selectedNote = note
                showLoadingPopup = true // Show loading popup when processing a note
                Task {
                    await viewModel.processNote(note)
                }
            }
            .environmentObject(noteService)
        }
        .sheet(isPresented: $showingCameraSheet) {
            CameraView(viewModel: viewModel)
                .onDisappear {
                    // Hide loading popup if camera was dismissed without processing
                    if !viewModel.isProcessing && viewModel.currentAnalysis == nil {
                        showLoadingPopup = false
                    }
                }
        }
        .onChange(of: showingDocumentPicker) { isShowing in
            if !isShowing && !viewModel.isProcessing && viewModel.currentAnalysis == nil {
                // Hide loading popup if document picker was dismissed without processing
                showLoadingPopup = false
            }
        }
        .onChange(of: showingCameraSheet) { isShowing in
            if !isShowing && !viewModel.isProcessing && viewModel.currentAnalysis == nil {
                // Hide loading popup if camera was dismissed without processing
                showLoadingPopup = false
            }
        }
        .onChange(of: viewModel.isProcessing) { isProcessing in
            showLoadingPopup = isProcessing
        }
    }
}
