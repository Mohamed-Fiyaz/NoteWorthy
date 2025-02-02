//
//  DocumentProcessingView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 28/01/25.
//

import SwiftUI
import FirebaseAuth

struct DocumentProcessingView: View {
    @ObservedObject var viewModel: IrisViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @EnvironmentObject private var noteService: NoteService
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if let analysis = viewModel.currentAnalysis {
                            AnalysisResultView(analysis: analysis)
                                .id("bottom")
                        }
                    }
                    .padding()
                    .onChange(of: viewModel.currentAnalysis) { _ in
                        withAnimation {
                            scrollProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                .navigationTitle("Document Analysis")
                .navigationBarItems(
                    leading: Group {
                        if let analysis = viewModel.currentAnalysis {
                            Button(action: {
                                saveAsNote(analysis: analysis)
                            }) {
                                Text("Save As Note")
                            }
                        }
                    },
                    trailing: Button("Done") {
                        viewModel.clearAnalysis()
                        dismiss()
                    }
                )
            }
        }
    }
    
    private func saveAsNote(analysis: DocumentAnalysis) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let note = Note(
            title: "Analysis \(Date().formatted(.dateTime))",
            content: analysis.summary,
            colorHex: "#FFE4E1",
            userId: userId,
            isFavorite: false
        )
        
        noteService.addNote(note)
        dismiss()
    }
}

#Preview {
    DocumentProcessingView(viewModel: IrisViewModel())
        .environmentObject(NoteService())
}
