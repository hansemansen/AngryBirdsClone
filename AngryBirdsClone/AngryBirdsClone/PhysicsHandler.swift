//
//  PhysicsHandler.swift
//  BallTest4
//
//  Created by dmu mac 26 on 26/04/2025.
//

import SpriteKit

extension GameScene {
    func didBegin(_ contact: SKPhysicsContact) {
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]

        // 1. Fuglen rammer grisen
        if names.contains("bird") && names.contains("pig") {
            let pigNode =
                contact.bodyA.node?.name == "pig"
                ? contact.bodyA.node : contact.bodyB.node
            print("🐦💥🐷 Fuglen ramte grisen!")

            // Find health og label
            if let pig = pigNode,
                let health = pig.userData?["health"] as? Int
                
            {
                //let label = pig.childNode(withName: "healthLabel") as? SKLabelNode
                //Ændr health
                let impulse = contact.collisionImpulse
                var newHealth: Int
                if impulse < 15 {
                    newHealth = max(health - 10, 0)

                    pig.userData?["health"] = newHealth
                    //label.text = "\(newHealth)"

                    if newHealth < 50, let pigSprite = pig as? SKSpriteNode {
                        pigSprite.texture = SKTexture(imageNamed: "pig-wounded")
                    }
                    if newHealth == 0 {
                        pig.removeFromParent()
                        pigs -= 1
                        checkForVictory()
                    }
                } else {
                    pig.removeFromParent()
                    pigs -= 1
                    checkForVictory()
                }
            }
        }

        // 2. Fuglen rammer bjælke
        if names.contains("bird") && names.contains("beam") {
            let beamNode =
                contact.bodyA.node?.name == "beam"
                ? contact.bodyA.node : contact.bodyB.node
            print("🐦💥🪵 Fuglen ramte en bjælke!")

            // Find health og label
            if let beam = beamNode,
                let health = beam.userData?["health"] as? Int
            {
                //let label = beam.childNode(withName: "healthLabel") as? SKLabelNode
                //Ændr health
                let impulse = contact.collisionImpulse

                var newHealth: Int

                //hårdt træf - bjælke fjernes
                if impulse > 20 {
                    newHealth = 0
                    print("💥 Bjælken blev ødelagt!")
                    SoundManager.shared.playSound(named: "crashhøj.wav")
                    beam.removeFromParent()
                }
                // ellers
                else {
                    if impulse > 10 {
                        SoundManager.shared.playSound(named: "crashmellem.wav")
                    }
                    else if impulse > 0.5 {
                        SoundManager.shared.playSound(named: "crashlav.wav")
                    }

                    newHealth = max(health - Int(impulse * 2), 0)
                    beam.userData?["health"] = newHealth
                    //label.text = "\(newHealth)"
                    if health <= 0 {
                        beam.removeFromParent()
                    }
                }
            }
        }

        // 3. Bjælke rammer bjælke
        if names.filter({ $0 == "beam" }).count == 2 {
            let beamNodeA = contact.bodyA.node
            let beamNodeB = contact.bodyB.node
            print("Bjælke ramte en bjælke!")

            // Find health og label
            if let beamA = beamNodeA, let beamB = beamNodeB,
                let healthA = beamA.userData?["health"] as? Int,
                let healthB = beamB.userData?["health"] as? Int
            {
                //let labelA = beamA.childNode(withName: "healthLabel") as? SKLabelNode
                //let labelB = beamB.childNode(withName: "healthLabel") as? SKLabelNode
                let impulse = contact.collisionImpulse

                var newHealthA: Int
                var newHealthB: Int

                newHealthA = max(healthA - Int(impulse / 2), 0)
                beamA.userData?["health"] = newHealthA
                // labelA.text = "\(newHealthA)"

                newHealthB = max(healthB - Int(impulse / 2), 0)
                beamB.userData?["health"] = newHealthB
                // labelB.text = "\(newHealthB)"

                if healthA == 0 {
                    beamA.removeFromParent()
                }
                if healthB == 0 {
                    beamB.removeFromParent()
                }
            }
        }
        // 4. Bjælke rammer grisen
        if names.contains("beam") && names.contains("pig") {
            let pigNode =
                contact.bodyA.node?.name == "pig"
                ? contact.bodyA.node : contact.bodyB.node
            let beamNode =
                contact.bodyA.node?.name == "beam"
                ? contact.bodyA.node : contact.bodyB.node
            print("🪵💥🐷 Bjælke ramte grisen!")

            if let pig = pigNode,
                let health = pig.userData?["health"] as? Int
            {
                //let label = pig.childNode(withName: "healthLabel") as? SKLabelNode
                let impulse = contact.collisionImpulse

                var newHealth: Int

                if impulse < 20 {
                    newHealth = max(health - Int(impulse * 2), 0)
                } else {
                    newHealth = 0  // Hård kollision = gris dør med det samme
                }

                pig.userData?["health"] = newHealth
                // label.text = "\(newHealth)"

                if newHealth == 0 {
                    pig.removeFromParent()
                    pigs -= 1
                    checkForVictory()
                } else if newHealth < 50,
                    let pigSprite = pig as? SKSpriteNode
                {
                    pigSprite.texture = SKTexture(imageNamed: "pig-wounded")
                }
            }
        }

        // 4. Print kontaktens styrke
        print("💥 Impuls: \(contact.collisionImpulse)")
    }
    
    func checkForVictory() {
        if pigs == 0 {
            gameState?.status = .won
        }
    }

}
