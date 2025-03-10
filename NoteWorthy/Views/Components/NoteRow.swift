//
//  NoteRow.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import SwiftUI

struct NoteRow: View {
    @ObservedObject var noteService: NoteService
    let note: Note
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(note.title)
                    .font(.headline)
                Text(note.content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Image(systemName: note.isFavorite ? "star.fill" : "star")
                .foregroundColor(note.isFavorite ? .yellow : .gray)
                .onTapGesture {
                    noteService.toggleFavorite(note)
                }
        }
        .padding(.vertical, 8)
    }
}


