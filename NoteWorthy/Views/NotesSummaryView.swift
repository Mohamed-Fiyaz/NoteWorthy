//
//  NotesSummaryView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct NoteSummaryView: View {
    let note: Note
    @ObservedObject var viewModel: IrisViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    
    var body: some View {
        NavigationView {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isProcessing {
                            LoadingAnimationView()
                        }
                        
                        Text("Original Note")
                            .font(.headline)
                        Text(note.content)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
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
                .navigationTitle(note.title)
                .navigationBarItems(
                    trailing: Group {
                        if !viewModel.isProcessing {
                            HStack {
                                if let analysis = viewModel.currentAnalysis {
                                    Button(action: {
                                        createAndSharePDF(from: analysis)
                                    }) {
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
                .sheet(isPresented: $showShareSheet, content: {
                    if let url = pdfURL {
                        ShareSheet(activityItems: [url])
                    }
                })
            }
        }
    }
    
    private func createAndSharePDF(from analysis: DocumentAnalysis) {
        let pdfData = generatePDFData(from: analysis)
        
        do {
            let tempDir = FileManager.default.temporaryDirectory
            let fileName = "\(note.title)_summary_\(Date().timeIntervalSince1970).pdf"
            let fileURL = tempDir.appendingPathComponent(fileName)
            try pdfData.write(to: fileURL)
            self.pdfURL = fileURL
            self.showShareSheet = true
        } catch {
            print("Error saving PDF: \(error.localizedDescription)")
        }
    }
    
    private func generatePDFData(from analysis: DocumentAnalysis) -> Data {
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
        
        return renderer.pdfData { context in
            context.beginPage()
            var yPosition: CGFloat = 50
            let marginX: CGFloat = 50
            let marginBottom: CGFloat = 50
            let contentWidth = pageWidth - (marginX * 2)
            
            // Helper function to measure content height
            func measureContentHeight(_ content: [String], withAttributes attrs: [NSAttributedString.Key: Any]) -> CGFloat {
                return content.reduce(0) { totalHeight, item in
                    let itemText = NSAttributedString(string: "• \(item)", attributes: attrs)
                    let height = itemText.boundingRect(
                        with: CGSize(width: contentWidth, height: .infinity),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        context: nil
                    ).height + 10
                    return totalHeight + height
                }
            }
            
            // Helper function to check if content fits on current page
            func willContentFitOnPage(headerHeight: CGFloat, contentHeight: CGFloat) -> Bool {
                return (yPosition + headerHeight + contentHeight) <= (pageHeight - marginBottom)
            }
            
            // Configure text styles
            let titleStyle = NSMutableParagraphStyle()
            titleStyle.alignment = .left
            titleStyle.lineSpacing = 6
            
            let contentStyle = NSMutableParagraphStyle()
            contentStyle.alignment = .left
            contentStyle.lineSpacing = 6
            contentStyle.paragraphSpacing = 10
            
            // Text attributes
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black,
                .paragraphStyle: titleStyle
            ]
            
            let headingAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black,
                .paragraphStyle: contentStyle
            ]
            
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.black,
                .paragraphStyle: contentStyle
            ]
            
            // Draw title
            let titleString = NSAttributedString(string: note.title, attributes: titleAttributes)
            titleString.draw(in: CGRect(x: marginX, y: yPosition, width: contentWidth, height: 50))
            yPosition += 60
            
            // Draw date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let dateString = NSAttributedString(
                string: "Generated: \(dateFormatter.string(from: Date()))",
                attributes: contentAttributes
            )
            dateString.draw(in: CGRect(x: marginX, y: yPosition, width: contentWidth, height: 20))
            yPosition += 40
            
            // Function to draw a section
            func drawSection(title: String, content: [String]) {
                let headerHeight: CGFloat = 40
                let contentHeight = measureContentHeight(content, withAttributes: contentAttributes)
                
                // Check if header and at least first content item will fit
                if !willContentFitOnPage(headerHeight: headerHeight, contentHeight: contentHeight) {
                    context.beginPage()
                    yPosition = 50
                }
                
                // Draw section title
                let sectionTitle = NSAttributedString(string: title, attributes: headingAttributes)
                sectionTitle.draw(in: CGRect(x: marginX, y: yPosition, width: contentWidth, height: headerHeight))
                yPosition += headerHeight
                
                // Draw section content
                for (index, item) in content.enumerated() {
                    let itemText = title == "Summary" ? item : "• \(item)"
                    let itemString = NSAttributedString(string: itemText, attributes: contentAttributes)
                    
                    let itemHeight = itemString.boundingRect(
                        with: CGSize(width: contentWidth, height: .infinity),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        context: nil
                    ).height + 10
                    
                    // If this item won't fit, start a new page
                    if yPosition + itemHeight > pageHeight - marginBottom {
                        context.beginPage()
                        yPosition = 50
                        
                        // If this is the first item, redraw the section header
                        if index == 0 {
                            sectionTitle.draw(in: CGRect(x: marginX, y: yPosition, width: contentWidth, height: headerHeight))
                            yPosition += headerHeight
                        }
                    }
                    
                    itemString.draw(in: CGRect(x: marginX, y: yPosition, width: contentWidth, height: itemHeight))
                    yPosition += itemHeight
                }
                
                yPosition += 20 // Add spacing after section
            }
            
            // Draw all sections
            drawSection(title: "Summary", content: [analysis.summary])
            drawSection(title: "Main Topics", content: analysis.mainTopics)
            drawSection(title: "Key Concepts", content: analysis.keyConcepts)
            drawSection(title: "Important Points", content: analysis.importantPoints)
        }
    }
    
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: nil
            )
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}
