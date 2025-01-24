//
//  NotesSummaryView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import SwiftUI
struct NoteSummaryView: View {
    let note: Note
    @ObservedObject var viewModel: IrisViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Original Note")
                        .font(.headline)
                    Text(note.content)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    if let analysis = viewModel.currentAnalysis {
                        AnalysisResultView(analysis: analysis)
                    }
                }
                .padding()
            }
            .navigationTitle(note.title)
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .task {
                await viewModel.processNote(note)
            }
        }
    }
}
