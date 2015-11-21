//
//  PERFMENUViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/2.

//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class PERFMENUViewController: CDUViewController {
    
    var currentPage = 1
    var isEnable = true {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(isEnable, forKey: "Adivisory VNAV")
            if isEnable {
                let displayString = NSMutableAttributedString(string: "ENABLE/DISABLE")
                displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(0, 6))
                lines[5].leftAttributeTitle = displayString
            } else {
                let displayString = NSMutableAttributedString(string: "ENABLE/DISABLE")
                displayString.addAttributes(DefaultConstant.selectedAttributes, range: NSMakeRange(7, 7))
                lines[5].leftAttributeTitle = displayString
            }
        }
    }
    
    override func pressL1() {
        super.pressL1()
        if currentPage == 1 {
            if let dvc = storyboard?.instantiateViewControllerWithIdentifier(CDUViewControllerID.PERFINIT) as? PERFINITViewController {
                navigationController?.pushViewController(dvc, animated: false)
            }
        }
    }
    
    override func pressL2() {
        super.pressL2()
        if currentPage == 1 {
            if let dvc = storyboard?.instantiateViewControllerWithIdentifier(CDUViewControllerID.VNAVSETUP) as? VNAVSETUPViewController {
                navigationController?.pushViewController(dvc, animated: false)
            }
        }
    }
    
    override func pressL3() {
        super.pressL3()
        if currentPage == 1 {
            if let dvc = storyboard?.instantiateViewControllerWithIdentifier(CDUViewControllerID.TAKEOFFREF) as? TAKEOFFREFViewController {
                navigationController?.pushViewController(dvc, animated: false)
            }
        }
    }
    
    override func pressL4() {
        super.pressL4()
        if currentPage == 1 {
            if let dvc = storyboard?.instantiateViewControllerWithIdentifier("N1 LIMIT") as? N1LIMITViewController {
                navigationController?.pushViewController(dvc, animated: false)
            }
        }
    }
    
    override func pressL5() {
        super.pressL5()
        if currentPage == 1 {
        isEnable = !isEnable
        }
    }
    
    
    override func updateUI() {
        super.updateUI()
        if firstPlan != nil && firstPlan?.performance == nil {
            if let performance = Performance.performance(plan: firstPlan!, context: firstPlan!.managedObjectContext!) {
                firstPlan?.performance = performance
                print("\(performance.unique)")
            }
        }
        
        if let advisoryVNAV = NSUserDefaults.standardUserDefaults().valueForKey("Adivisory VNAV") as? Bool {
            isEnable = advisoryVNAV
        } else {
            NSUserDefaults.standardUserDefaults().setBool(isEnable, forKey: "Adivisory VNAV")
            isEnable = true
        }
    }
    
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if currentPage == 1 {
            currentPage = 2
            for i in 1...6 {
                lines[i].clear()
            }
            lines[1].rightTitle = "SECOND PERF>"
        }
    }
    
    override func prevKey(sender: UIButton) {
        super.prevKey(sender)
        if currentPage == 2 {
            currentPage = 1
            for i in 1...6 {
                lines[i].leftTitle = DefaultDisplay.leftTitle[i-1]
                lines[i].rightTitle = DefaultDisplay.rightTitle[i-1]
            }
            lines[5].leftSubtitle = "ADVISORY VNAV"
            lines[6].leftSubtitle = "VNAV PLAN SPD"
            updateUI()
        }
    }
    
    
    struct DefaultDisplay {
        static let leftTitle = ["<PERF INIT","<VNAV SETUP","<TAKE OFF","<N1 LIMIT","","250KT"]
        static let rightTitle = ["FUEL MGMT>","FLT LOG>","APPROACH>","RTA>","",""]
    }

}
