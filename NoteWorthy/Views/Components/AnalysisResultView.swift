//
//  AnalysisResultView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import SwiftUI

struct AnalysisResultView: View {
    let analysis: DocumentAnalysis
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionViewAnalysis(title: "Summary", content: analysis.summary)
            
            SectionWithConditionalContent(
                title: "Main Topics",
                items: analysis.mainTopics,
                emptyReason: "Not enough context to extract main topics."
            )
            
            SectionWithConditionalContent(
                title: "Key Concepts",
                items: analysis.keyConcepts,
                emptyReason: "Unable to identify key concepts from the text."
            )
            
            SectionWithConditionalContent(
                title: "Important Points",
                items: analysis.importantPoints,
                emptyReason: "The document might be too short or lack sufficient detail."
            )
        }
    }
}

struct SectionWithConditionalContent: View {
    let title: String
    let items: [String]
    let emptyReason: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            if items.isEmpty {
                Text(emptyReason)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(items, id: \.self) { item in
                    Text("• \(item)")
                }
            }
        }
    }
}
