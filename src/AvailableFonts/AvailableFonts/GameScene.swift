//
//  GameScene.swift
//  AvailableFonts
//
//  Created by altair21 on 16/4/14.
//  Copyright (c) 2016年 altair21. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var familyIdx: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        showCurrentFamily()
    }
    
    func showCurrentFamily() {
        self.removeAllChildren()
        
        let familyName = UIFont.familyNames()[familyIdx]
        print("Family: \(familyName)")
        
        let fontNames = UIFont.fontNamesForFamilyName(familyName)
        
        for (idx, fontName) in fontNames.enumerate() {
            let label = SKLabelNode(fontNamed: fontName)
            label.text = fontName
            label.position = CGPoint(x: self.size.width / 2, y: self.size.height * CGFloat(idx + 1) / (CGFloat(fontNames.count) + 1))
            label.fontSize = 50
            label.verticalAlignmentMode = .Center
            self.addChild(label)
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        familyIdx += 1
        if familyIdx >= UIFont.familyNames().count {
            familyIdx = 0
        }
        showCurrentFamily()
    }
}
