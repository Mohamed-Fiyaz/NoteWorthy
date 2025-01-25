//
//  LoadingAnimationView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 25/01/25.
//

import SwiftUI

struct LoadingAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    Color.clear
                    
                    HStack(spacing: 10) {
                        ForEach(0..<5) { index in
                            Circle()
                                .fill(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
                                .frame(width: 15, height: 15)
                                .scaleEffect(calculateScale(for: index))
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.1),
                                    value: isAnimating
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
            }
            
            Text("Analyzing...")
                .foregroundColor(.secondary)
                .padding(.top, 10)
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    func calculateScale(for index: Int) -> CGFloat {
        return isAnimating ? (index % 2 == 0 ? 1.2 : 0.8) : 1.0
    }
}

extension Color {
    init(colorLiteral red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }
}
