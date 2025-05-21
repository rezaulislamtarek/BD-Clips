//
//  BD_ClipsApp.swift
//  BD Clips
//
//  Created by Rezaul Islam on 5/21/25.
//

import SwiftUI

@main
struct BD_ClipsApp: App {
    @StateObject private var state : AppState = AppState()
    var body: some Scene {
        WindowGroup {
            ClipView()
                .environmentObject(state)
        }
    }
}
