//
//  TitleScene.swift
//  ToraTora
//
//  Created by Marlon Peter Cardenas on 18/12/18.
//  Copyright © 2018 Marlon Peter Cardenas. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation

class TitleScene: SKScene {
    
    private var btnPlay : UIButton!
    private var textColorHUD = UIColor(displayP3Red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    private static var backgroundMusicPlayer: AVAudioPlayer!
    
    override func didMove(to view: SKView) {
        self.backgroundColor = UIColor.black
        
        let backgroundImage = SKSpriteNode(imageNamed: "tora_tora_splash_screen")
        backgroundImage.scale(to: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        backgroundImage.position = CGPoint(x: self.frame.midX, y: self.frame.midY)

        self.addChild(backgroundImage)
        
        setUpPlayButton()
        
        if TitleScene.backgroundMusicPlayer == nil {
            let backgroundMusicURL = Bundle.main.url(forResource: SoundFile.BackgroundMusic, withExtension: nil)
            
            do {
                let theme = try AVAudioPlayer(contentsOf: backgroundMusicURL!)
                TitleScene.backgroundMusicPlayer = theme
            } catch {
                // Could not load background music file
            }
            TitleScene.backgroundMusicPlayer.numberOfLoops = -1
        }
        
        if !TitleScene.backgroundMusicPlayer.isPlaying {
            TitleScene.backgroundMusicPlayer.play()
        }
    }
    
    func setUpPlayButton() {
        btnPlay = UIButton(frame: CGRect(x: 100, y: 100, width: 256, height: 80))
        btnPlay.center = CGPoint(x: view!.frame.size.width / 2, y: view!.frame.size.height / 2)
        btnPlay.setBackgroundImage(UIImage(named: "play_button_normal"), for: .normal)
        btnPlay.setBackgroundImage(UIImage(named: "play_button_pressed"), for: .highlighted)
        btnPlay.addTarget(self, action: #selector(playTheGame), for: UIControl.Event.touchUpInside)
        self.view?.addSubview(btnPlay)
    }
    
    @objc func playTheGame() {
        self.view?.presentScene(GameScene(), transition: SKTransition.crossFade(withDuration: 1.0))
        btnPlay.removeFromSuperview()
        
        if let scene = GameScene(fileNamed: "GameScene") {
            let skView = self.view! as SKView
            skView.ignoresSiblingOrder = true
            scene.scaleMode = .aspectFill
            skView.presentScene(scene)
        }
        
    }
}
