//
//  Airport.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/15.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(Airport) class Airport: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var name: String
    @NSManaged var procedure: NSOrderedSet
    @NSManaged var runaway: NSOrderedSet

}
