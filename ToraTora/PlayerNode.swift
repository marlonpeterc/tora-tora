//
//  Player.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 25/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import Foundation
import SpriteKit

class PlayerNode : BaseNode {
    
    convenience init(imageNamed: String, initialPosition: CGPoint) {
        self.init(imageNamed: imageNamed)
        position = initialPosition
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.affectedByGravity = false
        physicsBody?.categoryBitMask = physicsCategory.player
        physicsBody?.contactTestBitMask = physicsCategory.americanEnemyPlane | physicsCategory.germanEnemyPlane
        physicsBody?.collisionBitMask = 0
        physicsBody?.isDynamic = false
        zPosition = 1000
        maxAllowedHitCount = 5
    }
    
}
