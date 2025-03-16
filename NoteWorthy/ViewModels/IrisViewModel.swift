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
    
    @Published var selectedNote: Note?
    @Published var currentAnalysis: DocumentAnalysis?
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var isProcessing = false
    @Published var chatMessages: [ChatMessage] = []
    
    init() {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GEMINI_API_KEY") as? String else {
            fatalError("Gemini API Key not found. Please ensure it's added to the Config.xcconfig file.")
        }
        
        self.geminiService = GeminiService(apiKey: apiKey)
        self.documentProcessor = DocumentProcessingService()
        
        // Add welcome message
        let welcomeMessage = ChatMessage(
            id: UUID().uuidString,
            content: "Hello! I'm Iris, your note assistant. You can ask me questions, upload documents for analysis, or attach notes to get more context-specific answers.",
            type: .assistant,
            timestamp: Date()
        )
        self.chatMessages = [welcomeMessage]
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
    func addMessage(_ message: ChatMessage) {
        chatMessages.append(message)
    }
    
    func processMessage(_ content: String) async {
        isProcessing = true
        
        do {
            let response = try await geminiService.chat(prompt: content)
            
            let assistantMessage = ChatMessage(
                id: UUID().uuidString,
                content: response,
                type: .assistant,
                timestamp: Date()
            )
            
            addMessage(assistantMessage)
            isProcessing = false
        } catch {
            handleError(error)
        }
    }
    
    func generateQA(for noteContent: String) async -> [String: Any]? {
        isProcessing = true
        
        do {
            let qaResult = try await geminiService.generateQA(text: noteContent)
            isProcessing = false
            return qaResult
        } catch {
            handleError(error)
            return nil
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
    
    func handleError(_ error: Error) {
        errorMessage = "Operation failed: \(error.localizedDescription)"
        showError = true
        isProcessing = false
        print("Error details: \(error)")
    }
}
