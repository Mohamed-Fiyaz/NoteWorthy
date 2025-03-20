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
    var showStar: Bool = true
    
    var body: some View {
        ZStack {
            // Background and content
            VStack(alignment: .center, spacing: 8) {
                Spacer()
                
                Text(note.title)
                    .foregroundColor(.black)
                    .font(.headline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                
                if !isCompact {
                    Text(note.content)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding()
            .frame(width: isCompact ? 140 : 200, height: isCompact ? 100 : 130)
            .background(Color(hex: note.colorHex))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            // Icons overlay
            VStack {
                HStack {
                    // Star icon in top left
                    if showStar {
                        Image(systemName: note.isFavorite ? "star.fill" : "star")
                            .foregroundColor(note.isFavorite ? .yellow : .gray)
                            .padding(8)
                            .onTapGesture {
                                noteService.toggleFavorite(note)
                            }
                    }
                    
                    Spacer()
                    
                    // Sparkle icon in top right
                    if note.isAIGenerated {
                        Image(systemName: "sparkle")
                            .foregroundColor(.blue)
                            .padding(8)
                    }
                }
                Spacer()
            }
            .frame(width: isCompact ? 140 : 200, height: isCompact ? 100 : 130)
        }
    }
}
