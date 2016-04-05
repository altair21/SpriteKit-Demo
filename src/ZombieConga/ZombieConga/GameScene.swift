//
//  GameScene.swift
//  ZombieConga
//
//  Created by altair21 on 16/4/5.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.zPosition = -1
        self.addChild(background)
        let mySize = background.size
        print("Size: \(mySize)")
        
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    }
    
}
