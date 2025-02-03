//
//  CollectionService.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 03/02/25.
//

import FirebaseFirestore
import FirebaseAuth

class CollectionService: ObservableObject {
    private let db = Firestore.firestore()
    @Published var collections: [Collection] = []
    
    func fetchCollections() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("collections")
            .whereField("userId", isEqualTo: userId)
            .order(by: "dateCreated", descending: true)
            .addSnapshotListener { [weak self] querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching collections: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                self?.collections = documents.compactMap { document -> Collection? in
                    var collection = try? document.data(as: Collection.self)
                    collection?.id = document.documentID
                    return collection
                }
            }
    }
    
    func addCollection(_ collection: Collection) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Create the collection data manually to ensure all fields are set
        let collectionData: [String: Any] = [
            "userId": userId,
            "name": collection.name,
            "noteIds": collection.noteIds,
            "dateCreated": Timestamp(date: collection.dateCreated),
            "color": collection.color
        ]
        
        db.collection("collections").addDocument(data: collectionData) { [weak self] error in
            if let error = error {
                print("Error adding collection: \(error)")
            } else {
                self?.fetchCollections()
            }
        }
    }
    
    func updateCollection(_ collection: Collection) {
        guard let id = collection.id else { return }
        
        // Create the update data manually
        let updateData: [String: Any] = [
            "name": collection.name,
            "noteIds": collection.noteIds,
            "color": collection.color
        ]
        
        db.collection("collections").document(id).updateData(updateData) { [weak self] error in
            if let error = error {
                print("Error updating collection: \(error)")
            } else {
                self?.fetchCollections()
            }
        }
    }
    
    func deleteCollection(_ collection: Collection) {
        guard let id = collection.id else { return }
        db.collection("collections").document(id).delete { [weak self] error in
            if let error = error {
                print("Error deleting collection: \(error)")
            } else {
                DispatchQueue.main.async {
                    self?.collections.removeAll { $0.id == id }
                }
            }
        }
    }
    
    func addNoteToCollection(_ note: Note, collection: Collection) {
        var updatedCollection = collection
        if !updatedCollection.noteIds.contains(note.id) {
            updatedCollection.noteIds.append(note.id)
            updateCollection(updatedCollection)
        }
    }
    
    func removeNoteFromCollection(_ note: Note, collection: Collection) {
        var updatedCollection = collection
        updatedCollection.noteIds.removeAll { $0 == note.id }
        updateCollection(updatedCollection)
    }
}
