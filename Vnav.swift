//
//  Vnav.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/7.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(Vnav) class Vnav: NSManagedObject {

    @NSManaged var crzAltitude: NSNumber
    @NSManaged var tansAltitude: NSNumber
    @NSManaged var tansFlightLevel: NSNumber
    @NSManaged var performance: Performance

}
