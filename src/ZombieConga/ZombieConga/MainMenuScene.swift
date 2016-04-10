//
//  MainMenuScene.swift
//  ZombieConga
//
//  Created by altair21 on 16/4/10.
//  Copyright © 2016年 altair21. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    override func didMoveToView(view: SKView) {
        let background = SKSpriteNode(imageNamed: "MainMenu")
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(background)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        sceneTapped()
    }
    
    func sceneTapped() {
        let scene = GameScene(size: self.size)
        scene.scaleMode = self.scaleMode
        let reveal = SKTransition.doorwayWithDuration(1.5)
        self.view?.presentScene(scene, transition: reveal)
    }
}