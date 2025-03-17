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
        VStack(spacing: 15) {
            Image(systemName: "eye")
                .font(.system(size: 60))
                .foregroundColor(Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1)))
            
            Text("Iris")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your intelligent note assistant")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}
