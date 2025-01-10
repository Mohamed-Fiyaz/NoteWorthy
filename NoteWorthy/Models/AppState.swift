//
//  AppState.swift
//  NoteWorthy
//
//  Created by Mohamed Fiyaz on 08/01/25.
//

import Foundation

enum Route: Hashable {
    case main
    case login
    case signUp
}
class AppState: ObservableObject {
    
    @Published var routes: [Route] = []
}
