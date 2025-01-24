//
//  GeminiService.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import GoogleGenerativeAI

class GeminiService {
    private let model: GenerativeModel
    
    init(apiKey: String) {
        model = GenerativeModel(name: "gemini-pro", apiKey: apiKey)
    }
    
    func summarizeText(_ text: String) async throws -> String {
        let prompt = """
        Please provide a concise summary of the following text, highlighting the key points:
        
        \(text)
        """
        
        let response = try await model.generateContent(prompt)
        return response.text ?? "Unable to generate summary"
    }
    
    func generateQuestions(_ text: String) async throws -> [String] {
        let prompt = """
        Based on the following text, generate 5 practice questions that test understanding:
        
        \(text)
        """
        
        let response = try await model.generateContent(prompt)
        let questionsText = response.text ?? ""
        return questionsText.components(separatedBy: "\n").filter { !$0.isEmpty }
    }
    
    func analyzeDocument(_ text: String) async throws -> DocumentAnalysis {
        // Truncate very long text to avoid API limitations
        let truncatedText = String(text.prefix(10000))
        
        let prompt = """
        Analyze the following document and provide a structured JSON response with:
        1. Main topics
        2. Key concepts
        3. Summary
        4. Important points

        Ensure the response is a valid JSON object matching this structure:
        {
            "mainTopics": ["Topic 1", "Topic 2"],
            "keyConcepts": ["Concept 1", "Concept 2"],
            "summary": "A concise summary of the document",
            "importantPoints": ["Point 1", "Point 2"]
        }

        Document:
        \(truncatedText)
        """
        
        do {
            let response = try await model.generateContent(prompt)
            
            // Attempt to clean and parse the response
            guard let responseText = response.text else {
                throw NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No response text"])
            }
            
            // Extract JSON-like content between { and }
            if let jsonStartIndex = responseText.firstIndex(of: "{"),
               let jsonEndIndex = responseText.lastIndex(of: "}") {
                let jsonString = String(responseText[jsonStartIndex...jsonEndIndex])
                
                guard let jsonData = jsonString.data(using: .utf8) else {
                    throw NSError(domain: "GeminiService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert response to data"])
                }
                
                // Use lenient JSON decoding
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                return try decoder.decode(DocumentAnalysis.self, from: jsonData)
            } else {
                throw NSError(domain: "GeminiService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not find valid JSON in response"])
            }
        } catch {
            print("Document Analysis Error: \(error)")
            throw NSError(domain: "GeminiService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse document analysis: \(error.localizedDescription)"])
        }
    }
}
