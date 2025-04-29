import SpriteKit

extension GameScene {
    
    func addPig(x: CGFloat, y: CGFloat) {
        let pig = SKSpriteNode(imageNamed: "pig.png")
        pig.size = CGSize(width: 38, height: 38)
        pig.position = CGPoint(x: x, y: y)
        pig.physicsBody = SKPhysicsBody(texture: pig.texture!, size: pig.size)
        pig.physicsBody?.isDynamic = true
        pig.name = "pig"
        pig.physicsBody?.categoryBitMask = 0x1 << 1
        
        pig.userData = NSMutableDictionary()
        pig.userData?["health"] = 100
        pigs += 1
        addChild(pig)
        
        //Til Test af Pig-energi
        //let label = SKLabelNode(fontNamed: "Arial")
        //label.fontSize = 14
        //label.fontColor = .black
        //label.position = CGPoint(x: 0, y: 20)
        //label.text = "100"
        //label.name = "healthLabel"
        //label.zPosition = 100
        //pig.addChild(label)
    }
    
    func addBeam(x: CGFloat, y: CGFloat, horizontal: Bool = false) {
        let size = horizontal ? CGSize(width: 80, height: 15) : CGSize(width: 15, height: 80)
        let beam = SKSpriteNode(imageNamed: "beam.png")
        beam.size = size
        beam.position = CGPoint(x: x, y: y)
        beam.physicsBody = SKPhysicsBody(rectangleOf: size)
        beam.physicsBody?.restitution = 0.2
        beam.physicsBody?.isDynamic = true
        beam.name = "beam"
        beam.physicsBody?.categoryBitMask = 0x1 << 2
        beam.physicsBody?.contactTestBitMask = (0x1 << 1) | (0x1 << 2)
        
        beam.userData = NSMutableDictionary()
        beam.userData?["health"] = 100
        addChild(beam)
        
        //Til Test af Bjælke-energi
        //let label = SKLabelNode(fontNamed: "Arial")
        //label.fontSize = 14
        //label.fontColor = .black
        //label.position = CGPoint(x: 0, y: 40)
        //label.text = "100"
        //label.name = "healthLabel"
        //label.zPosition = 100
        //beam.addChild(label)
    }
    
    func setupLevel() {
        // 🪵 Genopbyg bjælker
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
        
        // 🐷 Genopret grisene
        addPig(x: size.width - 180, y: 80)
        addPig(x: size.width - 180, y: 224)
        addPig(x: size.width - 270, y: 245)
    }
    
    func resetGame() {
        // Fjern alle gamle noder undtagen kamera, baggrund og label
        for node in children {
            if node.name != "camera" && node.name != "background" && node.name != "birdsLeftLabel" {
                node.removeFromParent()
            }
        }
        
        birdsLeft = 3
        pigs = 0
        birdLaunched = false
        birdsLeftLabel.text = "Fugle: \(birdsLeft)"
        
        // Genskab jorden
        let ground = SKSpriteNode(color: .brown, size: CGSize(width: size.width, height: 30))
        ground.position = CGPoint(x: size.width / 2 - 30, y: 15)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        addChild(ground)
        
        // Genopbyg resten
        setupLevel()
        
        spawnNewBird()
    }
}
