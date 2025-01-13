//
//  NotePreviewCard.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import SwiftUI

struct NotePreviewCard: View {
    @ObservedObject var noteService: NoteService
    let note: Note
    var isCompact: Bool = false
    var showStar: Bool = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    Text(note.title)
                        .foregroundColor(.black)
                        .font(.headline)
                        .lineLimit(1)
                    Spacer()
                }
                if !isCompact {
                    Text(note.content)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .lineLimit(2)
                }
            }
            .padding()
            .frame(width: isCompact ? 120 : 200, height: isCompact ? 120 : 150)
            .background(Color(hex: note.colorHex))
            .cornerRadius(10)
            .shadow(radius: 2)
            
            if showStar {
                // Update star button to use local state
                Image(systemName: note.isFavorite ? "star.fill" : "star")
                    .foregroundColor(note.isFavorite ? .yellow : .gray)
                    .padding(8)
                    .onTapGesture {
                        noteService.toggleFavorite(note)
                    }
            }
        }
    }
}
