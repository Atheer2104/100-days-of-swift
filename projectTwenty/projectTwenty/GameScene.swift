//
//  GameScene.swift
//  projectTwenty
//
//  Created by Atheer on 2019-06-11.
//  Copyright © 2019 Atheer. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode!
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0

        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        
        
        
        
    }
    
    func createFirework(xMovment: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        // color fully by the color we specify
        // making sure we can recolor our texture
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan
        case 1:
            firework.color = .green
        default:
            firework.color = .red
        }
        
        // for drawing path ie straight, curved all kind of shape
        let path = UIBezierPath()
        path.move(to: .zero)
        // rocket could come from diffierent sides however it will always
        // shot up so we make it go to 1000 in y coord
        path.addLine(to: CGPoint(x: xMovment, y: 1000))
        
        // asOffset is start where the sprite start and move from there
        // orientToPath follow the rotation too
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        // node will follow that path
        node.run(move)
        
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }
        
        fireworks.append(node)
        addChild(node)
        
    }
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        
        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovment: 0, x: 512, y: bottomEdge)
            createFirework(xMovment: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovment: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovment: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovment: 0, x: 512 + 200, y: bottomEdge)
            
        case 1:
            //fire five, in a fan
            createFirework(xMovment: 0, x: 512, y: bottomEdge)
            createFirework(xMovment: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovment: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovment: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovment: 200, x: 512 + 200, y: bottomEdge)
        case 2:
            // fire five, from the left to the right
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovment: movementAmount, x: leftEdge, y: bottomEdge)
            
        case 3:
            // fire five, from right to left
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovment: -movementAmount, x: rightEdge, y: bottomEdge)
            
        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        // checking in our nodesAtPoint for SKSpriteNode only because that is our rocket
        // we use the special syntac to we create a constant that is node
        // which will be an SKSpriteNode and if that condition is true that
        // nodesAtPoint arrays node is a SKSpriteNode and only then we do the for loop
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            // parent because it contains both rocket and emitter ie fuse
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            // will go back to default color which is white
            node.colorBlendFactor = 0
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // getting firework with index by enumerated and we are reversing it
        // we are reversing the array because if we remove something at index 3
        // then the item at index 4 will be at index 3 now and we will remove multiple times 
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                // removing from array
                fireworks.remove(at: index)
                // removing from gamescene
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
        }
        
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            // firework is two parts one the firework it self and the emitter
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
            
        }
        
        
    }
   
}
