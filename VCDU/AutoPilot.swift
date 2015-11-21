//
//  AutoPilot.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/7/22.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import MapKit
import SpriteKit

enum RollMode:String {
    case HDG = "HDG"
    case LNAV = "LNAV"
    case ROLL = "ROLL"
    case BANK = "1/2BANK"
    case OFF = ""
}

enum PitchMode:String {
    case PITCH = "PITCH"
    case VS = "VS"
    case FLC = "FLC"
    case ALTS = "ALTS"
    case ALT = "ALT"
    case OFF = ""
}

class AutoPilot: NSObject,SKSceneDelegate {
    
    init(name:String){
        self.name = name
    }
    var name:String
    //MARK: - Airplane Status -
    var inAir = false {
        didSet {
            if inAir {
                NSNotificationCenter.defaultCenter().postNotificationName(AirplaneStatus.StatusNotification, object: self, userInfo: [AirplaneStatus.WeightOfWheel:inAir])
                targetHeading = preselectedHeading
            }
        }
    }
    
    func reset() {
        navOn = false
        navArm = false
        headingOn = false
        inAir = false
        heading = 0
        preselectedHeading = 0
        preselectedSpeed = 0
        currentLeg = 0
        autoTurning = false
        if currentRoute != nil && !inAir {
            NSNotificationCenter.defaultCenter().postNotificationName(AirplaneStatus.StatusNotification, object: self, userInfo: [AirplaneStatus.InitHeading:legInfoOf(currentRoute).headings![0]])
        }
    }
    
    //MARK: - Flght Paramaters -
    
    var preselectedSpeed:CGFloat=0 {
        didSet {
            
        }
    }
    var airspeed:CGFloat = 0 {
        didSet {
            if !inAir && airspeed > 140 {
                inAir = true
            }
        }
    }
    var heading:CGFloat = 0
    
    var aoa:CGFloat = 0
    var rollAngle:CGFloat = 0
    var pitchAngle:CGFloat = 0
    
    //MARK: - Navigation Data -
    var planePosition = CGPointZero
    var currentRoute:[Waypoint?]? {
        didSet {
            if currentRoute != nil && !inAir {
                NSNotificationCenter.defaultCenter().postNotificationName(AirplaneStatus.StatusNotification, object: self, userInfo: [AirplaneStatus.InitHeading:legInfoOf(currentRoute).headings![0]])
            }
        }
    }
    var modifyingRoute:[Waypoint?]?
    var mapPoints:[CGPoint?]? {
        return currentRoute?.map({
            (point:Waypoint?) -> CGPoint? in
            return point?.mapPoint != nil ? point!.mapPoint - self.currentRoute![0]!.mapPoint : nil
        }) ?? nil
    }
    
    var modifyingMapPoints:[CGPoint?]? {
        return modifyingRoute?.map({
            (point:Waypoint?) -> CGPoint? in
            return point?.mapPoint != nil ? point!.mapPoint - self.modifyingRoute![0]!.mapPoint : nil
        }) ?? nil
    }
    
    private func legInfoOf(points:[Waypoint?]?) -> (headings:[CGFloat]?,distances:[Double]?) {
        if points != nil {
            var headings = [CGFloat]()
            var distances = [Double]()
            for index in 0...points!.count-2 {
                if let waypoint = currentRoute?[index] {
                    if let nextWaypoint = currentRoute?[index+1] {
                        let info = Waypoint.legInfo(firstPoint: waypoint, secondPoint: nextWaypoint)
                        let heading = CGFloat(info.heading).radians
                        headings.append(heading)
                        distances.append(info.distance)
                    }
                }
            }
            return (headings,distances)
        }
        return (nil,nil)
    }
    
