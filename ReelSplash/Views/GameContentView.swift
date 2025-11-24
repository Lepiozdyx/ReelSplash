//
//  ContentView.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/19/25.
//

import SwiftUI

struct GameContentView: View {
    @StateObject private var playerStats = PlayerStats()

    var body: some View {
        ZStack {
            MainMenuView()
        }
        .environmentObject(playerStats)
        .onAppear {
            OrientationManager.shared.forceLandscape()
        }
    }
}
