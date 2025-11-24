//
//  GameScene.swift
//  reel_splash
//
//  Created by Alexey Meleshin on 11/11/25.
//

import SpriteKit
import SwiftUI

private enum Lane: String { case left, right, top }

enum FishColor: CaseIterable {
    case blue, red, yellow

    var imageName: String {
        switch self {
        case .blue: return "blue_fish"
        case .red: return "red_fish"
        case .yellow: return "yellow_fish"
        }
    }
}

struct PhysicsCategory {
    static let fish:  UInt32 = 1 << 0
    static let edge0: UInt32 = 1 << 1
    static let edge1: UInt32 = 1 << 2
    static let edge2: UInt32 = 1 << 3
}

final class FishNode: SKSpriteNode {
    let colorType: FishColor

    init(color: FishColor) {
        self.colorType = color
        let texture = SKTexture(imageNamed: color.imageName)
        super.init(texture: texture, color: .clear, size: texture.size())
        setScale(0.5)

        // Добавляем маленькое круговое физ.тело для корректного контакта с рёбрами треугольника
        let body = SKPhysicsBody(circleOfRadius: max(size.width, size.height) * 0.25)
        body.isDynamic = true
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.fish
        body.contactTestBitMask = PhysicsCategory.edge0 | PhysicsCategory.edge1 | PhysicsCategory.edge2
        body.collisionBitMask = 0
        self.physicsBody = body
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - TriangleContainer (visible triangle + 3 edge bodies)
final class TriangleContainer: SKNode {

    private var edgeCentersLocal: [String: CGPoint] = [:]
    func edgeCenter(named name: String, in scene: SKScene) -> CGPoint? {
        guard let p = edgeCentersLocal[name] else { return nil }
        return self.convert(p, to: scene)
    }

    override init() {
        super.init()

        let sprite = SKSpriteNode(imageNamed: "triangle")
        // Поверка вокруг центра по X и на 2/3 по Y (0 внизу текстуры)
        sprite.anchorPoint = CGPoint(x: 0.5, y: 2.0/3.0)
        sprite.setScale(0.6)
        addChild(sprite)

        let _ = sprite.size.width / 2
        let W = sprite.size.width
        let H = sprite.size.height
        // При anchorPoint (0.5, 2/3) локальные координаты углов:
        // верх:   y =  (1 - 2/3) * H =  H/3
        // низ:    y = -2/3 * H       = -2H/3
        // лево/право: x = ±W/2
        let vertices = [
            CGPoint(x: 0,        y:  H/3),   // верхняя вершина
            CGPoint(x: -W/2,     y: -2*H/3), // нижняя левая
            CGPoint(x:  W/2,     y: -2*H/3)  // нижняя правая
        ]

        // Три невидимых ребра как edge-физтела — точный контакт по касанию линии
        var edgeMidpoints: [CGPoint] = []
        var edgeNodes: [SKNode] = []
        for i in 0..<3 {
            let v0 = vertices[i]
            let v1 = vertices[(i + 1) % 3]
            let edgeHolder = SKNode()
            edgeHolder.physicsBody = SKPhysicsBody(edgeFrom: v0, to: v1)
            edgeHolder.physicsBody?.isDynamic = false
            edgeHolder.physicsBody?.collisionBitMask = 0
            addChild(edgeHolder)
            edgeNodes.append(edgeHolder)
            edgeMidpoints.append(CGPoint(x: (v0.x + v1.x)/2, y: (v0.y + v1.y)/2))
        }
        // Определим правую/левую/«верхнюю» (смотрящую вверх) грань по положению середины ребра.
        // правая — с максимальным x, левая — с минимальным x,
        // «верхняя» грань — та, чья середина имеет МИНИМАЛЬНЫЙ y (нормаль смотрит вверх).
        guard let rightIndex = edgeMidpoints.enumerated().max(by: { $0.element.x < $1.element.x })?.offset,
              let leftIndex  = edgeMidpoints.enumerated().min(by: { $0.element.x < $1.element.x })?.offset,
              let topIndex   = edgeMidpoints.enumerated().min(by: { $0.element.y < $1.element.y })?.offset else { return }
        // Привязываем цвета к конкретным рёбрам треугольника:
        // верхняя грань — синяя, правая — красная, левая — жёлтая
        edgeNodes[topIndex].name   = "edge_blue"
        edgeNodes[rightIndex].name = "edge_red"
        edgeNodes[leftIndex].name  = "edge_yellow"

        edgeNodes[rightIndex].physicsBody?.categoryBitMask = PhysicsCategory.edge0
        edgeNodes[leftIndex].physicsBody?.categoryBitMask  = PhysicsCategory.edge1
        edgeNodes[topIndex].physicsBody?.categoryBitMask   = PhysicsCategory.edge2

        // Сохраним середины для доступа извне
        self.edgeCentersLocal = [
            "right": edgeMidpoints[rightIndex],
            "left":  edgeMidpoints[leftIndex],
            "top":   edgeMidpoints[topIndex]
        ]
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    private let triangle = TriangleContainer()
    private let rightButton = SKSpriteNode(imageNamed: "right_button")
    private let leftButton  = SKSpriteNode(imageNamed: "left_button")
    private var hearts: [SKSpriteNode] = []
    private var hp: Int = 3
    private let closeButton = SKSpriteNode(imageNamed: "close_button")
    var onClose: (() -> Void)?

    private var score: Int = 0
    private var bestScore: Int = 0
    private let scoreLabel = SKLabelNode(fontNamed: "JustAnotherHand-Regular")
    private let bestLabel  = SKLabelNode(fontNamed: "JustAnotherHand-Regular")

    // Базовая раскладка цветов по направлениям при старте:
    // верхняя грань — синяя, правая — красная, левая — жёлтая
    private let initialLaneColor: [Lane: FishColor] = [
        .top:   .blue,
        .right: .red,
        .left:  .yellow
    ]
    // Текущая раскладка цветов (меняется при поворотах треугольника)
    private var laneColor: [Lane: FishColor] = [:]

    // Фиксированные точки назначения для рыбок (в координатах сцены, не «привязаны» к узлу треугольника)
    private var laneTargets: [Lane: CGPoint] = [:]

    // Колбэк для SwiftUI-экрана и флаг конца игры
    var onGameOver: ((Int, Int) -> Void)?
    private var isGameOver = false
    override func didMove(to view: SKView) {
        // Создаём узел с изображением фона
        let background = SKSpriteNode(imageNamed: "game_back")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.zPosition = -1 // чтобы фон был позади других элементов
        background.size = self.size // растягиваем на весь экран
        
        addChild(background)
        // Добавляем треугольник в центр
        triangle.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(triangle)

        // Сохраняем текущие (мировые) координаты середин граней как фиксированные точки назначения
        if let leftMid = triangle.edgeCenter(named: "left", in: self) {
            laneTargets[.left] = leftMid
        }
        if let rightMid = triangle.edgeCenter(named: "right", in: self) {
            laneTargets[.right] = rightMid
        }
        if let topMid = triangle.edgeCenter(named: "top", in: self) {
            laneTargets[.top] = topMid
        }
        // Кнопки управления (в правом нижнем углу)
        rightButton.name = "right_button"
        leftButton.name  = "left_button"

        rightButton.zPosition = 10
        leftButton.zPosition  = 10

        // Масштаб под размер экрана (чтобы не были огромными на маленьких девайсах)
        let baseScale: CGFloat = 0.9
        rightButton.setScale(baseScale)
        leftButton.setScale(baseScale)

        let margin: CGFloat = 20
        // Правую кнопку ставим в угол
        rightButton.position = CGPoint(
            x: size.width - margin - rightButton.size.width / 2,
            y: margin + rightButton.size.height / 2
        )
        // Левую — слева от правой с небольшим промежутком
        let spacing: CGFloat = 12
        leftButton.position = CGPoint(
            x: rightButton.position.x - rightButton.size.width - spacing,
            y: rightButton.position.y
        )

        addChild(rightButton)
        addChild(leftButton)
        
        // Кнопка выхода + Hearts HUD (ряд: кнопка, сердечко, сердечко, сердечко)
        let marginTop: CGFloat = 20
        let marginLeft: CGFloat = 20
        let spacingH: CGFloat = 8

        // Кнопка выхода (левый верхний угол)
        closeButton.name = "close_button"
        closeButton.zPosition = 30
        // Можно слегка уменьшить кнопку при необходимости
        // closeButton.setScale(0.9)
        let closeY = size.height - marginTop - closeButton.size.height / 2
        closeButton.position = CGPoint(
            x: marginLeft + closeButton.size.width / 2,
            y: closeY
        )
        addChild(closeButton)

        // Три сердца справа от кнопки
        let heartTex = SKTexture(imageNamed: "heart_on")
        let heartSize = heartTex.size()
        let heartsStartX = closeButton.position.x + closeButton.size.width / 2 + spacingH + heartSize.width / 2
        let heartsY = closeButton.position.y
        for i in 0..<3 {
            let h = SKSpriteNode(texture: heartTex)
            h.zPosition = 20
            let x = heartsStartX + CGFloat(i) * (heartSize.width + spacingH)
            h.position = CGPoint(x: x, y: heartsY)
            addChild(h)
            hearts.append(h)
        }
        updateHearts()

        // Score HUD (правый верхний угол)
        bestScore = UserDefaults.standard.integer(forKey: "bestScore")

        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: size.width - 20, y: size.height - 20)
        scoreLabel.zPosition = 20
        addChild(scoreLabel)

        bestLabel.text = "Best: \(bestScore)"
        bestLabel.fontSize = 16
        bestLabel.fontColor = .white
        bestLabel.horizontalAlignmentMode = .right
        bestLabel.verticalAlignmentMode = .top
        bestLabel.position = CGPoint(x: size.width - 20, y: scoreLabel.position.y - scoreLabel.fontSize - 6)
        bestLabel.zPosition = 20
        addChild(bestLabel)

        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self

        // Стартовое состояние
        isGameOver = false
        hp = 3
        score = 0

        // Стартовый поворот треугольника
        triangle.zRotation = 0

        // Исходная раскладка цветов по направлениям
        laneColor = initialLaneColor

        updateHearts()
        updateScoreLabels()

        // Запускаем спавн рыбок
        startSpawning()
    }
    private func rotateClockwise() {
        let angle = 2 * CGFloat.pi / 3 // +120° (математически против часовой)
        let action = SKAction.rotate(byAngle: angle, duration: 0.12)
        triangle.run(action)

        // Поворачиваем раскладку цветов так же, как треугольник (CCW):
        // top <- right, right <- left, left <- top
        let prev = laneColor.isEmpty ? initialLaneColor : laneColor
        laneColor[.top]   = prev[.right]
        laneColor[.right] = prev[.left]
        laneColor[.left]  = prev[.top]
    }

    private func rotateCounterClockwise() {
        let angle = -2 * CGFloat.pi / 3 // −120° (математически по часовой)
        let action = SKAction.rotate(byAngle: angle, duration: 0.12)
        triangle.run(action)

        // Поворачиваем раскладку цветов по часовой:
        // top <- left, right <- top, left <- right
        let prev = laneColor.isEmpty ? initialLaneColor : laneColor
        laneColor[.top]   = prev[.left]
        laneColor[.right] = prev[.top]
        laneColor[.left]  = prev[.right]
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)

        // Кнопка выхода из игры — должна работать всегда, даже при Game Over
        if tappedNodes.contains(where: { $0.name == closeButton.name }) {
            onClose?()
            return
        }

        // Если игра окончена, остальные кнопки уже не обрабатываем
        if isGameOver { return }

        // Проверяем по имени, чтобы не зависеть от порядка массива
        if tappedNodes.contains(where: { $0.name == rightButton.name }) {
            rotateClockwise()
            return
        }
        if tappedNodes.contains(where: { $0.name == leftButton.name }) {
            rotateCounterClockwise()
            return
        }
    }
    
    private func startSpawning() {
        // Первичный запуск последовательно: верхняя → правая → левая
        // Далее каждый лейн сам себя респавнит в finishFish(_:lane:)
        let delay: TimeInterval = 3.0 // увеличили паузу между спавнами рыбок
        run(.sequence([
            .run { [weak self] in self?.spawnTopFish() },
            .wait(forDuration: delay),
            .run { [weak self] in self?.spawnRightFish() },
            .wait(forDuration: delay),
            .run { [weak self] in self?.spawnLeftFish() }
        ]))
    }

    private func spawnLeftFish() {
        guard let leftMid = laneTargets[.left] else { return }
        let angle: CGFloat = .pi / 6  // 30° к оси X
        let dir = CGVector(dx: cos(angle), dy: sin(angle))
        let L = max(size.width, size.height) / 2 + 80 // чуть за пределами экрана
        let start = CGPoint(x: leftMid.x - dir.dx * L, y: leftMid.y - dir.dy * L)
        
        // Целью делаем фиксированную точку слева
        let target = leftMid
        spawnFish(from: start, to: target, lane: .left)
    }

    private func spawnRightFish() {
        guard let rightMid = laneTargets[.right] else { return }
        let angle: CGFloat = 5 * .pi / 6  // 150° к оси X
        let dir = CGVector(dx: cos(angle), dy: sin(angle))
        let L = max(size.width, size.height) / 2 + 80 // чуть за пределами экрана
        let start = CGPoint(x: rightMid.x - dir.dx * L, y: rightMid.y - dir.dy * L)
        
        // Цель — фиксированная точка справа
        let target = rightMid
        spawnFish(from: start, to: target, lane: .right)
    }

    private func spawnTopFish() {
        // Фиксированная точка назначения для верхней рыбки — центр соответствующей грани
        guard let topMid = laneTargets[.top] else { return }

        // Стартуем значительно выше грани по той же вертикали,
        // сама же "смерть" теперь будет происходить по физическому контакту с ребром
        let L = max(size.width, size.height) / 2 + 80
        let target = topMid
        let start  = CGPoint(x: topMid.x, y: topMid.y + L)

        spawnFish(from: start, to: target, lane: .top)
    }

    private func spawnFish(from start: CGPoint, to target: CGPoint, lane: Lane) {
        let randomColor = FishColor.allCases.randomElement()!
        let fish = FishNode(color: randomColor)
        fish.name = "fish_\(lane.rawValue)"

        // Ориентация спрайта по требованиям:
        //  - верхняя: повернуть на 90° против часовой (CCW)
        //  - правая:  повернуть на 30° против часовой (CCW)
        //  - левая:   отразить по X и повернуть на 30° против часовой (CCW)
        switch lane {
        case .top:
            fish.zRotation = .pi / 2
        case .right:
            fish.zRotation = -.pi / 6 // 60° по часовой (или 300° против часовой)
        case .left:
            fish.xScale = -abs(fish.xScale)
            fish.zRotation = .pi / 6
        }

        fish.position = start
        addChild(fish)

        let distance = hypot(target.x - start.x, target.y - start.y)
        let speed: CGFloat = 80 // px/s (ещё более медленное движение)
        let duration = distance / speed
        let move = SKAction.move(to: target, duration: duration)
        // Теперь "finish" не завершает рыбку — она исчезает только при контакте с ребром
        fish.run(move)
    }
    
    private func finishFish(_ fish: FishNode, lane: Lane) {
        // Если игра уже окончена — просто убираем рыбку
        if isGameOver {
            fish.removeFromParent()
            return
        }

        // Удаляем рыбку с экрана
        fish.removeFromParent()

        // Определяем цвет грани в направлении lane по текущей раскладке
        let currentLayout = laneColor.isEmpty ? initialLaneColor : laneColor
        let edgeColor = currentLayout[lane] ?? .blue

        if edgeColor == fish.colorType {
            // Совпало → +5 очков
            score += 5
            if score > bestScore {
                bestScore = score
                UserDefaults.standard.set(bestScore, forKey: "bestScore")
            }
            updateScoreLabels()
        } else {
            // Не совпало → минус одно сердечко
            hp = max(0, hp - 1)
            updateHearts()

            if hp == 0 && !isGameOver {
                isGameOver = true
                onGameOver?(score, bestScore)
            }
        }

        // Если после удара игра окончена — новых рыбок не спавним
        if isGameOver { return }

        // Иначе респавним новую рыбку в том же направлении
        switch lane {
        case .left:  spawnLeftFish()
        case .right: spawnRightFish()
        case .top:   spawnTopFish()
        }
    }
    
    private func updateHearts() {
        // Тушим справа налево: сначала правое, потом центральное, потом левое
        // hearts[0] — левое, hearts[1] — центр, hearts[2] — правое
        let onTex = SKTexture(imageNamed: "heart_on")
        let offTex = SKTexture(imageNamed: "heart_off")
        for (_, node) in hearts.enumerated() {
            node.texture = onTex
            node.size = onTex.size()
        }
        // Сколько потухших сердец = 3 - hp
        let offCount = max(0, min(3, 3 - hp))
        if offCount >= 1 { hearts[2].texture = offTex; hearts[2].size = offTex.size() }
        if offCount >= 2 { hearts[1].texture = offTex; hearts[1].size = offTex.size() }
        if offCount >= 3 { hearts[0].texture = offTex; hearts[0].size = offTex.size() }
    }

    private func updateScoreLabels() {
        scoreLabel.text = "Score: \(score)"
        bestLabel.text = "Best: \(bestScore)"
    }

    /// Сбрасывает состояние игры при нажатии Try Again:
    /// - обнуляет текущий счёт
    /// - восстанавливает жизни и сердечки
    /// - запускает новый цикл спавна рыбок
    func resetGame() {
        // Очищаем любые действия на сцене (включая schedule спавна)
        removeAllActions()
        
        // Удаляем всех оставшихся рыбок на сцене (имена "fish_left/right/top")
        children
            .filter { $0.name?.hasPrefix("fish_") == true }
            .forEach { $0.removeFromParent() }
        
        // Сбрасываем состояние
        isGameOver = false
        hp = 3
        score = 0

        // Останавливаем вращение треугольника и сбрасываем поворот
        triangle.removeAllActions()
        triangle.zRotation = 0

        laneColor = initialLaneColor
        
        updateHearts()
        updateScoreLabels()
        
        // Запускаем спавн рыбок заново
        startSpawning()
    }


    func didBegin(_ contact: SKPhysicsContact) {
        // Если игра уже окончена, ничего не делаем
        if isGameOver { return }

        guard let nodeA = contact.bodyA.node,
              let nodeB = contact.bodyB.node else { return }

        // Ищем, какая из двух нод — рыбка
        let fishNode = (nodeA as? FishNode) ?? (nodeB as? FishNode)
        let otherNode = (fishNode === nodeA ? nodeB : nodeA)

        guard let fish = fishNode else { return }

        // Имя рыбки имеет формат "fish_left/right/top" — по нему определяем направление
        guard let name = fish.name, name.hasPrefix("fish_") else { return }
        let suffix = name.replacingOccurrences(of: "fish_", with: "")

        let lane: Lane
        switch suffix {
        case "left":  lane = .left
        case "right": lane = .right
        case "top":   lane = .top
        default:        return
        }

        // Проверяем, что вторым участником контакта является одно из рёбер треугольника
        if let edgeName = otherNode.name, edgeName.hasPrefix("edge_") {
            // Останавливаем движение конкретной рыбки и сразу считаем её исход
            fish.removeAllActions()
            finishFish(fish, lane: lane)
        }
    }

}
