//
//  TapeNode.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/8/18.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit
import SpriteKit

enum ScaleType:UInt {
    case Speed = 0, Altitude, Modern
}


class TapeNode: SKNode {
    
    //MARK: - Public Display Parameters -
    var minimumScale:CGFloat = 0.0
    var maximumScale:CGFloat = 0.0
    var originScale:CGFloat = 0.0 {
        didSet {
            if type == .Altitude {
                //set the minus suptape
            }
        }
    }
    var pointsPerUnit:CGFloat = 1.0
    var interval:CGFloat = 0.0
    var type = ScaleType.Speed
    
    //MARK: - Auto Flight System Prameters -
    var value:CGFloat {
        if tape.position.y == 0 {
            return 0
        }
        return -tape.position.y/pointsPerUnit+originScale
    }
    
    var preselectedValue:CGFloat = 0 {
        didSet {
            refreshTape()
        }
    }
    
    var changeRate:CGFloat = 0 {//units per second
        didSet {
            subTape.speed = abs(changeRate/pointsPerUnit)
            tape.speed = abs(changeRate/pointsPerUnit)
        }
    }

    //MARK: - Animation Methods -
    
    var plane = SKNode()
    
    func reset() {
        plane.position.y = 0
        tape.position.y = yPositionOfTapeFor(originScale)
        subTape.position.y = 0
        currentValueLabel.text = "\(Int(self.originScale/self.periodOfSubTape.cgfloat))"
        preselectedValueLabel.text = "0"
        plane.removeAllActions()
        tape.removeAllActions()
        subTape.removeAllActions()
    }
    
    func climbOrDescend() {
        if value >= 0 {
        let verticalAction = SKAction.moveBy(CGVectorMake(0, changeRate), duration: 1)
        plane.runAction(verticalAction)
        }
    }
    
    func refresh() {
        if value >= 0 {
            tape.position.y = yPositionOfTapeFor(plane.position.y)
            subTape.position.y = yPositonOfSubTapeFor(value)
            currentValueLabel.text = "\(Int(self.value/self.periodOfSubTape.cgfloat))"
        }
    }
    
    private func yPositonOfSubTapeFor(value:CGFloat) -> CGFloat {
        return -(value%100)/10*fontSize
    }
    
    private func yPositionOfTapeFor(value:CGFloat) -> CGFloat {
        return (originScale-value)*pointsPerUnit
    }
    
    private func refreshTape() {
        if preselectedValue > minimumScale && preselectedValue < maximumScale {
            preselectedValueLabel.text = "\(Int(preselectedValue))"
            subTape.removeAllActions()
            tape.removeAllActions()
            correctYPositonOfSubTape()
            let time = (preselectedValue-value).double
            refreshSubTape(time)
            tape.runAction(SKAction.moveToY(yPositionOfTapeFor(preselectedValue), duration:abs(time)),completion:{
                self.subTape.removeAllActions()
                self.correctYPositonOfSubTape()
                })
        }

    }
    
    private func correctYPositonOfSubTape() {
        subTape.position.y = -subTapeIndexOf(preselectedValue)*fontSize
    }
    
    private func subTapeIndexOf(value:CGFloat) -> CGFloat {
        return (value*10/self.periodOfSubTape.cgfloat)%10
    }
    
    private var periodOfSubTape:Double {
        if type == .Speed {
            return 10
        }
        return 100
    }
    
    private func refreshSubTape(direction:Double) {
        var count:CGFloat = -(10-self.subTapeIndexOf(value))
        if direction.isSignMinus {
            count = self.subTapeIndexOf(value)
        }
        let roll = SKAction.moveBy(CGVectorMake(0, count*fontSize), duration:periodOfSubTape*abs(count/10).double)
        subTape.runAction(roll, completion: {
        self.subTape.position.y = 0
        self.refreshSubTape(direction)
        self.currentValueLabel.text = "\(Int(self.value/self.periodOfSubTape.cgfloat))"
        })
    }
    
    //MARK: - Private Display Setup -
    
