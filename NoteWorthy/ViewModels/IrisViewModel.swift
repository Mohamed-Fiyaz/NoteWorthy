//
//  IrisViewModel.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import UIKit
import SwiftUI

@MainActor
class IrisViewModel: ObservableObject {
    private let geminiService: GeminiService
    private let documentProcessor: DocumentProcessingService
    
    @Published var currentAnalysis: DocumentAnalysis?
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isProcessing = false
    
    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String else {
            fatalError("Gemini API Key not found. Please ensure it's added to the Config.xcconfig file.")
        }
        
        self.geminiService = GeminiService(apiKey: apiKey)
        self.documentProcessor = DocumentProcessingService()
    }
    
    func processNote(_ note: Note) async {
        isProcessing = true
        
        do {
            let parsedAnalysis = try await geminiService.analyzeDocument(note.content)
            currentAnalysis = parsedAnalysis
            isProcessing = false
        } catch {
            handleError(error)
        }
    }
    
    func processPDF(_ url: URL) async {
        isProcessing = true
        
        do {
            let text = try documentProcessor.extractTextFromPDF(url)
            let parsedAnalysis = try await geminiService.analyzeDocument(text)
            currentAnalysis = parsedAnalysis
            isProcessing = false
        } catch {
            handleError(error)
        }
    }
    
    func processImage(_ image: UIImage) async {
        isProcessing = true
        
        do {
            let text = try await documentProcessor.extractTextFromImage(image)
            let parsedAnalysis = try await geminiService.analyzeDocument(text)
            currentAnalysis = parsedAnalysis
            isProcessing = false
        } catch {
            handleError(error)
        }
    }
    
    func clearAnalysis() {
        currentAnalysis = nil
    }
    
    private func handleError(_ error: Error) {
        errorMessage = "Analysis failed: \(error.localizedDescription)"
        showError = true
        isProcessing = false
        print("Error details: \(error)")
    }
}
