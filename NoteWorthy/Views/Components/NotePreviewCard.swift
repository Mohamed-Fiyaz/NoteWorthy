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
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                
                Text(note.title)
                    .foregroundColor(.black)
                    .font(.headline) // Keep the font size as before
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center) // Center-align title
                    .lineLimit(1)
                
                if !isCompact {
                    Text(note.content)
                        .foregroundColor(.gray)
                        .font(.subheadline) // Keep content font size consistent
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
            .frame(width: isCompact ? 140 : 200, height: isCompact ? 100 : 130) // Reduced rectangle size
            .background(Color(hex: note.colorHex))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            if showStar {
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
