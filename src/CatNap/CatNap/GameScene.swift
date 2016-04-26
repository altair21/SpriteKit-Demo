//
//  GameScene.swift
//  CatNap
//
//  Created by altair21 on 16/4/19.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Cat:  UInt32 = 0b1 //1
    static let Block:UInt32 = 0b10  //2
    static let Bed:  UInt32 = 0b100 //4
    static let Edge: UInt32 = 0b1000 //8
    static let Label:UInt32 = 0b10000 //16
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
    var playble = true
    
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
    
    func didBeginContact(contact: SKPhysicsContact) {
        if !playble {
            return
        }
        
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
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
        let scene = GameScene(fileNamed: "GameScene")
        scene!.scaleMode = self.scaleMode
        self.view!.presentScene(scene)
    }
    
    func lose() {
        playble = false
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        self.runAction(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        
        inGameMessage("Try again...")
        
        self.performSelector("newGame", withObject: nil, afterDelay: 5)
        
        catNode.wakeUp()
    }
    
    func win() {
        playble = false
        
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        self.runAction(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        
        inGameMessage("Nice job!")
        
        self.performSelector("newGame", withObject: nil, afterDelay: 3)
        catNode.curlAt(bedNode.position)
    }
}
