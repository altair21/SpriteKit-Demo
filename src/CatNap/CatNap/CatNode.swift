//
//  CatNode.swift
//  CatNap
//
//  Created by altair21 on 16/4/24.
//  Copyright © 2016年 altair21. All rights reserved.
//

import SpriteKit

class CatNode: SKSpriteNode, CustomNodeEvents {
    func didMoveToScene() {
        print("cat added to scene")
        
        let catBodyTexture = SKTexture(imageNamed: "cat_body_outline")
        self.parent!.physicsBody = SKPhysicsBody(texture: catBodyTexture, size: catBodyTexture.size())
        self.parent!.physicsBody!.categoryBitMask = PhysicsCategory.Cat
        self.parent!.physicsBody!.collisionBitMask = PhysicsCategory.Block | PhysicsCategory.Edge
        self.parent!.physicsBody!.contactTestBitMask = PhysicsCategory.Bed | PhysicsCategory.Edge
    }
    
    func wakeUp() {
        for child in self.children {
            child.removeFromParent()
        }
        self.texture = nil
        self.color = SKColor.clearColor()
        
        let catAwake = SKSpriteNode(fileNamed: "CatWakeUp")!.childNodeWithName("cat_awake")!
        
        catAwake.moveToParent(self)
        catAwake.position = CGPoint(x: -30, y: 100)
    }
    
    func curlAt(scenePoint: CGPoint) {
        self.parent!.physicsBody = nil
        for child in self.children {
            child.removeFromParent()
        }
        self.texture = nil
        self.color = SKColor.clearColor()
        
        let catCurl = SKSpriteNode(fileNamed: "CatCurl")!.childNodeWithName("cat_curl")!
        catCurl.moveToParent(self)
        catCurl.position = CGPoint(x: -30, y: 100)
        
        var localPoint = self.parent!.convertPoint(scenePoint, toNode: scene!)
        localPoint.y += self.frame.size.height / 3
        
        self.runAction(SKAction.group([
            SKAction.moveTo(localPoint, duration: 0.66),
            SKAction.rotateToAngle(0, duration: 0.5)
            ]))
    }
}