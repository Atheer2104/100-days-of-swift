//
//  WhackSlot.swift
//  projectFourteen
//
//  Created by Atheer on 2019-06-05.
//  Copyright © 2019 Atheer. All rights reserved.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    
    var isVisible = false
    var isHit = false
    
    func configure(at position:CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
        
        // crop node will hide anything that is transparent in picture and show everything
        // with color
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        // it's under our holes
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        // adding our penguin picture into cropnode
        cropNode.addChild(charNode)
        addChild(cropNode)
        
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        
        charNode.xScale = 1
        charNode.yScale = 1
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            // changing our char node texture
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        }else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) {
            [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        // wait takes in duration in seconds
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        // later in code the self will be the penguin that got hit 
        let notVisible = SKAction.run {
            [weak self] in
            self?.isVisible = false
        }
        // we are creating a list of SKAction
        // will only go to the next item when the previous is finished
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence)
        
    }
    
}
