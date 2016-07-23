//
//  TAKEOFFREFPAGE2ViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/5.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class TAKEOFFREFPAGE2ViewController: TAKEOFFREFViewController {
    
    override func pressL1() {
        keySoundPlayer.play()
        if !isDeleting {
            if let cg = NSNumberFormatter().numberFromString(note)?.integerValue {
                if cg > 20 && cg < 40 {
                    isTyping = false
                    takeoff?.cg = cg
                }
            }
        } else {
            takeoff?.setNilValueForKey("cg")
            isDeleting = false
        }
        updateData()
    }

    override func pressL5() {
        keySoundPlayer.play()
        if engBleed < 2{
            engBleed += 1
        } else {
            engBleed = 0
        }
    }
    
    override func pressL6() {
        keySoundPlayer.play()
        v2Mode = !v2Mode
    }
    

    
    override func updateUI() {

        if let bleed = NSUserDefaults.standardUserDefaults().valueForKey("Engine Bleed") as? Int {
            engBleed = bleed
        } else {
            engBleed = 0
        }
        
        if let v2 = NSUserDefaults.standardUserDefaults().valueForKey("v2 Mode") as? Bool {
            v2Mode = v2
        } else {
            v2Mode = true
        }
        
        updateData()
    }
    
    override func updateData() {
        if let cg = takeoff?.cg {
            lines[1].leftTitle = "\(cg.integerValue)" + " %"
        } else {
            lines[1].leftTitle = "−− %"
        }
    }
    
    var v2Mode = true {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(v2Mode, forKey: "v2 Mode")
            if v2Mode {
                lines[6].leftAttributeTitle = normString
            } else {
                lines[6].leftAttributeTitle = incString
            }
        }
    }
    

    
    var engBleed:Int = 0 {
        didSet {
            NSUserDefaults.standardUserDefaults().setInteger(engBleed, forKey: "Engine Bleed")
            if engBleed == 0 {
                lines[5].attributeTitle = offString
            } else if engBleed == 1 {
                lines[5].attributeTitle = naiOnString
            } else {
                lines[5].attributeTitle = wnOnString
            }
        }
    }
    
    let normString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "NORM/INC")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 4))
        return displayString
        }()
    
    let incString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "NORM/INC")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(5, 3))
        return displayString
        }()
    
    let offString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "OFF/NAI ON/WAI+NAI ON")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 3))
        return displayString
        }()
    let naiOnString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "OFF/NAI ON/WAI+NAI ON")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(4, 6))
        return displayString
        }()
    let wnOnString:NSAttributedString = {
        let displayString = NSMutableAttributedString(string: "OFF/NAI ON/WAI+NAI ON")
        displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(11, 10))
        return displayString
        }()

    
}
