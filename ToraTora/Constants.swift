//
//  Constants.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 25/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import Foundation

struct physicsCategory {
    static let player: UInt32 = 0b1
    static let americanEnemyPlane: UInt32 = 0b10
    static let enemyProjectile: UInt32 = 0b11
    static let playerProjectile: UInt32 = 0b100
    static let enemyBattleShip: UInt32 = 0b101
    static let germanEnemyPlane: UInt32 = 0b110
}

struct SoundFile {
    static let BackgroundMusic = "bensound-highoctane.mp3"
    static let FireProjectile = "gunshot.mp3"
    static let Explode = "explosion.wav"
    static let Rocket = "missile01.mp3"
    static let Missile = "missile02.mp3"
    static let BulletImpact = "bulletimpact.mp3"
}
