//
//  GameScene.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 18/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import SpriteKit
import AVFoundation

let textColorHUD = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player : PlayerNode?
    private var projectile : PlayerProjectileNode?
    
    private var scoreLabel : SKLabelNode?
    private var mainLabel : SKLabelNode?
    
    private var playerFireProjectileRate = 0.2
    private var playerProjectileSpeed = 0.9
    private var enemySpeed = 4.0
    private var enemyBattleShipSpeed = 10.0
    private var enemySpawnRate = 0.6
    private var enemyGermanPlaneSpawnRate = 2.0
    private var enemyBattleShipSpawnRate = 10.0
    private var enemyProjectileSpeed = 2.0
    private var enemyFireProjectileRate = 0.5
    
    private var playerIsAlive = true
    private var score = 0
    
    private var playerYPosition : CGFloat = 0
    private var screenHeightFromMid : Int = 0
    private var screenWidthFromMid : Int = 0
    
    private static var backgroundMusicPlayer: AVAudioPlayer!
    private var fireProjectileSoundAction: SKAction!
    private var explodeSoundAction: SKAction!
    private var rocketSoundAction: SKAction!
    private var missileSoundAction: SKAction!
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.init(red: (14.0/255.0), green: (70.0/255.0), blue: (140.0/255.0), alpha: 1)
        
        playerYPosition = -1 * ((self.frame.size.height / 2) - 200)
        screenHeightFromMid = (Int(self.frame.size.height) / 2)
        screenWidthFromMid = (Int(self.frame.size.width) / 2)
        
        spawnPlayer()
        spawnScoreLabel()
        spawnMainLabel()
        spawnPlayerProjectile()
        firePlayerProjectile()
        randomAmericanPlaneTimerSpawn()
        randomEnemyBattleShipTimerSpawn()
        randomGermanPlaneTimerSpawn()
        updateScore()
        hideLabel()
        resetVariablesOnStart()
        setUpAudio()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchLocation = touch.location(in: self)
            if playerIsAlive {
                player?.position.x = touchLocation.x
                player?.position.y = touchLocation.y + 100
            } else {
                player?.position.x = -200
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !playerIsAlive {
            player?.position.x = -200
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody : SKPhysicsBody = contact.bodyA
        let secondBody : SKPhysicsBody = contact.bodyB
        
        if (((firstBody.categoryBitMask == physicsCategory.playerProjectile) && (secondBody.categoryBitMask == physicsCategory.enemy)) ||
            ((firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.playerProjectile))) {
            spawnEnemyExplosion(enemyTemp: firstBody.node as! SKSpriteNode)
            projectileCollision(enemyTemp: firstBody.node as! SKSpriteNode, projectileTemp: secondBody.node as! SKSpriteNode)
        }
        
        if (((firstBody.categoryBitMask == physicsCategory.playerProjectile) && (secondBody.categoryBitMask == physicsCategory.germanPlane)) || ((firstBody.categoryBitMask == physicsCategory.germanPlane) && (secondBody.categoryBitMask == physicsCategory.playerProjectile))) {
            spawnEnemyExplosion(enemyTemp: firstBody.node as! SKSpriteNode)
            projectileCollision(enemyTemp: firstBody.node as! SKSpriteNode, projectileTemp: secondBody.node as! SKSpriteNode)
        }
        
        if (((firstBody.categoryBitMask == physicsCategory.enemy) && (secondBody.categoryBitMask == physicsCategory.player)) ||
            ((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemy))) {
            spawnPlayerExplosion(playerTemp: firstBody.node as! SKSpriteNode)
            spawnEnemyExplosion(enemyTemp: secondBody.node as! SKSpriteNode)
            enemyPlayerCollision(enemyTemp: firstBody.node as! SKSpriteNode, playerTemp: secondBody.node as! SKSpriteNode)
        }
        
        if (((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemyProjectile)) ||
            ((firstBody.categoryBitMask == physicsCategory.enemyProjectile) && (secondBody.categoryBitMask == physicsCategory.player))) {
            spawnPlayerExplosion(playerTemp: firstBody.node as! SKSpriteNode)
            enemyPlayerCollision(enemyTemp: firstBody.node as! SKSpriteNode, playerTemp: secondBody.node as! SKSpriteNode)
        }
        
        if (((firstBody.categoryBitMask == physicsCategory.playerProjectile) && (secondBody.categoryBitMask == physicsCategory.enemyProjectile)) || ((firstBody.categoryBitMask == physicsCategory.enemyProjectile) && (secondBody.categoryBitMask == physicsCategory.playerProjectile))) {
            spawnEnemyExplosion(enemyTemp: firstBody.node as! SKSpriteNode)
            enemyPlayerProjectileCollision(enemyProjectileTemp: firstBody.node as! SKSpriteNode, playerProjectileTemp: secondBody.node as! SKSpriteNode)
        }
    }
    
    fileprivate func projectileCollision(enemyTemp: SKSpriteNode, projectileTemp: SKSpriteNode) {
        enemyTemp.removeFromParent()
        projectileTemp.removeFromParent()
        score = score + 1
        updateScore()
    }
    
    fileprivate func enemyPlayerCollision(enemyTemp: SKSpriteNode, playerTemp: SKSpriteNode) {
        mainLabel?.fontSize = 50
        mainLabel?.alpha = 1.0
        mainLabel?.text = "Game Over"
        playerIsAlive = false
        enemyTemp.removeFromParent()
        playerTemp.removeFromParent()
        player?.removeFromParent()
        self.removeAction(forKey: "projectileAction")
        waitThenMoveToTitleScreen()
    }
  
    fileprivate func enemyPlayerProjectileCollision(enemyProjectileTemp: SKSpriteNode, playerProjectileTemp: SKSpriteNode) {
        enemyProjectileTemp.removeFromParent()
        playerProjectileTemp.removeFromParent()
    }
    
    fileprivate func waitThenMoveToTitleScreen() {
        let wait = SKAction.wait(forDuration: 3.0)
        let transition = SKAction.run{
            self.view?.presentScene(TitleScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        }
        let sequence = SKAction.sequence([wait, transition])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    fileprivate func spawnPlayer() {
        let pos = CGPoint(x: self.frame.midX, y: playerYPosition)
        player = PlayerNode(imageNamed: "tora_tora_bida_plane_120px", initialPosition: pos)
        self.addChild(player!)
    }
    
    fileprivate func spawnScoreLabel() {
        let yCoord = self.frame.size.height / 2
        scoreLabel = SKLabelNode(fontNamed: "Futura")
        scoreLabel?.fontSize = 30
        scoreLabel?.fontColor = textColorHUD
        scoreLabel?.position = CGPoint(x: self.frame.midX, y: yCoord - 130)
        scoreLabel?.text = "Score"
        self.addChild(scoreLabel!)
    }
    
    fileprivate func spawnMainLabel() {
        mainLabel = SKLabelNode(fontNamed: "Futura")
        mainLabel?.fontSize = 100
        mainLabel?.fontColor = textColorHUD
        mainLabel?.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        mainLabel?.text = "Start"
        self.addChild(mainLabel!)
    }
    
    fileprivate func spawnPlayerProjectile() {
        let position = CGPoint(x: (player?.position.x)!, y: (player?.position.y)!)
        projectile = PlayerProjectileNode(imageNamed: "projectile", initialPosition: position)
        
        let moveForward = SKAction.moveTo(y: 1000, duration: playerProjectileSpeed)
        let playSound = SKAction.run{ self.run(self.fireProjectileSoundAction) }
        let group = SKAction.group([moveForward, playSound])
        let destroy = SKAction.removeFromParent()
        
        projectile?.run(SKAction.sequence([group, destroy]))
        self.addChild(projectile!)
    }
    
    fileprivate func spawnAmericanEnemyPlane() {
        let americanPlane = EnemyAmericanPlaneNode(imageNamed: "tora_tora_kalaban_plane_100px", initialPosition: self.enemyPlanePosition())
        self.runEnemyAction(enemyTemp: americanPlane)
        self.addChild(americanPlane)
    }
    
    fileprivate func spawnEnemyGermanPlane() {
        let germanPlane = EnemyGermanPlaneNode(imageNamed: "german_plane_100px", initialPosition: self.enemyPlanePosition())
        self.runEnemyAction(enemyTemp: germanPlane)
        self.addChild(germanPlane)
    }
    
    fileprivate func enemyPlanePosition() -> CGPoint {
        // make sure x coordinate is within screen bounds
        let x = (screenWidthFromMid > 100) ? (screenWidthFromMid - 100) : screenWidthFromMid
        let xPosition = Int.random(in: -x ... x)
        return CGPoint(x: xPosition, y: screenHeightFromMid)
    }
    
    fileprivate func runEnemyAction(enemyTemp: SKSpriteNode) {
        let yPos = CGFloat(-1 * screenHeightFromMid)
        let moveForward = SKAction.moveTo(y: yPos, duration: enemySpeed)
        let fire = SKAction.run {
            self.fireEnemyProjectile(enemyTemp: enemyTemp, repeatCount: 1)
        }
        let group = SKAction.group([moveForward, fire])
        let destroy = SKAction.removeFromParent()
        enemyTemp.run(SKAction.sequence([group, destroy]))
    }
    
    fileprivate func spawnEnemyProjectile(enemyTemp: SKSpriteNode) {
        let position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        let enemyProjectile = EnemyProjectileNode(imageNamed: "missile", initialPosition: position)
        
        let moveForward = SKAction.moveTo(y: -1000, duration: enemyProjectileSpeed)
        let playSound = SKAction.run { self.run(self.missileSoundAction) }
        let group = SKAction.group([moveForward, playSound])
        let destroy = SKAction.removeFromParent()
        
        enemyProjectile.run(SKAction.sequence([group, destroy]))
        self.addChild(enemyProjectile)
    }
    
    fileprivate func spawnEnemyBattleShipProjectile(enemyTemp: SKSpriteNode) {
        let position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        let enemyProjectile = BattleShipProjectileNode(imageNamed: "missile30x80", initialPosition: position)
        
        let moveForward = SKAction.moveTo(y: -1000, duration: enemyProjectileSpeed)
        let scale = SKAction.scale(to: 0.2, duration: 0.1)
        let resize = SKAction.scale(to: 1.0, duration: 1.0)
        let group = SKAction.group([moveForward, resize])
        let destroy = SKAction.removeFromParent()
        
        enemyProjectile.run(SKAction.sequence([scale, group, destroy]))
        self.addChild(enemyProjectile)
    }
    
    fileprivate func spawnEnemyBattleShip() {
        // make sure x coordinate is within screen bounds
        let x = (screenWidthFromMid > 100) ? (screenWidthFromMid - 100) : screenWidthFromMid
        let xPosition = Int.random(in: -x ... x)
        let yPosition = screenHeightFromMid + 200
        let position = CGPoint(x: xPosition, y: yPosition)
        let battleShip = BattleShipNode(imageNamed: "battleship", initialPosition: position)
        
        let yPos = CGFloat(-1 * yPosition)
        let moveForward = SKAction.moveTo(y: yPos, duration: enemyBattleShipSpeed)
        let fire = SKAction.run {
            self.fireEnemyBattleShipProjectile(enemyTemp: battleShip, repeatCount: 3)
        }
        let group = SKAction.group([moveForward, fire])
        let destroy = SKAction.removeFromParent()
        
        battleShip.run(SKAction.sequence([group, destroy]))
        self.addChild(battleShip)
    }
    
    fileprivate func spawnEnemyExplosion(enemyTemp: SKSpriteNode){
        let position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        let explosion = EnemyExplosionNode(imageNamed: "sabog_100px", initialPosition: position)
        
        let yCoord = Int(self.frame.size.height) / 2
        let yPos = CGFloat(-1 * yCoord)
        let moveForward = SKAction.moveTo(y: yPos, duration: enemySpeed)
        let resize = SKAction.resize(byWidth: -100.0, height: -100.0, duration: 2.0)
        let playSound = SKAction.run{ self.run(self.explodeSoundAction) }
        let group = SKAction.group([playSound, moveForward, resize])
        let destroy = SKAction.removeFromParent()
        
        explosion.run(SKAction.sequence([group, destroy]))
        self.addChild(explosion)
    }
    
    fileprivate func spawnPlayerExplosion(playerTemp: SKSpriteNode){
        let explosion = SKSpriteNode(imageNamed: "sabog_120px")
        explosion.position = CGPoint(x: playerTemp.position.x, y: playerTemp.position.y)
        explosion.zPosition = 1
        
        let playSound = SKAction.run{ self.run(self.explodeSoundAction) }
        let resize = SKAction.resize(byWidth: -120.0, height: -120.0, duration: 2.0)
        let group = SKAction.group([playSound, resize])
        let destroy = SKAction.removeFromParent()
        
        explosion.run(SKAction.sequence([group, destroy]))
        self.addChild(explosion)
    }
    
    fileprivate func firePlayerProjectile() {
        let fireProjectileTimer = SKAction.wait(forDuration: playerFireProjectileRate)
        let spawn = SKAction.run {
            self.spawnPlayerProjectile()
        }
        let sequence = SKAction.sequence([fireProjectileTimer, spawn])
        self.run(SKAction.repeatForever(sequence), withKey: "projectileAction")
    }
    
    fileprivate func fireEnemyProjectile(enemyTemp: SKSpriteNode, repeatCount: Int) {
        let fireProjectileTimer = SKAction.wait(forDuration: 0.5)
        let spawn = SKAction.run {
            self.spawnEnemyProjectile(enemyTemp: enemyTemp)
        }
        let sequence = SKAction.sequence([fireProjectileTimer, spawn])
        enemyTemp.run(SKAction.repeat(sequence, count: repeatCount))
    }
    
    fileprivate func fireEnemyBattleShipProjectile(enemyTemp: SKSpriteNode, repeatCount: Int) {
        let fireProjectileTimer = SKAction.wait(forDuration: 0.2)
        let spawn = SKAction.run {
            self.run(self.rocketSoundAction)
            self.spawnEnemyBattleShipProjectile(enemyTemp: enemyTemp)
        }
        let sequence = SKAction.sequence([fireProjectileTimer, spawn])
        enemyTemp.run(SKAction.repeat(sequence, count: repeatCount))
    }
    
    fileprivate func randomAmericanPlaneTimerSpawn() {
        let spawnEnemyTimer = SKAction.wait(forDuration: enemySpawnRate)
        let spawn = SKAction.run {
            self.spawnAmericanEnemyPlane()
        }
        let sequence = SKAction.sequence([spawnEnemyTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    fileprivate func randomGermanPlaneTimerSpawn() {
        let spawnGermanPlaneTimer = SKAction.wait(forDuration: enemyGermanPlaneSpawnRate)
        let spawn = SKAction.run {
            self.spawnEnemyGermanPlane()
        }
        let sequence = SKAction.sequence([spawnGermanPlaneTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    fileprivate func randomEnemyBattleShipTimerSpawn() {
        let spawnEnemyTimer = SKAction.wait(forDuration: enemyBattleShipSpawnRate)
        let spawn = SKAction.run {
            self.spawnEnemyBattleShip()
        }
        let sequence = SKAction.sequence([spawnEnemyTimer, spawn])
        self.run(SKAction.repeatForever(sequence))
    }
    
    fileprivate func updateScore() {
        scoreLabel!.text = "Score: \(score)"
    }
    
    fileprivate func hideLabel() {
        let wait = SKAction.wait(forDuration: 3.0)
        let hide = SKAction.run {
            self.mainLabel?.alpha = 0.0
        }
        let sequence = SKAction.sequence([wait, hide])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    fileprivate func resetVariablesOnStart() {
        playerIsAlive = true
        score = 0
    }
    
    fileprivate func setUpAudio() {
        if GameScene.backgroundMusicPlayer == nil {
            let backgroundMusicURL = Bundle.main.url(forResource: SoundFile.BackgroundMusic, withExtension: nil)
            
            do {
                let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
                GameScene.backgroundMusicPlayer = theme
            } catch {
                // Could not load background music file
            }
            GameScene.backgroundMusicPlayer.numberOfLoops = -1
        }
        
        if !GameScene.backgroundMusicPlayer.isPlaying {
            GameScene.backgroundMusicPlayer.play()
        }
        
        fireProjectileSoundAction = SKAction.playSoundFileNamed(SoundFile.FireProjectile, waitForCompletion: false)
        explodeSoundAction = SKAction.playSoundFileNamed(SoundFile.Explode, waitForCompletion: false)
        rocketSoundAction = SKAction.playSoundFileNamed(SoundFile.Rocket, waitForCompletion: false)
        missileSoundAction = SKAction.playSoundFileNamed(SoundFile.Missile, waitForCompletion: false)
    }
}
