//
//  PERFINITViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/2.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class PERFINITViewController: CDUViewController {
    
    func updateWeight() {
        
        var passengerNumber = 0
        var passengerWeight = 0
        
        if let number = firstPlan?.performance.passengerNumber.integerValue, let weight = firstPlan?.performance.passengerWeight.integerValue {
            passengerNumber = number
            passengerWeight = weight
        }
        
        if passengerNumber != 0  {
            lines[2].leftTitle = "\(passengerNumber) / \(passengerWeight) KG"
        } else {
            lines[2].leftTitle = "−− / 77 KG"
        }
        
        var cargoWeight = 0
        if let cargo = firstPlan?.performance.cargo.integerValue {
            cargoWeight = cargo
        }
        if cargoWeight != 0 {
            lines[3].leftTitle = "\(cargoWeight) KG"
        } else {
            lines[3].leftTitle = "−−−−− KG"
        }

        
        let zfw = passengerNumber * passengerWeight + cargoWeight + 24955
        let gwt = zfw + 4815
        lines[3].rightTitle = "\(zfw)  KG"
        lines[4].rightTitle = "\(gwt)  KG"

    }
    

    
    override func pressL2() {
        super.pressL2()
        if isDeleting {
            if firstPlan != nil {
                firstPlan?.performance.passengerNumber = 0
                firstPlan?.performance.passengerWeight = 0
                updateWeight()
                isDeleting = false
            }
        } else {
            isTyping = true
                let data = note.componentsSeparatedByString("/")
                if data.count == 2 {
                    if let number = NSNumberFormatter().numberFromString(data.first!)?.integerValue, let weight = NSNumberFormatter().numberFromString(data.last!)?.integerValue  {

                            if number < 91 && weight < 100 {
                                isTyping = false
                                if firstPlan != nil {
                                    firstPlan?.performance.passengerNumber = number
                                    firstPlan?.performance.passengerWeight = weight
                                    updateWeight()
                            }
                        }
                    }
                }
                if let number = NSNumberFormatter().numberFromString(note)?.integerValue {
                    if number > 0 {
                        isTyping = false
                        if firstPlan != nil {
                            firstPlan?.performance.passengerNumber = number
                            updateWeight()
                        }
                    }
                }
            }
    }
    
    override func pressL3() {
        super.pressL3()
        if isDeleting {
            if firstPlan != nil {
                firstPlan?.performance.cargo = 0
                updateWeight()
                isDeleting = false
            }
            
        } else {
        isTyping = true
            if let cargo = NSNumberFormatter().numberFromString(note)?.integerValue {
                if cargo < 10001 && cargo > 0 {
                    isTyping = false

                    if firstPlan != nil {
                        firstPlan?.performance.cargo = cargo
                        updateWeight()
                    }
                }
            }
        }
    }
    
    func updateAltitude() {
        lines[1].rightTitle = "☐☐☐☐☐"
        if let crzAltitude = firstPlan?.performance.crzAltitude.integerValue {
            if crzAltitude != 0 {
                let flightLevel = crzAltitude / 100
                lines[1].rightTitle = "FL\(flightLevel)"
            }
        }
        lines[2].rightTitle = "−−−−−"
        if let altnAltitude = firstPlan?.performance.altnAltitude.integerValue {
            if altnAltitude != 0 {
                let flightLevel = altnAltitude / 100
                lines[2].rightTitle = "FL\(flightLevel)"
            }
        }
    }
    
    
    override func pressR1() {
        super.pressR1()
        if isDeleting {
            if firstPlan != nil {
                firstPlan?.performance.crzAltitude = 0
                updateAltitude()
                isDeleting = false
            }
            
        } else {
            isTyping = true
            if let altitude = NSNumberFormatter().numberFromString(note)?.integerValue {
                if altitude < 40000 && altitude > 9999 {
                    isTyping = false
                    if firstPlan != nil {
                        firstPlan?.performance.crzAltitude = altitude
                        updateAltitude()
                    }
                }
            }
        }
    }
    
    override func pressR2() {
        super.pressR2()
        if isDeleting {
            if firstPlan != nil {
                firstPlan?.performance.altnAltitude = 0
                updateAltitude()
                isDeleting = false
            }
            
        } else {
            isTyping = true
            if let altitude = NSNumberFormatter().numberFromString(note)?.integerValue {
                if altitude < 40000 && altitude > 9999 {
                    isTyping = false
                    if firstPlan != nil {
                        firstPlan?.performance.altnAltitude = altitude
                        updateAltitude()
                    }
                }
            }
        }
    }
    
    override func pressR5() {
        super.pressR5()
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("TAKEOFF REF") as? TAKEOFFREFViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    override func pressR6() {
        super.pressR6()
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("VNAV SETUP") as? VNAVSETUPViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("PERF INIT PAGE2") as? PERFINITPAGE2ViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
        
    override func updateUI() {
        super.updateUI()
        updateWeight()
        updateAltitude()
        isTyping = false
        isDeleting = false
    }
    
}
