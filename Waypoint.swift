//
//  Waypoint.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/7.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(Waypoint) class Waypoint: NSManagedObject {

    @NSManaged var identifier: NSNumber
    @NSManaged var isAirport: NSNumber
    @NSManaged var isCreatedByPilot: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var name: String
    @NSManaged var navigation: NSNumber
    @NSManaged var status: NSNumber
    @NSManaged var plan: NSSet
    @NSManaged var procedure: NSOrderedSet

}
