//
//  DocumentAnalysis.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
struct DocumentAnalysis: Codable, Equatable {
    let mainTopics: [String]
    let keyConcepts: [String]
    let summary: String
    let importantPoints: [String]
}
