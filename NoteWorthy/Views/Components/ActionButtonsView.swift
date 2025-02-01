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
                action: {
                    viewModel.clearAnalysis() // Clear previous analysis
                    showingNoteSelector = true
                }
            )
            
            CustomButton(
                icon: "camera",
                title: "Scan Document",
                action: {
                    viewModel.clearAnalysis() // Clear previous analysis
                    showingCameraSheet = true
                }
            )
            
            CustomButton(
                icon: "doc.badge.plus",
                title: "Upload PDF",
                action: {
                    viewModel.clearAnalysis() // Clear previous analysis
                    showingDocumentPicker = true
                }
            )
        }
        .sheet(isPresented: $showingNoteSelector) {
            NoteSelectionView { note in
                selectedNote = note
            }
        }
        .sheet(isPresented: $showingCameraSheet) {
            CameraView(viewModel: viewModel)
        }
    }
}
