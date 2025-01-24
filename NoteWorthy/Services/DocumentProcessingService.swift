//
//  DocumentProcessingService.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import Vision
import PDFKit

class DocumentProcessingService {
    func extractTextFromPDF(_ url: URL) throws -> String {
        guard let document = PDFDocument(url: url) else {
            throw NSError(domain: "PDFProcessing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to load PDF"])
        }
        
        var text = ""
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }
            text += page.string ?? ""
        }
        return text
    }
    
    func extractTextFromImage(_ image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageProcessing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to get CGImage"])
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        let request = VNRecognizeTextRequest()
        try await requestHandler.perform([request])
        
        return request.results?
            .compactMap({ $0.topCandidates(1).first?.string })
            .joined(separator: "\n") ?? ""
    }
}
