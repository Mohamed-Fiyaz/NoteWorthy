//
//  NoteService.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import FirebaseFirestore
import FirebaseAuth

class NoteService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var notes: [Note] = []
    
    func fetchNotes() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("notes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "dateCreated", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                
                self.notes = documents.compactMap { document -> Note? in
                    var note = try? document.data(as: Note.self)
                    note?.id = document.documentID
                    return note
                }
            }
    }
    
    func addNote(_ note: Note) {
        do {
            try db.collection("notes").addDocument(from: note)
        } catch {
            print("Error adding note: \(error)")
        }
    }
    
    func updateNote(_ note: Note) {
        do {
            try db.collection("notes").document(note.id).setData(from: note)
        } catch {
            print("Error updating note: \(error)")
        }
    }
    
    func deleteNote(_ note: Note) {
        db.collection("notes").document(note.id).delete()
    }
    
    func toggleFavorite(_ note: Note) {
        var updatedNote = note
        updatedNote.isFavorite.toggle()
        updateNote(updatedNote)
    }
}
