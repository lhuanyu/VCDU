//
//  MFDViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/4/16.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AVFoundation
import SpriteKit


class MFDViewController: UIViewController {

    //MARK: - UI Setup -
    
    let ap = AutoPilot(name:"AP1")
    let displayScene = DisplayScene(size: CGSizeMake(512, 768))
    
    @IBOutlet weak var display: SKView!{
        didSet {
            let recall = UIScreenEdgePanGestureRecognizer(target: self, action: "recallControlPanel:")
            recall.edges = UIRectEdge.Right
            display.addGestureRecognizer(recall)
            display.showsFPS = true
            display.showsNodeCount = true
            
            
            let adjustHeading = UIRotationGestureRecognizer(target: self, action: "headingKnob:")
            display.addGestureRecognizer(adjustHeading)
            
            let moveCursor = UIPanGestureRecognizer(target: self, action: "moveCursor:")
            moveCursor.maximumNumberOfTouches = 1
            moveCursor.requireGestureRecognizerToFail(recall)
            display.addGestureRecognizer(moveCursor)
            

            displayScene.scaleMode = .Fill
            displayScene.delegate = ap
            display.presentScene(displayScene)

        }
    }
    
    @IBOutlet weak var controlPanel: UIView! {
        didSet{
            let hide = UISwipeGestureRecognizer(target:self, action: "hideControlPanel:")
            hide.direction = UISwipeGestureRecognizerDirection.Right
            hide.numberOfTouchesRequired = 2
            controlPanel.addGestureRecognizer(hide)
            controlPanel.layer.cornerRadius = 10
            controlPanel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet var controlButtons: [UIButton]!{
        didSet {
            for button in controlButtons {
                button.layer.cornerRadius = 5
            }
        }
    }
    

    
    //MARK: - Control Methods -
    
    //SKView
    var firstTouchPosition:CGPoint?
    
    func moveCursor(sender:UIPanGestureRecognizer) {
        if sender.state == .Began {
            firstTouchPosition = sender.locationInView(display)
        } else if sender.state == .Changed {
            if let origin = firstTouchPosition {
                let center = displayScene.cursorOrigin
                if abs(origin.x-center.x) < 30 && abs(origin.y-center.y) < 30 || displayScene.cursor.alpha == 1{
                    displayScene.convertTouchPointToCursorPosition(sender.locationInView(display))
                }
            }
        }
    }
    
    
    func headingKnob(sender: UIRotationGestureRecognizer) {
            if sender.state == .Began || sender.state == .Changed {
                displayScene.preselectingHeading += sender.rotation.degree
            } else if sender.state == .Ended {
                ap.preselectedHeading = displayScene.preselectingHeading.radians
            }
            sender.rotation = 0
    }
    
    //ControlPanel
    func recallControlPanel(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .Began || sender.state == .Changed {
            UIView.animateWithDuration(1.0, animations: {self.controlPanel.center.x = self.display.center.x})
            displayScene.fma.runAction(SKAction.fadeAlphaTo(1, duration: 1))
        }
    }
    func hideControlPanel(sender:UISwipeGestureRecognizer) {
        if sender.state == .Ended {
            UIView.animateWithDuration(1.0, animations: {self.controlPanel.center.x = self.display.bounds.maxX * 1.5})
            displayScene.fma.runAction(SKAction.fadeAlphaTo(0, duration: 1))
            largerPane = false
        }
    }
    
    var currentScale:CGFloat = 1.0 {
        didSet {
            displayScene.mapScale = 1/pow(2.0, currentScale)
        }
    }
    @IBAction func adjustRange(sender: UIButton) {
        keySoundPlayer.play()
        if sender.currentTitle == "+" {
            if currentScale > 0 {
                --currentScale
            }
        } else {
            if currentScale < 6 {
                ++currentScale
            }
        }
    }
    @IBAction func rollMode(sender: UIButton) {
        if sender.currentTitle == "HDG" {
            ap.headingOn = !ap.headingOn
        } else if sender.currentTitle == "NAV" {
            ap.navArm = !ap.navArm
        }
    }
    
    @IBAction func adjustingSpeed(sender: UISlider) {
         displayScene.preselectedSpeed = CGFloat(Int(sender.value))
    }
    
    @IBAction func adjustingAltitude(sender: UISlider) {
        if ap.inAir {
            displayScene.preselectedPitchAngle = CGFloat(sender.value)
        }
    }
    
    @IBAction func enter(sender: UIButton) {
        keySoundPlayer.play()
        if displayScene.cursor.alpha != 0 {
            if let tbc = splitViewController?.viewControllers.first as? UITabBarController {
                if let cduvc = tbc.selectedViewController as? CDUViewController {
                    cduvc.note = cursorWaypoint ?? ""
                } else if let nvc = tbc.selectedViewController as? UINavigationController {
                    if let cduvc = nvc.viewControllers.first as? CDUViewController {
                    cduvc.note = cursorWaypoint ?? ""
                }
            }
                displayScene.cursorPosition = CGPointZero
                displayScene.cursorWaypoint = nil
                displayScene.cursor.alpha = 0
            }
        }
    }
    
    @IBAction func changeDisplayFormat(sender: UIButton) {
        
    }
    
    
    @IBOutlet weak var pitchSlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!

    @IBAction func resetDisplay(sender: UIButton) {
        displayScene.reset()
        ap.reset()
        pitchSlider.value = 0
        speedSlider.value = 40
    }
    var largerPane = false
    {
        didSet {
            if largerPane {
                UIView.transitionWithView(display, duration: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {self.controlPanel.center.y-=170}, completion: { (flag) -> Void in })
                displayScene.moveUp = true
            } else {
                UIView.transitionWithView(display, duration: 0.5, options: UIViewAnimationOptions.CurveLinear, animations: {self.controlPanel.center.y+=170}, completion: { (flag) -> Void in })
                displayScene.moveUp = false
            }
        }
    }

    @IBAction func largerPanel(sender: UIButton) {
        largerPane = !largerPane
    }
    
    //MARK: - NavData Property
    
    var origin:CGPoint?
    
    
    var modifyingRoute:[Waypoint?]? {
        didSet {
            ap.modifyingRoute = modifyingRoute
            displayScene.modifyingRoute = modifyingRoute
        }
    }
    

    var route:[Waypoint?]? {
        didSet {
            displayScene.route = route
            ap.currentRoute = route
        }
    }
    
    var indexOfWaypoint = 0
    
    func prevWaypoint() {

    }
    
    func nextWaypoint() {

    }
    
    //MARK: - Coordinate Formatter -
    
    var cursorWaypoint:String? {
        if let coordinate = displayScene.cursorWaypoint {
            let latitudeDeg = modf(coordinate.latitude).0
            let latitudeMin = modf(coordinate.latitude).1 * 60
            let longitudeDeg = modf(coordinate.longitude).0
            let longitudeMin = modf(coordinate.longitude).1 * 60
            let string = latitudeDegreeFormatter.stringFromNumber(latitudeDeg)! + miniuteFormatter.stringFromNumber(latitudeMin)! + longitudeDegreeFormatter.stringFromNumber(longitudeDeg)! + miniuteFormatter.stringFromNumber(longitudeMin)!
            return string
        }
        return nil
    }
    
    let latitudeDegreeFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 2
        formatter.positivePrefix = "N"
        formatter.negativePrefix = "S"
        return formatter
        }()
    
    let longitudeDegreeFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 3
        formatter.positivePrefix = "E"
        formatter.negativePrefix = "W"
        return formatter
        }()
    
    let miniuteFormatter: NSNumberFormatter = {
        let formatter = NSNumberFormatter()
        formatter.paddingPosition = NSNumberFormatterPadPosition.AfterPrefix
        formatter.paddingCharacter = "0"
        formatter.formatWidth = 5
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
        }()
    
    lazy var keySoundPlayer:AVAudioPlayer = {
        let path = NSBundle.mainBundle().pathForResource("Button", ofType: "WAV")
        let url = NSURL(fileURLWithPath: path!)
        return try! AVAudioPlayer(contentsOfURL:url, fileTypeHint: "WAV")
        }()
    
}