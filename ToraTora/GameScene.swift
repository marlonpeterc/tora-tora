//
//  GameScene.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 18/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import SpriteKit

let textColorHUD = UIColor(displayP3Red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var player : PlayerNode?
    private var projectile : PlayerProjectileNode?
    
    private var scoreLabel : SKLabelNode?
    private var mainLabel : SKLabelNode?
//    private var healthBar : SKSpriteNode?
//    private var healthBarContainer : SKSpriteNode?
    
    private var playerFireProjectileRate = 0.2
    private var playerProjectileSpeed = 0.9
    private var enemySpeed = 4.0
    private var enemyBattleShipSpeed = 10.0
    private var enemySpawnRate = 1.6
    private var enemyGermanPlaneSpawnRate = 2.0
    private var enemyBattleShipSpawnRate = 10.0
    private var enemyProjectileSpeed = 2.0
    private var enemyFireProjectileRate = 0.5
    
    private var playerIsAlive = true
    private var score = 0
    
    private var playerYPosition : CGFloat = 0
    private var screenHeightFromMid : Int = 0
    private var screenWidthFromMid : Int = 0
    
    private var fireProjectileSoundAction: SKAction!
    private var explodeSoundAction: SKAction!
    private var rocketSoundAction: SKAction!
    private var missileSoundAction: SKAction!
    private var bulletImpactSoundAction: SKAction!
    
    private let playerNormalTexture = SKTexture(imageNamed: "tora_tora_bida_plane_120px")
    private let playerHitTexture = SKTexture(imageNamed: "tora_tora_bida_plane_120px_hit")
    private let battleshipNormalTexture = SKTexture(imageNamed: "battleship")
    private let battleshipHitTexture = SKTexture(imageNamed: "battleship_hit")
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.init(red: (14.0/255.0), green: (70.0/255.0), blue: (140.0/255.0), alpha: 1)
        
        playerYPosition = -1 * ((self.frame.size.height / 2) - 200)
        screenHeightFromMid = (Int(self.frame.size.height) / 2)
        screenWidthFromMid = (Int(self.frame.size.width) / 2)
        
//        healthBarContainer = SKSpriteNode(color: UIColor.red, size: CGSize(width: 60, height: 16))
//        healthBarContainer?.position = CGPoint(x: 100, y: 100)
//        addChild(healthBarContainer!)
//        healthBar = SKSpriteNode(color: UIColor.green, size: CGSize(width: 50, height: 10))
//        healthBar?.position = CGPoint(x: 101, y: 101)
//        addChild(healthBar!)
        
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
        
        // Player projectile and american enemy plane collision
        if (((firstBody.categoryBitMask == physicsCategory.playerProjectile) && (secondBody.categoryBitMask == physicsCategory.americanEnemyPlane)) ||
            ((firstBody.categoryBitMask == physicsCategory.americanEnemyPlane) && (secondBody.categoryBitMask == physicsCategory.playerProjectile))) {
            singleProjectileCollision(enemyTemp: firstBody.node as! BaseNode, projectileTemp: secondBody.node as! BaseNode)
        }
        
        // Player projectile and german enemy plane collision
        if (((firstBody.categoryBitMask == physicsCategory.playerProjectile) && (secondBody.categoryBitMask == physicsCategory.germanEnemyPlane)) ||
            ((firstBody.categoryBitMask == physicsCategory.germanEnemyPlane) && (secondBody.categoryBitMask == physicsCategory.playerProjectile))) {
            singleProjectileCollision(enemyTemp: firstBody.node as! BaseNode, projectileTemp: secondBody.node as! BaseNode)
        }
        
        // Player projectile and enemy battle ship collision
        if (((firstBody.categoryBitMask == physicsCategory.playerProjectile) && (secondBody.categoryBitMask == physicsCategory.enemyBattleShip)) ||
            ((firstBody.categoryBitMask == physicsCategory.enemyBattleShip) && (secondBody.categoryBitMask == physicsCategory.playerProjectile))) {
            multipleProjectileCollision(node1: firstBody.node as! BaseNode, node2: secondBody.node as! BaseNode)
        }
        
        // Player plane and american enemy plane collision
        if (((firstBody.categoryBitMask == physicsCategory.americanEnemyPlane) && (secondBody.categoryBitMask == physicsCategory.player)) ||
            ((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.americanEnemyPlane))) {
            enemyPlayerCollision(enemyTemp: firstBody.node as! BaseNode, playerTemp: secondBody.node as! BaseNode)
        }
        
        // Player plane and german enemy plane collision
        if (((firstBody.categoryBitMask == physicsCategory.germanEnemyPlane) && (secondBody.categoryBitMask == physicsCategory.player)) ||
            ((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.germanEnemyPlane))) {
            enemyPlayerCollision(enemyTemp: firstBody.node as! BaseNode, playerTemp: secondBody.node as! BaseNode)
        }
        
        // Player plane and enemy projectile collision
        if (((firstBody.categoryBitMask == physicsCategory.player) && (secondBody.categoryBitMask == physicsCategory.enemyProjectile)) ||
            ((firstBody.categoryBitMask == physicsCategory.enemyProjectile) && (secondBody.categoryBitMask == physicsCategory.player))) {
            enemyProjectilePlayerCollision(enemyTemp: firstBody.node as! BaseNode, playerTemp: secondBody.node as! BaseNode)
        }
        
        // Player projectile and enemy projectile collision
        if (((firstBody.categoryBitMask == physicsCategory.playerProjectile) && (secondBody.categoryBitMask == physicsCategory.enemyProjectile)) ||
            ((firstBody.categoryBitMask == physicsCategory.enemyProjectile) && (secondBody.categoryBitMask == physicsCategory.playerProjectile))) {
            enemyPlayerProjectileCollision(enemyProjectileTemp: firstBody.node as! BaseNode, playerProjectileTemp: secondBody.node as! BaseNode)
        }
    }
    
    fileprivate func multipleProjectileCollision(node1: BaseNode, node2: BaseNode) {
        hitBoth(node1: node1, node2: node2)
        if (bothWasDestroyed(node1: node1, node2: node2)) {
            spawnEnemyExplosion(enemyTemp: node1)
            score += 5
            updateScore()
        } else {
            if node1 is BattleShipNode {
                handleBattleshipTextureChange(ship: node1 as! BattleShipNode)
            } else if node2 is BattleShipNode {
                handleBattleshipTextureChange(ship: node2 as! BattleShipNode)
            }
        }
    }
    
    fileprivate func singleProjectileCollision(enemyTemp: BaseNode, projectileTemp: BaseNode) {
        hitBoth(node1: enemyTemp, node2: projectileTemp)
        if (bothWasDestroyed(node1: enemyTemp, node2: projectileTemp)) {
            spawnEnemyExplosion(enemyTemp: enemyTemp)
            score += 1
            updateScore()
        }
    }
    
    fileprivate func enemyPlayerCollision(enemyTemp: BaseNode, playerTemp: BaseNode) {
        handlePlayerTextureChange()
        hitBoth(node1: playerTemp, node2: enemyTemp)
        if (playerTemp.wasDestroyed()) {
            spawnPlayerExplosion(playerTemp: playerTemp)
        }
        if (enemyTemp.wasDestroyed()) {
            spawnEnemyExplosion(enemyTemp: enemyTemp)
        }
        if (bothWasDestroyed(node1: playerTemp, node2: enemyTemp)) {
            gameOver()
        }
    }
    
    fileprivate func enemyProjectilePlayerCollision(enemyTemp: BaseNode, playerTemp: BaseNode) {
        handlePlayerTextureChange()
        hitBoth(node1: playerTemp, node2: enemyTemp)
        if (bothWasDestroyed(node1: playerTemp, node2: enemyTemp)) {
            spawnPlayerExplosion(playerTemp: playerTemp)
            gameOver()
        }
    }
    
    fileprivate func enemyPlayerProjectileCollision(enemyProjectileTemp: BaseNode, playerProjectileTemp: BaseNode) {
        hitBoth(node1: playerProjectileTemp, node2: enemyProjectileTemp)
        if (bothWasDestroyed(node1: enemyProjectileTemp, node2: playerProjectileTemp)) {
            spawnEnemyExplosion(enemyTemp: enemyProjectileTemp)
        }
    }
    
    fileprivate func hitBoth(node1: BaseNode, node2: BaseNode){
        node1.hit()
        node2.hit()
    }
    
    fileprivate func bothWasDestroyed(node1: BaseNode, node2: BaseNode) -> Bool {
        return node1.wasDestroyed() && node2.wasDestroyed()
    }
    
    fileprivate func setPlayerHitTexture() {
        self.player?.texture = playerHitTexture
    }
    
    fileprivate func setPlayerNormalTexture() {
        self.player?.texture = playerNormalTexture
    }
    
    fileprivate func handlePlayerTextureChange() {
        run(bulletImpactSoundAction)
        let hit = SKAction.run {
            self.setPlayerHitTexture()
        }
        let normal = SKAction.run {
            self.setPlayerNormalTexture()
        }
        let wait = SKAction.wait(forDuration: 0.3)
        let sequence = SKAction.sequence([hit, wait, normal])
        self.run(sequence)
    }
    
    fileprivate func setBattleshipHitTexture(ship: BattleShipNode) {
        ship.texture = battleshipHitTexture
    }
    
    fileprivate func setBattleshipNormalTexture(ship: BattleShipNode) {
        ship.texture = battleshipNormalTexture
    }
    
    fileprivate func handleBattleshipTextureChange(ship: BattleShipNode) {
        run(bulletImpactSoundAction)
        let hit = SKAction.run {
            self.setBattleshipHitTexture(ship: ship)
        }
        let normal = SKAction.run {
            self.setBattleshipNormalTexture(ship: ship)
        }
        let wait = SKAction.wait(forDuration: 0.3)
        let sequence = SKAction.sequence([hit, wait, normal])
        self.run(sequence)
    }
    
    fileprivate func waitThenMoveToTitleScreen() {
        let wait = SKAction.wait(forDuration: 3.0)
        let transition = SKAction.run{
            self.view?.presentScene(TitleScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        }
        let sequence = SKAction.sequence([wait, transition])
        self.run(SKAction.repeat(sequence, count: 1))
    }
    
    fileprivate func gameOver() {
        mainLabel?.fontSize = 50
        mainLabel?.alpha = 1.0
        mainLabel?.text = "Game Over"
        playerIsAlive = false
        player?.removeFromParent()
        self.removeAction(forKey: "projectileAction")
        waitThenMoveToTitleScreen()
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
    
    fileprivate func runEnemyAction(enemyTemp: BaseNode) {
        let yPos = CGFloat(-1 * screenHeightFromMid)
        let moveForward = SKAction.moveTo(y: yPos, duration: enemySpeed)
        let fire = SKAction.run {
            self.fireEnemyProjectile(enemyTemp: enemyTemp, repeatCount: 1)
        }
        let group = SKAction.group([moveForward, fire])
        let destroy = SKAction.removeFromParent()
        enemyTemp.run(SKAction.sequence([group, destroy]))
    }
    
    fileprivate func spawnEnemyProjectile(enemyTemp: BaseNode) {
        let position = CGPoint(x: enemyTemp.position.x, y: enemyTemp.position.y)
        let enemyProjectile = EnemyProjectileNode(imageNamed: "missile", initialPosition: position)
        
        let moveForward = SKAction.moveTo(y: -1000, duration: enemyProjectileSpeed)
        let playSound = SKAction.run { self.run(self.missileSoundAction) }
        let group = SKAction.group([moveForward, playSound])
        let destroy = SKAction.removeFromParent()
        
        enemyProjectile.run(SKAction.sequence([group, destroy]))
        self.addChild(enemyProjectile)
    }
    
    fileprivate func spawnEnemyBattleShipProjectile(enemyTemp: BaseNode) {
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
    
    fileprivate func spawnEnemyExplosion(enemyTemp: BaseNode){
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
    
    fileprivate func spawnPlayerExplosion(playerTemp: BaseNode){
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
    
    fileprivate func fireEnemyProjectile(enemyTemp: BaseNode, repeatCount: Int) {
        let fireProjectileTimer = SKAction.wait(forDuration: 0.5)
        let spawn = SKAction.run {
            self.spawnEnemyProjectile(enemyTemp: enemyTemp)
        }
        let sequence = SKAction.sequence([fireProjectileTimer, spawn])
        enemyTemp.run(SKAction.repeat(sequence, count: repeatCount))
    }
    
    fileprivate func fireEnemyBattleShipProjectile(enemyTemp: BaseNode, repeatCount: Int) {
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
        fireProjectileSoundAction = SKAction.playSoundFileNamed(SoundFile.FireProjectile, waitForCompletion: false)
        explodeSoundAction = SKAction.playSoundFileNamed(SoundFile.Explode, waitForCompletion: false)
        rocketSoundAction = SKAction.playSoundFileNamed(SoundFile.Rocket, waitForCompletion: false)
        missileSoundAction = SKAction.playSoundFileNamed(SoundFile.Missile, waitForCompletion: false)
        bulletImpactSoundAction = SKAction.playSoundFileNamed(SoundFile.BulletImpact, waitForCompletion: false)
    }
}
