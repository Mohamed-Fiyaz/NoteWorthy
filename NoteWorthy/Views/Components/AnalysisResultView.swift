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
            SectionView(title: "Summary", content: analysis.summary)
            
            SectionView(title: "Main Topics") {
                ForEach(analysis.mainTopics, id: \.self) { topic in
                    Text("• \(topic)")
                }
            }
            
            SectionView(title: "Key Concepts") {
                ForEach(analysis.keyConcepts, id: \.self) { concept in
                    Text("• \(concept)")
                }
            }
            
            SectionView(title: "Important Points") {
                ForEach(analysis.importantPoints, id: \.self) { point in
                    Text("• \(point)")
                }
            }
        }
    }
}
