//
//  FlightPlan.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/15.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(FlightPlan) class FlightPlan: NSManagedObject {

    @NSManaged var arrive: String
    @NSManaged var departure: String
    @NSManaged var destination: String
    @NSManaged var distance: NSNumber
    @NSManaged var flightNO: String
    @NSManaged var name: String
    @NSManaged var origin: String
    @NSManaged var takeoff: String
    @NSManaged var approach: String
    @NSManaged var performance: Performance
    @NSManaged var waypoint: NSOrderedSet

}
