//
//  IrisDocument.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
struct IrisDocument: Identifiable {
    let id: String
    let title: String
    let content: String
    let type: DocumentType
    let dateCreated: Date
    var summary: String?
    var analysis: DocumentAnalysis?
    
    enum DocumentType: String, Codable {
        case note
        case pdf
        case image
    }
}
