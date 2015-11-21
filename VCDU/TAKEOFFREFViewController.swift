//
//  TAKEOFFREFViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/4.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class TAKEOFFREFViewController: CDUViewController {
    
    var takeoff:Takeoff? {
        return firstPlan?.performance.takeoff
    }

    
    override func updateUI() {
        if let runawayCondition = NSUserDefaults.standardUserDefaults().valueForKey("Runaway Condition") as? Bool {
            isDry = runawayCondition
        } else {
            isDry = true
        }
        
        if let apr = NSUserDefaults.standardUserDefaults().valueForKey("Auto Thrust Reserved") as? Bool {
            isArmed = apr
        } else {
            isArmed = true
        }
        
        if let flex = NSUserDefaults.standardUserDefaults().valueForKey("Flex Takeoff") as? Bool {
            isFlex = flex
        } else {
            isFlex = true
        }
        
        updateData()

    }
    
    override func updateData() {
        
        lines[1].leftTitle = firstPlan!.takeoff
        if let origin = Airport.airport(name: firstPlan!.origin, context: firstPlan!.managedObjectContext!) {
            if let takeoffRW = Runaway.runaway(name: firstPlan!.takeoff,airport:origin ,context: firstPlan!.managedObjectContext!) {
                lines[3].leftTitle = "\(takeoffRW.length.integerValue) M"
            }
        } else {
            lines[3].leftTitle = ""
        }
        
        if let slope = takeoff?.runawaySlope {
            lines[4].leftTitle = slopeFormatter.stringFromNumber(slope)! + "%"
        } else {
            lines[4].leftTitle = "−−.−%"
        }
        
        if let oat = takeoff?.performance.n1.oat {
            if let temp  = tempFormatter.stringFromNumber(oat) {
                lines[2].rightTitle = temp + "° C"
            }
        } else {
             lines[2].rightTitle =  "☐☐☐° C"
        }
        
        if let flex = takeoff?.performance.n1.flextemp {
            if let temp  = tempFormatter.stringFromNumber(flex) {
                lines[3].rightTitle = temp + "°"
            }
        } else {
            lines[3].rightTitle =  "−−−°"
        }
        
        if let angle = takeoff?.windAngle, let speed = takeoff?.windSpeed {
            lines[1].rightTitle = windFormatter.stringFromNumber(angle)! + "° / " + windFormatter.stringFromNumber(speed)!
        } else {
            lines[1].rightTitle = "−−−° / −−−"
        }
    }
    
    let lengthFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = " "
        formatter.formatWidth = 5
        return formatter
    }()
    
    let slopeFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 4
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        formatter.positivePrefix = "U"
        formatter.negativePrefix = "D"
        return formatter
    }()
    
    let windFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 3
        return formatter
    }()
    
    let tempFormatter:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 3
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        return formatter
        
        }()
    
    
    override func pressL4() {
        super.pressL4()
        if !isDeleting {
                if let slope = NSNumberFormatter().numberFromString(note)?.doubleValue {
                    if slope > -10 && slope < 10 {
                        takeoff?.runawaySlope = slope
                    }
                }
        } else {
            takeoff?.setNilValueForKey("runawaySlope")
        }
        updateData()
    }
    
    override func pressR1() {
        super.pressR1()
        if !isDeleting {
            let data = note.componentsSeparatedByString("/")
                    if data.count == 2 {
                        if let windAngle = NSNumberFormatter().numberFromString(data.first!)?.integerValue, let windSpeed = NSNumberFormatter().numberFromString(data.last!)?.integerValue  {
                            if windAngle < 359 && windAngle > -1 && windSpeed > 0 && windSpeed < 100 {
                                isTyping = false
                                takeoff?.windSpeed = windSpeed
                                takeoff?.windAngle = windAngle
                            }
                        }
                    }
        } else {
            takeoff?.setNilValueForKey("windSpeed")
            takeoff?.setNilValueForKey("windAngle")
        }
        updateData()
    }
    
    override func pressR2() {
        super.pressR2()
        if !isDeleting {
                if let oat = NSNumberFormatter().numberFromString(note)?.intValue {
                    if oat > -99 && oat < 99 {
                        takeoff?.performance.n1.oat = NSNumber(int: oat)
                        isTyping = false
                    }
                }
        } else {
            takeoff?.performance.n1.setNilValueForKey("oat")
        }
        updateData()

    }
    
    override func pressR3() {
        super.pressR3()
        if !isDeleting {
            if let oat = NSNumberFormatter().numberFromString(note)?.intValue {
                if oat > -99 && oat < 99 {
                    takeoff?.performance.n1.flextemp = NSNumber(int: oat)
                    isTyping = false
                }
            }
        } else {
            takeoff?.performance.n1.setNilValueForKey("flextemp")
        }
        updateData()
    }
    
    override func pressR4() {
        super.pressR4()
        isFlex = !isFlex
    }
    
    override func pressL5() {
        super.pressL5()
        isDry = !isDry
    }
    
    override func pressL6() {
        super.pressL6()
        isArmed = !isArmed
    }
    
    var isDry = true {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(isDry, forKey: "Runaway Condition")
            if isDry {
                lines[5].leftAttributeTitle = dryString
            } else {
                lines[5].leftAttributeTitle = wetString
            }
        }
    }
    
    let dryString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "DRY/WET")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 3))
        return displayString
        }()
    
    let wetString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "DRY/WET")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(4, 3))
        return displayString
        }()
    
    var isFlex = true {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(isFlex, forKey: "Flex Takeoff")
            if isFlex {
                lines[4].rightAttributeTitle = normalString
            } else {
                lines[4].rightAttributeTitle = flexString
            }
        }
        
    }
    
    let flexString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "NORM/FLEX")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 4))
        return displayString
        }()
    
    let normalString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "NORM/FLEX")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(5, 4))
        return displayString
        }()
    
    var isArmed = true {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(isArmed, forKey: "Auto Thrust Reserved")
            if isArmed {
                lines[6].leftAttributeTitle = notArmedString
            } else {
                lines[6].leftAttributeTitle = armedString
            }
        }
    }
    
    let notArmedString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "OFF/ARMED")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 3))
        return displayString
        }()
    
    let armedString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "OFF/ARMED")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(4, 5))
        return displayString
        }()
    
    
    
    
    override func prevKey(sender: UIButton) {
        super.prevKey(sender)
        if let count = navigationController?.viewControllers.count {
            if count > 3  {
                navigationController?.popViewControllerAnimated(false)
            } else if count == 3 {
                if let dvc = storyboard?.instantiateViewControllerWithIdentifier(CDUViewControllerID.TAKEOFFREFPAGE2) as? TAKEOFFREFPAGE2ViewController {
                    navigationController?.pushViewController(dvc, animated: false)
                    if let dvc = storyboard?.instantiateViewControllerWithIdentifier(CDUViewControllerID.TAKEOFFREFPAGE3) as? TAKEOFFREFPAGE3ViewController {
                        navigationController?.pushViewController(dvc, animated: false)
                        if let dvc = storyboard?.instantiateViewControllerWithIdentifier(CDUViewControllerID.TAKEOFFREFPAGE4) as? TAKEOFFREFPAGE4ViewController {
                            navigationController?.pushViewController(dvc, animated: false)
                        }
                    }
                }
            }
        }
    }
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if let identifer = sender.currentTitle {
            if let dvc: AnyObject = storyboard?.instantiateViewControllerWithIdentifier(identifer) {
                if dvc.isKindOfClass(TAKEOFFREFViewController) {
                    navigationController?.pushViewController(dvc as! TAKEOFFREFViewController, animated: false)
                }
            }
        } else {
            if let dvc = navigationController?.viewControllers[2] as? TAKEOFFREFViewController {
                navigationController?.popToViewController(dvc, animated: false)
            }
        }
    }
    
    
    

}
