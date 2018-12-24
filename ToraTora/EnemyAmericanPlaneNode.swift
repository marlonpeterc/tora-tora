//
//  EnemyAmericanPlaneNode.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 25/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import Foundation
import SpriteKit

class EnemyAmericanPlaneNode : SKSpriteNode {
    
    convenience init(imageNamed: String, initialPosition: CGPoint) {
        self.init(imageNamed: imageNamed)
        position = initialPosition
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = physicsCategory.enemy
        physicsBody?.contactTestBitMask = physicsCategory.playerProjectile
        physicsBody?.collisionBitMask = 0
        physicsBody?.allowsRotation = false
        physicsBody?.isDynamic = true
    }
    
}
