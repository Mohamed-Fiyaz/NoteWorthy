//
//  HeaderView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 22/01/25.
//

import Foundation
import SwiftUI
struct HeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "eye.fill")
                .font(.system(size: 34))
            
            Text("Iris")
                .font(.custom("JetBrainsMono-Regular", size: 34))
            
            Text("Make your studying more efficient with Iris")
                .font(.custom("JetBrainsMono-Regular", size: 24))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
        }
    }
}
