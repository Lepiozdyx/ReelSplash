//
//  BackgroundMusic.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/19/25.
//

import AVFoundation

final class BackgroundMusic {
    static let shared = BackgroundMusic()

    private var player: AVAudioPlayer?
    private(set) var isOn: Bool = true   // логический флаг "музыка включена"

    private init() {
        let defaults = UserDefaults.standard

        // читаем сохранённые настройки или подставляем значения по умолчанию
        let savedIsOn = defaults.object(forKey: "music_isOn") as? Bool ?? true
        let savedVolume = defaults.object(forKey: "music_volume") as? Float ?? 1.0

        isOn = savedIsOn

        if let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1   // бесконечный цикл
                player?.volume = savedVolume
                player?.prepareToPlay()
            } catch {
                print("Failed to initialize background music: \(error)")
            }
        } else {
            print("Background music file not found in bundle")
        }
    }

    func play() {
        guard isOn else { return }
        player?.play()
    }

    func pause() {
        player?.pause()
    }

    /// Включить/выключить музыку логически (без смены scenePhase).
    func setEnabled(_ enabled: Bool) {
        isOn = enabled
        UserDefaults.standard.set(enabled, forKey: "music_isOn")

        if enabled {
            player?.play()
        } else {
            player?.pause()
        }
    }

    /// Регулировка громкости от 0.0 до 1.0
    func setVolume(_ value: Float) {
        player?.volume = value
        UserDefaults.standard.set(value, forKey: "music_volume")
    }
}
