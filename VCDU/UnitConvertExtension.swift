//
//  UnitConvertExtension.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/7/22.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

let PI:CGFloat = 3.14159265358979323846264338327950288
let HSI_RADIUS:Double = 150
let SCALE_FACTOR = 1e4/(12.8/208*HSI_RADIUS)

extension CGFloat {
    
    var radians:CGFloat {
        return PI * self / 180.0
    }
    var degree:CGFloat {
        return self / PI * 180.0
    }
    
    var double:Double {
        return Double(self)
    }
    
    
}


extension Double {
    
    var radians:Double {
        return M_PI * self / 180.0
    }
    var degree:Double {
        return self / M_PI * 180.0
    }
    
    var cgfloat:CGFloat {
        return CGFloat(self)
    }
    
    var int:Int {
        return Int(self)
    }
    
}

extension Int {
    
    var cgfloat:CGFloat {
        return CGFloat(self)
    }
    var double:Double {
        return Double(self)
    }
}

extension CGPoint {
    var coordinate:CLLocationCoordinate2D {
        let mapPoint = MKMapPointMake(Double(self.x) * SCALE_FACTOR,-Double(self.y) * SCALE_FACTOR)
        let coordinate = MKCoordinateForMapPoint(mapPoint)
        return coordinate
    }
    var mapPoint:MKMapPoint {
        let point = MKMapPointMake(Double(self.x) * SCALE_FACTOR,-Double(self.y) * SCALE_FACTOR)
        return point
    }
}

infix operator - { associativity left precedence 140}
func - (left:CGPoint,right:CGPoint) -> CGPoint {
    return CGPointMake(left.x-right.x,left.y-right.y)
}

infix operator + { associativity left precedence 140}
func + (left:CGPoint,right:CGPoint) -> CGPoint {
    return CGPointMake(left.x+right.x,left.y+right.y)
}

infix operator * { associativity left precedence 140}
func * (left:CGPoint,right:CGFloat) -> CGPoint {
    return CGPointMake(left.x*right,left.y*right)
}

infix operator / { associativity left precedence 140}
func / (left:CGPoint,right:CGFloat) -> CGPoint {
    return CGPointMake(left.x/right,left.y/right)
}
