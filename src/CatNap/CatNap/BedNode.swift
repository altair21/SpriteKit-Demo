//
//  BedNode.swift
//  CatNap
//
//  Created by altair21 on 16/4/23.
//  Copyright © 2016年 altair21. All rights reserved.
//

import SpriteKit

class BedNode: SKSpriteNode, CustomNodeEvents {
    func didMoveToScene() {
        print("bed added to scene")
        
        let bedBodySize = CGSize(width: 40.0, height: 30.0)
        self.physicsBody = SKPhysicsBody(rectangleOfSize: bedBodySize)
        self.physicsBody!.dynamic = false
        self.physicsBody!.categoryBitMask = PhysicsCategory.Bed
        self.physicsBody!.collisionBitMask = PhysicsCategory.None
    }
}