//
//  LEGSViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/4/10.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit
import CoreLocation

class LEGSViewController: CDUViewController {
    
    private struct Constant {
        static let THEN = "   THEN"
        static let DISCONT = "☐☐☐☐☐       −  DISCONTINUITY  −    "
        static let CANCEL = "<CANCEL MOD"
        static let RWY = "<RWY UPDATE"
        static let CustomizedPointsCount = "CustomizedPointsCount"
    }

    //MARK: - Computed Varibles -
    var originRunaway:Waypoint?
    {
        if let point = Waypoint.waypoint(name: firstPlan!.origin + firstPlan!.takeoff, context: firstPlan!.managedObjectContext!){
                    return point
            }
        return nil
    }
    
    
    var departure:[Waypoint]? {
        didSet {
            if departure != nil && oldValue != nil {
                if departure! != oldValue! {
                    route = conectRoute()
                }
            } else {
                route = conectRoute()
            }
        }
    }
    var star:[Waypoint]? {
        didSet {
            if star != nil && oldValue != nil {
                if star! != oldValue! {
                    route = conectRoute()
                }
            } else {
                route = conectRoute()
            }
        }
    }
    var approach:[Waypoint]? {
        didSet {
            if approach != nil && oldValue != nil {
                if approach! != oldValue! {
                    route = conectRoute()
                }
            } else {
                route = conectRoute()
            }
        }
    }
    
    
    func conectRoute() -> [Waypoint?]? {
        var waypointsList:[Waypoint?]?
        if originRunaway != nil {
            waypointsList = [originRunaway!]

            if departure != nil {
                for point in departure! {
                    waypointsList?.append(point)
                }
            }
            
            if star != nil {
                waypointsList?.append(nil)
                for point in star! {
                    waypointsList?.append(point)
                }
            }
            
            if approach != nil {
                waypointsList?.append(nil)
                for point in approach! {
                    waypointsList?.append(point)
                }
            }
        }
        return waypointsList
    }
    
    var currentLeg = 0 {
        didSet {
            updatePage()
        }
    }
    
    var route:[Waypoint?]? {
        didSet {
            updatePage()
            if let mfdvc = splitViewController?.viewControllers.last as? MFDViewController {
                if undoRoute != nil {
                    mfdvc.modifyingRoute = route
                } else {
                    mfdvc.route = route
                }
            }
        }
    }
    
    var undoRoute:[Waypoint?]? {
        didSet {
            if undoRoute != nil {
                isModifying = true
                isTyping = false
                lines[6].leftTitle = Constant.CANCEL
            } else if let mfdvc = splitViewController?.viewControllers.last as? MFDViewController {
                mfdvc.route = route
                mfdvc.modifyingRoute = nil
            }

        }
    }
    
    //MARK: - Modify Legs -
    
