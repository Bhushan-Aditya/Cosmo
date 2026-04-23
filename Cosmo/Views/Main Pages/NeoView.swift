import SwiftUI
import SpriteKit

// MARK: - Neo View (Galaga-Style Space Shooter)
struct NeoView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var showGame = false
    @State private var showInstructions = true
    @State private var isPaused = false
    @State private var showPremiumPaywall = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CosmoAnimatedBackground()
                    .ignoresSafeArea()

                if showGame {
                    VStack(spacing: 0) {
                        GameHeaderView(isPaused: $isPaused)
                            .padding(.top, geometry.safeAreaInsets.top > 0 ? 8 : 16)
                            .padding(.horizontal, 20)
                            .zIndex(100)
                        
                        GalagaGameView(
                            showInstructions: $showInstructions,
                            isPaused: $isPaused,
                            hasPremium: purchaseManager.hasPremium,
                            topPadding: geometry.safeAreaInsets.top,
                            onPremiumRequired: {
                                showPremiumPaywall = true
                            },
                            onGameCompleted: { snapshot in
                                DailyStreakStore.shared.recordActivity()
                                Task {
                                    do {
                                        try await SupabaseGameSyncService.shared.uploadGameSession(snapshot)
                                        await ToastManager.shared.show("Session synced", style: .success)
                                    } catch {
                                        await ToastManager.shared.show("Sync failed — will retry when online", style: .error)
#if DEBUG
                                        print("[NeoView] Game sync failed: \(error.localizedDescription)")
#endif
                                    }
                                }
                            }
                        )
                        .transition(.opacity)
                    }
                }
                
                if showInstructions && showGame {
                    GameInstructionsOverlay(showInstructions: $showInstructions)
                        .transition(.opacity)
                        .zIndex(200)
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.3)) {
                showGame = true
            }
        }
        .sheet(isPresented: $showPremiumPaywall) {
            PremiumPaywallSheet(context: .gameContinue)
                .environmentObject(purchaseManager)
        }
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

// MARK: - Game Instructions Overlay
struct GameInstructionsOverlay: View {
    @Binding var showInstructions: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 0.3, green: 0.8, blue: 1.0))
                        
                        Text("Space Defender")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Protect the cosmos from incoming meteors")
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 14) {
                        InstructionRow(icon: "hand.draw.fill", text: "Drag anywhere to move your ship")
                        InstructionRow(icon: "sparkles", text: "Auto-fires bullets at meteors")
                        InstructionRow(icon: "star.fill", text: "Collect golden power-ups (+50 pts)")
                        InstructionRow(icon: "flame.fill", text: "Avoid meteors or lose lives")
                        InstructionRow(icon: "chart.line.uptrend.xyaxis", text: "Survive waves for higher scores")
                    }
                    .padding(.horizontal, 24)
                    
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showInstructions = false
                        }
                    }) {
                        Text("START GAME")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 240, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28, style: .continuous)
                                    .fill(Color(red: 0.3, green: 0.8, blue: 1.0).opacity(0.3))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                                            .stroke(Color(red: 0.3, green: 0.8, blue: 1.0), lineWidth: 2)
                                    )
                            )
                    }
                    .padding(.top, 4)
                    .padding(.bottom, 8)
                }
                .padding(.vertical, 32)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.black.opacity(0.7))
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 40)
            }
        }
    }
}

struct InstructionRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(red: 0.95, green: 0.82, blue: 0.45))
                .frame(width: 30)
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.85))
        }
    }
}

// MARK: - Game Header
struct GameHeaderView: View {
    @Binding var isPaused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                HStack(spacing: 10) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.3, green: 0.8, blue: 1.0), Color.cyan.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Space Defender")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
                
                Button(action: {
                    isPaused.toggle()
                }) {
                    Image(systemName: isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.15))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
            
            Text("Defend the cosmos · Survive the waves")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.55))
        }
    }
}

// MARK: - Game View Wrapper
struct GalagaGameView: UIViewRepresentable {
    @Binding var showInstructions: Bool
    @Binding var isPaused: Bool
    let hasPremium: Bool
    let topPadding: CGFloat
    let onPremiumRequired: () -> Void
    let onGameCompleted: (GameSessionSnapshot) -> Void
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.allowsTransparency = true
        skView.backgroundColor = .clear
        
        let scene = GalagaGameScene()
        scene.scaleMode = .resizeFill
        scene.showInstructionsBinding = showInstructions
        scene.topSafeAreaInset = topPadding
        scene.hasPremiumAccess = hasPremium
        scene.onPremiumRequired = onPremiumRequired
        scene.onGameCompleted = onGameCompleted
        skView.presentScene(scene)
        
        context.coordinator.scene = scene
        context.coordinator.showInstructionsBinding = _showInstructions
        context.coordinator.isPausedBinding = _isPaused
        
