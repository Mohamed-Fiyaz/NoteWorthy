//
//  SectionView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import SwiftUI
struct SectionViewAnalysis<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, content: String) where Content == Text {
        self.title = title
        self.content = Text(content)
    }
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            content
                .font(.body)
        }
    }
}
