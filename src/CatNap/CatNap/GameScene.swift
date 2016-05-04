//
//  GameScene.swift
//  CatNap
//
//  Created by altair21 on 16/4/19.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let Cat:   UInt32 = 0b1 //1
    static let Block: UInt32 = 0b10  //2
    static let Bed:   UInt32 = 0b100 //4
    static let Edge:  UInt32 = 0b1000 //8
    static let Label: UInt32 = 0b10000 //16
    static let Spring:UInt32 = 0b100000 //32
    static let Hook:  UInt32 = 0b1000000 //64
}

protocol CustomNodeEvents {
    func didMoveToScene()
}

protocol InteractiveNode {
    func interact()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var bedNode: BedNode!
    var catNode: CatNode!
    var playable = true
    var currentLevel: Int = 0
    
    class func level(levelNum: Int) -> GameScene? {
        let scene = GameScene(fileNamed: "Level\(levelNum)")!
        scene.currentLevel = levelNum
        scene.scaleMode = .AspectFill
        return scene
    }
    
    override func didMoveToView(view: SKView) {
        //Calculate playable margin
        let maxAspectRatio: CGFloat = 16.0 / 9.0    //iphone5
        let maxAspectRatioHeight = self.size.width / maxAspectRatio
        let playableMargin: CGFloat = (self.size.height - maxAspectRatioHeight) / 2
        let playableRect = CGRect(x: 0, y: playableMargin, width: self.size.width, height: self.size.height - 2 * playableMargin)
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: playableRect)
        self.physicsWorld.contactDelegate = self
        self.physicsBody!.categoryBitMask = PhysicsCategory.Edge
        
        self.enumerateChildNodesWithName("//*") { (node, _) in
            if let customNode = node as? CustomNodeEvents {
                customNode.didMoveToScene()
            }
        }
        
        bedNode = self.childNodeWithName("bed") as! BedNode
        catNode = self.childNodeWithName("//cat_body") as! CatNode
//        bedNode.setScale(1.5)
//        catNode.setScale(1.5)
        
        SKTAudio.sharedInstance().playBackgroundMusic("backgroundMusic.mp3")
        
//        let rotationConstraint = SKConstraint.zRotation(SKRange(lowerLimit: -π / 4, upperLimit: π / 4))
//        catNode.parent!.constraints = [rotationConstraint]
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    override func didSimulatePhysics() {
        if playable {
            if fabs(catNode.parent!.zRotation) > CGFloat(25).degreesToRadians() {
                lose()
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if collision == PhysicsCategory.Label | PhysicsCategory.Edge {
            let labelNode = (contact.bodyA.categoryBitMask == PhysicsCategory.Label) ? contact.bodyA.node : contact.bodyB.node
            (labelNode as! MessageNode).didBounce()
        }
        
        if !playable {
            return
        }
        
        
        if collision == PhysicsCategory.Cat | PhysicsCategory.Bed {
            print("Success")
            win()
        } else if collision == PhysicsCategory.Cat | PhysicsCategory.Edge {
            print("Fail")
            lose()
        }
    }
    
    func inGameMessage(text: String) {
        let message = MessageNode(message: text)
        message.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        self.addChild(message)
    }
    
    func newGame() {
        self.view!.presentScene(GameScene.level(currentLevel))
    }
    
    func lose() {
        playable = false
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        self.runAction(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        
        inGameMessage("Try again...")
        
        self.performSelector("newGame", withObject: nil, afterDelay: 5)
        
        catNode.wakeUp()
    }
    
    func win() {
        playable = false
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        self.runAction(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        
        inGameMessage("Nice job!")
        
        self.performSelector("newGame", withObject: nil, afterDelay: 3)
        catNode.curlAt(bedNode.position)
    }
}
