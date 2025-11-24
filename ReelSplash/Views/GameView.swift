//
//  GameView.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/13/25.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject var playerStats: PlayerStats
    let onClose: () -> Void

    @State private var isGameOver = false
    @State private var gameScene = GameScene()
    // scene is stored in @State as gameScene
     
    var body: some View {
        ZStack {
            SpriteView(scene: gameScene)
                .ignoresSafeArea()

            if isGameOver {
                GameOverView(
                    onTryAgain: restartGame
                )
                .environmentObject(playerStats)
            }
        }
        .onAppear {
            gameScene.size = UIScreen.main.bounds.size
            gameScene.scaleMode = .aspectFill

            // Получаем сигнал Game Over из сцены
            gameScene.onGameOver = { score, _ in
                // сохраняем результат в общей модели
                playerStats.finishGame(with: score)
                isGameOver = true
            }

            // Колбэк закрытия (кнопка close_button в GameScene)
            gameScene.onClose = onClose
        }
    }

    private func restartGame() {
        // Скрываем экран Game Over
        isGameOver = false

        // Обнуляем данные игрока для новой игры (если нужно)
        playerStats.startNewGame()
        
        // Сбрасываем состояние текущей сцены:
        // - обнуляем score
        // - восстанавливаем жизни и сердечки
        // - перезапускаем спавн рыбок
        gameScene.resetGame()
    }
}

#Preview {
    GameView(onClose: {})
        .environmentObject(PlayerStats())
}
 
