//
//  AppDelegate.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/19/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var manager = StateManager()
        
    var body: some View {
        Group {
            switch manager.appState {
            case .request:
                LoadingView()
                
            case .support:
                if let url = manager.networkManager.reelSplashURL {
                    WKWebViewManager(
                        url: url,
                        webManager: manager.networkManager
                    )
                } else {
                    WKWebViewManager(
                        url: NetworkManager.initURL,
                        webManager: manager.networkManager
                    )
                }
                
            case .loading:
                GameContentView()
            }
        }
        .onAppear {
            manager.stateRequest()
        }
    }
}

#Preview {
    ContentView()
}
