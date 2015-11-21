//
//  DEPARRViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/3/27.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class DEPARRViewController: CDUViewController {
    


    func selectProcdures(airport:String, origin:Bool)
    {
        if Airport.validatingData(airport) == nil {
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("DEPARR Detail") as? DEPARRDetailViewController {
            dvc.airport = Airport.airport(name: airport, context: firstPlan!.managedObjectContext!)
            dvc.isDep = origin
            navigationController?.pushViewController(dvc, animated: false)
            }
        }
    }
    
    override func pressL1() {
        super.pressL1()
        selectProcdures(firstPlan!.origin, origin: true)
    }
    
    override func pressR1() {
        super.pressR1()
    }
    
    override func pressL2() {
        super.pressL2()

    }
    
    override func pressR2() {
        super.pressR2()
        selectProcdures(firstPlan!.destination, origin: false)
    }
    
    
    override func updateUI() {
        if let origin = firstPlan?.origin {
            if origin != "☐☐☐☐" && origin != "" {
                lines[1].title = origin
                lines[1].leftTitle = DefaultDisplayData.line1[3]
                lines[1].rightTitle = DefaultDisplayData.line1[5]
            } else {
                lines[1].title = ""
                lines[1].leftTitle = ""
                lines[1].rightTitle = ""
            }

        } else {
            lines[1].title = ""
            lines[1].leftTitle = ""
            lines[1].rightTitle = ""
        }

        if let destination = firstPlan?.destination {
            if destination != "☐☐☐☐" && destination != "" {
                lines[2].title = destination
                lines[2].leftTitle = DefaultDisplayData.line1[3]
                lines[2].rightTitle = DefaultDisplayData.line1[5]
            } else {
                lines[2].title = ""
                lines[2].leftTitle = ""
                lines[2].rightTitle = ""
            }

        } else {
            lines[2].title = ""
            lines[2].leftTitle = ""
            lines[2].rightTitle = ""
        }
    }

    
    struct DefaultDisplayData
    {
        static let line0 = [""," ",""," "," "," "]
        static let line1 = ["","ACT PLAN","","<DEP"," ","ARR>"]
        static let line2 = ["ROUTE", "", "ALTN","<DEP" ,"","ARR>"]
        static let line3 = ["", "", "ORIG RWY","" ,"",""]
        static let line4 = ["VIA", "", "TO","−−−−−" ,"","−−−−−"]
        static let line5 = ["", "−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−", "","" ,"","FLT NO"]
        static let line6 = ["", "", "−−−−−−−−", "<SEC FPLN" ,"","PERF INIT>"]
        
    }
    
}