        return skView
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        if let scene = context.coordinator.scene {
            scene.showInstructionsBinding = showInstructions
            scene.isGamePaused = isPaused
            scene.hasPremiumAccess = hasPremium
            scene.onPremiumRequired = onPremiumRequired
            scene.onGameCompleted = onGameCompleted
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var scene: GalagaGameScene?
        var showInstructionsBinding: Binding<Bool>?
        var isPausedBinding: Binding<Bool>?
    }
}

// MARK: - Game Scene
class GalagaGameScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: - Game State
    private var player: SKSpriteNode!
    private var score = 0
    private var lives = 3
    private var scoreLabel: SKLabelNode!
    private var livesLabel: SKLabelNode!
    private var gameOverLabel: SKLabelNode!
    private var restartButton: SKSpriteNode!
    private var restartLabel: SKLabelNode!
    private var continueButton: SKSpriteNode?
    private var continueButtonBackground: SKShapeNode?
    private var isGameOver = false
    private var didUseContinueInCurrentRun = false
    private var didReportCurrentGame = false
    private var lastUpdateTime: TimeInterval = 0
    private var deltaTime: TimeInterval = 0
    private var wave = 1
    private var meteorsDestroyed = 0
    private var gameStartedAt: Date = Date()
    var showInstructionsBinding = false
    var topSafeAreaInset: CGFloat = 0
    var hasPremiumAccess = false {
        didSet {
            guard oldValue != hasPremiumAccess, isGameOver else { return }
            refreshGameOverButtons()
        }
    }
    var onPremiumRequired: (() -> Void)?
    var onGameCompleted: ((GameSessionSnapshot) -> Void)?
    var isGamePaused = false {
        didSet {
            handlePauseStateChange()
        }
    }
    
    // MARK: - Physics Categories
    private let playerCategory: UInt32 = 0x1 << 0
    private let meteorCategory: UInt32 = 0x1 << 1
    private let bulletCategory: UInt32 = 0x1 << 2
    private let powerUpCategory: UInt32 = 0x1 << 3
    
    // MARK: - Game Settings
    private let playerSpeed: CGFloat = 500
    private let bulletSpeed: CGFloat = 800
    private let meteorSpeed: CGFloat = 150
    private let fireRate: TimeInterval = 0.2
    private var lastFireTime: TimeInterval = 0
    private var touchLocation: CGPoint?
    
    // MARK: - Setup
    override func didMove(to view: SKView) {
        size = view.bounds.size
        backgroundColor = .clear
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        setupBackground()
        setupPlayer()
        setupHUD()
        gameStartedAt = Date()
        didReportCurrentGame = false
        startSpawning()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        if oldSize != .zero && oldSize != size {
            repositionHUD()
        }
    }
    
    private func repositionHUD() {
        let headerHeight: CGFloat = 80
        let topInset = topSafeAreaInset > 0 ? topSafeAreaInset + 8 : 16
        let totalTopSpace = topInset + headerHeight + 12
        let hudY = size.height - totalTopSpace
        
        let hudWidth: CGFloat = min(size.width - 40, 360)
        let leftX = (size.width - hudWidth) / 2 + 60
        let rightX = size.width - leftX
        
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.position = CGPoint(x: leftX, y: hudY)
        }
        if let livesLabel = childNode(withName: "livesLabel") as? SKLabelNode {
            livesLabel.position = CGPoint(x: rightX, y: hudY)
        }
    }
    
    private func setupBackground() {
        backgroundColor = .clear
    }
    
    private func setupPlayer() {
        player = SKSpriteNode(imageNamed: "Spaceship")
        player.size = CGSize(width: 60, height: 60)
        let bottomSafeArea: CGFloat = 100
        player.position = CGPoint(x: size.width / 2, y: bottomSafeArea + 50)
        player.zPosition = 10
        
        player.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 45, height: 45))
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = playerCategory
        player.physicsBody?.contactTestBitMask = meteorCategory | powerUpCategory
        player.physicsBody?.collisionBitMask = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        
        let engineGlow = SKShapeNode(circleOfRadius: 12)
        engineGlow.fillColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.5)
        engineGlow.strokeColor = .clear
        engineGlow.position = CGPoint(x: 0, y: -25)
        engineGlow.setScale(1.0)
        engineGlow.zPosition = -1
        player.addChild(engineGlow)
        
        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.4, duration: 0.2),
                SKAction.fadeAlpha(to: 0.3, duration: 0.2)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.2),
                SKAction.fadeAlpha(to: 0.5, duration: 0.2)
            ])
        ])
        engineGlow.run(SKAction.repeatForever(pulse))
        
        addChild(player)
    }
    
    private func setupHUD() {
        let headerHeight: CGFloat = 80
        let topInset = topSafeAreaInset > 0 ? topSafeAreaInset + 8 : 16
        let totalTopSpace = topInset + headerHeight + 12
        let hudY = size.height - totalTopSpace
        
        let hudWidth: CGFloat = min(size.width - 40, 360)
        let leftX = (size.width - hudWidth) / 2 + 60
        let rightX = size.width - leftX
        
        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 18
        scoreLabel.fontColor = UIColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 1.0)
        scoreLabel.position = CGPoint(x: leftX, y: hudY)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = 100
        scoreLabel.name = "scoreLabel"
        updateScoreLabel()
        addChild(scoreLabel)
        
        livesLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        livesLabel.fontSize = 18
        livesLabel.fontColor = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        livesLabel.position = CGPoint(x: rightX, y: hudY)
        livesLabel.horizontalAlignmentMode = .right
        livesLabel.verticalAlignmentMode = .center
        livesLabel.zPosition = 100
        livesLabel.name = "livesLabel"
        updateLivesLabel()
        addChild(livesLabel)
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    
    private func updateLivesLabel() {
        livesLabel.text = "Lives: \(lives)"
    }
    
    // MARK: - Spawning
    private func startSpawning() {
        updateSpawnRate()
        
        let spawnPowerUp = SKAction.run { [weak self] in
            if Double.random(in: 0...1) < 0.15 {
                self?.spawnPowerUp()
            }
        }
        let powerUpWait = SKAction.wait(forDuration: 8.0)
        let powerUpSequence = SKAction.sequence([spawnPowerUp, powerUpWait])
        run(SKAction.repeatForever(powerUpSequence), withKey: "powerUpSpawning")
    }
    
    private func updateSpawnRate() {
        removeAction(forKey: "spawning")
        
        let spawnInterval = max(0.5, 1.2 - (Double(wave - 1) * 0.1))
        
        let spawnMeteor = SKAction.run { [weak self] in
            self?.spawnMeteor()
        }
        let wait = SKAction.wait(forDuration: spawnInterval)
        let spawnSequence = SKAction.sequence([spawnMeteor, wait])
        run(SKAction.repeatForever(spawnSequence), withKey: "spawning")
    }
    
    private func spawnMeteor() {
        let meteorSize = CGFloat.random(in: 40...80)
        let meteor = SKSpriteNode(imageNamed: "Comets")
        meteor.size = CGSize(width: meteorSize, height: meteorSize)
        
        let leftMargin = meteorSize + 20
        let rightMargin = size.width - meteorSize - 20
        
        meteor.position = CGPoint(
            x: CGFloat.random(in: leftMargin...rightMargin),
            y: size.height + meteorSize
        )
        meteor.zPosition = 5
        meteor.name = "meteor"
        
        meteor.physicsBody = SKPhysicsBody(circleOfRadius: meteorSize * 0.35)
        meteor.physicsBody?.isDynamic = true
        meteor.physicsBody?.categoryBitMask = meteorCategory
        meteor.physicsBody?.contactTestBitMask = bulletCategory | playerCategory
        meteor.physicsBody?.collisionBitMask = 0
        meteor.physicsBody?.usesPreciseCollisionDetection = true
        
        let glowNode = SKShapeNode(circleOfRadius: meteorSize * 0.5)
        glowNode.fillColor = UIColor(red: 0.9, green: 0.5, blue: 0.3, alpha: 0.25)
        glowNode.strokeColor = .clear
        glowNode.zPosition = -1
        glowNode.setScale(1.0)
        meteor.addChild(glowNode)
        
        let glowPulse = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.3, duration: 0.5),
                SKAction.fadeAlpha(to: 0.15, duration: 0.5)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.5),
                SKAction.fadeAlpha(to: 0.25, duration: 0.5)
            ])
        ])
        glowNode.run(SKAction.repeatForever(glowPulse))
        
        let trailEmitter = SKEmitterNode()
        trailEmitter.particleTexture = SKTexture(imageNamed: "Comets")
        trailEmitter.particleBirthRate = 30
        trailEmitter.particleLifetime = 0.8
        trailEmitter.particleScale = 0.15
        trailEmitter.particleScaleSpeed = -0.1
        trailEmitter.particleAlpha = 0.6
        trailEmitter.particleAlphaSpeed = -0.75
        trailEmitter.particleColor = UIColor(red: 0.7, green: 0.88, blue: 1.0, alpha: 1.0)
        trailEmitter.particleColorBlendFactor = 1.0
        trailEmitter.particleSpeed = 20
        trailEmitter.particleSpeedRange = 10
        trailEmitter.emissionAngle = .pi / 2
        trailEmitter.emissionAngleRange = .pi / 6
        trailEmitter.position = CGPoint(x: 0, y: meteorSize * 0.3)
        trailEmitter.zPosition = -2
        trailEmitter.targetNode = self
        meteor.addChild(trailEmitter)
        
        addChild(meteor)
        
        let duration = TimeInterval(CGFloat.random(in: 3...6))
        let moveAction = SKAction.moveTo(y: -meteorSize, duration: duration)
        let rotateAction = SKAction.rotate(byAngle: CGFloat.random(in: -8...8), duration: duration)
        let removeAction = SKAction.removeFromParent()
        
        meteor.run(SKAction.sequence([
            SKAction.group([moveAction, rotateAction]),
            removeAction
        ]))
    }
    
    private func spawnPowerUp() {
        let powerUp = SKShapeNode(circleOfRadius: 18)
        powerUp.fillColor = UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 0.9)
        powerUp.strokeColor = UIColor.white.withAlphaComponent(0.6)
        powerUp.lineWidth = 2
        powerUp.glowWidth = 8
        
        let outerGlow = SKShapeNode(circleOfRadius: 24)
        outerGlow.fillColor = UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 0.2)
        outerGlow.strokeColor = .clear
        outerGlow.zPosition = -1
        powerUp.addChild(outerGlow)
        
        let star = SKShapeNode()
        let starPath = UIBezierPath()
        for i in 0..<5 {
            let angle = CGFloat(i) * .pi * 2 / 5 - .pi / 2
            let point = CGPoint(x: cos(angle) * 12, y: sin(angle) * 12)
            if i == 0 {
                starPath.move(to: point)
            } else {
                starPath.addLine(to: point)
            }
            let innerAngle = angle + .pi / 5
            let innerPoint = CGPoint(x: cos(innerAngle) * 6, y: sin(innerAngle) * 6)
            starPath.addLine(to: innerPoint)
        }
        starPath.close()
        star.path = starPath.cgPath
        star.fillColor = .white
        star.strokeColor = .clear
        powerUp.addChild(star)
        
        let leftMargin: CGFloat = 50
        let rightMargin = size.width - 50
        
        powerUp.position = CGPoint(
            x: CGFloat.random(in: leftMargin...rightMargin),
            y: size.height + 40
        )
        powerUp.zPosition = 5
        powerUp.name = "powerUp"
        
        powerUp.physicsBody = SKPhysicsBody(circleOfRadius: 18)
        powerUp.physicsBody?.isDynamic = true
        powerUp.physicsBody?.categoryBitMask = powerUpCategory
        powerUp.physicsBody?.contactTestBitMask = playerCategory
        powerUp.physicsBody?.collisionBitMask = 0
        
        addChild(powerUp)
        
        let pulse = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.25, duration: 0.35),
                SKAction.fadeAlpha(to: 0.7, duration: 0.35)
            ]),
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.35),
                SKAction.fadeAlpha(to: 1.0, duration: 0.35)
            ])
        ])
        powerUp.run(SKAction.repeatForever(pulse))
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        powerUp.run(SKAction.repeatForever(rotate))
        
        let moveAction = SKAction.moveTo(y: -40, duration: 6.0)
        let removeAction = SKAction.removeFromParent()
        powerUp.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        if !isGameOver && !isGamePaused {
            updatePlayerPosition()
            autoFire(currentTime: currentTime)
        }
    }
    
    private func handlePauseStateChange() {
        if isGamePaused {
            self.isPaused = true
        } else {
            self.isPaused = false
        }
    }
    
    private func updatePlayerPosition() {
        guard let touch = touchLocation else { return }
        
        let distance = hypot(touch.x - player.position.x, touch.y - player.position.y)
        
        if distance > 5 {
            let angle = atan2(touch.y - player.position.y, touch.x - player.position.x)
            let maxMove = playerSpeed * CGFloat(deltaTime)
            let moveDistance = min(distance, maxMove)
            
            player.position.x += cos(angle) * moveDistance
            player.position.y += sin(angle) * moveDistance
            
            let headerHeight: CGFloat = 60
            let topInset = topSafeAreaInset > 0 ? topSafeAreaInset + 8 : 16
            let topBoundary = size.height - topInset - headerHeight - 100
            let bottomBoundary: CGFloat = 80
            
            player.position.x = max(40, min(size.width - 40, player.position.x))
            player.position.y = max(bottomBoundary, min(topBoundary, player.position.y))
        }
    }
    
    private func autoFire(currentTime: TimeInterval) {
        if currentTime - lastFireTime >= fireRate {
            fireBullet()
            lastFireTime = currentTime
        }
    }
    
    private func fireBullet() {
        let bullet = SKShapeNode(rectOf: CGSize(width: 6, height: 20), cornerRadius: 3)
        bullet.fillColor = UIColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 1.0)
        bullet.strokeColor = UIColor.white.withAlphaComponent(0.8)
        bullet.lineWidth = 1.5
        bullet.glowWidth = 6
        bullet.position = CGPoint(x: player.position.x, y: player.position.y + 30)
        bullet.zPosition = 8
        bullet.name = "bullet"
        
        let trail = SKShapeNode(rectOf: CGSize(width: 4, height: 12), cornerRadius: 2)
        trail.fillColor = UIColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 0.4)
        trail.strokeColor = .clear
        trail.position = CGPoint(x: 0, y: -12)
        trail.zPosition = -1
        bullet.addChild(trail)
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 6, height: 20))
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = bulletCategory
        bullet.physicsBody?.contactTestBitMask = meteorCategory
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        addChild(bullet)
        
        let moveAction = SKAction.moveTo(y: size.height + 50, duration: 1.0)
        let fadeTrail = SKAction.fadeOut(withDuration: 0.3)
        trail.run(fadeTrail)
        
        let removeAction = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    // MARK: - Touch Handling
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if showInstructionsBinding {
            return
        }
        
        if isGameOver {
            if let continueButton, continueButton.contains(location) {
                if hasPremiumAccess && !didUseContinueInCurrentRun {
                    continueGameFromGameOver()
                } else {
                    onPremiumRequired?()
                }
                return
            }
            if let restartButton, restartButton.contains(location) {
                restartGame()
            }
            return
        }
        
        touchLocation = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !isGameOver, !showInstructionsBinding else { return }
        touchLocation = touch.location(in: self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchLocation = nil
    }
    
    // MARK: - Collision Detection
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if (firstBody.categoryBitMask == bulletCategory && secondBody.categoryBitMask == meteorCategory) ||
           (firstBody.categoryBitMask == meteorCategory && secondBody.categoryBitMask == bulletCategory) {
            
            let bullet = firstBody.categoryBitMask == bulletCategory ? firstBody.node : secondBody.node
            let meteor = firstBody.categoryBitMask == meteorCategory ? firstBody.node : secondBody.node
            
            bulletHitMeteor(bullet: bullet, meteor: meteor)
        }
        
        if (firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == meteorCategory) ||
           (firstBody.categoryBitMask == meteorCategory && secondBody.categoryBitMask == playerCategory) {
            
            let meteor = firstBody.categoryBitMask == meteorCategory ? firstBody.node : secondBody.node
            playerHitMeteor(meteor: meteor)
        }
        
        if (firstBody.categoryBitMask == playerCategory && secondBody.categoryBitMask == powerUpCategory) ||
           (firstBody.categoryBitMask == powerUpCategory && secondBody.categoryBitMask == playerCategory) {
            
            let powerUp = firstBody.categoryBitMask == powerUpCategory ? firstBody.node : secondBody.node
            playerCollectedPowerUp(powerUp: powerUp)
        }
    }
    
    private func bulletHitMeteor(bullet: SKNode?, meteor: SKNode?) {
        guard let bullet = bullet, let meteor = meteor else { return }
        
        createExplosion(at: meteor.position, color: UIColor(red: 0.95, green: 0.6, blue: 0.3, alpha: 1.0))
        
        bullet.removeFromParent()
        meteor.removeFromParent()
        
        score += 10
        meteorsDestroyed += 1
        updateScoreLabel()
        
        if meteorsDestroyed % 15 == 0 {
            wave += 1
            updateSpawnRate()
            showWaveNotification()
        }
        
        let scorePopup = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scorePopup.text = "+10"
        scorePopup.fontSize = 20
        scorePopup.fontColor = UIColor(red: 0.3, green: 1.0, blue: 0.3, alpha: 1.0)
        scorePopup.position = meteor.position
        scorePopup.zPosition = 50
        addChild(scorePopup)
        
        let rise = SKAction.moveBy(x: 0, y: 40, duration: 0.6)
        let fade = SKAction.fadeOut(withDuration: 0.6)
        let remove = SKAction.removeFromParent()
        scorePopup.run(SKAction.sequence([
            SKAction.group([rise, fade]),
            remove
        ]))
    }
    
    private func showWaveNotification() {
        let waveLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        waveLabel.text = "WAVE \(wave)"
        waveLabel.fontSize = 40
        waveLabel.fontColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
        waveLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        waveLabel.zPosition = 150
        waveLabel.alpha = 0
        waveLabel.setScale(0.5)
        addChild(waveLabel)
        
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            SKAction.scale(to: 1.2, duration: 0.3)
        ])
        let hold = SKAction.wait(forDuration: 1.0)
        let disappear = SKAction.group([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.scale(to: 0.8, duration: 0.3)
        ])
        let remove = SKAction.removeFromParent()
        
        waveLabel.run(SKAction.sequence([appear, hold, disappear, remove]))
    }
    
    private func playerHitMeteor(meteor: SKNode?) {
        guard let meteor = meteor, !isGameOver else { return }
        
        createExplosion(at: player.position, color: UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0))
        createExplosion(at: meteor.position, color: UIColor(red: 0.95, green: 0.6, blue: 0.3, alpha: 1.0))
        meteor.removeFromParent()
        
        lives -= 1
        updateLivesLabel()
        
        let shieldFlash = SKShapeNode(circleOfRadius: 40)
        shieldFlash.fillColor = .clear
        shieldFlash.strokeColor = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 0.8)
        shieldFlash.lineWidth = 3
        shieldFlash.glowWidth = 6
        shieldFlash.position = player.position
        shieldFlash.zPosition = 12
        addChild(shieldFlash)
        
        let expand = SKAction.scale(to: 2.0, duration: 0.3)
        let fade = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        shieldFlash.run(SKAction.sequence([
            SKAction.group([expand, fade]),
            remove
        ]))
        
        player.run(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.2, duration: 0.08),
            SKAction.fadeAlpha(to: 1.0, duration: 0.08),
            SKAction.fadeAlpha(to: 0.2, duration: 0.08),
            SKAction.fadeAlpha(to: 1.0, duration: 0.08),
            SKAction.fadeAlpha(to: 0.2, duration: 0.08),
            SKAction.fadeAlpha(to: 1.0, duration: 0.08)
        ]))
        
        if lives <= 0 {
            gameOver()
        }
    }
    
    private func playerCollectedPowerUp(powerUp: SKNode?) {
        guard let powerUp = powerUp else { return }
        
        let powerUpRing = SKShapeNode(circleOfRadius: 50)
        powerUpRing.fillColor = .clear
        powerUpRing.strokeColor = UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 0.8)
        powerUpRing.lineWidth = 3
        powerUpRing.glowWidth = 8
        powerUpRing.position = powerUp.position
        powerUpRing.zPosition = 25
        addChild(powerUpRing)
        
        let expand = SKAction.scale(to: 2.5, duration: 0.5)
        let fade = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        powerUpRing.run(SKAction.sequence([
            SKAction.group([expand, fade]),
            remove
        ]))
        
        for _ in 0..<20 {
            let sparkle = SKShapeNode(circleOfRadius: 3)
            sparkle.fillColor = UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 1.0)
            sparkle.strokeColor = .white
            sparkle.lineWidth = 1
            sparkle.position = powerUp.position
            sparkle.zPosition = 26
            addChild(sparkle)
            
            let angle = CGFloat.random(in: 0...2 * .pi)
            let distance = CGFloat.random(in: 50...120)
            let destination = CGPoint(
                x: powerUp.position.x + cos(angle) * distance,
                y: powerUp.position.y + sin(angle) * distance
            )
            
            let move = SKAction.move(to: destination, duration: 0.7)
            let fade = SKAction.fadeOut(withDuration: 0.7)
            let remove = SKAction.removeFromParent()
            
            sparkle.run(SKAction.sequence([
                SKAction.group([move, fade]),
                remove
            ]))
        }
        
        powerUp.removeFromParent()
        
        score += 50
        updateScoreLabel()
        
        let scorePopup = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scorePopup.text = "+50"
        scorePopup.fontSize = 28
        scorePopup.fontColor = UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 1.0)
        scorePopup.position = player.position
        scorePopup.zPosition = 50
        addChild(scorePopup)
        
        let rise = SKAction.moveBy(x: 0, y: 60, duration: 0.8)
        let popFade = SKAction.fadeOut(withDuration: 0.8)
        let popRemove = SKAction.removeFromParent()
        scorePopup.run(SKAction.sequence([
            SKAction.group([rise, popFade]),
            popRemove
        ]))
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        player.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    private func createExplosion(at position: CGPoint, color: UIColor) {
        let flashNode = SKShapeNode(circleOfRadius: 40)
        flashNode.fillColor = color.withAlphaComponent(0.6)
        flashNode.strokeColor = .clear
        flashNode.position = position
        flashNode.zPosition = 20
        addChild(flashNode)
        
        let flashExpand = SKAction.scale(to: 2.0, duration: 0.3)
        let flashFade = SKAction.fadeOut(withDuration: 0.3)
        let flashRemove = SKAction.removeFromParent()
        flashNode.run(SKAction.sequence([
            SKAction.group([flashExpand, flashFade]),
            flashRemove
        ]))
        
        for _ in 0..<16 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            particle.fillColor = color
            particle.strokeColor = .white.withAlphaComponent(0.6)
            particle.lineWidth = 1
            particle.glowWidth = 2
            particle.position = position
            particle.zPosition = 15
            addChild(particle)
            
            let angle = CGFloat.random(in: 0...2 * .pi)
            let distance = CGFloat.random(in: 40...100)
            let destination = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            
            let move = SKAction.move(to: destination, duration: 0.6)
            let fade = SKAction.fadeOut(withDuration: 0.6)
            let scale = SKAction.scale(to: 0.1, duration: 0.6)
            let rotate = SKAction.rotate(byAngle: CGFloat.random(in: -4...4), duration: 0.6)
            let remove = SKAction.removeFromParent()
            
            particle.run(SKAction.sequence([
                SKAction.group([move, fade, scale, rotate]),
                remove
            ]))
        }
        
        for _ in 0..<8 {
            let sparkle = SKShapeNode(circleOfRadius: 2)
            sparkle.fillColor = .white
            sparkle.strokeColor = .clear
            sparkle.position = position
            sparkle.zPosition = 16
            addChild(sparkle)
            
            let angle = CGFloat.random(in: 0...2 * .pi)
            let distance = CGFloat.random(in: 60...140)
            let destination = CGPoint(
                x: position.x + cos(angle) * distance,
                y: position.y + sin(angle) * distance
            )
            
            let move = SKAction.move(to: destination, duration: 0.8)
            let fade = SKAction.fadeOut(withDuration: 0.8)
            let remove = SKAction.removeFromParent()
            
            sparkle.run(SKAction.sequence([
                SKAction.group([move, fade]),
                remove
            ]))
        }
    }
    
    // MARK: - Game Over
    private func gameOver() {
        isGameOver = true
        removeAction(forKey: "spawning")
        removeAction(forKey: "powerUpSpawning")
        touchLocation = nil
        clearGameOverOverlayNodes()

        let canContinue = hasPremiumAccess && !didUseContinueInCurrentRun
        let shouldShowSecondaryButton = canContinue || !hasPremiumAccess
        if !canContinue {
            finalizeCurrentGameIfNeeded()
        }
        
        let overlay = SKShapeNode(rectOf: size)
        overlay.fillColor = UIColor.black.withAlphaComponent(0.75)
        overlay.strokeColor = .clear
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 190
        overlay.alpha = 0
        overlay.name = "gameOverOverlay"
        addChild(overlay)
        
        let cardWidth: CGFloat = min(340, size.width - 60)
        // Inset buttons from card edge so stroke + glow don't clip the rounded card corners
        let buttonWidth: CGFloat = min(250, max(200, cardWidth - 40))
        let cardHeight: CGFloat = shouldShowSecondaryButton ? 400 : 300
        let cardBackground = SKShapeNode(rectOf: CGSize(width: cardWidth, height: cardHeight), cornerRadius: 32)
        cardBackground.fillColor = UIColor.black.withAlphaComponent(0.6)
        cardBackground.strokeColor = UIColor.white.withAlphaComponent(0.2)
        cardBackground.lineWidth = 1
        cardBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        cardBackground.zPosition = 195
        cardBackground.alpha = 0
        cardBackground.name = "gameOverCard"
        addChild(cardBackground)
        
        gameOverLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        gameOverLabel.text = "MISSION COMPLETE"
        gameOverLabel.fontSize = 28
        gameOverLabel.fontColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 90)
        gameOverLabel.zPosition = 200
        gameOverLabel.alpha = 0
        gameOverLabel.name = "gameOverTitle"
        addChild(gameOverLabel)
        
        let finalScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        finalScoreLabel.text = "SCORE"
        finalScoreLabel.fontSize = 16
        finalScoreLabel.fontColor = UIColor.white.withAlphaComponent(0.6)
        finalScoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 35)
        finalScoreLabel.zPosition = 200
        finalScoreLabel.alpha = 0
        finalScoreLabel.name = "scoreTitle"
        addChild(finalScoreLabel)
        
        let scoreValueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreValueLabel.text = "\(score)"
        scoreValueLabel.fontSize = 56
        scoreValueLabel.fontColor = UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 1.0)
        scoreValueLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 - 25)
        scoreValueLabel.zPosition = 200
        scoreValueLabel.alpha = 0
        scoreValueLabel.name = "scoreValue"
        addChild(scoreValueLabel)
        
        let buttonHeight: CGFloat = 50
        let cornerRadius: CGFloat = buttonHeight / 2
        let restartY: CGFloat = shouldShowSecondaryButton ? (size.height / 2 - 140) : (size.height / 2 - 100)
        let buttonBackground = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: cornerRadius)
        buttonBackground.fillColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 0.25)
        buttonBackground.strokeColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0)
        buttonBackground.lineWidth = 2
        buttonBackground.glowWidth = 2
        buttonBackground.position = CGPoint(x: size.width / 2, y: restartY)
        buttonBackground.zPosition = 199
        buttonBackground.alpha = 0
        buttonBackground.name = "restartButtonBackground"
        addChild(buttonBackground)

        restartButton = SKSpriteNode(color: .clear, size: CGSize(width: buttonWidth, height: buttonHeight))
        restartButton.position = CGPoint(x: size.width / 2, y: restartY)
        restartButton.zPosition = 200
        restartButton.alpha = 0
        restartButton.name = "restartButton"
        addChild(restartButton)
        
        restartLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        restartLabel.text = "PLAY AGAIN"
        restartLabel.fontSize = 20
        restartLabel.fontColor = .white
        restartLabel.position = CGPoint(x: 0, y: -7)
        restartLabel.zPosition = 201
        restartButton.addChild(restartLabel)

        if shouldShowSecondaryButton {
            addContinueOrUpgradeButton(
                y: size.height / 2 - 66,
                buttonWidth: buttonWidth,
                buttonHeight: buttonHeight,
                cornerRadius: cornerRadius,
                canContinue: canContinue
            )
        }
        
        overlay.run(SKAction.fadeAlpha(to: 0.75, duration: 0.4))
        cardBackground.run(SKAction.fadeIn(withDuration: 0.5))
        gameOverLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
        finalScoreLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.4),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
        scoreValueLabel.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
        buttonBackground.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
        restartButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.7),
            SKAction.fadeIn(withDuration: 0.4)
        ]))
    }

    private func addContinueOrUpgradeButton(
        y: CGFloat,
        buttonWidth: CGFloat,
        buttonHeight: CGFloat,
        cornerRadius: CGFloat,
        canContinue: Bool
    ) {
        let buttonBackground = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: cornerRadius)
        buttonBackground.fillColor = canContinue
        ? UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 0.25)
        : UIColor.white.withAlphaComponent(0.12)
        buttonBackground.strokeColor = canContinue
        ? UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 1.0)
        : UIColor.white.withAlphaComponent(0.35)
        buttonBackground.lineWidth = 2
        buttonBackground.glowWidth = 2
        buttonBackground.position = CGPoint(x: size.width / 2, y: y)
        buttonBackground.zPosition = 199
        buttonBackground.alpha = 0
        buttonBackground.name = "continueButtonBackground"
        addChild(buttonBackground)
        continueButtonBackground = buttonBackground

        let button = SKSpriteNode(color: .clear, size: CGSize(width: buttonWidth, height: buttonHeight))
        button.position = CGPoint(x: size.width / 2, y: y)
        button.zPosition = 200
        button.alpha = 0
        button.name = "continueButton"
        addChild(button)
        continueButton = button

        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.text = canContinue ? "CONTINUE RUN" : "UNLOCK PREMIUM"
        label.fontSize = 18
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: -7)
        label.zPosition = 201
        button.addChild(label)

        buttonBackground.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
        button.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.6),
            SKAction.fadeIn(withDuration: 0.3)
        ]))
    }

    private func refreshGameOverButtons() {
        guard isGameOver else { return }

        clearGameOverOverlayNodes()
        gameOver()
    }

    private func continueGameFromGameOver() {
        didUseContinueInCurrentRun = true
        isGameOver = false
        lives = 1
        updateLivesLabel()

        clearGameOverOverlayNodes()

        enumerateChildNodes(withName: "meteor") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "powerUp") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "bullet") { node, _ in node.removeFromParent() }

        let continueLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        continueLabel.text = "CONTINUE USED"
        continueLabel.fontSize = 22
        continueLabel.fontColor = UIColor(red: 0.95, green: 0.82, blue: 0.45, alpha: 1.0)
        continueLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        continueLabel.alpha = 0
        continueLabel.zPosition = 220
        addChild(continueLabel)

        continueLabel.run(SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.wait(forDuration: 0.45),
            SKAction.fadeOut(withDuration: 0.25),
            SKAction.removeFromParent()
        ]))

        startSpawning()
    }

    private func clearGameOverOverlayNodes() {
        enumerateChildNodes(withName: "gameOver*") { node, _ in
            node.removeFromParent()
        }
        childNode(withName: "restartButtonBackground")?.removeFromParent()
        childNode(withName: "continueButtonBackground")?.removeFromParent()
        childNode(withName: "restartButton")?.removeFromParent()
        childNode(withName: "continueButton")?.removeFromParent()
        restartButton = nil
        restartLabel = nil
        continueButton = nil
        continueButtonBackground = nil
    }

    private func finalizeCurrentGameIfNeeded() {
        guard !didReportCurrentGame else { return }
        didReportCurrentGame = true

        let duration = max(0, Int(Date().timeIntervalSince(gameStartedAt)))
        onGameCompleted?(
            GameSessionSnapshot(
                score: score,
                waveReached: wave,
                livesLeft: max(0, lives),
                durationSeconds: duration
            )
        )
    }

    private func restartGame() {
        finalizeCurrentGameIfNeeded()
        removeAllChildren()

        score = 0
        lives = 3
        wave = 1
        meteorsDestroyed = 0
        isGameOver = false
        didUseContinueInCurrentRun = false
        didReportCurrentGame = false
        gameStartedAt = Date()
        lastFireTime = 0
        touchLocation = nil

        setupBackground()
        setupPlayer()
        setupHUD()
        startSpawning()
    }
}
