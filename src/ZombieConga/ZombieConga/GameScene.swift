//
//  GameScene.swift
//  ZombieConga
//
//  Created by altair21 on 16/4/5.
//  Copyright (c) 2016 altair21. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    var velocity = CGPoint.zero
    var lastTouchLocation: CGPoint?
    
    let playableRect: CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        self.backgroundColor = SKColor.blackColor()
        let background = SKSpriteNode(imageNamed: "background1")
        background.zPosition = -1
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        self.addChild(background)
        let mySize = background.size
        
        zombie.position = CGPoint(x: 400, y: 400)
        self.addChild(zombie)
        
//        debugDrawPlayableArea()
        
        self.runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),
                SKAction.waitForDuration(2.0)])))
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
        if let lastTouchLocation = lastTouchLocation {
            let offset = lastTouchLocation - zombie.position
            if offset.length() <= zombieMovePointsPerSec * CGFloat(dt) {
                zombie.position = lastTouchLocation
                velocity = CGPoint.zero
            } else {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotatePerSec: zombieRotateRadiansPerSec)
            }
        }
        
        boundsCheckZombie()
    }
    
    func debugDrawPlayableArea() {
        let shape = SKShapeNode()
        let path = CGPathCreateMutable()
        CGPathAddRect(path, nil, playableRect)
        shape.path = path
        shape.strokeColor = SKColor.redColor()
        shape.lineWidth = 4.0
        self.addChild(shape)
    }
    
    func sceneTouched(touchLocation: CGPoint) {
        lastTouchLocation = touchLocation
        moveZombieToward(touchLocation)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.locationInNode(self)
        sceneTouched(touchLocation)
    }
    
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
        sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
        let offset = location - zombie.position
        velocity = offset.normalized() * zombieMovePointsPerSec
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotatePerSec: CGFloat) {
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: direction.angle)
        let amtToRotate = min(zombieRotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amtToRotate
    }
    
    func boundsCheckZombie() {
        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
        let topRight = CGPoint(x: self.size.width, y: CGRectGetMaxY(playableRect))
        
        if zombie.position.x <= bottomLeft.x {
            zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
        }
        if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x
        }
        if zombie.position.y <= bottomLeft.y {
            zombie.position.y = bottomLeft.y
            velocity.y = -velocity.y
        }
        if zombie.position.y >= topRight.y {
            zombie.position.y = topRight.y
            velocity.y = -velocity.y
        }
    }
    
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = CGPoint(x: self.size.width + enemy.size.width / 2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height / 2, max: CGRectGetMaxY(playableRect) - enemy.size.height / 2))
        addChild(enemy)
        
        let actionMove = SKAction.moveToX(-enemy.size.width / 2, duration: 2.0)
        enemy.runAction(actionMove)
        
        
//        let enemy = SKSpriteNode(imageNamed: "enemy")
//        enemy.position = CGPoint(x: self.size.width + enemy.size.width / 2,
//                                 y: self.size.height / 2)
//        addChild(enemy)
//        
//        let actionMidMove = SKAction.moveByX(-self.size.width / 2 - enemy.size.width / 2, y: -CGRectGetHeight(playableRect) / 2 + enemy.size.height / 2, duration: 1.0)
//        let actionMove = SKAction.moveByX(-self.size.width / 2 - enemy.size.width / 2, y: CGRectGetHeight(playableRect) / 2 - enemy.size.height / 2, duration: 1.0)
//        let wait = SKAction.waitForDuration(0.25)
//        let logMessage = SKAction.runBlock { 
//            print("Reach bottom!")
//        }
////        let reverseMid = actionMidMove.reversedAction()
////        let reverseMove = actionMove.reversedAction()
////        let sequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove, reverseMove, logMessage, wait, reverseMid])
////        enemy.runAction(sequence)
//        let halfSequence = SKAction.sequence([actionMidMove, logMessage, wait, actionMove])
//        let sequence = SKAction.sequence([halfSequence, halfSequence.reversedAction()])
//        let repeatAction = SKAction.repeatActionForever(sequence)
//        enemy.runAction(repeatAction)
    }
}
