//
//  SpringNode.swift
//  CatNap
//
//  Created by altair21 on 16/5/4.
//  Copyright © 2016年 altair21. All rights reserved.
//

import SpriteKit

class SpringNode: SKSpriteNode, CustomNodeEvents, InteractiveNode {
    func didMoveToScene() {
        self.userInteractionEnabled = true
    }
    
    func interact() {
        self.userInteractionEnabled = false
        
        self.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 250), atPoint: CGPoint(x: self.size.width / 2, y: self.size.height))
        self.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.0),
            SKAction.removeFromParent()
            ]))
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        interact()
    }
}
