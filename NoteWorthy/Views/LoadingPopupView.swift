//
//  LoadingPopupView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 25/01/25.
//

import SwiftUI

struct LoadingPopupView: View {
    @Binding var isVisible: Bool
    
    var body: some View {
        ZStack {
            // White blur background
            VisualEffectView(effect: UIBlurEffect(style: .light))
                .edgesIgnoringSafeArea(.all)
            
            // Loading animation and text
            VStack(spacing: 20) {
                Spacer()
                LoadingAnimationView() // Use the provided LoadingAnimationView
                Spacer()
            }
            .padding(30)
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
        .opacity(isVisible ? 1 : 0) // Show/hide based on isVisible
    }
}

// Helper view for blur effect
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
