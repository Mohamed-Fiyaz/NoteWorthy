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
            VisualEffectView(effect: UIBlurEffect(style: .light))
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Spacer()
                LoadingAnimationView()
                Spacer()
            }
            .padding(30)
            .background(Color.white.opacity(0.9))
            .cornerRadius(15)
            .shadow(radius: 10)
        }
        .opacity(isVisible ? 1 : 0)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: effect)
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = effect
    }
}
