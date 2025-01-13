//
//  UserGreetingView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 13/01/25.
//

import SwiftUI

struct UserGreetingView: View {
    let userName: String
    
    var body: some View {
        HStack {
            Text("Hi, \(userName)")
                .font(.system(size: 24, weight: .regular, design: .default))
                .padding(.leading)
            Spacer()
        }
    }
}

