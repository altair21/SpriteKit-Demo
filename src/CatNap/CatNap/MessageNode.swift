//
//  MessageNode.swift
//  CatNap
//
//  Created by altair21 on 16/4/25.
//  Copyright © 2016年 altair21. All rights reserved.
//

import SpriteKit

class MessageNode: SKLabelNode {
    convenience init(message: String) {
        self.init(fontNamed: "AvenirNext-Regular")
        
        self.text = message
        self.fontSize = 256.0
        self.fontColor = SKColor.grayColor()
        self.zPosition = 100
        
        let front = SKLabelNode(fontNamed: "AvenirNext-Regular")
        front.text = message
        front.fontSize = 256.0
        front.fontColor = SKColor.whiteColor()
        front.position = CGPoint(x: -2, y: -2)
        self.addChild(front)
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 10.0)
        self.physicsBody!.categoryBitMask = PhysicsCategory.Label
        self.physicsBody!.collisionBitMask = PhysicsCategory.Edge
        self.physicsBody!.restitution = 0.7
    }
}