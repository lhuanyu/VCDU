//
//  DEPARRDetailViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/4/3.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class DEPARRDetailViewController: CDUViewController {

    //MARK: - Data Collection
    
    //current selected airport
    var airport:Airport? 
    var runaways = [Runaway]()
    var availableRunaways:[Runaway]?
    var selectedProcedure:Procedure? {
        didSet {
            //update plan
            if isDep {
                firstPlan?.departure = selectedProcedure?.name ?? ""
            } else {
                firstPlan?.arrive = selectedProcedure?.name ?? ""
            }


            
            if selectedProcedure != nil {

                isModifying = true
                availableRunaways = selectedProcedure?.runaway.array as? [Runaway]//reload data
                //refresh UI
                lines[1].leftTitleColor = UIColor.greenColor()
                lines[1].leftTitle = selectedProcedure!.name
                
                var index = 2
                    if lines[2].rightSubtitle != "TRANS" {
                        lines[2].leftSubtitle = "TRANS"
                        lines[2].leftTitle = "NONE"
                        lines[2].leftTitleColor = UIColor.greenColor()
                        index = 3
                    } else {
                        totalPage = 1
                    }
                
                for i in index...linesNumber {
                    lines[i].leftTitle = ""
                }
                currentPage = 1
                totalPage = Int(ceil(Double(availableRunaways!.count) / Double(linesNumber)))
                if totalPage == 0 {totalPage = 1}
            } else {
                isModifying = false

                lines[1].leftTitleColor = UIColor.whiteColor()
                lines[2].leftTitleColor = UIColor.whiteColor()
                lines[2].leftSubtitle = ""
                if selectedRunaway != nil {
                    totalPage = Int(ceil(Double(availableProcedures!.count) / Double(linesNumber)))
                } else {
                    reloadData()
                    setup()
                }
            }
        }
    }
    
    var procedues = [Procedure]()
    var availableProcedures:[Procedure]?
    var selectedRunaway:Runaway? {
        didSet {
            //update plan
            if isDep {
                firstPlan?.takeoff = selectedRunaway?.name ?? ""
            } else {
                firstPlan?.approach = selectedRunaway?.name ?? ""
            }

            if selectedRunaway != nil {
                isModifying = true

                availableProcedures = selectedRunaway?.procedure.array as? [Procedure]
                currentPage = 1
                totalPage = Int(ceil(Double(availableProcedures!.count) / Double(linesNumber)))
                if totalPage == 0 {totalPage = 1}
                lines[1].rightTitleColor = UIColor.greenColor()
                lines[1].rightTitle = selectedRunaway!.name
                var index = 2
                if lines[2].leftSubtitle != "TRANS" {
                    lines[2].rightSubtitle = "TRANS"
                    lines[2].rightTitle = "VECTORS"
                    lines[2].rightTitleColor = UIColor.greenColor()
                    index = 3
                } else {
                    totalPage = 1
                }
                
                for i in index...linesNumber {
                    lines[i].rightTitle = ""
                }

            } else {
                isModifying = false
                //refresh UI
                lines[1].rightTitleColor = UIColor.whiteColor()
                lines[2].rightTitleColor = UIColor.whiteColor()
                lines[2].rightSubtitle = ""
                if selectedProcedure != nil {
                    totalPage = Int(ceil(Double(availableRunaways!.count) / Double(linesNumber)))
                } else {
                    reloadData()
                    setup()
                }
            }
        }
    }
    
    override var isModifying:Bool {
        didSet {
            if isModifying {
                displayView.addSubview(execLabel)
                lines[0].leftTitle = "MOD"
                lines[0].leftTitleColor = UIColor.whiteColor()
                lines[6].leftTitle = "<CANCEL MOD"

            } else {
                execLabel.removeFromSuperview()
                lines[0].leftTitle = "ACT"
                lines[0].leftTitleColor = UIColor.cduBlueColor()
                lines[6].leftTitle = "<DEP/ARR IDX"

            }
        }
    }
    
    //MARK: - Display Setting

    var isDep:Bool = true {
        didSet {
            if isDep {
                linesNumber = 5
            } else {
                linesNumber = 4
            }
        }
    }
    
    var linesNumber = 5 //DEP use 5 lines and ARR uses 4 lines
    var totalPage:Int = 1 {
        didSet {
            updatePage()
        }
    }
    var currentPage:Int = 1 {
        didSet {
            updatePage()
        }
    }
    
    private func updatePage()
    {
        lines[0].rightTitle = "\(currentPage)/\(totalPage)"
        for  i in 1...linesNumber {
            let index = (currentPage-1) * linesNumber + i - 1
            if selectedProcedure == nil {
                if index < availableProcedures!.count {
                    lines[i].leftTitle = availableProcedures![index].name
                } else {
                    lines[i].leftTitle  = ""
                }
            }
            
            if selectedRunaway == nil {
                if index < availableRunaways!.count {
                    lines[i].rightTitle = availableRunaways![index].name
                } else {
                    lines[i].rightTitle  = ""
                }
            }
        }
    }
    
    override func prevKey(sender: UIButton) {
        super.prevKey(sender)
        if currentPage > 1 && airport != nil {
            currentPage -= 1
        }
    }
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if currentPage < totalPage && airport != nil  {
            currentPage += 1
        }
    }
    
    //MARK: - Initialization
    
    //basic UI setup when view did appear
    override func updateUI()
    {
        if firstPlan?.departure != "" && firstPlan?.takeoff != "" && isDep {
            selectProcedure(firstPlan!.departure)
            selectRunaway(firstPlan!.takeoff)
            isModifying = false
        } else if firstPlan?.arrive != "" && firstPlan?.approach != "" && !isDep {
            selectProcedure(firstPlan!.arrive)
            selectRunaway(firstPlan!.approach)
            isModifying = false
        } else {
            reloadData()
        }
        setup()
    }
    
    private func setup() {
        if isDep {
            lines[0].title = airport!.name + "    DEPART"
            lines[1].leftSubtitle = " DEPARTURES"
        } else {
            lines[0].title = airport!.name + "    ARRIVE"
            lines[1].leftSubtitle = "STARS"
            lines[1].rightSubtitle = "APPROCHES"
            lines[5].subtitle =  "−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−−"
            lines[5].rightTitle = "ARR DATA>"
            lines[6].subtitle = ""
        }
        totalPage = max(Int(ceil(Double(procedues.count) / Double(linesNumber))),Int(ceil(Double(runaways.count) / Double(linesNumber))))
        if totalPage == 0 {totalPage = 1}

    }
    
    private func reloadData()
    {
        if airport != nil && runaways.isEmpty && procedues.isEmpty {
            if let procedueList = airport?.procedure.array as? [Procedure] {
                for procedure in procedueList {
                    if procedure.isDeparture == isDep {
                        procedues.append(procedure)
                    }
                }
            }
            
            if let runawayList = airport?.runaway.array as? [Runaway] {
                for runaway in runawayList {
                    if runaway.isDepatrure == isDep {
                        runaways.append(runaway)
                    }
                }
            }
            
        }
        availableProcedures = procedues
        availableRunaways = runaways
    }
    
    //MARK: - Function key
    override func pressL1() {
        super.pressL1()
        if isDeleting {
            if selectedProcedure != nil {
                selectedProcedure  = nil
                isDeleting = false
            }
        } else {
            selectProcedure(lines[1].leftTitle)
        }
    }
    
    override func pressL2() {
        super.pressL2()
        selectProcedure(lines[2].leftTitle)

    }
    
    override func pressL3() {
        super.pressL3()
        selectProcedure(lines[3].leftTitle)

    }
    
    override func pressL4() {
        super.pressL4()
        selectProcedure(lines[4].leftTitle)
    }
    
    override func pressL5() {
        super.pressL5()
        selectProcedure(lines[5].leftTitle)
    }
    
    override func pressR1() {
        super.pressR1()
        if isDeleting {
            if selectedRunaway != nil {
                selectedRunaway = nil
                isDeleting = false
            }
        } else {
            selectRunaway(lines[1].rightTitle)
        }
    }
    
    override func pressR2() {
        super.pressR2()
        selectRunaway(lines[2].rightTitle)
    }
    
    override func pressR3() {
        super.pressR3()
        selectRunaway(lines[3].rightTitle)
    }
    
    override func pressR4() {
        super.pressR4()
        selectRunaway(lines[4].rightTitle)
    }
    
    override func pressR5() {
        super.pressR5()
        selectRunaway(lines[5].rightTitle)
    }
    
    override func pressR6() {
        super.pressR6()
        tabBarController?.selectedIndex = 3
    }
    
    private func selectProcedure(name:String)
    {
        if selectedProcedure == nil {
            if let procedure = Procedure.procedure(name: name,context: airport!.managedObjectContext!) {
                selectedProcedure = procedure
            }
        }
    }
    
    private func selectRunaway(name:String)
    {
        if selectedRunaway == nil {
            if let runaway = Runaway.runaway(name: name, airport:airport!,isDep:nil, context: airport!.managedObjectContext!) {
                selectedRunaway = runaway
            }
        }
    }
    
    override func execButtton() {
        super.execButtton()
        isModifying = false
        lines[6].leftTitle = "<DEP/ARR IDX"
    }

    //pop to the DEPARR page or cancel modify
    override func pressL6() {
        super.pressL6()
        if isModifying {//redo
            if lines[2].leftSubtitle == "TRANS" {
                if selectedRunaway == nil {
                    selectedProcedure = nil
                } else {
                    selectedRunaway = nil
                }
            } else {
                if selectedProcedure == nil {
                    selectedRunaway = nil
                } else {
                    selectedProcedure = nil
                }
            }
            if selectedRunaway != nil || selectedProcedure != nil {
                isModifying = true
            }
        } else {//pop
            navigationController?.popToRootViewControllerAnimated(false)
        }
        
    }
    
    override func switchPage(sender: UIButton) {
        super.switchPage(sender)
        if sender.currentTitle == "DEPARR" {
            if !isModifying {
                navigationController?.popToRootViewControllerAnimated(false)
            }
        }
    }

}
