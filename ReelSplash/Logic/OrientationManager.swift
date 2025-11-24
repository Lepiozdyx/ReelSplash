//
//  OrientationManager.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/19/25.
//

import UIKit

final class OrientationManager {
    static let shared = OrientationManager()

    private init() {}

    // Маска ориентаций по умолчанию (как в шаблоне: всё, кроме вверх ногами)
    var orientationMask: UIInterfaceOrientationMask = .allButUpsideDown

    /// Лочим ориентацию в landscapeRight.
    func forceLandscape() {
        lock(mask: .landscapeRight, rotateTo: .landscapeRight)
    }

    /// Возвращаем дефолтный портрет и стандартную маску.
    func resetToDefault() {
        lock(mask: .allButUpsideDown, rotateTo: .portrait)
    }

    private func lock(mask: UIInterfaceOrientationMask,
                      rotateTo orientation: UIInterfaceOrientation) {
        orientationMask = mask

        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}
