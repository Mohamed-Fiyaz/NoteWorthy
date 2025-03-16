//
//  AttachmentPickerView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 16/03/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct AttachmentPickerView: View {
    @Binding var selectedURL: URL?
    @Binding var selectedImage: UIImage?
    @ObservedObject var viewModel: IrisViewModel
    
    @State private var isDocumentPickerPresented = false
    @State private var isImagePickerPresented = false
    @State private var isNoteSelectionPresented = false

    var body: some View {
        VStack(spacing: 20) {
            Button("Pick a Document") {
                isDocumentPickerPresented = true
            }
            .sheet(isPresented: $isDocumentPickerPresented) {
                DocumentPicker(viewModel: viewModel)
            }

            Button("Pick an Image") {
                isImagePickerPresented = true
            }
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerView(viewModel: viewModel)
            }

            Button("Select a Note") {
                isNoteSelectionPresented = true
            }
            .sheet(isPresented: $isNoteSelectionPresented) {
                NoteSelectionView { selectedNote in
                    viewModel.selectedNote = selectedNote
                }
            }
        }
        .padding()
    }
}
