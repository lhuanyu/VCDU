//
//  Performance.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/12.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(Performance) class Performance: NSManagedObject {

    @NSManaged var altnAltitude: NSNumber
    @NSManaged var cargo: NSNumber
    @NSManaged var crzAltitude: NSNumber
    @NSManaged var passengerNumber: NSNumber
    @NSManaged var passengerWeight: NSNumber
    @NSManaged var unique: String
    @NSManaged var cruiseWindSpeed: NSNumber
    @NSManaged var climbWindSpeed: NSNumber
    @NSManaged var cruiseWindAngle: NSNumber
    @NSManaged var climbWindAngle: NSNumber
    @NSManaged var descentWindSpeed: NSNumber
    @NSManaged var descentWindAngle: NSNumber
    @NSManaged var approach: Approach
    @NSManaged var fuel: FuelManagement
    @NSManaged var n1: N1Limit
    @NSManaged var plan: FlightPlan
    @NSManaged var takeoff: Takeoff
    @NSManaged var vnav: Vnav

}
