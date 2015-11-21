//
//  DisplayScene.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/7/13.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import SpriteKit
import MapKit

class DisplayScene: SKScene
{
    
    //MARK: - Updating Route -
    var route:[Waypoint?]? {
        didSet {
            updateRouteNode(route: route, name: MapConstant.NodeName.Route)
        }
    }
    var modifyingRoute:[Waypoint?]? {
        didSet {
            updateRouteNode(route: modifyingRoute, name: MapConstant.NodeName.MRoute, usingDashing: true)
        }
    }
    
    
    private func updateRouteNode(route points:[Waypoint?]?,name:String,usingDashing dash:Bool = false,color:SKColor = SKColor.whiteColor()) -> SKShapeNode?
    {
        func waypointMark(waypoint:Waypoint,position:CGPoint) ->SKNode {//Prepare Waypoint name and mark
            var path = UIBezierPath()
            var markColor = SKColor.whiteColor()
            if waypoint.isAirport.boolValue {
                path = UIBezierPath(arcCenter:CGPointMake(0, 0), radius: 7, startAngle: 0, endAngle: CGFloat(M_PI * 2), clockwise: false)
                markColor = SKColor.cyanColor()
            } else {
                path = UIBezierPath.bezierPathForStarMark(center: CGPointMake(0, 0), size: 10)
            }
            let mark = SKShapeNode(path: path.CGPath)
            mark.strokeColor = markColor
            if waypoint.isAirport.boolValue {
                mark.fillColor = SKColor.blackColor()
            }
            let pinNode = SKNode()
            pinNode.position = position
            mark.name = MapConstant.NodeName.WMark
            let label = SKLabelNode(fontNamed: FontName.Arial)
            label.text = waypoint.name
            label.horizontalAlignmentMode = .Left
            label.fontSize = 12
            label.name = MapConstant.NodeName.WName
            label.position = CGPointMake(10, 0)
            mark.addChild(label)
            pinNode.addChild(mark)
            return pinNode
        }
        
        if let oldNode = hsi.map.childNodeWithName(name) {
            oldNode.removeFromParent()
        }
        if points != nil {
            let path = UIBezierPath()
            var markNodes = [SKNode]()
            for i in 0...points!.count-1 {
                if let waypoint = points?[i] {
                    let nextPoint = waypoint.mapPoint - points![0]!.mapPoint
                    let index = max(i-1,0)
                    if points?[index] != nil {
                        if i==0 {
                            path.moveToPoint(nextPoint)
                        } else {
                            path.addLineToPoint(nextPoint)
                        }
                    } else {
                        path.moveToPoint(nextPoint)
                    }
                    markNodes.append(waypointMark(points![i]!,position: nextPoint))
                }
            }
            var cgPath = path.CGPath
            if dash {
                cgPath = CGPathCreateCopyByDashingPath(cgPath, nil, 10, [20,10], 2)!
            }
            let node = SKShapeNode(path: cgPath)
            node.name = name
            node.strokeColor = color
            for markNode in markNodes {
                node.addChild(markNode)
            }
            hsi.map.addChild(node)
            mapScale = CGFloat(mapScale)
            return node
        }
        return nil
        
    }

    
    var offset:CGFloat? {
        didSet {
            if offset != nil {
                updateOffsetRoute()
            } else {
                if let offsetRouteNode = hsi.map.childNodeWithName("//" + MapConstant.NodeName.ORoute) {
                    offsetRouteNode.removeFromParent()
                }
            }
        }
    }
    
