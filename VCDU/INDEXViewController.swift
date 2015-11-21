//
//  INDEXViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/3/30.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class INDEXViewController: CDUViewController {

    override func pressL2() {
        super.pressL2()
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("STATUS") as? STATUSViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    override func pressL3() {
        super.pressL3()
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("POS INIT") as? POSINITViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    override func pressL5() {
        super.pressL5()
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier(CDUViewControllerID.VORDMECTR) as? VORDMECONTROLViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
 


}
