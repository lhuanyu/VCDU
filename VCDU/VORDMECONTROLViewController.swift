//
//  VORDMECONTROLViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/13.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class VORDMECONTROLViewController: INDEXSubMenuViewController {
    
    var radioStations:[String] = ["−−−−","−−−−","−−−−","−−−−","−−−−","−−−−","−−−−","−−−−"]  {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(radioStations, forKey: "VOR/DME")
        }
    }
    
    var vorIsEnable = true {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(vorIsEnable, forKey: "VORUSE")
            if vorIsEnable {
                lines[5].leftTitle = "<ENABLED>"
                lines[5].leftTitleColor = UIColor.greenColor()
                lines[5].leftTitleSize = 22
            } else {
                lines[5].leftTitle = "<DISABLD>"
                lines[5].leftTitleColor = UIColor.whiteColor()
                lines[5].leftTitleSize = 20
            }
        }
    }
    
    var dmeIsEnable = true {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(dmeIsEnable, forKey: "DMEUSE")
            if dmeIsEnable {
                lines[5].rightTitle = "<ENABLED>"
                lines[5].rightTitleColor = UIColor.greenColor()
                lines[5].rightTitleSize = 22
            } else {
                lines[5].rightTitle = "<DISABLD>"
                lines[5].rightTitleColor = UIColor.whiteColor()
                lines[5].rightTitleSize = 20
            }
        }
    }
    
    private func update(line:Int,isLeft:Bool = true) {
        if !isDeleting {
                if note.characters.count == 4 {
                    isTyping = false
                    if isLeft {
                        lines[line].leftTitle = note
                        radioStations[line-1] = note
                    } else {
                        lines[line].rightTitle = note
                        radioStations[line+3] = note
                    }
                }
        } else {
            isDeleting = false
            if isLeft {
                lines[line].leftTitle = "−−−−"
                radioStations[line-1] = "−−−−"
            } else {
                lines[line].rightTitle = "−−−−"
                radioStations[line+3] = "−−−−"

            }
        }
    }
    
    override func pressL1() {
        super.pressL1()
        update(1)
    }
    
    override func pressL2() {
        super.pressL2()
        update(2)
    }
    
    override func pressL3() {
        super.pressL3()
        update(3)
    }
    
    override func pressL4() {
        super.pressL4()
        update(4)
    }
    
    override func pressL5() {
        super.pressL5()
        vorIsEnable = !vorIsEnable
    }
    
    override func pressR1() {
        super.pressR1()
        update(1,isLeft: false)
    }
    
    override func pressR2() {
        super.pressR2()
        update(2,isLeft: false)
    }
    
    override func pressR3() {
        super.pressR3()
        update(3,isLeft: false)
    }
    
    override func pressR4() {
        super.pressR4()
        update(4,isLeft: false)
    }
    
    override func pressR5() {
        super.pressR5()
        dmeIsEnable = !dmeIsEnable
    }
    
    override func updateUI() {
        super.updateUI()
        if let radioData = NSUserDefaults.standardUserDefaults().valueForKey("VOR/DME") as? [String] {
            radioStations = radioData
            for i in 1...4 {
                lines[i].leftTitle = radioStations[i-1]
                lines[i].rightTitle = radioStations[i+3]
            }
        }
        
        vorIsEnable = NSUserDefaults.standardUserDefaults().boolForKey("VORUSE")
        dmeIsEnable = NSUserDefaults.standardUserDefaults().boolForKey("DMEUSE")    }
    

    

}