    private func updateOffsetRoute() -> [CGPoint]? {
        
        func caculateKandB(first p1:CGPoint,second p2:CGPoint) -> (k:CGFloat?,b:CGFloat?) {
            var k:CGFloat?
            var b:CGFloat?
            if p1.x != p2.x {
                k = (p1.y-p2.y)/(p1.x-p2.x)
                b = p1.y - k! * p1.x
            }
            return (k,b)
        }
        
        func caculateIntersectionOf(line1:(k:CGFloat,b:CGFloat),line2:(k:CGFloat,b:CGFloat)) -> CGPoint {
            return CGPointMake((line2.b-line1.b)/(line1.k-line2.k), (line2.b*line1.k-line1.b*line2.k)/(line1.k-line2.k))
        }
        
        func caculateOffsetMapPoints() -> [CGPoint]? {
            if let os = self.offset {
                var offset = os
                if route!.count > 3 {
                    var offsetWaypoint = [CGPoint]()
                    for index in 0...route!.count-3 {
                        if let p1 = route?[index]?.mapPoint, let p2 = route?[index+1]?.mapPoint,p3 = route?[index+2]?.mapPoint {
                            if let k1 = caculateKandB(first: p1, second: p2).k,let b1 = caculateKandB(first: p1, second: p2).b,let k2 = caculateKandB(first: p2, second: p3).k,let b2 = caculateKandB(first: p2, second: p3).b {
                                
                                if index == 0 {
                                    if k1<0 {offset = -offset}
                                    let y = k1>0 ? offset*cos(atan2(p2.y-p1.y,p2.x-p1.x)):offset*cos(PI-atan2(p2.y-p1.y,p2.x-p1.x))
                                    let x = k1>0 ? offset*sin(atan2(p2.y-p1.y,p2.x-p1.x)):offset*abs(sin(PI-atan2(p2.y-p1.y,p2.x-p1.x)))
                                    let offsetPathOrigin = CGPointMake(x, y)
                                    offsetWaypoint.append(offsetPathOrigin)
                                }
                                
                                let b11 = k1>0 ? b1 + offset/cos(atan2(p2.y-p1.y,p2.x-p1.x)):b1 - offset/cos(PI-atan2(p2.y-p1.y,p2.x-p1.x))
                                let b22 = k2>0 ? b2 + offset/cos(atan2(p3.y-p2.y,p3.x-p2.x)):b2 - offset/cos(PI-atan2(p3.y-p2.y,p3.x-p2.x))
                                let intersection = caculateIntersectionOf((k1,b11), line2: (k2,b22))
                                offsetWaypoint.append(intersection)
                                
                                if index == route!.count-3 {
                                    if let lastPoint = route?.last??.mapPoint {
                                        let y = k2>0 ? offset*cos(atan2(p3.y-p2.y,p3.x-p2.x)):offset*cos(PI-atan2(p3.y-p2.y,p3.x-p2.x))
                                        let x = k2>0 ? offset*sin(atan2(p3.y-p2.y,p3.x-p2.x)):offset*abs(sin(PI-atan2(p3.y-p2.y,p3.x-p2.x)))
                                        let offsetPathLast = CGPointMake(x+lastPoint.x, y+lastPoint.y)
                                        offsetWaypoint.append(offsetPathLast)
                                    }
                                }
                            }
                        }
                    }
                    return offsetWaypoint
                }
            }
            return nil
        }

        if let points = caculateOffsetMapPoints() {
            let path = UIBezierPath()
            path.moveToPoint(CGPointZero)
            for point in points {
                path.addLineToPoint(point)
            }
            path.applyTransform(CGAffineTransformMake(1, 0, 0, 1, -route![0]!.mapPoint.x, -route![0]!.mapPoint.y))
            let cgpath = CGPathCreateCopyByDashingPath(path.CGPath, nil, 3, [10,2,2,2,10], 4)
            let node = SKShapeNode(path: cgpath!)
            node.name = MapConstant.NodeName.ORoute
            node.strokeColor = SKColor.magentaColor()
            hsi.map.addChild(node)
            return points
        }
        return nil
    }
    
