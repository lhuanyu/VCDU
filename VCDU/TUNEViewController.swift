//
//  TUNEViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/6.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class TUNEViewController: CDUViewController {
    
    struct Constant {
        static let LeftTuneStatus = "Tune Status1"
        static let RightTuneStatus = "Tune Status2"

        
    }

    override func pressL4() {
        super.pressL4()
        isAutoLeft = !isAutoLeft
    }
    
    override func pressR4() {
        super.pressR4()
        isAutoRight = !isAutoRight
    }
    
    override func updateUI() {
        super.updateUI()
        
        if let tuneStatus = NSUserDefaults.standardUserDefaults().valueForKey(Constant.LeftTuneStatus) as? Bool {
            isAutoLeft = tuneStatus
        } else {
            isAutoLeft = false
        }
        
        if let tuneStatus = NSUserDefaults.standardUserDefaults().valueForKey(Constant.RightTuneStatus) as? Bool {
            isAutoRight = tuneStatus
        } else {
            isAutoRight = false
        }

    }
    
    var isAutoLeft = false {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(isAutoLeft, forKey: Constant.LeftTuneStatus)
            if isAutoLeft {
                lines[4].leftAttributeTitle = autoString
            } else {
                lines[4].leftAttributeTitle = manString
            }
        }
    }
    
    var isAutoRight = false {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(isAutoRight, forKey: Constant.RightTuneStatus)
            if isAutoRight {
                lines[4].rightAttributeTitle = autoString
            } else {
                lines[4].rightAttributeTitle = manString
            }
        }
    }
    
    let autoString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "AUTO/MAN")
        displayString.addAttributes(DefaultConstant.cyanSelectedAttributes, range: NSMakeRange(0, 4))
        return displayString
    }()
    
    let manString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "AUTO/MAN")
        displayString.addAttributes(DefaultConstant.cyanSelectedAttributes, range: NSMakeRange(5, 3))
        return displayString
        }()
    
    
}
