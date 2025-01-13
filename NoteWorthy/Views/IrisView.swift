//
//  IrisView.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 10/01/25.
//

import SwiftUI

struct IrisView: View {
    var body: some View {
        VStack(spacing: 10) {
            
                Image(systemName: "eye.fill")
                    .font(.system(size: 34))
                    .padding(.top, 100)
                Text("Iris")
                    .font(.custom("JetBrainsMono-Regular", size: 34))
            
            Text("Make your studying more efficient\nwith Iris")
                .font(.custom("JetBrainsMono-Regular", size: 24))
                .multilineTextAlignment(.center)
                .padding(.top, 30)
            
            VStack(spacing: 20) {
                Button(action: {}) {
                    HStack {
                        Image(systemName: "doc.text")
                            .foregroundColor(.primary)
                        Text("Summarize")
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "lightbulb")
                            .foregroundColor(.primary)
                        Text("Practice")
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                }

                Button(action: {}) {
                    HStack {
                        Image(systemName: "doc.badge.plus")
                            .foregroundColor(.primary)
                        Text("Upload")
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                }

            }
            .padding(.horizontal, 40)
            .padding(.top, 50)
            
            Spacer()
        }
    }
}

#Preview {
    IrisView()
}
