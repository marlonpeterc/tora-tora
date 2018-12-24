//
//  PlayerProjectileNode.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 25/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerProjectileNode : SKSpriteNode {
    
    convenience init(imageNamed: String, initialPosition: CGPoint) {
        self.init(imageNamed: imageNamed)
        position = initialPosition
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = physicsCategory.playerProjectile
        physicsBody?.contactTestBitMask = physicsCategory.enemy | physicsCategory.enemyProjectile
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
        zPosition = -1
    }
    
}
