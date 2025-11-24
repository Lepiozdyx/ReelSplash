//
//  LoadingView.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/14/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue.opacity(0.5), .blue], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            Image(.menuLogo)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
            
            VStack {
                Spacer()
                ProgressView()
            }.padding(.bottom)
        }
    }
}

#Preview {
    LoadingView()
}
