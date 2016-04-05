//
//  GameScene.swift
//  ZombieConga
//
//  Created by altair21 on 16/4/5.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.zPosition = -1
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(background)
        let mySize = background.size
        print("Size: \(mySize)")
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.setScale(2.0)
        self.addChild(zombie)
        
    }
    
}
