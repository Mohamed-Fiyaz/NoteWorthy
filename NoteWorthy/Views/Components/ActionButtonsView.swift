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
                    showingCameraSheet = true
                }
            )
            
            CustomButton(
                icon: "doc.badge.plus",
                title: "Upload PDF",
                description: "Process PDF documents for analysis",
                action: {
                    viewModel.clearAnalysis()
                    showingDocumentPicker = true
                }
            )
        }
        .sheet(isPresented: $showingNoteSelector) {
            NoteSelectionView { note in
                selectedNote = note
            }
            .environmentObject(noteService)
        }
        .sheet(isPresented: $showingCameraSheet) {
            CameraView(viewModel: viewModel)
                .onDisappear {
                    if viewModel.currentAnalysis != nil {
                        showLoadingPopup = true
                    }
                }
        }
    }
}


