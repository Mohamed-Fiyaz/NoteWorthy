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
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching notes: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.notes = documents.compactMap { document -> Note? in
                    var note = try? document.data(as: Note.self)
                    note?.id = document.documentID
                    return note
                }
            }
    }
    
    func addNote(_ note: Note) {
        do {
            let docRef = try db.collection("notes").addDocument(from: note)
            // Update local array immediately
            var newNote = note
            newNote.id = docRef.documentID
            DispatchQueue.main.async {
                self.notes.insert(newNote, at: 0)
            }
        } catch {
            print("Error adding note: \(error)")
        }
    }
    
    func updateNote(_ note: Note) {
        do {
            try db.collection("notes").document(note.id).setData(from: note)
            // Update local array immediately
            DispatchQueue.main.async {
                if let index = self.notes.firstIndex(where: { $0.id == note.id }) {
                    self.notes[index] = note
                }
            }
        } catch {
            print("Error updating note: \(error)")
        }
    }
    
    func deleteNote(_ note: Note) {
        db.collection("notes").document(note.id).delete { [weak self] error in
            if let error = error {
                print("Error deleting note: \(error)")
            } else {
                // Update local array immediately
                DispatchQueue.main.async {
                    self?.notes.removeAll { $0.id == note.id }
                }
            }
        }
    }
    
    func toggleFavorite(_ note: Note) {
        var updatedNote = note
        updatedNote.isFavorite.toggle()
        // Update local array immediately before sending to Firebase
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isFavorite.toggle()
        }
        updateNote(updatedNote)
    }
}
