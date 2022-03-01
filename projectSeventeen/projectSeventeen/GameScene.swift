//
//  GameScene.swift
//  projectSeventeen
//
//  Created by Atheer on 2019-06-09.
//  Copyright © 2019 Atheer. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    // our possible enemies which we have texture on in asset catalog
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
   
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")!
        starfield.position = CGPoint(x: 1024, y: 384)
        // in the begining the background will be just black and the star will gradully come
        // but now we are telling to make 10 second of simulation of our particale
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        starfield.zPosition = -1
        
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        // creating a physics body from a texture ie a picture
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        // it can only collide with object that have categoryBitMask value of 1
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        score = 0
        
        // no gravity
        physicsWorld.gravity = .zero
        // tell us when contact happens
        physicsWorld.contactDelegate = self
        
        // creating a timer that fires every 0.35 seconds when it fires it calles our function
        // create enemy, we don't send any info and it repeats
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        // our screen is 1024 but we put at 1200 so it
        // looks like it comes from right to left
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        // the speed at the item travels at
        // we are giving a constant force of 500 to the left
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        // setting the spin for object
        sprite.physicsBody?.angularVelocity = 5
        // how fast it will slow over time and
        // we are telling it won't stop
        sprite.physicsBody?.linearDamping = 0
        // also it will not stop rotating
        sprite.physicsBody?.angularDamping = 0
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // update called every frame
        
        // children is all the nodes on the scene
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            score += 1
        }
    }
    
    // we use because touches began it's called only when we tap the screen
    // if we are pressing the screen it counts only once hence we use
    // touchesMoved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        }else if location.y > 668 {
            location.y = 668
        }
        
        // setting our tocuh position to our position
        player.position = location
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        
    }
    
}
