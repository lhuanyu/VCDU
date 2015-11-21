//
//  VNAVSETUPViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/4.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class VNAVSETUPViewController: CDUViewController {

    override func pressR6() {
        super.pressR6()
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("PERF INIT") as? PERFINITViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    override func prevKey(sender: UIButton) {
        super.prevKey(sender)
        if let count = navigationController?.viewControllers.count {
            if count > 3  {
                navigationController?.popViewControllerAnimated(false)
            }
        }
    }
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if let identifer = sender.currentTitle {
            if let dvc: AnyObject = storyboard?.instantiateViewControllerWithIdentifier(identifer) {
                if dvc.isKindOfClass(VNAVSETUPViewController) {
                    navigationController?.pushViewController(dvc as! VNAVSETUPViewController, animated: false)
                }
            }
        }
    }
    
}
