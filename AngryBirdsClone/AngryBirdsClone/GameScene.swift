import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var gameState: GameState?
    
    init(size: CGSize, gameState: GameState) {
           self.gameState = gameState
           super.init(size: size)
           self.scaleMode = .aspectFit
       }

       required init?(coder aDecoder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    let pigSounds = PigSounds()
    var bird: SKSpriteNode!
    var startTouchLocation: CGPoint?
    var birdLaunched = false
    var pigs = 0
    var birdsLeft = 3
    var currentBird: SKSpriteNode?
    var birdTimer: Timer?

    var birdsLeftLabel: SKLabelNode!

    var gameStatus: GameStatus = .playing

    override func didMove(to view: SKView) {
        pigSounds.startPigGryntTimer()
        
        backgroundColor = SKColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0)
        physicsWorld.contactDelegate = self

        let cameraNode = SKCameraNode()
        camera = cameraNode
        cameraNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(cameraNode)

        // ✅ Venstre væg
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: 0, y: 0),
            to: CGPoint(x: 0, y: size.height)
        )
        addChild(leftWall)

        // ✅ Bund
        let bottomWall = SKNode()
        bottomWall.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: 0, y: 0),
            to: CGPoint(x: size.width, y: 0)
        )
        addChild(bottomWall)

        // ✅ Højre væg
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(
            edgeFrom: CGPoint(x: size.width, y: 0),
            to: CGPoint(x: size.width, y: size.height)
        )
        addChild(rightWall)

        // 🟫 Jord/platform
        let ground = SKSpriteNode(
            color: .brown,
            size: CGSize(width: size.width, height: 30)
        )
        ground.position = CGPoint(x: size.width / 2 - 30, y: 15)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        addChild(ground)

        // 🐷 4. Grisene
        addPig(x: size.width - 180, y: 80)
        addPig(x: size.width - 180, y: 224)
        addPig(x: size.width - 270, y: 245)

        // 🪵 5. Bjælker omkring grisen
        addBeam(x: size.width - 210, y: 70)
        addBeam(x: size.width - 150, y: 70)
        addBeam(x: size.width - 210, y: 150)
        addBeam(x: size.width - 150, y: 150)
        addBeam(x: size.width - 90, y: 70)
        addBeam(x: size.width - 90, y: 150)
        addBeam(x: size.width - 270, y: 70)
        addBeam(x: size.width - 270, y: 150)
        addBeam(x: size.width - 270, y: 197.5, horizontal: true)
        addBeam(x: size.width - 305, y: 245)
        addBeam(x: size.width - 235, y: 245)
        addBeam(x: size.width - 180, y: 197.5, horizontal: true)

        //Antal fugle tilbage-label
        birdsLeftLabel = SKLabelNode(fontNamed: "Arial-BoldMT")
        birdsLeftLabel.fontSize = 24
        birdsLeftLabel.fontColor = .black
        birdsLeftLabel.name = "birdsLeftLabel"
        
        birdsLeftLabel.position = CGPoint(
            x: size.width - 800,
            y: size.height - 50
        )  // Øverst højre hjørne
        birdsLeftLabel.text = "Fugle: \(birdsLeft)"
        birdsLeftLabel.zPosition = 1000
        addChild(birdsLeftLabel)

        //Indsæt baggrundsbillede
        let background = SKSpriteNode(imageNamed: "background")
        background.name = "background"
        background.position = CGPoint(
            x: size.width / 2 - 35,
            y: size.height / 2
        )
        background.zPosition = -1  // Sørger for at baggrunden er bag ALT andet
        background.size = size
        addChild(background)

        //Preloade lyde
        SoundManager.shared.preloadSounds(filenames: [
            "fugl.wav", "start.wav", "crashlav.wav", "crashmellem.wav",
            "crashhøj.wav", "grynt1.wav", "grynt2.wav", "grynt3.wav",
            "grynt4.wav",
        ])
        SoundManager.shared.playSound(named: "start.wav")

        pigSounds.startPigGryntTimer()
        spawnNewBird()
    }

    // 🐦 3. Fuglen
    func spawnNewBird() {
        guard birdsLeft > 0 else {
            print("Ingen fugle tilbage!")
            return
        }

        birdsLeft -= 1
        birdsLeftLabel.text = "Fugle: \(birdsLeft)"

        bird = SKSpriteNode(imageNamed: "bird")
        bird.size = CGSize(width: 35, height: 35)
        bird.position = CGPoint(x: 100, y: 200)
        bird.physicsBody = SKPhysicsBody(
            texture: bird.texture!,
            size: bird.size
        )
        bird.physicsBody?.affectedByGravity = false
        bird.physicsBody?.isDynamic = true
        bird.name = "bird"
        bird.physicsBody?.categoryBitMask = 0x1 << 0
        bird.physicsBody?.contactTestBitMask = 0x1 << 1 | 0x1 << 2
        addChild(bird)
        currentBird = bird
        birdLaunched = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        startTouchLocation = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = startTouchLocation else {
            return
        }
        var location = touch.location(in: self)
        if location.y < 60 {
            location.y = 60
        }
        if location.x < 1 {
            location.x = 1
        }
        bird.position = location

        // Fjern tidligere prikker
        enumerateChildNodes(withName: "aimDot") { node, _ in
            node.removeFromParent()
        }

        // Tegn prikker mellem start og aktuel placering
        let numberOfDots = 8
        for i in 1...numberOfDots {
            let t = CGFloat(i) / CGFloat(numberOfDots + 1)
            let x = start.x + t * (location.x - start.x)
            let y = start.y + t * (location.y - start.y)

            let dot = SKShapeNode(circleOfRadius: 3)
            dot.position = CGPoint(x: x, y: y)
            dot.fillColor = .gray
            dot.strokeColor = .clear
            dot.name = "aimDot"
            addChild(dot)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let start = startTouchLocation else {
            return
        }
        SoundManager.shared.playSound(named: "fugl.wav")

        let end = touch.location(in: self)

        let dx = start.x - end.x
        let dy = start.y - end.y
        let impulse = CGVector(dx: dx * 1.0, dy: dy * 1.0)

        bird.physicsBody?.affectedByGravity = true
        bird.physicsBody?.applyImpulse(impulse)
        birdLaunched = true

        // Fjern prikker
        enumerateChildNodes(withName: "aimDot") { node, _ in
            node.removeFromParent()
        }
        startBirdTimer()
    }

    //Følg fuglen når den ryger over skærmen
    override func update(_ currentTime: TimeInterval) {
        let baseY = size.height / 2  // fx 207 hvis height = 414
        let threshold: CGFloat = 360

        // Bestem ny y-position for kamera
        let newY: CGFloat

        if bird.position.y <= threshold {
            newY = baseY
        } else {
            // Eksempel: Fuglen er i 430 → offset = 40 → kamera.y = baseY + 40
            let offset = bird.position.y - threshold
            newY = baseY + offset
        }

        camera?.position = CGPoint(x: baseY * 2, y: newY)
    }

    func startBirdTimer() {
        birdTimer?.invalidate()  // Stop en evt. gammel timer

        birdTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false)
        { [weak self] _ in
            self?.checkBirdStopped()
        }
    }

    func checkBirdStopped() {
        guard let bird = currentBird else { return }

        let speed = bird.physicsBody?.velocity.length() ?? 0

        if bird.position.y <= 30 || speed < 10 {
            // Fuglen er stoppet eller på jorden
            bird.removeFromParent()
            if birdsLeft > 0 {
                spawnNewBird()
            } else {
                gameState?.status = .lost
            }
        } else {
            // Fuglen flyver stadig → prøv igen om 1 sekund
            startBirdTimer()
        }
    }
}

extension CGVector {
    func length() -> CGFloat {
        return sqrt(dx * dx + dy * dy)
    }
}
