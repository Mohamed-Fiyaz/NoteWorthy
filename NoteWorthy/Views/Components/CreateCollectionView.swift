//
//  CreateCollectionView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 03/02/25.
//

import SwiftUI
import FirebaseAuth

struct CreateCollectionView: View {
    @ObservedObject var collectionService: CollectionService
    @Environment(\.dismiss) private var dismiss
    @State private var collectionName = ""
    @State private var selectedColor = "#8DB4E1"
    
    private let colors = [
        "#8DB4E1", // Blue
        "#FF9B9B", // Red
        "#FFB7B7", // Pink
        "#B1E5F9", // Light Blue
        "#D3B5E5", // Purple
        "#FFD93D", // Yellow
        "#98FF98", // Green
        "#FFC0CB", // Light Pink
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Collection Details")) {
                    TextField("Collection Name", text: $collectionName)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 44))
                    ], spacing: 10) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(Color(hex: color))
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 2 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
            .navigationTitle("New Collection")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Create") {
                    createCollection()
                }
                .disabled(collectionName.isEmpty)
            )
        }
    }
    
    private func createCollection() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let collection = Collection(userId: userId, name: collectionName, color: selectedColor)
        collectionService.addCollection(collection)
        dismiss()
    }
}