    var currentLeg:Int = 0 {
        didSet {
            updateCurrentRouteNode()
        }
    }
    private func updateCurrentRouteNode() {
            if let node = hsi.map.childNodeWithName(MapConstant.NodeName.Route) as? SKShapeNode {
                if currentLeg < route!.count - 2 {
                    if let fromPoint = route?[currentLeg] {
                        if let toPoint = route?[currentLeg+1] {
                            if let currentNode = node.childNodeWithName(MapConstant.NodeName.CLeg) {
                                currentNode.removeFromParent()
                            }
                            let path = UIBezierPath()
                            path.moveToPoint(fromPoint.mapPoint)
                            path.addLineToPoint(toPoint.mapPoint)
                            path.applyTransform(CGAffineTransformMake(1, 0, 0, 1, -route![0]!.mapPoint.x, -route![0]!.mapPoint.y))
                            let currentLegRouteNode = SKShapeNode(path: path.CGPath)
                            currentLegRouteNode.name = MapConstant.NodeName.CLeg
                            currentLegRouteNode.strokeColor = SKColor.greenColor()
                            node.addChild(currentLegRouteNode)
                        }
                    }
                }

            }
    }
    
    //MARK: - Upper Indicators
    let fma = FMANode(size: CGSizeMake(260, 36),center:CGPointMake(-30, 295))
    let attitude = AttitudeIndicatorNode(size: CGSizeMake(190, 190), center: CGPointMake(0, 180))
    let speedTape = TapeNode(domain: CGPointMake(40, 380),origin: 40, interval: 5, pointsPerUnit: 2, size: CGSizeMake(64, 160),type:.Speed)
    let altitudeTape = TapeNode(domain: CGPointMake(-1000, 40000),origin: 0, interval: 100, pointsPerUnit: 0.4, size: CGSizeMake(64, 160),type:.Altitude)
    let vsScale = VerticalSpeedScaleNode(size:CGSizeMake(30, 200),center:CGPointMake(182,180))
    var preselectedSpeed:CGFloat = 0 {
        didSet {
            speedTape.preselectedValue = preselectedSpeed
        }
    }
    
    //MARK: - Horizontal Situation Indicator -
    private let hsi = HSINode(center: CGPoint(x:0,y:-90))

    var planePosition:CGPoint {
        return hsi.plane.position
    }
    
    var mapScale:CGFloat = 1 {
        didSet {
            hsi.setMapScale(mapScale)
            refreshCursorLabel()
        }
    }
    
    var heading:CGFloat = 0 {
        didSet {
            if heading > 360 {heading-=360}
            else if heading < 0 {heading+=360}
            else if heading == 360 {heading=0}
            hsi.headingLabel.text = "\(Int(heading))"
            hsi.map.enumerateChildNodesWithName("//\(MapConstant.NodeName.WMark)", usingBlock: { (node, bool) -> Void in
                node.zRotation = -self.hsi.rose.zRotation
            })
        }
    }
    
    var preselectingHeading:CGFloat = 0 {
        didSet {
            if preselectingHeading > 360 {preselectingHeading-=360}
            else if preselectingHeading < 0 {preselectingHeading+=360}
            else if heading == 360 {heading=0}
            hsi.headingCursor.zRotation = -preselectingHeading.radians
            hsi.cursorLine.alpha = 1.0
            hsi.preselectingHeadingLabel.text = "HDG \(Int(preselectingHeading))"
        }
    }
    
    //MARK: - Other Indicators

    private lazy var groundSpeedLabel:SKLabelNode = {[unowned self] in
    let label = SKLabelNode(text: "0", fontSize: 12, horizontalAlignment: .Center, verticalAlignment: .Baseline)
    label.fontColor = SKColor.magentaColor()
    label.position = CGPointMake(-160, 0)
    return label
    }()
    
