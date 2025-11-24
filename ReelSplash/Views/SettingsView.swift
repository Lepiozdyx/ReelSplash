//
//  Settings.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/11/25.
//

import SwiftUI
import AVFoundation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isMusicOn: Bool = true
    @State private var volume: CGFloat = 0.5
    
    var body: some View {
        ZStack {
            // Фон
            Image("menu_back")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                ZStack {
                    GeometryReader { geo in
                        let w = geo.size.width
                        let h = geo.size.height
                        
                        let sliderWidth = w * 0.6
                        let sliderHeight = h * 0.08
                        
                        ZStack {
                            // Рамка и close button
                            ZStack(alignment: .topTrailing) {
                                Image("menu_frame")
                                    .resizable()
                                    .scaledToFit()
                                
                                Button {
                                    dismiss()
                                } label: {
                                    Image("close_button")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: w * 0.10)
                                }
                                .buttonStyle(.plain)
                                .padding(.trailing, w * 0)
                                .padding(.top, h * 0)
                            }
                            
                            // Контент внутри рамки
                            VStack(alignment: .leading, spacing: h * 0.01) {
                                
                                // MUSIC TITLE + ON / OFF buttons
                                HStack(spacing: w * 0.05) {
                                    Spacer()
                                    
                                    Text("Music")
                                        .font(.custom("JustAnotherHand-Regular", size: h * 0.16))
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.5)
                                    
                                    Spacer()
                                    
                                    Button {
                                        isMusicOn = true
                                        BackgroundMusic.shared.setEnabled(true)
                                    } label: {
                                        Image("on_button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: h * 0.18)
                                            .opacity(isMusicOn ? 1.0 : 0.6)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Button {
                                        isMusicOn = false
                                        BackgroundMusic.shared.setEnabled(false)
                                    } label: {
                                        Image("off_button")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: h * 0.18)
                                            .opacity(!isMusicOn ? 1.0 : 0.6)
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                                // VOLUME
                                HStack {
                                    Spacer()
                                    
                                    VStack(spacing: h * 0.02) {
                                        Text("Volume")
                                            .font(.custom("JustAnotherHand-Regular", size: h * 0.22))
                                            .foregroundColor(.white)
                                            .minimumScaleFactor(0.5)
                                            .frame(maxWidth: .infinity)
                                        
                                        ZStack(alignment: .leading) {
                                            Image("scale_blue")
                                                .resizable()
                                                .frame(width: sliderWidth, height: sliderHeight)
                                            
                                            Image("scale_white")
                                                .resizable()
                                                .frame(width: max(sliderWidth * volume,
                                                                  sliderHeight * 0.3),
                                                       height: sliderHeight)
                                            
                                            Image("slider")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: sliderHeight * 1.4)
                                                .position(
                                                    x: sliderWidth * volume,
                                                    y: sliderHeight / 2
                                                )
                                        }
                                        .contentShape(Rectangle())
                                        .gesture(
                                            DragGesture(minimumDistance: 0)
                                                .onChanged { value in
                                                    let x = min(max(0, value.location.x), sliderWidth)
                                                    volume = x / sliderWidth
                                                    BackgroundMusic.shared.setVolume(Float(volume))
                                                }
                                        )
                                    }
                                    .frame(width: sliderWidth)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                                // LANGUAGE
                                HStack {
                                    Spacer()
                                    
                                    Text("Language")
                                        .font(.custom("JustAnotherHand-Regular", size: h * 0.13))
                                        .foregroundColor(.white)
                                        .minimumScaleFactor(0.5)
                                    
                                    Spacer()
                                    
                                    Button {
                                        // смена языка
                                    } label: {
                                        ZStack {
                                            Image("language_scale")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: h * 0.13)
                                            
                                            Text("English")
                                                .font(.custom("JustAnotherHand-Regular", size: h * 0.14))
                                                .foregroundColor(.white)
                                                .minimumScaleFactor(0.5)
                                                .lineLimit(1)
                                                .padding(.horizontal, 8)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                                
                                // APPLY BUTTON
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        // apply settings
                                    } label: {
                                        ZStack {
                                            Image("button")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: h * 0.18)
                                            
                                            Text("Apply")
                                                .font(.custom("JustAnotherHand-Regular", size: h * 0.15))
                                                .foregroundColor(.white)
                                                .minimumScaleFactor(0.5)
                                                .lineLimit(1)
                                                .padding(.horizontal, 8)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    
                                    Spacer()
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, w * 0.12)
                            .padding(.vertical, h * 0.12)
                        }
                    }
                }
                .frame(maxWidth: 520)
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, UIScreen.main.bounds.height * 0.05)
        }
        .onAppear {
            isMusicOn = BackgroundMusic.shared.isOn
            // Optionally sync volume if needed:
            // BackgroundMusic.shared.player?.volume can be accessed via a getter if added.
        }
    }
}

#Preview {
    SettingsView()
}
