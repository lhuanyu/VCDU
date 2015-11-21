//
//  Runaway.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/15.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(Runaway) class Runaway: NSManagedObject {

    @NSManaged var heading: NSNumber
    @NSManaged var isDepatrure: NSNumber
    @NSManaged var length: NSNumber
    @NSManaged var name: String
    @NSManaged var unique: String
    @NSManaged var airport: Airport
    @NSManaged var plan: NSOrderedSet
    @NSManaged var procedure: NSOrderedSet

}