    @IBAction func modifyLegs(sender: UIButton) {
        if route != nil && sender.currentTitle != nil {
            if let index = Int(sender.currentTitle!) {
                let insertingIndex = 5 * (currentPage - 1) + index - 1
                if note == "" {//copy waypoint to the note
                    if lines[index].leftTitle != "" {
                        note = lines[index].leftTitle
                    }
                } else if let i = findWaypoint(note).1 {// delete DISCONT or directly connect 2 waypoints
                    if i > insertingIndex {
                        undoRoute = route
                        route!.removeRange(insertingIndex...i-1)
                    }
                } else { //validate the input from note, modify the current route
                    if insertingIndex > 0  { //assure the waypoint will be inserted after the airport
                        if lines[index].title != Constant.DISCONT {
                            //Latitude and longtidute withou a name
                            let data = note.componentsSeparatedByString("/")
                            if data.count == 1 {
                                insertLatLongPoint(note, atIndex: index)
                            } else if data.count == 2 {//PBD,PB/PB, or PD without a name,
                                if let identity = data.first, distance = NSNumberFormatter().numberFromString(data.last!)?.doubleValue {
                                    if !insertPDWaypoint(point: identity, distance: distance) {
                                        insertPBDWaypoint(pointAndBearing: identity, distance: distance, atIndex:insertingIndex)
                                    }
                                }
                                if let firstInfo = data.first, secondInfo = data.last {//LatLong with a name
                                    if !insertPBPBWaypoint(firstPointAndBearing: firstInfo, secondPointAndBearing: secondInfo, atIndex: insertingIndex) {
                                        insertLatLongPoint(firstInfo,newPointName:secondInfo,atIndex:insertingIndex)
                                    }
                                }
                            } else if data.count == 3 {//PBD and PD with a name
                                if let identity = data.first, distance = NSNumberFormatter().numberFromString(data[1])?.doubleValue, name = data.last {
                                    if !insertPBDWaypoint(pointAndBearing: identity, distance: distance, newPointName: name, atIndex:insertingIndex) {
                                        insertPDWaypoint(point: identity, distance: distance, newPointName: name)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    private func insertLatLongPoint(latAndLong:String,newPointName name:String = "",atIndex index:Int) -> Bool {
        if let lat = extractDataFromInput(latAndLong).lat, let long = extractDataFromInput(latAndLong).long {
            if let waypoint = route?[index] {
                let identity = waypoint.name.componentsSeparatedByString(" ").first!
                let newName = name != "" ? name : identity + " " + identityFormatter.stringFromNumber(customizedPointsCount)!
                if let newWaypoint = waypoint.createWaypoint(lat, longitude: long, name:newName) {
                    customizedPointsCount += 1
                    undoRoute = route
                    route?.insert(newWaypoint, atIndex: index)
                    return true
                }
            }
        }
        return false
    }
    
    private func insertPBPBWaypoint(firstPointAndBearing id1:String,secondPointAndBearing id2:String,newPointName name:String = "",atIndex index:Int) -> Bool {
        
        let firstPointName = id1.substringToIndex(id1.endIndex.advancedBy(-3))
        let secondPointName = id2.substringToIndex(id2.endIndex.advancedBy(-3))
        let bearing1String = id1.substringFromIndex(id1.endIndex.advancedBy(-3))
        let bearing2String = id2.substringFromIndex(id2.endIndex.advancedBy(-3))
        
        let newName = name != "" ? name : route![index]!.name + " " + identityFormatter.stringFromNumber(customizedPointsCount)!
        if let waypoint1 = findWaypoint(firstPointName).0, let waypoint2 = findWaypoint(secondPointName).0 {
            if let bearing1 = NSNumberFormatter().numberFromString(bearing1String)?.doubleValue, bearing2 = NSNumberFormatter().numberFromString(bearing2String)?.doubleValue {
                if let newWaypoint = waypoint1.createWaypoint(bearing1, antherWaypoint: waypoint2, bearing2: bearing2, name: newName) {
                    customizedPointsCount += 1
                    undoRoute = route
                    route?.insert(newWaypoint, atIndex: index)
                }
                return true
            }
        }
        return false
    }
    
    private func insertPBDWaypoint(pointAndBearing identity:String,distance:Double,newPointName name:String = "",atIndex index:Int) -> Bool {
        let bearingIndex = identity.endIndex.advancedBy(-3)
        let id = identity.substringToIndex(bearingIndex)
        let newName = name != "" ? name : id + " " + identityFormatter.stringFromNumber(customizedPointsCount)!
        if let waypoint = findWaypoint(id).0 {
            if let bearing = NSNumberFormatter().numberFromString(identity.substringFromIndex(bearingIndex))?.doubleValue {
                if bearing < 361 && bearing > -1 {
                    if let newPoint = waypoint.createWaypointWith(bearing, distance: distance, name: newName) {
                        undoRoute = route
                        route?.insert(newPoint, atIndex: index)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func insertPDWaypoint(point identity:String,distance:Double,newPointName name:String = "") -> Bool {
        if let waypoint = findWaypoint(identity).0 , i = findWaypoint(identity).1 {
            let newName = name != "" ? name : identity + " " + identityFormatter.stringFromNumber(customizedPointsCount)!
            var bearing = 0.0
            if distance > 0 {
                if i < route!.count - 1{
                    bearing = Waypoint.legInfo(firstPoint: route![i]!, secondPoint:route![i+1]!).heading
                    let distanceLimitation = Waypoint.legInfo(firstPoint: route![i]!, secondPoint:route![i+1]!).distance
                    if distance < distanceLimitation {
                        if let newPoint = waypoint.createWaypointWith(bearing, distance: distance, name: newName) {
                            undoRoute = route
                            route?.insert(newPoint, atIndex: i + 1)
                            return true
                        }
                    }
                }
            } else {
                if i > 0 {
                    bearing = Waypoint.legInfo(firstPoint: route![i]!, secondPoint:route![i-1]!).heading  + 180
                    let distanceLimitation = Waypoint.legInfo(firstPoint: route![i]!, secondPoint:route![i-1]!).distance
                    if distance > -distanceLimitation {
                        if let newPoint = waypoint.createWaypointWith(bearing, distance: distance, name: newName) {
                            undoRoute = route
                            route?.insert(newPoint, atIndex: i)
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    
    private func extractDataFromInput(latAndLong:String) -> (lat:Double?,long:Double?) {
        var lat:Double?
        var long:Double?
        var string = latAndLong
        var signLat = 1.0
        var signLong = 1.0
        
        if latAndLong.characters.count == 5 || latAndLong.characters.count == 6 {//simplified lat and long
            if let range = latAndLong.rangeOfString("N") {
                signLong = -1.0
                string.removeAtIndex(range.startIndex)
            } else if let range = latAndLong.rangeOfString("E") {
                string.removeAtIndex(range.startIndex)
            } else if let range = latAndLong.rangeOfString("S") {
                signLat = -1.0
                string.removeAtIndex(range.startIndex)
            } else if let range = latAndLong.rangeOfString("W") {
                signLat = -1.0
                signLong = -1.0
                string.removeAtIndex(range.startIndex)
            }
            if let unsignedLat = Int(string.substringToIndex(string.startIndex.advancedBy(2)))?.double {
                lat = unsignedLat * signLat
            }
            if let unsignedLong = Int(string.substringFromIndex(string.startIndex.advancedBy(2)))?.double {
                long = unsignedLong * signLong
            }
        } else {//complete lat and long
            if latAndLong.rangeOfString("W") != nil || latAndLong.rangeOfString("E") != nil {
                let range = latAndLong.rangeOfString("W") ?? latAndLong.rangeOfString("E")!
                let latString = latAndLong.substringToIndex(range.startIndex)
                let longString = latAndLong.substringFromIndex(range.startIndex)
                if latString.characters.count == 3 {
                    signLat = latString.rangeOfString("N") != nil ? 1.0 : -1.0
                    if let degree = NSNumberFormatter().numberFromString(String(latString.characters.dropFirst()))?.doubleValue {
                        lat = degree * signLat
                    }
                } else if latString.characters.count > 3 {
                    let miniuteIndex = latString.startIndex.advancedBy(3)
                    if let miniute = NSNumberFormatter().numberFromString(latString.substringFromIndex(miniuteIndex))?.doubleValue {
                        signLat = latString.rangeOfString("N") != nil ? 1.0 : -1.0
                        if let degree = NSNumberFormatter().numberFromString(String(latString.characters.dropFirst()).substringToIndex(miniuteIndex.predecessor()))?.doubleValue {
                            lat = (degree + miniute/60) * signLat
                        }
                    }
                }
                
                if longString.characters.count == 4 {
                    signLong = longString.rangeOfString("E") != nil ? 1.0 : -1.0
                    if let degree = NSNumberFormatter().numberFromString(String(longString.characters.dropFirst()))?.doubleValue {
                        long = degree * signLong
                    }
                } else if longString.characters.count > 4 {
                    signLong = longString.rangeOfString("E") != nil ? 1.0 : -1.0
                    let miniuteIndex = longString.startIndex.advancedBy(4)
                    if let miniute = NSNumberFormatter().numberFromString(longString.substringFromIndex(miniuteIndex))?.doubleValue {
                        if let degree = NSNumberFormatter().numberFromString(String(longString.characters.dropFirst()).substringToIndex(miniuteIndex.predecessor()))?.doubleValue {
                            long = (degree + miniute/60) * signLong
                        }
                    }
                }
            }
        }
        return (lat,long)
    }
    
    private var customizedPointsCount:UInt  {
        get {
            if let count = NSUserDefaults.standardUserDefaults().valueForKey(Constant.CustomizedPointsCount) as? NSNumber {
                return UInt(count.unsignedIntegerValue)
            }
            NSUserDefaults.standardUserDefaults().setValue(1, forKey: Constant.CustomizedPointsCount)
            return 1
        }
        set {
            NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: Constant.CustomizedPointsCount)
        }
    }
    
    private func findWaypoint(name:String) -> (Waypoint?,Int?) {
        for i in 0...route!.count - 1 {
            if let waypoint = route![i] {
                if name == waypoint.name {
                    return (route![i] , i)
                }
            }
        }
        return (nil,nil)
    }
    
    let identityFormatter:NSNumberFormatter =  {
        let formatter = NSNumberFormatter()
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 2
        return formatter
    }()
    
    //MARK: - UI setup -
    override func updateUI() {
        if let mfdvc = splitViewController?.viewControllers.last as? MFDViewController {
            if let DisplayScene = mfdvc.display.scene as? DisplayScene {
                let center = NSNotificationCenter.defaultCenter()
                let queue = NSOperationQueue.mainQueue()
                center.addObserverForName(APOder.APNotificaton, object: DisplayScene.delegate, queue: queue, usingBlock: { [unowned self] notification in
                    if let leg = notification.userInfo?[APOder.UpdateLegIndex] as? Int {
                        self.currentLeg = leg
                    }
                    })
            }
        }
        
        if firstPlan != nil  {
            departure = firstPlan?.dep()
            star = firstPlan?.star()
            approach = firstPlan?.app()
            lines[0].title = "    LEGS      " + firstPlan!.flightNO
            if route != nil {
                totalPage = Int(ceil(Double(route!.count) / 5))
            } else {
                totalPage = 1
                currentPage = 1
            }
        } else {
            route = nil
            totalPage = 1
            currentPage = 1
        }
    }
    var totalPage:Int = 1 {
        didSet {
            updatePage()
        }
    }
    var currentPage:Int = 1 {
        didSet {
            updatePage()
        }
    }
    
    
    let angleFormatter:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 3
        return formatter
        }()
    
    let distanceFormatter:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 3
        return formatter
        }()
    
    private func updatePage()
    {
        lines[0].rightTitle = "\(currentPage)/\(totalPage)"
        for  i in 1...5 {
            lines[i].clear()
            let index = (currentPage-1) * 5 + i - 1
            if route != nil {
                if index < route!.count {
                    if currentPage == 1 {
                        lines[1].rightSubtitle = "SEQUENCE"
                        let displayString = NSMutableAttributedString(string: "AUTO/INHIBIT")
                        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 4))
                        lines[1].rightAttributeTitle = displayString
                    }
                    
                    if index == currentLeg {
                        lines[i].leftTitleColor = UIColor.cduBlueColor()
                        lines[i].subtitleColor = UIColor.whiteColor()
                    } else if index == currentLeg + 1 {
                        lines[i].leftTitleColor = UIColor.magentaColor()
                        lines[i].subtitleColor = UIColor.magentaColor()
                    } else {
                        lines[i].leftTitleColor = UIColor.whiteColor()
                        lines[i].leftSubtitleColor = UIColor.whiteColor()
                        lines[i].subtitleColor = UIColor.whiteColor()
                        
                    }
                    if let point = route![index] {
                        lines[i].leftTitle = point.name
                        if index > 0 {
                            if let prevPoint = route![index - 1] {
                                let angle = Waypoint.legInfo(firstPoint: prevPoint, secondPoint: point).heading
                                let distance = Waypoint.legInfo(firstPoint: prevPoint, secondPoint: point).distance
                                if let angleString = angleFormatter.stringFromNumber(angle) {
                                    let distanceString = String(format: "%.1f NM",distance)
                                    lines[i].subtitle = " " + angleString + "°  " + distanceString
                                }
                                lines[i].rightAttributeTitle = NSAttributedString(string: "−−−/−−−−−", attributes: [NSForegroundColorAttributeName:UIColor.yellowColor()])
                            }
                        }
                    } else {
                        //discontinuity
                        lines[i].titleAlignment = 0
                        lines[i].subtitle = Constant.THEN
                        lines[i].title = Constant.DISCONT
                    }
                } else {
                    lines[i].clear()
                }
            }
        }
    }

    
    //MARK: - Function keys -
    
    override func pressL6() {
        super.pressL6()
        if isModifying && undoRoute != nil {
            route = undoRoute
            undoRoute = nil
            isModifying = false
            customizedPointsCount -= 1
            lines[6].leftTitle = Constant.RWY
        }
    }
    
    override func execButtton() {
        super.execButtton()
        if undoRoute != nil {
            undoRoute = nil
            lines[6].leftTitle = Constant.RWY
            isModifying = false
        }
    }
    
    override func prevKey(sender: UIButton) {
        super.prevKey(sender)
        if currentPage > 1 && route != nil {
            currentPage -= 1
        }
    }
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if currentPage < totalPage && route != nil  {
            currentPage += 1
        }
    }
   
}


