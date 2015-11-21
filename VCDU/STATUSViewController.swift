//
//  STATUSViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/3/30.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

class STATUSViewController: INDEXSubMenuViewController {
    
    weak var timer:NSTimer?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateTime()
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateTime", userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    func updateTime()
    {
        let utc =  NSDate()
        let utcDateFormatter = NSDateFormatter()
        utcDateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        utcDateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("HH mm", options: 0, locale: NSLocale.currentLocale())
        utcDateFormatter.timeZone = NSTimeZone(abbreviation: "GMT")
        lines[4].leftTitle = "\(utcDateFormatter.stringFromDate(utc))"
        utcDateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("dd MM yy", options: 0, locale: NSLocale(localeIdentifier: "en_US"))
        lines[4].rightTitle = "\(utcDateFormatter.stringFromDate(utc))"
        print("updating")
    }
    
    override func prevKey(sender: UIButton) {
        nextKey(sender)
    }
    
    override func nextKey(sender: UIButton) {
        super.nextKey(sender)
        if let dvc = storyboard?.instantiateViewControllerWithIdentifier("STATUS PAGE2") as? INDEXSubMenuViewController {
            navigationController?.pushViewController(dvc, animated: false)
        }
    }
    
    
}
