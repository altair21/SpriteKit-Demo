//
//  BlockNode.swift
//  CatNap
//
//  Created by altair21 on 16/4/25.
//  Copyright © 2016年 altair21. All rights reserved.
//

import SpriteKit

class BlockNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    func didMoveToScene() {
        self.userInteractionEnabled = true
    }
    
    func interact() {
        self.userInteractionEnabled = false
        
        self.runAction(SKAction.sequence([
            SKAction.playSoundFileNamed("pop.mp3", waitForCompletion: false),
            SKAction.scaleTo(0.8, duration: 0.1),
            SKAction.removeFromParent()
            ]))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        print("destroy block")
        interact()
    }
}