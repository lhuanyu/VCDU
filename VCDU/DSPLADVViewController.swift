//
//  DSPLADVViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/1.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class DSPLADVViewController: CDUViewController {
    
    override func pressL1() {
        super.pressL1()
        if let mfdvc = splitViewController?.viewControllers.last as? MFDViewController {
            mfdvc.prevWaypoint()
        }
    }

    override func pressL2() {
        super.pressL2()
        if let mfdvc = splitViewController?.viewControllers.last as? MFDViewController {
            mfdvc.nextWaypoint()
        }
    }
    
    
    override func pressR6() {
        super.pressR6()
        isLeft = !isLeft
    }
    
    override func updateUI() {
        super.updateUI()
        
        if let displayStatus = NSUserDefaults.standardUserDefaults().valueForKey("MFD Display") as? Bool {
            isLeft = displayStatus
        } else {
            NSUserDefaults.standardUserDefaults().setBool(isLeft, forKey: "MFD Display")
            isLeft = false
        }
    }
    
    var isLeft = false {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(isLeft, forKey: "MFD Display")
            if isLeft {
                let displayString = NSMutableAttributedString(string: "L/R")
                displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 1))
                lines[6].rightAttributeTitle = displayString
                lines[0].leftTitle = "LEFT"
            } else {
                let displayString = NSMutableAttributedString(string: "L/R")
                displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(2, 1))
                lines[6].rightAttributeTitle = displayString
                lines[0].leftTitle = "RIGHT"
            }
        }
    }
    
    
        
}
