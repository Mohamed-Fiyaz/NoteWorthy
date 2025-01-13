//
//  Note.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import Foundation
struct Note: Identifiable, Codable {
    var id: String // Firebase document ID
    var title: String
    var content: String
    var dateCreated: Date
    var isFavorite: Bool
    var colorHex: String
    var userId: String // To associate notes with users
    
    init(id: String = UUID().uuidString,
         title: String = "",
         content: String = "",
         colorHex: String = "#FFE4E1",
         userId: String,
         isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.content = content
        self.dateCreated = Date()
        self.isFavorite = isFavorite
        self.colorHex = colorHex
        self.userId = userId
    }
}
