//
//  GameScene.swift
//  projectTwentySix
//
//  Created by Atheer on 2019-06-20.
//  Copyright © 2019 Atheer. All rights reserved.
//

import CoreMotion
import SpriteKit

enum collisonTypes: UInt32 {
    // good thing to know about is that we can add these number together
    // when we do it and get a number back it's important that the number doesn't have case
    // because we could add to items and then it become another if the same number exists
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
}


class GameScene: SKScene, SKPhysicsContactDelegate{
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    var motionManager: CMMotionManager?
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
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
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        
        loadLevel()
        createPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        motionManager = CMMotionManager()
        // start collecting tilt information
        motionManager?.startAccelerometerUpdates()
    }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level1", withExtension: "txt") else {
            // the app will crash if this line is hit and it's okay becuase we can't
            // either play the game if there is no level
            fatalError("Could not find level1.txt in the app bundle")
            
        }
        // load the url into string ie the file can in be in string formar
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle")
        }
        
        let lines = levelString.components(separatedBy: "\n")
        
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                // creating the position of the object that we will know level1
                // x is a wall, space is just empty ie a place where the ball will roll
                // s is a star, v is for vortex and f is finish line
                let position = CGPoint(x: (64 * column + 32), y: (64 * row + 32))
                
                // categorybitmask number that defines what object for considering collisons
                // collisonbitmask a number defines what we can collide with
                // contacttestbitmask a number, it tell us about the collision we want
                // to know about
                
                if letter == "x" {
                    let node = SKSpriteNode(imageNamed: "block")
                    node.position = position
                    
                    node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
                    // rawValue becuase else we would pass in an enum instead of the Int
                    node.physicsBody?.categoryBitMask = collisonTypes.wall.rawValue
                    node.physicsBody?.isDynamic = false
                    addChild(node)
                } else if letter == "v" {
                    let node = SKSpriteNode(imageNamed: "vortex")
                    node.name = "vortex"
                    node.position = position
                    // constantly rotating 180 degress
                    node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = collisonTypes.vortex.rawValue
                    // we want to know about when a vortex touches a player
                    node.physicsBody?.contactTestBitMask = collisonTypes.player.rawValue
                    // it doesn't collide with other objects
                    node.physicsBody?.collisionBitMask = 0
                    addChild(node)
                } else if letter == "s" {
                    let node = SKSpriteNode(imageNamed: "star")
                    node.name = "star"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = collisonTypes.star.rawValue
                    node.physicsBody?.contactTestBitMask = collisonTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == "f" {
                    let node = SKSpriteNode(imageNamed: "finish")
                    node.name = "finish"
                    node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
                    node.physicsBody?.isDynamic = false
                    
                    node.physicsBody?.categoryBitMask = collisonTypes.finish.rawValue
                    node.physicsBody?.contactTestBitMask = collisonTypes.player.rawValue
                    node.physicsBody?.collisionBitMask = 0
                    node.position = position
                    addChild(node)
                } else if letter == " " {
                        // empty space do nothing
                } else {
                    fatalError("Unkown level letter: \(letter)")
                }
                
            }
        }
        
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 96, y: 672)
        player.zPosition = 1
        
        player.physicsBody = SKPhysicsBody.init(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        // adding friction to the ball
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = collisonTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = collisonTypes.star.rawValue | collisonTypes.vortex.rawValue | collisonTypes.finish.rawValue
        player.physicsBody?.collisionBitMask = collisonTypes.wall.rawValue
        addChild(player)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        // when game is over then we don't have to update the ball position
        guard isGameOver == false else { return }
        
        // this code will be only excuted if we are running the app on
        // the simulator in a real app we want to use tilt instead of tap
        // but because of testing purposes we are using tap in simulator
        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            // we are setting the y data on the x value for vector because we
            // flipped device, we are multipling so user don't have to tilt far to get
            // the ball rolling and using -50 because we have flipped device
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
        #endif
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
        
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25 )
            let scale = SKAction.scale(to: 0.001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) {
                [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1
        } else if node.name == "finish" {
            // next level
        }
    }
    
}
