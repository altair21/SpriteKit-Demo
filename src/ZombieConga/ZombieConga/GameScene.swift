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
    let catMovePointsPerSec: CGFloat = 480.0
    let zombieRotateRadiansPerSec: CGFloat = 4.0 * π
    var velocity = CGPoint.zero
    var lastTouchLocation: CGPoint?
    let zombieAnimation: SKAction
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed("hitCatLady.wav", waitForCompletion: false)
    var zombieInvincible = false
    var lives = 5
    var gameOver = false
    let cameraNode = SKCameraNode()
    let cameraMovePotionPerSec: CGFloat = 200.0
    var cameraRect : CGRect {
        return CGRect(
            x: getCameraPosition().x - size.width/2
                + (size.width - playableRect.width)/2,
            y: getCameraPosition().y - size.height/2
                + (size.height - playableRect.height)/2,
            width: playableRect.width,
            height: playableRect.height)
    }
    
    let playableRect: CGRect
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2.0
        playableRect = CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        
        var textures: [SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)"))
        }
        textures.append(textures[2])
        textures.append(textures[1])
        zombieAnimation = SKAction.animateWithTextures(textures, timePerFrame: 0.1)
        
        super.init(size: size)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        playBackgroundMusic("backgroundMusic.mp3")
        self.backgroundColor = SKColor.blackColor()
//        let background = SKSpriteNode(imageNamed: "background1")
//        background.zPosition = -1
//        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
//        self.addChild(background)
//        let mySize = background.size
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position = CGPoint(x: CGFloat(i) * background.size.width, y: 0)
            background.name = "background"
            self.addChild(background)
        }
        
        zombie.position = CGPoint(x: 400, y: 400)
        zombie.zPosition = 100
        self.addChild(zombie)
//        zombie.runAction(SKAction.repeatActionForever(zombieAnimation))
        
//        debugDrawPlayableArea()
        
        self.runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnEnemy),
                SKAction.waitForDuration(2.0)])))
        self.runAction(SKAction.repeatActionForever(
            SKAction.sequence([SKAction.runBlock(spawnCat),
                SKAction.waitForDuration(1.0)])))
        
        self.addChild(cameraNode)
        self.camera = cameraNode
//        cameraNode.position = zombie.position
        setCameraPosition(CGPoint(x: self.size.width/2, y: self.size.height/2))
    }
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
        
//        if let lastTouchLocation = lastTouchLocation {
//            let offset = lastTouchLocation - zombie.position
//            if offset.length() <= zombieMovePointsPerSec * CGFloat(dt) {
//                zombie.position = lastTouchLocation
//                velocity = CGPoint.zero
//                stopZombieAnimation()
//            } else {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity, rotatePerSec: zombieRotateRadiansPerSec)
//            }
//        }
        
        boundsCheckZombie()