    private lazy var trueAirSpeedLabel:SKLabelNode = {[unowned self] in
        let label = SKLabelNode(text: "0", fontSize: 12, horizontalAlignment: .Center, verticalAlignment: .Baseline)
        label.fontColor = SKColor.greenColor()
        label.position = CGPoint(x:-95,y:0)
        return label
    }()
    
    
    private lazy var isaLabel:SKLabelNode = {[unowned self] in
        let label = SKLabelNode(text: "0", fontSize: 12, horizontalAlignment: .Center, verticalAlignment: .Baseline)
        label.fontColor = SKColor.greenColor()
        label.position = CGPoint(x:-25,y:0)
        return label
        }()
    
    
    private lazy var satLabel:SKLabelNode = {[unowned self] in
        let label = SKLabelNode(text: "15", fontSize: 12, horizontalAlignment: .Center, verticalAlignment: .Baseline)
        label.fontColor = SKColor.greenColor()
        label.position = CGPoint(x:75,y:0)
        return label
        }()
    
    private lazy var tatLabel:SKLabelNode = {[unowned self] in
        let label = SKLabelNode(text: "15", fontSize: 12, horizontalAlignment: .Center, verticalAlignment: .Baseline)
        label.fontColor = SKColor.greenColor()
        label.position = CGPoint(x:170,y:0)
        return label
        }()

    
    private lazy var namesLabel:SKLabelNode = {[unowned self] in
        let label = SKLabelNode(text: "GS                 TAS                    ISA           °C               SAT          °C              TAT         °C", fontSize: 10, horizontalAlignment: .Center, verticalAlignment: .Baseline)
        label.position = CGPointMake(0, -205)
        label.zPosition = 15
        label.addChild(self.groundSpeedLabel)
        label.addChild(self.trueAirSpeedLabel)
        label.addChild(self.isaLabel)
        label.addChild(self.satLabel)
        label.addChild(self.tatLabel)
        return label
    }()

    private lazy var radarLabel:SKLabelNode = { [unowned self] in
        let label = SKLabelNode(text: "TERR/WX", fontSize: 10, horizontalAlignment: .Right, verticalAlignment: .Baseline)
        label.position = CGPointMake(195, -150)
        label.zPosition = 15
        label.addChild(self.radarStatusLabel)
        label.addChild(self.radarTiltAngleLabel)
        return label
    }()
    
    private lazy var radarStatusLabel:SKLabelNode = { [unowned self] in
        let label = SKLabelNode(text: "STBY", fontSize: 10, horizontalAlignment: .Right, verticalAlignment: .Baseline)
        label.position = CGPointMake(0, -10)
        return label
        }()

    private lazy var radarTiltAngleLabel:SKLabelNode = { [unowned self] in
        let label = SKLabelNode(text: "T0.0", fontSize: 10, horizontalAlignment: .Right, verticalAlignment: .Baseline)
        label.position = CGPointMake(0, -20)
        return label
        }()
    
    private lazy var trafficLable:SKLabelNode = { [unowned self] in
        let label = SKLabelNode(text: "TFC", fontSize: 10, horizontalAlignment: .Right, verticalAlignment: .Baseline)
        label.position = CGPointMake(195, -50)
        label.zPosition = 15
        label.addChild(self.trafficStatusLabel)
        return label
        }()
    
    private lazy var trafficStatusLabel:SKLabelNode = { [unowned self] in
        let label = SKLabelNode(text: "TA ONLY", fontSize: 10, horizontalAlignment: .Right, verticalAlignment: .Baseline)
        label.position = CGPointMake(0, -10)
        return label
        }()
    
