//
//  HSINode.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/7/23.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit
import SpriteKit


struct ConstantOfZ {
    static let UpperContents:CGFloat = 17.0
    static let Plane:CGFloat = 15.0
    static let HeadingLabel:CGFloat = 14.0
    static let HeadingFrame:CGFloat = 13.0
    static let Cover:CGFloat = 12.0
    static let OutterCircle:CGFloat = 11.0
    static let Mask:CGFloat = 10.0
    static let Map:CGFloat = 9.0
    static let OutterRadiusLabel:CGFloat = 8.0
    static let HeadingCursor:CGFloat = 8.0
    static let InnerRadiusLabel:CGFloat = 5.0
    
}

enum DisplayFormat:UInt {
    case ROSE = 0, PPOS, PLAN
}

class HSINode: SKNode {
    
    func reset() {
        rose.removeAllActions()
        rose.zRotation = 0
        plane.removeAllActions()
        plane.position = CGPointZero

    }

    //MARK: - Public Display Property -

    
    var format = DisplayFormat.PPOS {
        didSet {
            switch format {
            case .ROSE:
            maskON = false
            case .PPOS:
            maskON = true
            case .PLAN:
            maskON = false
            }
        }
    }
    
    let rose = SKNode()
    let map = SKNode()
    let plane = SKNode()

    func setMapScale(mapScale:CGFloat) {
        map.setScale(mapScale)
        innerRadiusLabel.text = "\(Int(5/mapScale))"
        outterRadiusLabel.text = "\(Int(10/mapScale))"
        if let route = map.childNodeWithName(MapConstant.NodeName.Route) as? SKShapeNode {
            route.lineWidth = 1/mapScale
            for node in route.children {
                if node.name != MapConstant.NodeName.CLeg {
                    node.setScale(1/mapScale)
                }
            }
        }
        if let modifyingRoute = map.childNodeWithName(MapConstant.NodeName.MRoute) as? SKShapeNode {
            modifyingRoute.lineWidth = 1/mapScale
            for node in modifyingRoute.children {
                node.setScale(1/mapScale)
            }
        }
        if let offsetRoute = map.childNodeWithName(MapConstant.NodeName.ORoute) as? SKShapeNode {
            offsetRoute.lineWidth = 1/mapScale
        }
    }
    
    //MARK: - UI Setting -
    
    
    lazy var headingCursor:SKShapeNode = { [unowned self] in
        let cursorPath = UIBezierPath()
        cursorPath.moveToPoint(CGPointMake(-8, 1.03*self.radius))
        cursorPath.addLineToPoint(CGPointMake(-5, 1.03 * self.radius))
        cursorPath.addLineToPoint(CGPointMake(0,1.01*self.radius))
        cursorPath.addLineToPoint(CGPointMake(5, 1.03 * self.radius))
        cursorPath.addLineToPoint(CGPointMake(8, 1.03 * self.radius))
        cursorPath.addLineToPoint(CGPointMake(8, self.radius))
        cursorPath.addLineToPoint(CGPointMake(-8, self.radius))
        cursorPath.closePath()
        let node = SKShapeNode(path: cursorPath.CGPath)
        node.fillColor = SKColor.cyanColor()
        node.addChild(self.cursorLine)
        node.zPosition = ConstantOfZ.HeadingCursor
        return node
        }()
    
    lazy var headingLabel:SKLabelNode = { [unowned self] in
        let node = SKLabelNode(fontNamed:FontName.Arial)
        node.text = "360"
        node.fontSize = self.fontSize+4
        node.fontColor = SKColor.greenColor()
        node.position = CGPoint(x:0, y:1.07*self.radius)
        node.zPosition = ConstantOfZ.HeadingLabel
        return node
        }()
    
    lazy var preselectingHeadingLabel:SKLabelNode = { [unowned self] in
        let node = SKLabelNode(fontNamed: FontName.Arial)
        node.text = "HDG 360"
        node.fontSize = self.fontSize
        node.fontColor = SKColor.magentaColor()
        node.horizontalAlignmentMode = .Center
        node.position = CGPoint(x: -0.5*self.radius, y: 1.07 * self.radius)
        return node
        }()
    
    lazy var cursorLine:SKShapeNode = { [unowned self] in
        let path = UIBezierPath()
        path.moveToPoint(self.position)
        path.addLineToPoint(CGPointMake(0, self.radius))
        let dashedLine = CGPathCreateCopyByDashingPath(path.CGPath, nil, 5, [10,5], 2)
        let line = SKShapeNode(path: dashedLine!)
        line.lineWidth = 1
        line.alpha = 0
        return line
        }()
    
    private var fontSize:CGFloat {
        return 11*radius/150
    }
    
    private lazy var innerRadiusLabel:SKLabelNode = {[unowned self] in
        let node = SKLabelNode(fontNamed: FontName.Arial)
        node.text = "5"
        node.fontSize = self.fontSize
        node.color = SKColor.blackColor()
        node.blendMode = SKBlendMode.Replace
        node.fontColor = SKColor.whiteColor()
        node.horizontalAlignmentMode = .Center
        node.position = CGPoint(x: -self.radius*cos(25.0.radians).cgfloat/2, y:  self.radius*sin(25.0.radians).cgfloat/2)
        node.zPosition = ConstantOfZ.InnerRadiusLabel
        return node
        }()
    
