//
//  Collection.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 03/02/25.
//

import FirebaseFirestore

struct Collection: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    var name: String
    var noteIds: [String]
    let dateCreated: Date
    var color: String  // Added color property
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case noteIds
        case dateCreated
        case color
    }
    
    init(userId: String, name: String, noteIds: [String] = [], color: String = "#8DB4E1") {
        self.userId = userId
        self.name = name
        self.noteIds = noteIds
        self.dateCreated = Date()
        self.color = color
    }
}
