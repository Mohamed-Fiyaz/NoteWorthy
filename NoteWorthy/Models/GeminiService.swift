//
//  GeminiService.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation

class GeminiService {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent"
    
    init(apiKey: String) {
        self.apiKey = apiKey
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

        
        let response = try await sendRequest(prompt: prompt)
        return try parseAnalysisResponse(response)
    }
    
    func chat(prompt: String) async throws -> String {
        let wrappedPrompt = """
        User Message:
        \(prompt)
        
        Respond in a helpful, concise manner with accurate information.
        """
        
        let response = try await sendRequest(prompt: wrappedPrompt)
        return try parseChatResponse(response)
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
        
        let response = try await sendRequest(prompt: prompt)
        return try parseQAResponse(response)
    }
    
    private func sendRequest(prompt: String) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
            throw NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "GeminiService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard let responseJSON = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "GeminiService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON response"])
        }
        
        return responseJSON
    }
    
    private func parseAnalysisResponse(_ response: [String: Any]) throws -> DocumentAnalysis {
        guard let candidates = response["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw NSError(domain: "GeminiService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }

        // Extract the JSON part from the response
        guard let jsonStartIndex = text.firstIndex(of: "{"),
              let jsonEndIndex = text.lastIndex(of: "}") else {
            throw NSError(domain: "GeminiService", code: 5, userInfo: [NSLocalizedDescriptionKey: "No JSON found in response"])
        }

        let jsonStr = String(text[jsonStartIndex...jsonEndIndex])

        guard let jsonData = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "GeminiService", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
        }

        guard let mainTopics = json["mainTopics"] as? [String],
              let keyConcepts = json["keyConcepts"] as? [String],
              let summary = json["summary"] as? String,
              let importantPoints = json["importantPoints"] as? [String] else {
            throw NSError(domain: "GeminiService", code: 7, userInfo: [NSLocalizedDescriptionKey: "Missing required fields in JSON"])
        }

        return DocumentAnalysis(mainTopics: mainTopics, keyConcepts: keyConcepts, summary: summary, importantPoints: importantPoints)
    }

    
    private func parseChatResponse(_ response: [String: Any]) throws -> String {
        guard let candidates = response["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw NSError(domain: "GeminiService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        return text
    }
    
    private func parseQAResponse(_ response: [String: Any]) throws -> [String: Any] {
        guard let candidates = response["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw NSError(domain: "GeminiService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        // Extract the JSON part from the response
        guard let jsonStartIndex = text.firstIndex(of: "{"),
              let jsonEndIndex = text.lastIndex(of: "}") else {
            throw NSError(domain: "GeminiService", code: 5, userInfo: [NSLocalizedDescriptionKey: "No JSON found in response"])
        }
        
        let jsonStr = String(text[jsonStartIndex...jsonEndIndex])
        
        guard let jsonData = jsonStr.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "GeminiService", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON"])
        }
        
        return json
    }
}
