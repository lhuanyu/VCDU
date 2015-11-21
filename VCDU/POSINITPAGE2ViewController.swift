//
//  POSINITPAGE2ViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/13.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class POSINITPAGE2ViewController: INDEXSubMenuViewController {

    
    override func pressL1() {
        super.pressL1()
        note = lines[1].title
    }
    
    override func pressL2() {
        super.pressL2()
        note = lines[2].title
    }
    
    override func pressL3() {
        super.pressL3()
        note = lines[3].title
    }
    
    override func prevKey(sender: UIButton) {
        super.prevKey(sender)
        navigationController?.popViewControllerAnimated(false)
    }
    
    override func nextKey(sender: UIButton) {
        prevKey(sender)
    }
    
}
