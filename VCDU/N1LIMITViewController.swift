//
//  N1LIMITViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/5.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class N1LIMITViewController: CDUViewController {
    
    override func pressL1() {
        super.pressL1()
        let data = note.componentsSeparatedByString("/")
        if data.count == 2 {
            if let oat = NSNumberFormatter().numberFromString(data.first!)?.integerValue, let flex = NSNumberFormatter().numberFromString(data.last!)?.integerValue {
                if oat < flex {
                    firstPlan?.performance.n1.oat = oat
                    firstPlan?.performance.n1.flextemp = flex
                    updateUI()
                }
            }
        }
    }
    
    let tempFormatter:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 4
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        return formatter
        }()
    
    
    override func pressL2() {
        super.pressL2()
        isFlex = false
    }
    
    override func pressL3() {
        super.pressL3()
        isFlex = true
    }
    
    override func pressL4() {
        super.pressL3()
        if trMode < 2 {
            trMode += 1
        } else {
            trMode = 0
        }
    }

    override func pressL6() {
        super.pressL6()
        navigationController?.popViewControllerAnimated(false)
    }
    
    override func pressR6() {
        super.pressR6()
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("PERF INIT") as? PERFINITViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    
    
    var isFlex = false {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(isFlex, forKey: "Flex Takeoff")
            if isFlex {
                lines[3].leftTitleColor = UIColor.cduBlueColor()
                lines[3].leftTitleSize = 22
                lines[2].leftTitleColor = UIColor.whiteColor()
                lines[2].leftTitleSize = 20

            } else {
                lines[2].leftTitleColor = UIColor.cduBlueColor()
                lines[2].leftTitleSize = 22
                lines[3].leftTitleColor = UIColor.whiteColor()
                lines[3].leftTitleSize = 20
            }
        }
    }
    
    override func updateUI() {
        super.updateUI()
        if let flexStatus = NSUserDefaults.standardUserDefaults().valueForKey("Flex Takeoff") as? Bool {
            isFlex = flexStatus
        } else {
            isFlex = false
        }
        if let trStatus = NSUserDefaults.standardUserDefaults().valueForKey("T/R Mode") as? Int {
            trMode = trStatus
        } else {
            trMode = 0
        }
        
        
        var flexString = "−−−−"
        var oatString = "☐☐☐☐"
        if let oat = firstPlan?.performance.n1.oat {
            oatString  = tempFormatter.stringFromNumber(oat) ?? "☐☐☐☐"
        }
        if let flex = firstPlan?.performance.n1.flextemp {
            flexString  = tempFormatter.stringFromNumber(flex) ?? "−−−−"
        }
        lines[1].leftTitle = oatString + "° C/" + flexString + "° C"

    }
    
    var trMode:Int = 0 {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(trMode, forKey: "T/R Mode")
            if trMode == 0 {
                lines[4].leftAttributeTitle = offString
            } else if trMode == 1 {
                lines[4].leftAttributeTitle = altString
            } else {
                lines[4].leftAttributeTitle = flapString
            }
        }
    }
    
    let offString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "OFF/ALT/FLAP")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 3))
        return displayString
        }()
    let altString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "OFF/ALT/FLAP")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(4, 3))
        return displayString
        }()
    let flapString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "OFF/ALT/FLAP")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(8, 4))
        return displayString
        }()

    

}
