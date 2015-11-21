//
//  FPLNViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/3/26.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit
import CoreData

class FPLNViewController: CDUViewController {
    
    override func updateUI() {

        if firstPlan?.origin != "" {
            lines[1].leftTitle = firstPlan!.origin
        } else {
            lines[1].leftTitle = "☐☐☐☐"
        }
        if firstPlan?.destination != "" {
            lines[1].rightTitle = firstPlan!.destination
        } else {
            lines[1].rightTitle = "☐☐☐☐"
        }
        if let distance = firstPlan?.distance {
            lines[1].title = "\(distance.integerValue)"
        } else {
            lines[1].title = "−−−−"
        }
        if let takeoff = firstPlan?.takeoff {
            lines[3].rightTitle = takeoff
        }
        
        if messageLabel.text! == "" {
            messageLabel.font = UIFont(name: FontName.Arial, size: 12)
            messageLabel.text = "数据库仅供演示，起飞机场请选择ZBAA，目的机场ZSSS"
        }
    }
    
    //check input data then update UI
    
    func updateAirport(isOrigin isOrigin: Bool){
        var airport = ""
        if isOrigin {
            airport = lines[1].leftTitle
        } else {
            airport = lines[2].rightTitle
        }

        if !isDeleting {
            if note == ""  {
                if airport != "☐☐☐☐" && airport != "−−−−" {
                    note = airport
                }
            } else {
                if let erro = Airport.validatingData(note) {
                    messageLabel.text = erro
                } else {
                    if isOrigin {
                        FlightPlan.fisrtFlightPlan(note, context: firstPlan!.managedObjectContext!)
                    } else {
                        FlightPlan.fisrtFlightPlan(destination:note, context: firstPlan!.managedObjectContext!)
                    }
                    isTyping = false
                    isModifying = true
                }
            }
        } else {
            isDeleting = false
            if isOrigin {
                deleteFlightPlan()
            } else {
                firstPlan?.destination = ""
                FlightPlan.fisrtFlightPlan(context: firstPlan!.managedObjectContext!)
            }
        }
        updateUI()
    }
    
    
    func updateAirport() -> String {
        let name = ""
        return name
    }
    
    func deleteFlightPlan()
    {
        firstPlan?.managedObjectContext?.deleteObject(firstPlan!)
        print("FPLN DELETED")
        firstPlan = FlightPlan.fisrtFlightPlan(context: delegate.managedObjectContext!)
        isDeleting = false
    }
    
    //MARK: - Function Keys Impelementation
    override func pressL1()
    {
        super.pressL1()
        updateAirport(isOrigin: true)
    }
    
    override func pressR1()
    {
        super.pressR1()
        updateAirport(isOrigin: false)
    }
    
    override func pressR2() {
        super.pressR2()
    }
    
    
    override func pressR5() {
        super.pressR5()
        if !isDeleting {
            if note.characters.count < 9 {
                lines[6].rightSubtitle = note
                firstPlan?.flightNO = note
                isTyping = false
            }
        } else {
            lines[6].rightSubtitle = DefaultDisplayData.line6[2]
            firstPlan?.flightNO = ""
            isDeleting = false
        }
    }
    
    override func pressR6() {
        tabBarController?.selectedIndex = 5
        if let pvc = tabBarController?.viewControllers![5] as? PERFMENUViewController {
            pvc.pressL1()
        }
    }
    
    override func execButtton() {
        super.execButtton()
        isModifying = false
    }
    
    
    
    //MARK: - Reserved Data -
    struct DefaultDisplayData
    {
        static let line0 = ["","","","FPLN","ACT","1/1"]
        static let line1 = ["ORIGIN","DIST", "DEST", "☐☐☐☐", "−−−−", "☐☐☐☐"]
        static let line2 = ["ROUTE", "", "ALTN","−−−−−−−−−−" ,"","−−−−"]
        static let line3 = ["", "", "ORIG RWY","" ,"",""]
        static let line4 = ["VIA", "", "TO","−−−−−" ,"","−−−−−"]
        static let line5 = ["", "−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−", "","" ,"","FLT NO"]
        static let line6 = ["", "", "−−−−−−−−", "<SEC FPLN" ,"","PERF INIT>"]

    }
    
    
}
