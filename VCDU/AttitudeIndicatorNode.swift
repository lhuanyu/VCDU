//
//  AttitudeIndicatorNode.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/8/27.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import SpriteKit

class AttitudeIndicatorNode: SKCropNode {
    
    func reset() {
        rollNode.removeAllActions()
        pitchNode.removeAllActions()
        pitchMark.removeAllActions()
        rollNode.zRotation = 0.0
        pitchNode.position.y = 0
        pitchNode.position.y = 0
    }
    
    var rollAngle:CGFloat {
        return rollNode.zRotation
    }
    var pitchAngle:CGFloat {
        return -pitchNode.position.y/9*5
    }
    
    func refreshRollAngleWith(dheading:CGFloat,duration:Double) {
        rollNode.removeActionForKey("ROLL")
        let rollIn = SKAction.rotateToAngle(dheading/PI*25.0.radians.cgfloat, duration: min(2,duration/6))
        let holdRoll = SKAction.waitForDuration(duration-2*min(2,duration/6))
        let rollOut = SKAction.rotateToAngle(0, duration: min(2,duration/6))
        let rollSequnce = SKAction.sequence([rollIn,holdRoll,rollOut])
        rollNode.runAction(rollSequnce, withKey: "ROLL")
    }
    
    func refreshPitchAngleWith(pitchAngle:CGFloat) {
        pitchNode.removeActionForKey("PITCH")
        pitchMark.removeActionForKey("PITCH")
        let pitch = SKAction.moveToY(pitchAngle/2.5*9, duration: 2)
        pitchNode.runAction(pitch, withKey: "PITCH")
        pitchMark.runAction(pitch, withKey: "PITCH")
    }

    
    
    private let rollNode = SKNode()
    private let pitchNode = SKNode()
    
    private lazy var rollMark:SKSpriteNode = { [unowned self] in
        let node = SKSpriteNode(imageNamed: "mark")
        node.size = self.size
        return node
    }()
    
    private lazy var background:SKSpriteNode = {[unowned self] in
        let sky = SKSpriteNode(color: SKColor(red: 74/255, green: 186/255, blue: 246/255, alpha: 1), size: CGSizeMake(self.size.width*2, self.size.height*2))
        
        let ground = SKSpriteNode(color: SKColor.brownColor(), size: CGSizeMake(self.size.width*2, self.size.height*2))
        ground.position = CGPointMake(0, -self.size.height)
        sky.addChild(ground)
        return sky
        }()
    
    private lazy var cropMask:SKSpriteNode = { [unowned self] in
        let node = SKSpriteNode(color: SKColor.redColor(), size: self.size)
        node.size = self.size
        return node
        }()
    
    
    private lazy var pitchMark:SKShapeNode = { [unowned self] in
        let pitchAngleMark = SKShapeNode()
        let path = UIBezierPath()
        for i in -16...16 {
            var x:CGFloat = 3
            var label1 = SKLabelNode()
            var label2 = SKLabelNode()
            if abs(i)%4 == 0 {
                x  = x*4
                if i != 0 {
                    label1 = SKLabelNode(text: "\(Int(abs(Double(i)*2.5)))", fontSize: 12,horizontalAlignment:.Right)
                    label2 = SKLabelNode(text: "\(Int(abs(Double(i)*2.5)))", fontSize: 12,horizontalAlignment:.Left)
                }
            } else if abs(i)%2 == 0 {
                x  = x*2
            }
            path.moveToPoint(CGPointMake(-x, CGFloat(i)*9))
            label1.position = path.currentPoint

            path.addLineToPoint(CGPointMake(x, CGFloat(i)*9))
            label2.position = path.currentPoint
            pitchAngleMark.addChild(label1)
            pitchAngleMark.addChild(label2)

        }
        pitchAngleMark.path = path.CGPath
        return pitchAngleMark
    } ()
    
    private lazy var pitchMarkCropNode:SKCropNode = { [unowned self] in
        let mask = SKSpriteNode(imageNamed: "roundMask")
        mask.size = CGSizeMake(self.size.width-20, self.size.width-20)
        let crop = SKCropNode()
        crop.maskNode = mask
        crop.addChild(self.pitchMark)
        return crop
    }()
    
    var size = CGSizeZero
    
    private let cropNode = SKCropNode()

    
    init(size:CGSize,center:CGPoint) {
        super.init()
        self.size = size
        self.position = center
        self.maskNode = cropMask
        self.cropNode.addChild(self.rollNode)
        self.cropNode.addChild(rollMark)
        
        self.rollNode.addChild(pitchNode)
        self.rollNode.addChild(pitchMarkCropNode)

        self.pitchNode.addChild(self.background)
        addChild(cropNode)
        zPosition = ConstantOfZ.UpperContents
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

extension SKLabelNode {
    convenience init(text:String,fontSize:CGFloat,horizontalAlignment:SKLabelHorizontalAlignmentMode = .Center,verticalAlignment:SKLabelVerticalAlignmentMode = .Center) {
        self.init(fontNamed: FontName.Arial)
        self.text = text
        self.fontSize = fontSize
        self.horizontalAlignmentMode = horizontalAlignment
        self.verticalAlignmentMode = verticalAlignment
    }
}
