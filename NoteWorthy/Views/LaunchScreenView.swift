//
//  LaunchScreenView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 06/01/25.
//

import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.553298533, green: 0.7063716054, blue: 0.8822532296, alpha: 1))
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                VStack {
                    Text("NoteWorthy")
                        .font(.custom("PatrickHand-Regular", size: 48))
                        .foregroundColor(.white)
                }
                Spacer()
                HStack {
                    Text("Made By Mohamed Fiyaz")
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
}
