//
//  PERFINITPAGE2ViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/3.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class PERFINITPAGE2ViewController: CDUViewController {
    
    
    override func pressL2() {
        super.pressL2()
        if !isDeleting {
            if let isaDev = NSNumberFormatter().numberFromString(note)?.integerValue {
                if isaDev > -99  && isaDev < 99 {
                    if let isa = tempFormatter.stringFromNumber(isaDev) {
                        lines[2].leftTitle = isa + "° C"
                    }
                }
            }
        } else {
            lines[2].leftTitle = "−−−° C"
            isDeleting = false
        }
    }
    
    let tempFormatter:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 3
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        return formatter
        
        }()
    
    let windFormatter:NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 3
        return formatter
        
        }()
    
    override func pressR1() {
        super.pressR1()
            if let angle = transInput(note).0 ,let speed = transInput(note).1 {
                firstPlan?.performance.climbWindAngle = angle
                firstPlan?.performance.climbWindSpeed = speed
            }
        updateData()
    }
    
    override func pressR2() {
        super.pressR2()
            if let angle = transInput(note).0 ,let speed = transInput(note).1 {
                firstPlan?.performance.cruiseWindAngle = angle
                firstPlan?.performance.cruiseWindSpeed = speed
            }
        updateData()
    }
    
    override func pressR3() {
        super.pressR3()
            if let angle = transInput(note).0 ,let speed = transInput(note).1 {
                firstPlan?.performance.descentWindAngle = angle
                firstPlan?.performance.descentWindSpeed = speed
            }
        updateData()
    }
    
    private func updateWind(windAngle:NSNumber?, windSpeed:NSNumber?,line:Int) {
        if let angle = windAngle, let speed = windSpeed {
            if angle.integerValue > 90 && angle.integerValue < 270 {
                lines[line].rightTitle = windFormatter.stringFromNumber(angle)! + "T / " + windFormatter.stringFromNumber(speed)!
            } else {
                lines[line].rightTitle = windFormatter.stringFromNumber(angle)! + "H / " + windFormatter.stringFromNumber(speed)!
            }
        } else {
            lines[line].rightTitle = "−−−T / −−−"
        }
    }
    
    private func updateISADev() {
        if let oat = firstPlan?.performance.n1.oat {
            let dev = oat.integerValue - 15
            lines[2].leftTitle = tempFormatter.stringFromNumber(dev)! + "° C"
        } else {
            lines[2].leftTitle = "−−−° C"
        }
    }
    
    override func updateData() {
        
        updateISADev()
        updateWind(firstPlan?.performance.climbWindAngle, windSpeed: firstPlan?.performance.climbWindSpeed, line: 1)
        updateWind(firstPlan?.performance.cruiseWindAngle, windSpeed: firstPlan?.performance.cruiseWindSpeed, line: 2)
        updateWind(firstPlan?.performance.descentWindAngle, windSpeed: firstPlan?.performance.descentWindSpeed, line: 3)

    }
    
    func transInput(input:String) -> (Int?,Int?) {
        var angle:Int?
        var speed:Int?
        if input.hasPrefix("H") || input.hasPrefix("M") {
            if let sp = NSNumberFormatter().numberFromString(String(String(input.characters.dropFirst())))?.integerValue {
                angle = 0
                speed = sp
            }
        } else if input.hasPrefix("T") || input.hasPrefix("P") {
            if let sp = NSNumberFormatter().numberFromString(String(String(input.characters.dropFirst())))?.integerValue {
                angle = 180
                speed = sp
            }
        }
        
        let data = input.componentsSeparatedByString("/")
        if data.count == 2 {
            if let sp = NSNumberFormatter().numberFromString(data.last!)?.integerValue {
                if let ag = NSNumberFormatter().numberFromString(data.first!)?.integerValue {
                    if sp > 0 && sp < 100 && ag > -1 && ag < 360 {
                        speed = sp
                        angle = ag
                    }
                }
            }
        }
        
        if angle != nil && speed != nil {
            isTyping = false
        }
        return (angle,speed)
    }
    
    override func pressR6() {
        super.pressR6()
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("VNAV SETUP") as? VNAVSETUPViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    override func prevKey(sender: UIButton) {
        super.prevKey(sender)
        navigationController?.popViewControllerAnimated(false)
    }
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("PERF INIT PAGE3") as? PERFINITPAGE3ViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }

}