    private lazy var preselectedValueLabel:SKLabelNode = { 
        let node = SKLabelNode(fontNamed: FontName.Arial)
        node.text = "\(Int(self.preselectedValue))"
        node.fontSize = self.fontSize
        node.fontColor = SKColor.cyanColor()
        if self.type == .Speed {
            let shape = SKShapeNode()
            let path = UIBezierPath()
            path.moveToPoint(CGPointMake(13, 5))
            path.addLineToPoint(CGPointMake(19, 8))
            path.addLineToPoint(CGPointMake(25, 8))
            path.addLineToPoint(CGPointMake(25, 2))
            path.addLineToPoint(CGPointMake(19, 2))
            path.closePath()
            shape.path = path.CGPath
            node.addChild(shape)
            node.position = CGPointMake(-15, self.size.height/2)
        } else {
            node.position = CGPointMake(0, self.size.height/2+10)
        }
        return node
    }()
    
    
    private lazy var cursor:SKShapeNode = {
        let path = UIBezierPath()
        let node = SKShapeNode()
        node.path = path.CGPath
        return node
    }()
    
    private lazy var currentValueNode:SKNode = {  
        let node = SKNode()
        let frameNode = SKShapeNode()
        frameNode.fillColor = SKColor.blackColor()
        let path = UIBezierPath()
        
        var frameSize = CGSizeMake(50, 30)
        if self.type == .Speed {
            path.moveToPoint(CGPointZero)
            path.addLineToPoint(CGPointMake(-3, 3))
            path.addLineToPoint(CGPointMake(-3, frameSize.height/2))
            path.addLineToPoint(CGPointMake(-3-self.size.width/2, frameSize.height/2))
            path.addLineToPoint(CGPointMake(-3-self.size.width/2, -frameSize.height/2))
            path.addLineToPoint(CGPointMake(-3, -frameSize.height/2))
            path.addLineToPoint(CGPointMake(-3, -3))
        } else if self.type == .Altitude {
            frameSize = CGSizeMake(50, 40)
            path.moveToPoint(CGPointMake(-6+self.size.width/2, 0))
            path.addLineToPoint(CGPointMake(-9+self.size.width/2, 3))
            path.addLineToPoint(CGPointMake(-9+self.size.width/2, frameSize.height/2))
            path.addLineToPoint(CGPointMake(6-self.size.width/2, frameSize.height/2))
            path.addLineToPoint(CGPointMake(6-self.size.width/2, -frameSize.height/2))
            path.addLineToPoint(CGPointMake(-9+self.size.width/2, -frameSize.height/2))
            path.addLineToPoint(CGPointMake(-9+self.size.width/2, -3))
        }
        path.closePath()
        frameNode.path = path.CGPath
        let cropMask = SKSpriteNode(color: SKColor.blackColor(), size:frameSize)
        let cropNode = SKCropNode()
        cropNode.maskNode = cropMask
        cropNode.addChild(self.subTape)
        node.addChild(frameNode)
        node.addChild(self.currentValueLabel)
        node.addChild(cropNode)
        return node
    }()
    
    private lazy var currentValueLabel:SKLabelNode = {  
        let node = SKLabelNode(fontNamed: FontName.Arial)
        if self.type == .Speed {
            node.text = "\(Int(self.originScale/10))"
            node.fontSize = self.fontSize
            node.position = CGPointMake(-18, 0)
        } else if self.type == .Altitude {
            node.text = "00"
            node.fontSize = self.fontSize+2
            node.position = CGPointMake(8, 0)
        }
        node.horizontalAlignmentMode = .Right
        node.verticalAlignmentMode = .Center
        node.fontColor = SKColor.greenColor()
        return node
        }()
    
    
    
