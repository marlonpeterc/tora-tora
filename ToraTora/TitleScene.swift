//
//  TitleScene.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 18/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import Foundation
import SpriteKit

class TitleScene: SKScene {
    
    private var btnPlay : UIButton!
    private var gameTitle : UILabel!
    private var textColorHUD = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.black
        
        let backgroundImage = SKSpriteNode(imageNamed: "toratoracover")
        backgroundImage.scale(to: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        backgroundImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        self.addChild(backgroundImage)
        
        setUpText()
    }
    
    func setUpText() {
        btnPlay = UIButton(frame: CGRect(x: 100, y: 100, width: 400, height: 100))
        btnPlay.center = CGPoint(x: view!.frame.size.width / 2, y: view!.frame.size.height / 2)
        btnPlay.titleLabel?.font = UIFont(name: "Futura", size: 60)
        btnPlay.setTitle("Play!", for: UIControl.State.normal)
        btnPlay.setTitleColor(textColorHUD, for: UIControl.State.normal)
        btnPlay.addTarget(self, action: #selector(playTheGame), for: UIControl.Event.touchUpInside)
        self.view?.addSubview(btnPlay)
        
        gameTitle = UILabel(frame: CGRect(x: 0, y: 0, width: view!.frame.width, height: 300))
        gameTitle!.textColor = textColorHUD
        gameTitle!.font = UIFont(name: "Futura", size: 40)
        gameTitle!.textAlignment = NSTextAlignment.center
        gameTitle!.text = "TORA! TORA!"
        self.view?.addSubview(gameTitle)
    }
    
    @objc func playTheGame() {
        self.view?.presentScene(GameScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        btnPlay.removeFromSuperview()
        gameTitle.removeFromSuperview()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
        
    }
}
