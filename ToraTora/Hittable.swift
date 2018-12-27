//
//  Hittable.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 27/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import Foundation

protocol Hittable {
    
    var hitCount: Int { get }
    
    var maxAllowedHitCount: Int { get }
    
    func hit()
    
}