    var currentRollMode = RollMode.OFF {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(APOder.APNotificaton, object: self, userInfo: [APOder.CurrentRollMode:currentRollMode.rawValue])
        }
    }
    var armedRollMode = RollMode.OFF {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(APOder.APNotificaton, object: self, userInfo: [APOder.ArmedRollMode:armedRollMode.rawValue])
        }
    }
    
    //MARK: - HDG Mode -
    var preselectedHeading:CGFloat = 0 {
        didSet {
            if headingOn {
                targetHeading = preselectedHeading
            }
        }
    }
    var targetHeading:CGFloat = 0 {
        didSet {
            if headingOn  {
                broadcastHeadingOrder()
            }
        }
    }
    func dHeading(next:CGFloat) -> CGFloat {
        var dh = abs(next - heading)
        if dh>PI {dh = 2*PI-dh}
        return dh
    }
    
    var headingOn = false
    {
        didSet {
            if headingOn {
                navOn = false
                navArm = false
                currentRollMode = .HDG
                targetHeading = preselectedHeading
            } else {
                if oldValue && !navOn  {
                    currentRollMode = .ROLL
                }
            }
        }
    }
    
    
    private func broadcastHeadingOrder() {
        if inAir {
            let duration = Double(dHeading(targetHeading))/4.0.radians
            NSNotificationCenter.defaultCenter().postNotificationName(APOder.APNotificaton, object: self, userInfo: [APOder.TargetHeading:targetHeading,APOder.TurningDuration:duration])
        }
    }
    
    //MARK: - LNAV Mode -
    var navOn = false {
        didSet {
            if navOn {
                currentRollMode = .LNAV
                armedRollMode = .OFF
                headingOn = false
            } else {
                if oldValue && !headingOn {
                    currentRollMode = .ROLL
                }
            }
        }
    }

    var navArm = false {
        didSet {
            if navArm  {
                armedRollMode = .LNAV
            } else {
                navOn = false
                armedRollMode = .OFF
            }
        }
    }
    
    var currentLeg = 0 {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(APOder.APNotificaton, object: self, userInfo: [APOder.UpdateLegIndex : currentLeg])
        }
    }
    
    private func legToCaputure() -> (index:Int,distance:CGFloat) {
        var minIndex = 0
        var minDistance = CGFloat.max
        for index in 0...mapPoints!.count-2 {
            if let point1 = mapPoints?[index],let point2 = mapPoints?[index+1] {
                let point = planePosition
                let s = abs((point.x-point1.x)*(point1.y-point2.y)-(point1.x-point2.x)*(point.y-point1.y))
                let l = sqrt(pow(point1.x-point2.x,2)+pow(point1.y-point2.y,2))
                let distance = s/l
                if distance < minDistance {
                    minDistance = distance
                    minIndex = index
                }
            }
        }
        return (minIndex,minDistance)
    }
    
    private func distanceToTurn(next:CGFloat) -> CGFloat {
        let speed = airspeed/0.048/3600
        let turnRadius = speed / 4.0.cgfloat.radians
        let dToTurn = turnRadius * tan(dHeading(next)/2)
        return dToTurn
    }
    
    private var isCapuring = false {
        didSet {
            if isCapuring {
                NSNotificationCenter.defaultCenter().postNotificationName(APOder.APNotificaton, object: self, userInfo: [APOder.LNAVCapuring:isCapuring])
            }
        }
    }
    
    private func captureRoute() {
        if let headings = legInfoOf(currentRoute).headings {
            let distance = legToCaputure().distance
            let nextHeading = headings[legToCaputure().index]
            if distance < distanceToTurn(nextHeading) * sin(dHeading(nextHeading)) && !isCapuring  {
                targetHeading = nextHeading
                isCapuring = true
                currentLeg = legToCaputure().index
                broadcastHeadingOrder()
            }
            if distance < 1 {
                navOn = true
                isCapuring = false
            }
        }
    }
    
    private var autoTurning = false
    private func lateralNavigation() {
        if let headings = legInfoOf(currentRoute).headings,let _ = legInfoOf(currentRoute).distances {
            if currentLeg < headings.count-1 {
                if let nextWaypoint = mapPoints?[currentLeg+1] {
                    let distanceToNextWaypoint = sqrt(pow(planePosition.x - nextWaypoint.x,2) + pow(planePosition.y - nextWaypoint.y,2))
                    let nextHeading = headings[currentLeg+1]
                    if distanceToNextWaypoint < distanceToTurn(nextHeading) && !autoTurning {
                        autoTurning = true
                        ++currentLeg
                        targetHeading = headings[currentLeg]
                        broadcastHeadingOrder()
                        //print("Turning,move to leg \(currentLeg)")
                    }

                    
                    if legToCaputure().distance > 1 && !autoTurning {
                        autoTurning = true
                        var correctionHeading = atan2(-planePosition.y+nextWaypoint.y,-planePosition.x+nextWaypoint.x)
                        if correctionHeading > PI/2 {correctionHeading+=PI}
                        else if correctionHeading < PI/2 {correctionHeading = PI/2 - correctionHeading}
                        targetHeading = correctionHeading
                        broadcastHeadingOrder()
                        //print("\(correctionHeading.degree)   correcting heading error")
                    }
                    
                    if dHeading(targetHeading) < 0.01.cgfloat.radians && autoTurning {
                        autoTurning = false
                        //print("Finish Auto turning")
                    }
                }
            }
        }
    }
    
    //MARK: - DisplayScene Delegate -
    
    func didFinishUpdateForScene(scene: SKScene) {

        if scene is DisplayScene {
            let displayScene = scene as! DisplayScene
                displayScene.refreshIndication()
                planePosition = displayScene.planePosition
                heading = displayScene.heading.radians
                airspeed = displayScene.airspeed
            if inAir {
                    if navArm {
                        if !navOn {
                            captureRoute()
                        } else {
                            lateralNavigation()
                    }
                }
            }
        }
    }
}




