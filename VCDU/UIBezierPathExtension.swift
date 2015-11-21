//
//  UIBezierPathExtension.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/7/22.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

extension UIBezierPath {
    class func bezierPathForStarMark(center point: CGPoint,size:CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        
        
        let point1 = CGPointMake(point.x, point.y + size)
        let point2 = CGPointMake(point.x + size, point.y)
        let point3 = CGPointMake(point.x, point.y - size)
        let point4 = CGPointMake(point.x - size, point.y)
        
        
        let point12 = CGPointMake(point.x + size / 4, point.y + size / 4)
        let point23 = CGPointMake(point.x + size / 4, point.y - size / 4)
        let point34 = CGPointMake(point.x - size / 4, point.y - size / 4)
        let point41 = CGPointMake(point.x - size / 4, point.y + size / 4)
        
        path.moveToPoint(point1)
        path.addLineToPoint(point12)
        path.addLineToPoint(point2)
        path.addLineToPoint(point23)
        path.addLineToPoint(point3)
        path.addLineToPoint(point34)
        path.addLineToPoint(point4)
        path.addLineToPoint(point41)
        path.closePath()
        
        
        return path
    }
    
    
    class func bezierPathForAirplane(center:CGPoint,size:CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let point1 = CGPointMake(center.x - size/8, center.y + size/2)
        let point2 = CGPointMake(center.x - size/8, center.y + size/8)
        let point3 = CGPointMake(center.x - size/2, center.y - size/8)
        let point4 = CGPointMake(point3.x, point3.y - size/8)
        let point5 = CGPointMake(point2.x, point3.y)
        let point6 = CGPointMake(point5.x, point5.y - size/4)
        let point7 = CGPointMake(point6.x - size/6, point6.y-size/8)
        let point8 = CGPointMake(point7.x, point7.y - size/8)
        let point9 = CGPointMake(center.x, point8.y + size/16)
        
        let point11 = CGPointMake(center.x + size/8, center.y + size/2)
        let point22 = CGPointMake(center.x + size/8, center.y + size/8)
        let point33 = CGPointMake(center.x + size/2, center.y - size/8)
        let point44 = CGPointMake(point33.x, point33.y - size/8)
        let point55 = CGPointMake(point22.x, point33.y)
        let point66 = CGPointMake(point55.x, point55.y - size/4)
        let point77 = CGPointMake(point66.x + size/6, point66.y-size/8)
        let point88 = CGPointMake(point77.x, point77.y - size/8)
        path.moveToPoint(point1)
        path.addLineToPoint(point2)
        path.addLineToPoint(point3)
        path.addLineToPoint(point4)
        path.addLineToPoint(point5)
        path.addLineToPoint(point6)
        path.addLineToPoint(point7)
        path.addLineToPoint(point8)
        path.addLineToPoint(point9)
        path.addLineToPoint(point88)
        path.addLineToPoint(point77)
        path.addLineToPoint(point66)
        path.addLineToPoint(point55)
        path.addLineToPoint(point44)
        path.addLineToPoint(point33)
        path.addLineToPoint(point22)
        path.addLineToPoint(point22)
        path.addLineToPoint(point11)
        path.moveToPoint(point1)
        path.addArcWithCenter(CGPoint(x: center.x, y: center.y + size/2), radius: size/8, startAngle:CGFloat(-M_PI), endAngle: 0, clockwise: false)
        
        return path
    }
}
