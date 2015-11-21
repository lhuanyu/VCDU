//
//  Takeoff.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/7.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(Takeoff) class Takeoff: NSManagedObject {

    @NSManaged var cg: NSNumber
    @NSManaged var leveloffHeight: NSNumber
    @NSManaged var obstacleDistance: NSNumber
    @NSManaged var obstacleHeight: NSNumber
    @NSManaged var pAltitude: NSNumber
    @NSManaged var runawaySlope: NSNumber
    @NSManaged var runawayWind: NSNumber
    @NSManaged var tofl: NSNumber
    @NSManaged var windAngle: NSNumber
    @NSManaged var windSpeed: NSNumber
    @NSManaged var performance: Performance

}
