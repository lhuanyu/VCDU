//
//  VerticalSpeedScaleNode.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/8/27.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit
import SpriteKit

class VerticalSpeedScaleNode: SKNode {
    
    private struct Constant {
        static let VerticalScaleBackground = "VerticalSpeedScale"
    }
    
    var value:CGFloat = 0 {
        didSet {
            indicator.zRotation = -indicatorZRotationFor(value: value)
            valueLabel.text = "\(Int(abs(value)*60))"
            if abs(value) >= 1000/60 {
                valueLabel.alpha = 1
                let yPosition = value/abs(value)*(size.height/2-fontSize/2)
                valueLabel.position.y = yPosition
            } else {
                valueLabel.alpha = 0
            }
        }
    }
    
    private func indicatorZRotationFor(value value:CGFloat) -> CGFloat {
        let vsPerMin = value*60
        let sign = vsPerMin/abs(vsPerMin)
        var angle:CGFloat = 0
        switch abs(vsPerMin) {
        case 0...1000:
            angle += 10.cgfloat.radians*(vsPerMin/1000)
        case 1000...2000:
            angle += 10.cgfloat.radians*sign
            let delta = abs(vsPerMin) - 1000
            angle += 5.cgfloat.radians*(delta/1000)*sign
        case 2000...4000:
            angle += 15.cgfloat.radians*sign
            let delta = abs(vsPerMin) - 2000
            angle += 5.cgfloat.radians*(delta/2000)*sign
        case 4000...999_999:
            angle = 20.radians.cgfloat*sign
        default:break
        }
        return angle
    }
   
    private var fontSize:CGFloat {
        return self.size.width/3
    }
    
    private lazy var background:SKSpriteNode = {[unowned self] in
        let node = SKSpriteNode(imageNamed: Constant.VerticalScaleBackground)
        node.size = self.size
        return node
    }()
    
    private lazy var indicator:SKNode = {
        let node = SKNode()
        let sprite = SKSpriteNode(color: SKColor.greenColor(), size: CGSizeMake(16, 3))
        sprite.position = CGPointMake(-200, 0)
        node.position = CGPointMake(200, 0)
        node.addChild(sprite)
        let constraint = SKConstraint.zRotation(SKRange(lowerLimit: -20.0.radians.cgfloat, upperLimit: 20.0.radians.cgfloat))
        node.constraints = [constraint]
        
        return node
    }()
    
    private lazy var valueLabel:SKLabelNode = {[unowned self] in
    let label = SKLabelNode(fontNamed: FontName.Arial)
    label.fontColor = SKColor.greenColor()
    label.fontSize = self.fontSize
    label.horizontalAlignmentMode = .Center
    label.verticalAlignmentMode =  .Center
    label.alpha = 0
    return label
    }()
    
    private let cropNode = SKCropNode()
    private lazy var cropMask:SKSpriteNode = { [unowned self] in
        let node = SKSpriteNode(color: SKColor.redColor(), size: self.size)
        return node
        }()
    
    var size = CGSizeZero
    
    init(size:CGSize,center:CGPoint) {
        super.init()
        self.size = size
        self.position = center
        cropNode.maskNode = cropMask
        cropNode.addChild(background)
        addChild(cropNode)
        addChild(indicator)
        addChild(valueLabel)
        self.zPosition = ConstantOfZ.UpperContents
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