     lazy var tape:SKShapeNode = { 
        let pathNode = SKShapeNode()
        let path = UIBezierPath()
        let intervalCount = Int((self.maximumScale-self.minimumScale+1)/self.interval)
        
        if self.type == .Speed {
            path.moveToPoint(CGPointMake(0, -self.yPositionOfTapeFor(self.minimumScale)))
            path.addLineToPoint(CGPointMake(0, -self.yPositionOfTapeFor(self.maximumScale)))
            for i in 0...intervalCount {
                let index = CGFloat(i)
                path.moveToPoint(CGPointMake(0,-self.yPositionOfTapeFor(self.minimumScale+index*self.interval)))
                if i%2 == 0 {
                    path.addLineToPoint(CGPointMake(-10,-self.yPositionOfTapeFor(self.minimumScale+index*self.interval)))
                    if i%4 == 0 {
                        let numberLabel = SKLabelNode(text: "\(Int(self.originScale+index*self.interval))", fontSize: self.fontSize, horizontalAlignment: .Right, verticalAlignment: .Center)
                        numberLabel.position = path.currentPoint
                        
                        pathNode.addChild(numberLabel)
                    }
                } else {
                    path.addLineToPoint(CGPointMake(-10*0.5,-self.yPositionOfTapeFor(self.minimumScale+index*self.interval)))
                }
            }
        } else if self.type == .Altitude {
            let landNode = SKSpriteNode(color: SKColor.brownColor(), size: self.size)
            landNode.position = CGPointMake(0, -self.size.height/2)
            pathNode.addChild(landNode)

            
            for i in 0...100 {
                let index = CGFloat(i)
                let value = self.minimumScale+index*self.interval
                
                path.moveToPoint(CGPointMake(self.size.width/2,-self.yPositionOfTapeFor(self.minimumScale+index*self.interval)))
                path.addLineToPoint(CGPointMake(-10*1+self.size.width/2,-self.yPositionOfTapeFor(self.minimumScale+index*self.interval)))
                let savePoint = path.currentPoint
                var factor:CGFloat = 2.0
                if Int(value/100)%2 == 0 {
                    factor = 1
                }
                let rectPath = UIBezierPath(rect: CGRectMake(-0.4*self.size.width, path.currentPoint.y-self.fontSize/6, self.fontSize/factor, self.fontSize/4))
                path.appendPath(rectPath)
                path.moveToPoint(savePoint)

                let decimalNumberLabel = SKLabelNode(text: "00", fontSize: self.fontSize-1, horizontalAlignment: .Right, verticalAlignment: .Center)
                decimalNumberLabel.position = path.currentPoint
                let numberLabel = SKLabelNode(text: "\(Int(value/100))", fontSize: self.fontSize+1, horizontalAlignment: .Right, verticalAlignment: .Center)
                numberLabel.position = path.currentPoint+CGPointMake(-15,0)
                pathNode.addChild(decimalNumberLabel)
                pathNode.addChild(numberLabel)
            }

        }
        pathNode.path = path.CGPath
        
        
        return pathNode
    }()
    
    private lazy var subTape:SKNode = { 
        
        let node = SKNode()
        for i in 0...30 {
            let numberLabel = SKLabelNode(fontNamed: FontName.Arial)
            numberLabel.fontSize = self.fontSize
            if self.type == .Speed {
                numberLabel.text = "\(i%10)"
            } else if self.type == .Altitude {
                numberLabel.text = "\((i%10)*10)"
                if i%10 == 0 {
                    numberLabel.text = "00"
                }
                node.position = CGPointMake(self.size.width/2, 0)
            }
            numberLabel.fontColor = SKColor.greenColor()
            numberLabel.position = CGPointMake(-10,CGFloat(i-10)*self.fontSize)
            numberLabel.horizontalAlignmentMode = .Right
            numberLabel.verticalAlignmentMode = .Center
            node.addChild(numberLabel)
        }
        

        return node
    }()
    
    private var fontSize:CGFloat {
        return self.size.width/5
    }
    
    private lazy var background:SKSpriteNode = {
        let node = SKSpriteNode(color: SKColor.blueColor(), size: self.size)
        return node
    }()
    
    private lazy var cropMask:SKSpriteNode = { 
        let node = SKSpriteNode(color: SKColor.redColor(), size: self.size)
        return node
    }()
    
    private let cropNode = SKCropNode()
    
    private var size = CGSizeZero
    
    //MARK: - Init Methods -
    
    init(domain:CGPoint,origin:CGFloat,interval:CGFloat,pointsPerUnit:CGFloat,size:CGSize,type:ScaleType) {
        super.init()
        self.type = type
        self.minimumScale = domain.x
        self.maximumScale = domain.y
        self.originScale = origin
        self.pointsPerUnit = pointsPerUnit
        self.interval = interval
        self.size = size
        cropNode.maskNode = cropMask
        cropNode.addChild(background)
        cropNode.addChild(tape)
        addChild(cropNode)
        addChild(preselectedValueLabel)
        addChild(currentValueNode)
        addChild(plane)
        self.zPosition = ConstantOfZ.UpperContents
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
}

extension SKNode {
    var sprite:SKSpriteNode {
        let skview = SKView()
        return SKSpriteNode(texture: skview.textureFromNode(self))
    }
}