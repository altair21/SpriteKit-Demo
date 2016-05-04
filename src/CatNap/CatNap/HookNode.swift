//
//  HookNode.swift
//  CatNap
//
//  Created by altair21 on 16/5/4.
//  Copyright © 2016年 altair21. All rights reserved.
//

import SpriteKit

class HookNode: SKSpriteNode, CustomNodeEvents {
    private var hookNode = SKSpriteNode(imageNamed: "hook")
    private var ropeNode = SKSpriteNode(imageNamed: "rope")
    private var hookJoint: SKPhysicsJointFixed!
    
    var isHooked: Bool {
        return hookJoint != nil
    }
    
    func didMoveToScene() {
        guard let scene = self.scene else {
            return
        }
        
        let ceilingFix = SKPhysicsJointFixed.jointWithBodyA(scene.physicsBody!, bodyB: self.physicsBody!, anchor: CGPoint.zero)
        scene.physicsWorld.addJoint(ceilingFix)
        
        ropeNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        ropeNode.zRotation = CGFloat(270).degreesToRadians()
        ropeNode.position = self.position
        scene.addChild(ropeNode)
        
        hookNode.position = CGPoint(x: self.position.x, y: self.position.y - ropeNode.size.width)
        hookNode.physicsBody = SKPhysicsBody(circleOfRadius: hookNode.size.width / 2)
        hookNode.physicsBody!.categoryBitMask = PhysicsCategory.Hook
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.Cat
        hookNode.physicsBody!.collisionBitMask = PhysicsCategory.None
        scene.addChild(hookNode)
        
        let hookPosition = CGPoint(x: hookNode.position.x, y: hookNode.position.y + hookNode.size.height / 2)
        let repoJoint = SKPhysicsJointSpring.jointWithBodyA(self.physicsBody!, bodyB: hookNode.physicsBody!, anchorA: self.position, anchorB: hookPosition)
        scene.physicsWorld.addJoint(repoJoint)
        
        let range = SKRange(lowerLimit: 0.0, upperLimit: 0.0)
        let orientConstraint = SKConstraint.orientToNode(hookNode, offset: range)
        ropeNode.constraints = [orientConstraint]
        
        hookNode.physicsBody!.applyImpulse(CGVector(dx: 50, dy: 0))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HookNode.catTapped), name: kCatTappedNotification, object: nil)
    }
    
    func catTapped() {
        if isHooked {
            releaseCat()
        }
    }
    
    func hookCat(catNode: SKNode) {
        catNode.parent!.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        catNode.parent!.physicsBody!.angularVelocity = 0
        
        let pinPoint = CGPoint(x: hookNode.position.x,
                               y: hookNode.position.y + hookNode.size.height / 2)
        hookJoint = SKPhysicsJointFixed.jointWithBodyA(hookNode.physicsBody!, bodyB: catNode.parent!.physicsBody!, anchor: pinPoint)
        self.scene!.physicsWorld.addJoint(hookJoint)
        
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.None
    }
    
    func releaseCat() {
        hookNode.physicsBody!.categoryBitMask = PhysicsCategory.None
        hookNode.physicsBody!.contactTestBitMask = PhysicsCategory.None
        hookJoint.bodyA.node!.zRotation = 0
        hookJoint.bodyB.node!.zRotation = 0
        self.scene!.physicsWorld.removeJoint(hookJoint)
        hookJoint = nil
    }
    
}