    //map cursor implementation
    lazy var cursor:SKShapeNode = {
        let cursorPath = UIBezierPath(arcCenter: CGPointZero, radius: 10, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
        let node = SKShapeNode(path: cursorPath.CGPath)
        node.zPosition = 13.0
        node.alpha = 0
        return node
        }()

    var cursorOrigin:CGPoint {
        return convertPointToView(contents.convertPoint(hsi.position, toNode: self))
    }
    
    func convertTouchPointToCursorPosition(point:CGPoint) {
        cursorPosition = contents.convertPoint(convertPointFromView(point), fromNode: self)
    }
    var cursorPosition:CGPoint = CGPointZero {
        didSet {
            let cursorPath = UIBezierPath(arcCenter: cursorPosition, radius: 5, startAngle: 0, endAngle: CGFloat(M_PI*2), clockwise: true)
            let radiusPath = UIBezierPath()
            radiusPath.moveToPoint(cursorPosition)
            radiusPath.addLineToPoint(hsi.position)
            let dashedRadiusPath = CGPathCreateCopyByDashingPath(radiusPath.CGPath, nil, 5, [10,5], 2)
            let mutablePath = CGPathCreateMutableCopy(dashedRadiusPath)
            CGPathAddPath(mutablePath, nil, cursorPath.CGPath)
            cursor.path = mutablePath
            cursor.alpha = 1
            refreshCursorLabel()
        }
    }
    
    var cursorWaypoint:CLLocationCoordinate2D?
    
    private func refreshCursorLabel() {
        
        if let points = route {
            if let firstMapPoint = points[0]?.mapPoint {
                let cursorPositionInMap = hsi.map.convertPoint(cursorPosition, fromNode: contents) + firstMapPoint
                let currentPlanePosition = planePosition + firstMapPoint
                let distance = Int(MKMetersBetweenMapPoints(cursorPositionInMap.mapPoint, currentPlanePosition.mapPoint) / 1852)
                var angle = Int(atan2(cursorPosition.x-hsi.position.x, cursorPosition.y-hsi.position.y).degree + heading)
                if angle<0 {angle+=360}
                if let label = cursor.childNodeWithName(MapConstant.NodeName.PositionLabel) as? SKLabelNode {
                    label.text = "\(angle)/\(distance)"
                    if cursorPosition.x < 0 {
                        label.position = CGPointMake(cursorPosition.x - 15, cursorPosition.y + 10)
                    } else {
                        label.position = CGPointMake(cursorPosition.x + 15, cursorPosition.y + 10)
                    }
                } else {
                    let label = SKLabelNode(fontNamed: FontName.Arial)
                    label.fontSize = 14
                    label.name = MapConstant.NodeName.PositionLabel
                    cursor.addChild(label)
                }
                cursorWaypoint = cursorPositionInMap.coordinate
            }
        }
    }
    
    

    
    //MARK: - Initialization -
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    private var contents = SKNode()
    var moveUp = false {
        didSet {
            if moveUp {
                contents.runAction(SKAction.moveToY(170, duration: 0.5))
            } else {
                contents.runAction(SKAction.moveToY(0, duration: 0.5))
            }
        }
    }
    

    private func setupContents() {
        backgroundColor = SKColor.blackColor()
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        contents.addChild(hsi)
        addChild(contents)
        
        let frameNode = SKSpriteNode(imageNamed: "Display")
        frameNode.size = CGSize(width: 512, height: 646)
        frameNode.zPosition = 20
        frameNode.position = CGPointMake(0, 60)
        speedTape.position = CGPointMake(-130, 180)
        altitudeTape.position = CGPointMake(130, 180)
        
        altitudeTape.changeRate = 20.0
        speedTape.changeRate = 10.0
        
        
        let mask = SKSpriteNode(imageNamed: "Mask.png")
        mask.position = CGPointMake(0, 55)
        mask.zPosition = ConstantOfZ.Mask
        
        contents.addChild(mask)
        contents.addChild(frameNode)
        contents.addChild(fma)
        contents.addChild(cursor)
        contents.addChild(speedTape)
        contents.addChild(altitudeTape)
        contents.addChild(attitude)
        contents.addChild(vsScale)
        contents.addChild(namesLabel)
        contents.addChild(radarLabel)
        contents.addChild(trafficLable)

    }
    
    private func tuneToAutoPilotRadio() {
        NSNotificationCenter.defaultCenter().addObserverForName(APOder.APNotificaton, object: delegate, queue: NSOperationQueue.mainQueue()) { [unowned self] notification -> Void in
            if let target = notification.userInfo?[APOder.TargetHeading] as? CGFloat,let duration = notification.userInfo?[APOder.TurningDuration] as? Double {
                self.headingTo(target,duration: duration)
            }
            if let _ = notification.userInfo?[APOder.LNAVCapuring] as? Bool {
                self.fma.armedRollFlash()
            }
            if let rawValue = notification.userInfo?[APOder.CurrentRollMode] as? String {
                self.fma.currentRollMode =  RollMode(rawValue: rawValue)!
            }
            if let rawValue = notification.userInfo?[APOder.ArmedRollMode] as? String {
                self.fma.armedRollMode =  RollMode(rawValue: rawValue)!
            }
            if let index = notification.userInfo?[APOder.UpdateLegIndex] as? Int {
                self.currentLeg = index
            }
            
        }
        NSNotificationCenter.defaultCenter().addObserverForName(AirplaneStatus.StatusNotification, object: delegate, queue: NSOperationQueue.mainQueue()) { [unowned self] notification -> Void in
            if let _ = notification.userInfo?[AirplaneStatus.WeightOfWheel] as? Bool {
                self.fly()
            }
            if let firstHeading = notification.userInfo?[AirplaneStatus.InitHeading] as? CGFloat {
                self.headingTo(firstHeading, duration: 1)
            }
        }
    }

    //MARK: - Scene Methods -
    override func didMoveToView(view: SKView) {
        setupContents()
        tuneToAutoPilotRadio()
    }

    func refreshIndication() {
        //horizontal
        heading = hsi.rose.zRotation.degree
        let planePositionInWorld = hsi.rose.convertPoint(hsi.plane.position, fromNode: hsi.map)
        hsi.map.position = CGPointMake(hsi.map.position.x - planePositionInWorld.x,hsi.map.position.y - planePositionInWorld.y)
        //vertical
        vsScale.value = sin(attitude.pitchAngle.radians)*airspeed*6076/3600/4
        altitudeTape.changeRate = vsScale.value
        altitudeTape.refresh()
        //others
        groundSpeedLabel.text = "\(Int(airspeed))"
        trueAirSpeedLabel.text = "\(Int(airspeed))"
    }
    
    private func headingTo(target:CGFloat,duration:Double) {
        
        var tHeading = target.degree - heading
        var dHeading:CGFloat = 0
        if tHeading < 0  {tHeading+=360}
        if tHeading < 360 && tHeading > 180 {
            dHeading = (tHeading - 360).radians
        } else if tHeading < 180 && tHeading > 0 {
            dHeading = tHeading.radians
        }

        hsi.rose.removeAllActions()
        hsi.rose.runAction(SKAction.rotateToAngle(target, duration: duration, shortestUnitArc: true), completion: {[unowned self] in self.hsi.cursorLine.alpha = 0})
        attitude.refreshRollAngleWith(dHeading, duration: duration)
        
    }
    
    private func fly() {
        let actionSpeed = airspeed/0.048/3600
        let speedVector = CGVectorMake(actionSpeed*sin(hsi.rose.zRotation), actionSpeed*cos(hsi.rose.zRotation))
        let flyAction =  SKAction.moveBy(speedVector, duration: 1)
        hsi.plane.runAction(flyAction, completion: {[unowned self] in self.fly()})
        altitudeTape.climbOrDescend()
    }
    
    var airspeed:CGFloat {
        return speedTape.value
    }
    
    var preselectedPitchAngle:CGFloat = 0 {
        didSet {
            attitude.refreshPitchAngleWith(preselectedPitchAngle)
        }
    }
    
    func reset() {
        hsi.reset()
        altitudeTape.reset()
        speedTape.reset()
        attitude.reset()
    }
    

    
}

