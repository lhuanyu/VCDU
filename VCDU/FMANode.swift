//
//  FMANode.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/7/23.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit
import SpriteKit


class FMANode: SKNode {
    
    //MARK: - Auto Flight Mode -
    var currentRollMode:RollMode = .ROLL {
        didSet {
            rollModeLabel.text = currentRollMode.rawValue
            if currentRollMode == .LNAV {
                armedRollModeLabel.removeAllActions()
                armedRollModeLabel.alpha = 1.0
            }
        }
    }
    var armedRollMode:RollMode = .OFF {
        didSet {
            armedRollModeLabel.text = armedRollMode.rawValue
        }
    }
    
    var currentPitchMode:PitchMode = .PITCH {
        didSet {
            pitchModeLabel.text = currentPitchMode.rawValue
        }
    }
    
    var armedPitchMode:PitchMode = .OFF {
        didSet {
            pitchModeLabel.text = currentPitchMode.rawValue
        }
    }
    
    //MARK: - Private UI Impelementation -
    
    private lazy var rollModeLabel:SKLabelNode = {
        let label = SKLabelNode(fontNamed: FontName.Arial)
        label.text = "ROLL"
        label.fontColor = SKColor.greenColor()
        label.fontSize = self.fontSize
        label.horizontalAlignmentMode = .Center
        label.verticalAlignmentMode =  .Top
        label.position = CGPointMake(-self.size.width/8, self.fontSize+3)
        return label
    }()
    
    private lazy var armedRollModeLabel:SKLabelNode = {
        let label = SKLabelNode(fontNamed: FontName.Arial)
        label.fontSize = self.fontSize-2
        label.horizontalAlignmentMode = .Center
        label.position = CGPointMake(-self.size.width/8, -self.fontSize)

        return label
    }()
    
    lazy var thrustModeLable:SKLabelNode = {
        let label = SKLabelNode(fontNamed: FontName.Arial)
        label.text = "SPD"
        label.fontColor = SKColor.greenColor()
        label.fontSize = self.fontSize
        label.horizontalAlignmentMode = .Left
        label.verticalAlignmentMode =  .Top
        label.position = CGPointMake(-self.size.width/2+5, self.fontSize+3)
        return label
    }()
    
    lazy var xfrLabel:SKShapeNode = {
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(2, 0))
        path.addLineToPoint(CGPointMake(self.fontSize/2, self.fontSize/4))
        path.addLineToPoint(CGPointMake(self.fontSize/2, -self.fontSize/4))
        path.closePath()
        path.moveToPoint(CGPointMake(self.fontSize/2, 0))
        path.addLineToPoint(CGPointMake(self.size.width/8-2, 0))
        let node = SKShapeNode(path: path.CGPath)
        node.fillColor = SKColor.whiteColor()
        return node
    }()
    
    lazy var apLabel:SKLabelNode = {
        let label = SKLabelNode(fontNamed: FontName.Arial)
        label.text = "APYD"
        label.fontSize = self.fontSize
        label.fontColor = SKColor.greenColor()
        label.horizontalAlignmentMode = .Center
        label.verticalAlignmentMode =  .Top
        label.position = CGPointMake(self.size.width/16, self.fontSize+3)
        return label
    }()
    
    lazy var atLabel:SKLabelNode = {
        let label = SKLabelNode(fontNamed: FontName.Arial)
        label.text = "AT"
        label.fontSize = self.fontSize
        label.horizontalAlignmentMode = .Center
        label.position = CGPointMake(self.size.width/16, -self.fontSize)
        return label
    }()
    
    lazy var pitchModeLabel:SKLabelNode = {
        let label = SKLabelNode(fontNamed: FontName.Arial)
        label.text = "PITCH"
        label.fontSize = self.fontSize
        label.fontColor = SKColor.greenColor()
        label.horizontalAlignmentMode = .Center
        label.verticalAlignmentMode =  .Top
        label.position = CGPointMake(self.size.width/5, self.fontSize+3)
        return label
        }()
    
    private var fontSize:CGFloat {
        return size.height*0.3
    }
    
    func armedRollFlash() {
        let flash = SKAction.repeatActionForever(SKAction.sequence([SKAction.fadeOutWithDuration(0.3),SKAction.fadeInWithDuration(0.3)]))
        armedRollModeLabel.runAction(flash)
    }
    
    private lazy var background:SKSpriteNode = {
        let node = SKSpriteNode(color: SKColor.blueColor(), size: self.size)
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(-self.size.width/4, self.size.height/2))
        path.addLineToPoint(CGPointMake(-self.size.width/4, 0))
        path.moveToPoint(CGPointMake(0, self.size.height/2))
        path.addLineToPoint(CGPointZero)
        path.moveToPoint(CGPointMake(self.size.width/8, self.size.height/2))
        path.addLineToPoint(CGPointMake(self.size.width/8, 0))
        let pathNode = SKShapeNode(path: path.CGPath)
        node.addChild(pathNode)
        return node
        }()
    
    var size = CGSizeZero
    
    //MARK: - Init Methods -
    
    init(size:CGSize,center:CGPoint) {
        super.init()
        self.size = size
        addChild(background)
        addChild(rollModeLabel)
        addChild(armedRollModeLabel)
        addChild(thrustModeLable)
        addChild(xfrLabel)
        addChild(atLabel)
        addChild(apLabel)
        addChild(pitchModeLabel)
        self.position = center
        self.zPosition = ConstantOfZ.UpperContents
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
