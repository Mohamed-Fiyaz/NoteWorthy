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
        model = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey)
    }
    
    func analyzeDocument(_ text: String) async throws -> DocumentAnalysis {
        let prompt = """
        Analyze the following document and provide:
        1. A concise summary
        2. Main topics
        3. Key concepts
        4. Important points and insights

        Document:
        \(text)

        Format your response as JSON with the following keys:
        {
            "summary": "Complete summary here",
            "mainTopics": ["topic 1", "topic 2", ...],
            "keyConcepts": ["concept 1", "concept 2", ...],
            "importantPoints": ["point 1", "point 2", ...]
        }
        """
        
        let response = try await model.generateContent(prompt)
        guard let responseText = response.text else {
            throw NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No response text"])
        }
        
        // Extract JSON content
        if let jsonStartIndex = responseText.firstIndex(of: "{"),
           let jsonEndIndex = responseText.lastIndex(of: "}") {
            let jsonString = String(responseText[jsonStartIndex...jsonEndIndex])
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw NSError(domain: "GeminiService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to convert response to data"])
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(DocumentAnalysis.self, from: jsonData)
        } else {
            throw NSError(domain: "GeminiService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not find valid JSON in response"])
        }
    }
    
    func chat(prompt: String) async throws -> String {
        // Enhanced chat prompt that better handles document context
        let wrappedPrompt = """
        User Message:
        \(prompt)
        
        Respond in a helpful, concise manner with accurate information. If document content is provided as context, use it to provide detailed and specific answers. If asked about specific information from the document, quote relevant sections when possible to support your answer.
        """
        
        let response = try await model.generateContent(wrappedPrompt)
        return response.text ?? "Unable to generate response"
    }
    
    func generateQA(text: String) async throws -> [String: Any] {
        let prompt = """
        Generate 5-10 question and answer pairs for the following content. The questions should cover the main points and important details.
        
        Content:
        \(text)
        
        Format your response as JSON with the following structure:
        {
            "questions": [
                {
                    "question": "Question 1",
                    "answer": "Answer 1"
                },
                {
                    "question": "Question 2",
                    "answer": "Answer 2"
                },
                ...
            ]
        }
        """
        
        let response = try await model.generateContent(prompt)
        guard let responseText = response.text else {
            throw NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No response text"])
        }
        
        // Extract JSON content
        let jsonPattern = "\\{[\\s\\S]*\\}"
        let regex = try NSRegularExpression(pattern: jsonPattern, options: [])
        let range = NSRange(responseText.startIndex..., in: responseText)
        
        guard let match = regex.firstMatch(in: responseText, options: [], range: range),
              let jsonRange = Range(match.range, in: responseText) else {
            throw NSError(domain: "GeminiService", code: 5, userInfo: [NSLocalizedDescriptionKey: "No JSON found in response"])
        }
        
        let jsonStr = String(responseText[jsonRange])
        
        guard let jsonData = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "GeminiService", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
        }
        
        // Make sure the expected structure is there
        if json["questions"] as? [[String: String]] == nil {
            throw NSError(domain: "GeminiService", code: 7, userInfo: [NSLocalizedDescriptionKey: "Missing questions array in response"])
        }
        
        return json
    }
    
    // Function to extract specific information from a document
    func extractInformation(fromDocument text: String, query: String) async throws -> String {
        let prompt = """
        I have the following document content and a specific query about it. Please answer the query based only on the information in the document. If the answer is not in the document, please indicate that.
        
        Document content:
        \(text)
        
        Query: \(query)
        
        Please provide a detailed and specific answer.
        """
        
        let response = try await model.generateContent(prompt)
        return response.text ?? "Unable to extract information"
    }
    
    // Function to search for specific terms in a document
    func searchInDocument(text: String, searchTerm: String) async throws -> String {
        let prompt = """
        Find and extract all relevant information about "\(searchTerm)" from the following document:
        
        Document content:
        \(text)
        
        If "\(searchTerm)" is mentioned, please provide:
        1. The context in which it appears
        2. Any relevant details associated with it
        3. Direct quotes containing the term, if possible
        
        If "\(searchTerm)" is not found in the document, please indicate that.
        """
        
        let response = try await model.generateContent(prompt)
        return response.text ?? "Unable to search document"
    }
}
