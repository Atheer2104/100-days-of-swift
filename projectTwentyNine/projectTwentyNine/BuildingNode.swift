//
//  BuildingNode.swift
//  projectTwentyNine
//
//  Created by Atheer on 2019-06-24.
//  Copyright © 2019 Atheer. All rights reserved.
//

import SpriteKit
import UIKit

class BuildingNode: SKSpriteNode {
    var currentImage: UIImage!
    
    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = collisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = collisionTypes.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            let color: UIColor
            
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOfColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            // it start from ten and goes up to height - 10 then goes by 40 each time 
            for row in stride(from: 10, to: Int(size.height - 10 ), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    // getting random boolean value and if it's true then it will run
                    if Bool.random() {
                        lightOnColor.setFill()
                    } else {
                        lightOfColor.setFill()
                    }
                    
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
                
            }
            
        }
        
        return img
    }
    
    func hit(at point: CGPoint) {
        // converting from spritekit to coregraphics because spritekit positons
        // things from center and coregraphics from bottom left
        // abs är det absolutabeloppet meaning everything negative will be positiv
        let convertedPoint = CGPoint(x: point.x + size.width / 2 , y: abs(point.y - size.height / 2))
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image {
            ctx in
            // drawing the same layer of buildings
            currentImage.draw(at: .zero)
            // creating an ellipse that is on the center of converted point
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64))
            // this will remove everything that is there already because we did draw the ellipse
            // over the building like a second layer and it will remove it
            // making the illusion that there is a hole there
            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.drawPath(using: .fill)
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        configurePhysics()
    }
    
    
}