    private lazy var outterRadiusLabel:SKLabelNode = {[unowned self] in
        let node = SKLabelNode(fontNamed: FontName.Arial)
        node.text = "10"
        node.fontSize = self.fontSize
        node.fontColor = SKColor.whiteColor()
        node.horizontalAlignmentMode = .Center
        node.position = CGPoint(x: -self.radius*cos(25.0.radians).cgfloat, y: self.radius*sin(25.0.radians).cgfloat)*0.9
        node.zPosition = ConstantOfZ.OutterRadiusLabel
        return node
        }()
    

    
    private var hashMark:[(CGPoint,CGPoint)] {
        var marks = [(CGPoint,CGPoint)]()
        for i in 0...71 {
            let point0 = CGPointMake(radius * sin(PI*2/72*i.cgfloat),radius * cos(PI*2/72*i.cgfloat))
            let b = i%2
            var point1 = CGPointZero
            if b != 0 {
                point1 = CGPointMake((radius+5) * sin(PI*2/72*i.cgfloat),(radius+5) * cos(PI*2/72*i.cgfloat))
            } else {
                point1 = CGPointMake((radius+10) * sin(PI*2/72*i.cgfloat),(radius+10) * cos(PI*2/72*i.cgfloat))
            }
            marks.append((point0,point1))
        }
        return marks
    }
    
    private func addScaleLabel() {
        for i in 0...71 {
            let a = (i*5)%30
            if a==0 {
                let angle = Double(i*5)
                let scaleLabel = SKLabelNode(text: "\(Int(angle/10))")
                if angle == 0 {scaleLabel.text = "N"}
                else if angle == 90 {scaleLabel.text = "E"}
                else if angle == 180 {scaleLabel.text = "S"}
                else if angle == 270 {scaleLabel.text = "W"}
                scaleLabel.position = hashMark[i].1
                scaleLabel.fontName = FontName.Arial
                scaleLabel.fontSize = self.fontSize
                scaleLabel.zRotation = CGFloat(-angle/180*M_PI)
                scaleLabel.zPosition = ConstantOfZ.OutterCircle
                rose.addChild(scaleLabel)
            }
        }
        
    }
    
    private func addContents() {
        let innerCirclePath = UIBezierPath(arcCenter: CGPointZero, radius: radius/2, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        let node = SKShapeNode(path: innerCirclePath.CGPath)
        let planePath = UIBezierPath.bezierPathForAirplane(CGPointZero, size: 20)
        let planeShape = SKShapeNode(path: planePath.CGPath)
        planeShape.zPosition = ConstantOfZ.Plane
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(-16, 1.17 * radius))
        path.addLineToPoint(CGPointMake(-16, 1.05 * radius))
        path.addLineToPoint(CGPointMake(-5, 1.05 * radius))
        path.addLineToPoint(CGPointMake(0, 1.025 * radius))
        path.addLineToPoint(CGPointMake(5, 1.05 * radius))
        path.addLineToPoint(CGPointMake(16, 1.05 * radius))
        path.addLineToPoint(CGPointMake(16, 1.17 * radius))
        let headingFrame = SKShapeNode(path: path.CGPath)
        headingFrame.fillColor = SKColor.blackColor()
        headingFrame.zPosition = ConstantOfZ.HeadingFrame
        addChild(node)
        addChild(planeShape)
        addChild(outterRadiusLabel)
        addChild(rose)
        addChild(headingFrame)
        addChild(headingLabel)
        addChild(preselectingHeadingLabel)
    }
    
    private var radius:CGFloat = HSI_RADIUS.cgfloat
    
    private var maskON = true {
        didSet {
            if maskON {
                addChild(mask)
            } else {
                mask.removeFromParent()
            }
        }
    }
    
    private lazy var mask:SKShapeNode = { [unowned self] in
        let coverPath = UIBezierPath(arcCenter: self.position, radius: self.radius+15, startAngle: CGFloat(M_PI/6), endAngle: CGFloat(M_PI*5/6), clockwise: false)
        let cover = SKShapeNode(path: coverPath.CGPath)
        cover.lineWidth = self.radius/4
        cover.strokeColor = SKColor.blackColor()
        cover.zPosition = ConstantOfZ.Cover
        return cover
        }()
    
    //MARK: - Init Methods -
    
    init(center:CGPoint,radius:CGFloat = HSI_RADIUS.cgfloat,format:DisplayFormat = .PPOS) {
        super.init()
        self.radius = radius
        switch format {
        case .PPOS:
            let path = UIBezierPath(arcCenter:CGPointZero, radius: radius, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
            for i in 0...self.hashMark.count-1 {
                path.moveToPoint(hashMark[i].0)
                path.addLineToPoint(hashMark[i].1)
            }
            let outterCircleNode = SKShapeNode(path: path.CGPath)
            outterCircleNode.zPosition = ConstantOfZ.OutterCircle
            rose.addChild(outterCircleNode)
            rose.addChild(headingCursor)
            addScaleLabel()
            addChild(innerRadiusLabel)
            addChild(mask)
        case .ROSE:break
        case .PLAN:break
        }
        map.addChild(plane)
        map.zPosition = ConstantOfZ.Map
        rose.addChild(map)
        addContents()
        self.position = center
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    
}
