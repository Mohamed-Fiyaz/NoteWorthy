//
//  NoteService.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class NoteService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var notes: [Note] = []
    @Published var isLoading = false
    private var listener: ListenerRegistration?
    
    init() {
        // Don't auto-fetch on initialization
        // Let views control when to fetch
    }
    
    deinit {
        // Remove listener when service is deallocated
        listener?.remove()
    }
    
    func fetchNotes() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.isLoading = false
            return
        }
        
        // Set loading state
        self.isLoading = true
        
        // Remove existing listener if any
        listener?.remove()
        
        // Create new listener
        listener = db.collection("notes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "dateCreated", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let self = self else { return }
                
                // Always update loading state when complete
                defer {
                    DispatchQueue.main.async {
                        self.isLoading = false
                    }
                }
                
                if let error = error {
                    print("Error fetching notes: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found")
                    // Clear notes if no documents
                    DispatchQueue.main.async {
                        self.notes = []
                    }
                    return
                }
                
                // Process fetched notes
                let fetchedNotes = documents.compactMap { document -> Note? in
                    do {
                        var note = try document.data(as: Note.self)
                        note.id = document.documentID
                        return note
                    } catch {
                        print("Error decoding note: \(error)")
                        return nil
                    }
                }
                
                // Update on main thread
                DispatchQueue.main.async {
                    self.notes = fetchedNotes
                    print("Notes updated: \(fetchedNotes.count) notes loaded")
                }
            }
    }
    
    // Force an immediate fetch with completion handler
    func forceRefresh(completion: @escaping () -> Void = {}) {
        guard let userId = Auth.auth().currentUser?.uid else {
            DispatchQueue.main.async {
                self.isLoading = false
                completion()
            }
            return
        }
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        db.collection("notes")
            .whereField("userId", isEqualTo: userId)
            .order(by: "dateCreated", descending: true)
            .getDocuments { [weak self] querySnapshot, error in
                guard let self = self else {
                    completion()
                    return
                }
                
                // Always update loading state when complete
                defer {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion()
                    }
                }
                
                if let error = error {
                    print("Error in forceRefresh: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No documents found in forceRefresh")
                    // Clear notes if no documents
                    DispatchQueue.main.async {
                        self.notes = []
                    }
                    return
                }
                
                // Process fetched notes
                let fetchedNotes = documents.compactMap { document -> Note? in
                    do {
                        var note = try document.data(as: Note.self)
                        note.id = document.documentID
                        return note
                    } catch {
                        print("Error decoding note: \(error)")
                        return nil
                    }
                }
                
                // Update on main thread
                DispatchQueue.main.async {
                    self.notes = fetchedNotes
                    print("forceRefresh complete: \(fetchedNotes.count) notes loaded")
                }
            }
    }
    
    func addNote(_ note: Note) {
        do {
            let docRef = try db.collection("notes").addDocument(from: note)
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
        guard !note.id.isEmpty else {
            print("Cannot update note with empty ID")
            return
        }
        
        do {
            try db.collection("notes").document(note.id).setData(from: note)
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
        guard !note.id.isEmpty else {
            print("Cannot delete note with empty ID")
            return
        }
        
        db.collection("notes").document(note.id).delete { [weak self] error in
            if let error = error {
                print("Error deleting note: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.notes.removeAll { $0.id == note.id }
                }
            }
        }
    }
    
    func toggleFavorite(_ note: Note) {
        var updatedNote = note
        updatedNote.isFavorite.toggle()
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].isFavorite.toggle()
        }
        updateNote(updatedNote)
    }
}