//        checkCollisions()
        moveTrain()
        moveCamera()
        
        if lives <= 0 && !gameOver {
            gameOver = true
            print("You Lose")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: self.size, won: false)
            gameOverScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    override func didEvaluateActions() {
        checkCollisions()
    }
    
    func startZombieAnimation() {
        if zombie.actionForKey("animation") == nil {
            zombie.runAction(SKAction.repeatActionForever(zombieAnimation), withKey: "animation")
        }
    }
    
    func stopZombieAnimation() {
        zombie.removeActionForKey("animation")
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
        startZombieAnimation()
        let offset = location - zombie.position
        velocity = offset.normalized() * zombieMovePointsPerSec
    }
    
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, rotatePerSec: CGFloat) {
        let shortest = shortestAngleBetween(sprite.zRotation, angle2: direction.angle)
        let amtToRotate = min(zombieRotateRadiansPerSec * CGFloat(dt), abs(shortest))
        sprite.zRotation += shortest.sign() * amtToRotate
    }
    
    func boundsCheckZombie() {
//        let bottomLeft = CGPoint(x: 0, y: CGRectGetMinY(playableRect))
//        let topRight = CGPoint(x: self.size.width, y: CGRectGetMaxY(playableRect))
        let bottomLeft = CGPoint(x: CGRectGetMinX(cameraRect), y: CGRectGetMinY(cameraRect))
        let topRight = CGPoint(x: CGRectGetMaxX(cameraRect), y: CGRectGetMaxY(cameraRect))
        
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
        enemy.name = "enemy"
        enemy.position = CGPoint(x: self.size.width + enemy.size.width / 2, y: CGFloat.random(min: CGRectGetMinY(playableRect) + enemy.size.height / 2, max: CGRectGetMaxY(playableRect) - enemy.size.height / 2))
        addChild(enemy)
        
        let actionMove = SKAction.moveToX(-enemy.size.width / 2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
        
        
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
    
    func spawnCat() {
        let cat = SKSpriteNode(imageNamed: "cat")
        cat.name = "cat"
//        cat.position = CGPoint(x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)), y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect)))
        cat.position = CGPoint(x: CGFloat.random(min: CGRectGetMinX(cameraRect), max: CGRectGetMaxX(cameraRect)), y: CGFloat.random(min: CGRectGetMinY(cameraRect), max: CGRectGetMaxY(cameraRect)))
        cat.zPosition = 50
        cat.setScale(0)
        addChild(cat)
        
        let appear = SKAction.scaleTo(1.0, duration: 0.5)
        cat.zRotation = -π / 16.0
        let leftWiggle = SKAction.rotateByAngle(π / 8.0, duration: 0.5)
        let rightWiggle = leftWiggle.reversedAction()
        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
        let scaleDown = scaleUp.reversedAction()
        let fullScale = SKAction.sequence([scaleUp, scaleDown, scaleUp, scaleDown])
        let group = SKAction.group([fullWiggle, fullScale])
        let groupWait = SKAction.repeatAction(group, count: 10)
        let disappear = SKAction.scaleTo(0, duration: 0.5)
        let removeFromParent = SKAction.removeFromParent()
        let actions = [appear, groupWait, disappear, removeFromParent]
        cat.runAction(SKAction.sequence(actions))
    }
    
    func zombieHitCat(cat: SKSpriteNode) {
//        cat.removeFromParent()
        cat.name = "train"
        cat.removeAllActions()
        cat.setScale(1.0)
        cat.zRotation = 0.0
        let colorizeAction = SKAction.colorizeWithColor(SKColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2)
        let sequence = SKAction.sequence([catCollisionSound, colorizeAction])
        cat.runAction(sequence)
    }
    
    func zombieHitEnemy(enemy: SKSpriteNode) {
//        enemy.removeFromParent()
        zombieInvincible = true
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) { (node, elapsedTime) in
            let slice = duration / blinkTimes
            let remainder = Double(elapsedTime) % slice
            node.hidden = remainder > slice / 2
        }
        let resetZombie = SKAction.runBlock { 
            self.zombie.hidden = false
            self.zombieInvincible = false
        }
        let sequence = SKAction.sequence([enemyCollisionSound, blinkAction, resetZombie])
        zombie.runAction(sequence)
        loseCats()
        lives -= 1
    }
    
    func checkCollisions() {
        var hitCats: [SKSpriteNode] = []
        enumerateChildNodesWithName("cat") { (node, _) in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame) {
                hitCats.append(cat)
            }
        }
        for cat in hitCats {
            zombieHitCat(cat)
        }
        
        if zombieInvincible == true {
            return
        }
        var hitEnemies: [SKSpriteNode] = []
        enumerateChildNodesWithName("enemy") { (node, _) in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(CGRectInset(node.frame, 20, 20), self.zombie.frame) {
                hitEnemies.append(enemy)
            }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy)
        }
    }
    
    func moveTrain() {
        var targetPosition = zombie.position
        var trainCount = 0
        
        enumerateChildNodesWithName("train") { (node, _) in
            trainCount += 1
            if !node.hasActions() {
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized()
                let amountToMovePerSec = direction * self.catMovePointsPerSec
                let amountToMove = amountToMovePerSec * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                node.runAction(moveAction)
            }
            targetPosition = node.position
        }
        
        if trainCount >= 15 && !gameOver {
            gameOver = true
            print("You win")
            backgroundMusicPlayer.stop()
            
            let gameOverScene = GameOverScene(size: self.size, won: true)
            gameOverScene.scaleMode = self.scaleMode
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
    func loseCats() {
        var loseCount = 0
        enumerateChildNodesWithName("train") { (node, stop) in
            var randomSpot = node.position
            randomSpot.x += CGFloat.random(min: -100, max: 100)
            randomSpot.y += CGFloat.random(min: -100, max: 100)
            
            node.name = ""
            node.runAction(SKAction.sequence([
                SKAction.group([
                    SKAction.rotateByAngle(π * 4.0, duration: 1.0),
                    SKAction.moveTo(randomSpot, duration: 1.0),
                    SKAction.scaleTo(0, duration: 1.0)]),
                SKAction.removeFromParent()]))
            
            loseCount += 1
            if loseCount >= 2 {
                stop.memory = true
            }
        }
    }
    
    func overlapAmount() -> CGFloat {
        guard let view = self.view else {
            return 0
        }
        let scale = view.bounds.size.width / self.size.width
        let scaledHeight = self.size.height * scale
        let scaledOverlap = scaledHeight - view.bounds.size.height
        return scaledOverlap / scale
    }
    
    func getCameraPosition() -> CGPoint {
        return CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + overlapAmount() / 2)
    }
    
    func setCameraPosition(position: CGPoint) {
        cameraNode.position = CGPoint(x: position.x, y: position.y - overlapAmount() / 2)
    }
    
    func backgroundNode() -> SKSpriteNode {
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPoint.zero
        backgroundNode.name = "background"
        
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPoint.zero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPoint.zero
        background2.position = CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        
        backgroundNode.size = CGSize(width: background1.size.width + background2.size.width,
                                     height: background1.size.height)
        return backgroundNode
    }
    
    func moveCamera() {
        let backgroundVelocity = CGPoint(x: cameraMovePotionPerSec, y: 0)
        let amountToMove = backgroundVelocity * CGFloat(dt)
        cameraNode.position += amountToMove
        
        enumerateChildNodesWithName("background") { (node, _) in
            let background = node as! SKSpriteNode
            if background.position.x + background.size.width < self.cameraRect.origin.x {
                background.position = CGPoint(x: background.position.x + background.size.width * 2, y: background.position.y)
            }
        }
    }
    
}
