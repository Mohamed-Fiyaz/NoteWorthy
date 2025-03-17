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
    @Published var isChatProcessing = false
    @Published var chatMessages: [ChatMessage] = []
    @Published var attachedDocumentContent: String?
    @Published var attachedDocumentType: String?
    
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
            
            // For chat context
            attachedDocumentContent = text
            attachedDocumentType = "PDF"
            
            isProcessing = false
        } catch {
            handleError(error)
        }
    }
    
    func processPDFWithAnalysis(_ url: URL) async {
        isProcessing = true
        
        do {
            let text = try documentProcessor.extractTextFromPDF(url)
            
            // For chat context
            attachedDocumentContent = text
            attachedDocumentType = "PDF"
            
            // For analysis view
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
            
            // For chat context
            attachedDocumentContent = text
            attachedDocumentType = "image"
            
            isProcessing = false
        } catch {
            handleError(error)
        }
    }
    
    func processImageWithAnalysis(_ image: UIImage) async {
        isProcessing = true
        
        do {
            let text = try await documentProcessor.extractTextFromImage(image)
            
            // For chat context
            attachedDocumentContent = text
            attachedDocumentType = "image"
            
            // For analysis view
            let parsedAnalysis = try await geminiService.analyzeDocument(text)
            currentAnalysis = parsedAnalysis
            isProcessing = false
        } catch {
            handleError(error)
        }
    }
    
    func attachNote(_ note: Note) {
        attachedDocumentContent = note.content
        attachedDocumentType = "note"
    }
    
    func clearAttachedDocument() {
        attachedDocumentContent = nil
        attachedDocumentType = nil
    }
    
    func clearAnalysis() {
        currentAnalysis = nil
    }
    // Add these methods to your IrisViewModel class

    // This method will handle document-specific questions
    func askAboutDocument(question: String) async -> String {
        isChatProcessing = true
        
        do {
            guard let attachedContent = attachedDocumentContent else {
                isChatProcessing = false
                return "There's no document attached. Please attach a document first."
            }
            
            // Use the extractInformation method to get a more focused answer
            let answer = try await geminiService.extractInformation(
                fromDocument: attachedContent,
                query: question
            )
            
            isChatProcessing = false
            return answer
        } catch {
            isChatProcessing = false
            print("Error asking about document: \(error)")
            return "Sorry, I encountered an error processing your question about the document."
        }
    }

    // This method will search for specific terms in the attached document
    func searchInDocument(term: String) async -> String {
        isChatProcessing = true
        
        do {
            guard let attachedContent = attachedDocumentContent else {
                isChatProcessing = false
                return "There's no document attached. Please attach a document first."
            }
            
            let result = try await geminiService.searchInDocument(
                text: attachedContent,
                searchTerm: term
            )
            
            isChatProcessing = false
            return result
        } catch {
            isChatProcessing = false
            print("Error searching in document: \(error)")
            return "Sorry, I encountered an error searching for that term in the document."
        }
    }

    // Modify processMessage to intelligently handle document queries
    func processMessage(_ content: String) async {
        isChatProcessing = true
        
        do {
            var response: String
            
            // Check if the message contains a document-specific query
            let lowercasedContent = content.lowercased()
            let isSearchQuery = lowercasedContent.contains("find") ||
                               lowercasedContent.contains("search") ||
                               lowercasedContent.contains("look for")
            
            let isDocumentQuery = (lowercasedContent.contains("in this") ||
                                  lowercasedContent.contains("from this") ||
                                  lowercasedContent.contains("in the") ||
                                  lowercasedContent.contains("from the")) &&
                                  attachedDocumentContent != nil
            
            if isSearchQuery && attachedDocumentContent != nil {
                // Extract the search term
                var searchTerm = ""
                
                if let range = content.range(of: "find", options: .caseInsensitive) {
                    searchTerm = String(content[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                } else if let range = content.range(of: "search for", options: .caseInsensitive) {
                    searchTerm = String(content[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                } else if let range = content.range(of: "look for", options: .caseInsensitive) {
                    searchTerm = String(content[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if !searchTerm.isEmpty {
                    response = await searchInDocument(term: searchTerm)
                } else {
                    // Use regular chat if we couldn't extract a clear search term
                    var contextualContent = content
                    if let attachedContent = attachedDocumentContent, let docType = attachedDocumentType {
                        contextualContent += "\n\nContext from attached \(docType): \n\(attachedContent)"
                    }
                    response = try await geminiService.chat(prompt: contextualContent)
                }
            } else if isDocumentQuery {
                // For specific questions about the document
                response = await askAboutDocument(question: content)
            } else {
                // Regular chat flow with document context if available
                var contextualContent = content
                if let attachedContent = attachedDocumentContent, let docType = attachedDocumentType {
                    contextualContent += "\n\nContext from attached \(docType): \n\(attachedContent)"
                }
                response = try await geminiService.chat(prompt: contextualContent)
            }
            
            let assistantMessage = ChatMessage(
                id: UUID().uuidString,
                content: response,
                type: .assistant,
                timestamp: Date()
            )
            
            addMessage(assistantMessage)
            isChatProcessing = false
        } catch {
            let errorMsg = "Sorry, I'm having trouble processing your request. Please try again."
            let assistantMessage = ChatMessage(
                id: UUID().uuidString,
                content: errorMsg,
                type: .assistant,
                timestamp: Date()
            )
            addMessage(assistantMessage)
            isChatProcessing = false
            print("Chat error details: \(error)")
        }
    }
    func handleError(_ error: Error) {
        errorMessage = "Operation failed: \(error.localizedDescription)"
        showError = true
        isProcessing = false
        isChatProcessing = false
        print("Error details: \(error)")
    }
}
