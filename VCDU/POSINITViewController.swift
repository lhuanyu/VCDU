//
//  POSINITViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/6/13.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class POSINITViewController: INDEXSubMenuViewController {
    
    
    override func prevKey(sender: UIButton) {
        nextKey(sender)
    }
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("POS INIT PAGE2") as? INDEXSubMenuViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    override func pressL1() {
        super.pressL1()
        note = lines[1].title
    }
    
    override func pressL2() {
        super.pressL2()
        note = lines[2].title

    }
    
    override func pressR5() {
        super.pressR5()
        if !isDeleting {
            if note.characters.count == 20 {
                lines[5].title = note
                NSUserDefaults.standardUserDefaults().setValue(lines[5].title, forKey: "Initial Position")
                isTyping = false
            }
        } else {
            lines[5].title = "☐☐☐°☐☐.☐☐ ☐☐☐☐°☐☐.☐☐"
            NSUserDefaults.standardUserDefaults().setValue(lines[5].title, forKey: "Initial Position")
            isDeleting = false
        }
    }
    
    override func updateUI() {
        if let pos = NSUserDefaults.standardUserDefaults().valueForKey("Initial Position") as? String {
            lines[5].title = pos
        }
    }
    
}
