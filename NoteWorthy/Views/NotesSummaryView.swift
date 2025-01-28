//
//  NotesSummaryView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

//
//  NotesSummaryView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import SwiftUI
import PDFKit

struct NoteSummaryView: View {
    let note: Note
    @ObservedObject var viewModel: IrisViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isDownloadingPDF = false
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Loading animation at the top
                        if viewModel.isProcessing {
                            LoadingAnimationView()
                        }
                        
                        // Original Note section
                        Text("Original Note")
                            .font(.headline)
                        Text(note.content)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        // Analysis results
                        if let analysis = viewModel.currentAnalysis {
                            AnalysisResultView(analysis: analysis)
                                .id("bottom") // ID for automatic scrolling
                        }
                    }
                    .padding()
                    .onChange(of: viewModel.currentAnalysis) { _ in
                        // Automatically scroll to the bottom when analysis is complete
                        withAnimation {
                            scrollProxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
                .navigationTitle(note.title)
                .navigationBarItems(
                    trailing: Group {
                        if !viewModel.isProcessing {
                            HStack {
                                if let analysis = viewModel.currentAnalysis {
                                    Button(action: downloadPDF) {
                                        Image(systemName: "square.and.arrow.down")
                                    }
                                }
                                
                                Button("Done") {
                                    dismiss()
                                }
                            }
                        }
                    }
                )
                .task {
                    await viewModel.processNote(note)
                }
                .alert(isPresented: $isDownloadingPDF) {
                    Alert(title: Text("PDF Downloaded"),
                          message: Text("The analysis has been saved to your device."),
                          dismissButton: .default(Text("OK")))
                }
            }
        }
    }
    
    func downloadPDF() {
        guard let analysis = viewModel.currentAnalysis else { return }
        
        let documentURL = createPDF(from: analysis)
        
        if documentURL != nil {
            isDownloadingPDF = true
        }
    }
    
    func createPDF(from analysis: DocumentAnalysis) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "NoteWorthy",
            kCGPDFContextTitle: note.title
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { context in
            context.beginPage()
            
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            let textAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                NSAttributedString.Key.foregroundColor: UIColor.black
            ]
            
            let titleString = NSAttributedString(string: note.title, attributes: titleAttributes)
            titleString.draw(at: CGPoint(x: 36, y: 36))
            
            var yPosition: CGFloat = 100
            
            let sections = [
                ("Summary", analysis.summary),
                ("Main Topics", analysis.mainTopics.joined(separator: "\n")),
                ("Key Concepts", analysis.keyConcepts.joined(separator: "\n")),
                ("Important Points", analysis.importantPoints.joined(separator: "\n"))
            ]
            
            for (title, content) in sections {
                let titleString = NSAttributedString(string: title, attributes: [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.black
                ])
                titleString.draw(at: CGPoint(x: 36, y: yPosition))
                yPosition += 30
                
                let contentString = NSAttributedString(string: content.isEmpty ? "No content available" : content, attributes: textAttributes)
                contentString.draw(at: CGPoint(x: 36, y: yPosition))
                yPosition += 60
            }
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("\(note.title)_summary.pdf")
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Could not write PDF file: \(error)")
            return nil
        }
    }
}
