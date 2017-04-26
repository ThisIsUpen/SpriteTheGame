//
//  GameScene.swift
//  Project11
//
//  Created by Upendar Gareri on 23.04.17.
//  Copyright © 2017 Upendar Gareri. All rights reserved.
//

import GameplayKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var scoreLabel: SKLabelNode!
    var editLabel: SKLabelNode!
    
    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.blendMode = .replace
        background.position = CGPoint(x: 512, y: 384)
        background.zPosition = -1
        addChild(background)
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        for i in 0...4 {
            makeBouncer(at: CGPoint(x: i*256, y: 0))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            /*
            let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))
            box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
            //box.physicsBody = SKPhysicsBody(circleOfRadius: 80)
            box.position = location
            addChild(box)
             */
            
            let objects = nodes(at: location)
            if objects.contains(editLabel) {
                editingMode = !editingMode
            } else {
                if editingMode {
                    // create a box
                    let size = CGSize(width: GKRandomDistribution(lowestValue: 16, highestValue: 128).nextInt(), height: 16) //nextInt is a function inside GKRandomDistribution class that generates a random int between the range [lowest,highest]
                    let box = SKSpriteNode(color: RandomColor(), size: size)
                    box.zRotation = RandomCGFloat(min: 0, max: 3)
                    box.physicsBody = SKPhysicsBody(rectangleOf: size)
                    box.physicsBody!.isDynamic = false
                    box.position = location
                    
                    addChild(box)
                    
                } else {
                    // create a ball
                    addBall(at: location)
                }
            }
            
        }
    }
    
    func addBall(at location: CGPoint) {
        let ball = SKSpriteNode(imageNamed: "ballRed")
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
        ball.physicsBody!.restitution = 0.4
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask //contactTestBitMask is by default set to nothing and collisionBitMask is by default set to everything; but here we are changing contact value to everything i.e tell me if the ball collides to anything
        ball.name = "ball"
        ball.position = location
        addChild(ball)
    }
    
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody!.isDynamic = false
        bouncer.position = position //you can take it as centre of the object and cgsize is taken as image pixel size
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "goodBase"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "badBase"
        }
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        slotBase.position = position
        slotGlow.position = position
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: CGFloat.pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collisionBetween(ball: SKNode, andObject object: SKNode) {
        if object.name == "goodBase" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "badBase" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        
        if let particle = SKEmitterNode(fileNamed: "FireParticles") {
            particle.position = ball.position
            addChild(particle)
        }
        
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.node?.name == "ball" {
            collisionBetween(ball: contact.bodyA.node!, andObject: contact.bodyB.node!)
        } else if contact.bodyB.node?.name == "ball" {
            collisionBetween(ball: contact.bodyB.node!, andObject: contact.bodyA.node!)
        }
    }
}
