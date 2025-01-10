//
//  Model.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 08/01/25.
//

import Foundation
import FirebaseAuth

@MainActor
class Model: ObservableObject {
    func updateDisplayName(for user: User, displayName: String) async throws {
        let request = user.createProfileChangeRequest()
        request.displayName = displayName
        try await request.commitChanges()
    }
}
