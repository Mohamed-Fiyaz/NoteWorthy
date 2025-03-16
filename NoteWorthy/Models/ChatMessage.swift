//
//  ChatMessage.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 16/03/25.
//

import Foundation
import SwiftUI

enum MessageType {
    case user
    case assistant
}

struct ChatMessage: Identifiable {
    var id: String
    var content: String
    var type: MessageType
    var timestamp: Date
    
    var formattedContent: AttributedString {
        try! AttributedString(markdown: content)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
}

