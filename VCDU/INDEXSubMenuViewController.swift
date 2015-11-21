//
//  INDEXSubMenuViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/13.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class INDEXSubMenuViewController: CDUViewController {

    override func pressL6() {
        super.pressL6()
        navigationController?.popToRootViewControllerAnimated(false)
    }
    
    override func switchPage(sender: UIButton) {
        super.switchPage(sender)
        if sender.currentTitle == "INDEX" {
            navigationController?.popToRootViewControllerAnimated(false)
        }
    }
    
    

}
