//
//  N1Limit.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/7.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import CoreData

@objc(N1Limit) class N1Limit: NSManagedObject {

    @NSManaged var flextemp: NSNumber
    @NSManaged var n1Ref: NSNumber
    @NSManaged var oat: NSNumber
    @NSManaged var performance: Performance

}
