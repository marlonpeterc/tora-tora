//
//  BaseNode.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 27/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import Foundation
import SpriteKit

class BaseNode : SKSpriteNode, Hittable, Destroyable {
  
    var hitCount: Int = 0
    var maxAllowedHitCount: Int = 0
    
    func hit() {
        hitCount += 1
    }
    
    func wasDestroyed() -> Bool {
        if hitCount >= maxAllowedHitCount {
            self.removeFromParent()
            return true
        }
        return false
    }

}
