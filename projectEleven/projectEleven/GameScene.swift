//
//  GameScene.swift
//  projectEleven
//
//  Created by Atheer on 2019-05-28.
//  Copyright © 2019 Atheer. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var editLabel: SKLabelNode!
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    var balls = ["ballRed", "ballBlue", "ballCyan", "ballGreen",
    "ballGrey", "ballPurple", "ballYellow"]
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        // positioning at center of screen
        background.position = CGPoint(x: 512, y: 384)
        // .replace as blendmode means ignore alpha/transparency
        background.blendMode = .replace
        // puting the background behind everything
        background.zPosition = -1
        // adding it to our scen
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        // if want left or right horziontal
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 700)
        addChild(scoreLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        // giving a physics body to our scen
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        // making slots between our bouncers
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        // placing bouncers evenly with intervalls of 256
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
    }
    
    // when the user tocuhed the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // we use first because the user could have tapped with multiple fingers
        guard let touch = touches.first else { return }
        // find where the touch was in my game scene
        let location = touch.location(in: self)
        /*
        let box = SKSpriteNode(color: .red, size: CGSize(width: 64, height: 64))
        // giving our box a physics body that has the same size as it self i.e the box
        box.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 64, height: 64))
        box.position = location
        addChild(box)
        */
        
        // what node exist at the location where we tapped
        let objects = nodes(at: location)
        
        if objects.contains(editLabel) {
            // is the same as editingMode = !editingMode
            editingMode.toggle()
        } else {
            if editingMode {
                // creating a random width between 16 and 128
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                // the rotation is in radiens and not in degrees so this between 0 and 180
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
            } else {
                guard let colorBall = balls.randomElement() else { return }
                
                let ball = SKSpriteNode(imageNamed: colorBall)
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                // the bouncines
                ball.physicsBody?.restitution = 0.4
                // contactTestBitMask is which collision do you wanna know about default is nothing
                // collisionBitMask which object should i bump into default is set to everything
                // basically we are telling it you collide with everything and tell us of every
                // single bounce
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                ball.position = CGPoint(x: location.x, y: 700)
                ball.name = "ball"
                addChild(ball)
            }
        }
    }
    
    func makeBouncer(at position:CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2)
        // the object will collide with object however it will not move it's fixed in place
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        // making a spin behavior with SKAction
        // we are spining half a cirlce over 10 seconds
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    // SKNode is the parent of SKSpriteNode
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }
    }
    
    func destroy(ball: SKNode) {
        // SKEmitterNode used for mostly for particles
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        
        ball.removeFromParent()
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        
        // body a refers what between the two object collide was it A or B
        if contact.bodyA.node?.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if contact.bodyB.node?.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }

}
