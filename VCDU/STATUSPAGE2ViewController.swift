//
//  STATUSPAGE2ViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/13.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class STATUSPAGE2ViewController: INDEXSubMenuViewController {

    override func prevKey(sender: UIButton) {
        super.prevKey(sender)
        navigationController?.popViewControllerAnimated(false)
    }
    
    override func nextKey(sender: UIButton) {
        prevKey(sender)
    }

}
