//
//  Procedure.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/15.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(Procedure) class Procedure: NSManagedObject {

    @NSManaged var isDeparture: NSNumber
    @NSManaged var name: String
    @NSManaged var airport: Airport
    @NSManaged var plan: NSOrderedSet
    @NSManaged var runaway: NSOrderedSet
    @NSManaged var waypoint: NSOrderedSet

}
