//
//  GameScene.swift
//  projectTwentyThree
//
//  Created by Atheer on 2019-06-15.
//  Copyright © 2019 Atheer. All rights reserved.
//

import SpriteKit
import AVFoundation

enum foreceBomb {
    case never, always, random
}

// CaseIterable it list all of our cases into an array useful in our case
// for we could use random to choose one of the cases
enum sequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain, fastOne
}

class GameScene: SKScene {
    var gameScore: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    // drawing shape using SKShapeNode
    // one for our yellow one and for our white one which will be in middle
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    
    // the time when the enemy is destroyed and new one will appear
    var popupTime = 0.9
    var sequnce = [sequenceType]()
    var sequncePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
 
    override func didMove(to view: SKView) {
     
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        // setting custom gravity
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        // changing the speed of the world this will make things go a bit slower
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        // starting sequence for game like a tutortial later we make our sequnce random
        sequnce = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .fastOne, .three, .one, .chain]
         
        // creating random cases for our sequence
        for _ in 0...1000 {
            // allCases comes from CaseIterable
            if let nextSequence = sequenceType.allCases.randomElement() {
                sequnce.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in
            self?.tossEnemies()
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        // this will be on top of activeSliceBG because
        // it has higher zPosition
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = .white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
        
    }
    
    func enemy(node: SKSpriteNode) {
        if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
            emitter.position = node.position
            addChild(emitter)
        }
        
        node.name = ""
        // turning of the physics body
        node.physicsBody?.isDynamic = false
        
        let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
        let fadeOut = SKAction.fadeIn(withDuration: 0.2)
        // creating a group so they can be run at the same time
        let group = SKAction.group([scaleOut, fadeOut])
        
        
        // we run our group command plus we remove it from scene
        // we run group first then the other not at the same time
        // as a group
        let seq = SKAction.sequence([group, .removeFromParent()])
        node.run(seq)
        
        if let index = activeEnemies.firstIndex(of: node) {
            activeEnemies.remove(at: index)
        }
        
        run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        // will only enter the loop if node is type of SKSpriteNode
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" {
                //destroy the penguin, it was hit
                enemy(node: node)
                score += 1
                
            } else if node.name == "fastEnemy" {
                enemy(node: node)
                score += 5
            } else if node.name == "bomb" {
                // destroy the bomb, it was hit
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeIn(withDuration: 0.2)
                // creating a group so they can be run at the same time
                let group = SKAction.group([scaleOut, fadeOut])
                
                // we run our group command plus we remove it from scene
                // we run group first then the other not at the same time
                // as a group
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggerdByBomb: true)
                
            }
            
            
        }
        
    }
    
    func endGame(triggerdByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        isGameEnded = true
        // stop everything from moving
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggerdByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        let gameOver = SKLabelNode(fontNamed: "Chalkduster")
        gameOver.text = "Game Over"
        gameOver.horizontalAlignmentMode = .center
        gameOver.fontSize = 48
        gameOver.position = CGPoint(x: 512, y: 384)
        gameOver.run(SKAction.fadeIn(withDuration: 2))
        addChild(gameOver)
        
        
        
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        // creating a random number between 1 and 3 because
        // our swoosh audio is named swoosh and number
        // we want a random one
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        // playing our swoosh sound and waiting for it to complete
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // using closure because we are telling it what to do when it's done playing
        run(swooshSound) {
            [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        // also we are removing our SKAction because we called an action
        // to make them fadeout, Because it could happen that the action is stil
        // continuing if you are fast and that why we remove them
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        // setting the alpha back to one because when we remove our finger we fade them out
        // and when we fade them out we are setting their alpha to 0 thus next time
        // they would not be shown because they are hidden ie alpha is 0
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    func redrawActiveSlice() {
        
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        if activeSlicePoints.count > 12 {
            // example if we have 15 points - 12 then have 3
            // so then we are removing the first 3 point in the array
            // so line doesn't get to long
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        // starting path from our first point
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            //  checking other point in the array and
            // the path to each point in array
            path.addLine(to: activeSlicePoints[i])
            
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
        
    }
    
    func createEnemy(forceBomb: foreceBomb = .random) {
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            enemyType = Int.random(in: 1...6)
        }else if forceBomb == .always {
            enemyType = 0
        }
        
        
        if enemyType == 0 {
            // bomb code
            enemy = SKSpriteNode()
            // appear head of other things because they could be trapped under
            // the penguin so making sure it has higher zPosition than penguin
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                // stopping audio from playing and setting it to nil
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
            
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        let randomXAxis = 64...960
        
        // position code
        let randomPosition = CGPoint(x: Int.random(in: randomXAxis), y: -128)
        enemy.position = randomPosition
  
        // spin
        let randomAngularVelocity = CGFloat.random(in: -3...3)
        let randomXVelocity: Int
        
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 8...15)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 3...5)
        } else if randomPosition.x < 768 {
            // giving a negative value so it goes left negative value is force on left
            randomXVelocity = -Int.random(in: 3...5)
        } else {
            randomXVelocity = -Int.random(in: 8...15)
        }
        
        let randomYValueVelocity = 24...32
        
        let randomYVelocity = Int.random(in: randomYValueVelocity)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        // it doesn't bounce of other object
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy )
        
    }
    
    func createFastEnemy() {
        let enemy = SKSpriteNode(imageNamed: "penguin")
        
        
        run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
        enemy.name = "fastEnemy"
        enemy.colorBlendFactor = 0.5
        enemy.color = .yellow
        
        let randomXAxis = 64...960
        
        // position code
        let randomPosition = CGPoint(x: Int.random(in: randomXAxis), y: -128)
        enemy.position = randomPosition
        
        // spin
        let randomAngularVelocity = CGFloat.random(in: -6...6)
        let randomXVelocity: Int
        
        if randomPosition.x < 256 {
            randomXVelocity = Int.random(in: 12...20)
        } else if randomPosition.x < 512 {
            randomXVelocity = Int.random(in: 6...10)
        } else if randomPosition.x < 768 {
            // giving a negative value so it goes left negative value is force on left
            randomXVelocity = -Int.random(in: 6...10)
        } else {
            randomXVelocity = -Int.random(in: 12...20)
        }
        
        let randomYValueVelocity = 28...36
        
        let randomYVelocity = Int.random(in: randomYValueVelocity)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        // it doesn't bounce of other object
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func subtractLife() {
        lives -= 1
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggerdByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        
        life.run(SKAction.scale(to: 1, duration: 0.1))
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                     node.removeAllActions()
                    
                    if node.name == "enemy" || node.name == "fastEnemy" {
                        node.name = ""
                        subtractLife()
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                
                }
            }
        } else {
            // when there no next sequnce ie the value is false
            if !nextSequenceQueued  {
                // then we wait a delay the same as our popupTime then we call
                // tossEnemies
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) {
                    [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs - stop fuse sound 
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    func tossEnemies() {
        guard isGameEnded == false else { return }
        
        // it will decrease over time making game harder
        popupTime *= 0.991
        chainDelay *= 0.991
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequnce[sequncePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
       
        case .one:
            // don't need paramater as it is set to random as default
             createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()
            
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:
            createEnemy()
            
            // creating enemy after some delay
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) {
                [weak self] in self?.createEnemy()
            }
            
            
        case .fastChain:
            createEnemy()
            
            // creating enemy after some delay
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) {
                [weak self] in self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) {
                [weak self] in self?.createEnemy()
            }
            
        case .fastOne:
            createFastEnemy()
            
        }
        
        sequncePosition += 1
        nextSequenceQueued = false
    }
}


