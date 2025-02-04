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
    
    let colors = [
        "#F8F8F8", // Light Gray
        "#FFFBF2", // Light Cream
        "#FFE4E1", // Misty Rose
        "#E6F7FF", // Light Sky Blue
        "#E5EAF5", // Lavender Blue
        "#F2F2D9", // Light Pastel Yellow
        "#DCE9E2", // Mint Green
        "#EADFF7", // Light Lilac
        "#D7CCC8", // Light Taupe
        "#C8E6C9", // Pale Green
        "#B2DFDB", // Aquamarine
        "#B3CDE3"  // Dusty Blue
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
                                        .stroke(color == selectedColor ? Color.blue : Color.clear, lineWidth: 2)
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
