//
//  PERFINITPAGE3ViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/4.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class PERFINITPAGE3ViewController: CDUViewController {
    
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

}
