//
//  CDUViewController.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/3/26.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.


//  This is the basic class of CDUViewController

import UIKit
import CoreData
import CoreLocation
import AVFoundation


struct CDUViewControllerID {
    static let VNAVSETUP = "VNAV SETUP"
    static let PERFMENU = "PERF MENU"
    static let PERFINIT = "PERF INIT"
    static let PERFINITPAGE2 = "PERF INIT PAGE2"
    static let PERFINITPAGE3 = "PERF INIT PAGE3"
    static let VORDMECTR = "VORDME CONTROL"
    static let POSINIT = "POS INIT"
    static let TAKEOFFREF = "TAKEOFF REF"
    static let TAKEOFFREFPAGE2 = "TAKEOFF REF PAGE2"
    static let TAKEOFFREFPAGE3 = "TAKEOFF REF PAGE3"
    static let TAKEOFFREFPAGE4 = "TAKEOFF REF PAGE4"
}

class CDUViewController: UIViewController {
    
    //MARK: - Public Stored Property -
    var firstPlan:FlightPlan? {
        get {
            return delegate.firstFlightPlan
        }
        set {
            delegate.firstFlightPlan = newValue
        }
    }
    var secondPlan:FlightPlan?
    
    var note:String {
        get {
            return input.text!
        }
        set {
            input.text = newValue
            delegate.sharedNote = newValue
        }
    }
    
    var delegate:AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }

    //MARK: - Display
    
    @IBOutlet weak var displayView: UIView!
    {
        didSet{
            displayView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var input: UILabel! {
        didSet {
            input.font = UIFont(name: FontName.Fixedsys, size: 20)!
            input.textColor = UIColor.whiteColor()
        }
    }
    @IBOutlet weak var messageLabel: UILabel!     
    lazy var execLabel:UILabel =  {
        var label = UILabel(frame: CGRectMake(315, 253, 50, 21))
        label.textColor = UIColor.blackColor()
        label.text = "EXEC"
        label.font = UIFont(name: FontName.Fixedsys, size: 20)!
        label.backgroundColor = UIColor.whiteColor()
        return label
    }()

    //CDU display lines (7 lines including the Page Header Title)
    @IBOutlet var lines: [CDUDisplayLineView]!

    //MARK: - Function Keys

    //CDU line selecting button function
    @IBAction func pressL1(){keySoundPlayer.play()}
    @IBAction func pressL2(){keySoundPlayer.play()}
    @IBAction func pressL3(){keySoundPlayer.play()}
    @IBAction func pressL4(){keySoundPlayer.play()}
    @IBAction func pressL5(){keySoundPlayer.play()}
    @IBAction func pressL6(){keySoundPlayer.play()}
    @IBAction func pressR1(){keySoundPlayer.play()}
    @IBAction func pressR2(){keySoundPlayer.play()}
    @IBAction func pressR3(){keySoundPlayer.play()}
    @IBAction func pressR4(){keySoundPlayer.play()}
    @IBAction func pressR5(){keySoundPlayer.play()}
    @IBAction func pressR6(){keySoundPlayer.play()}
    
    

    @IBAction func nextKey(sender: UIButton) {keySoundPlayer.play()}
    @IBAction func prevKey(sender: UIButton) {keySoundPlayer.play()}
    
    //using a Tabbar Controller to handle the page switching
    @IBAction func switchPage(sender:UIButton) {
        keySoundPlayer.play()
        if let index = indexOfPage(sender.currentTitle) {
            tabBarController?.selectedIndex = index
        } else {
            let alert = UIAlertView(title: "抱歉！", message: "更多功能开发中...", delegate: self, cancelButtonTitle: "确定")
            alert.show()
        }
    }
    
    private func indexOfPage(title:String?) -> Int? {
        var index: Int?
        if title != nil {
            switch title! {
            case "INDEX": index = 0
            case "FPLN": index = 1
            case "DEPARR": index = 2
            case "LEGS":index = 3
            case "DSPLADV": index = 4
            case "PERF": index = 5
            case "TUNE": index = 6
            default:break
            }
        }
        return index
    }
    
    @IBAction func execButtton()
    {
        keySoundPlayer.play()
    }
    
    //MARK: - Keybord

    //input status
    var isDeleting = false {
        didSet {
            if !isDeleting {
                clearNote()
            }
        }
    }
    var isTyping = true {
        didSet {
            if !isTyping {
                isTyping = true
                clearNote()
                clearMessage()
            }
        }
    }
    var isModifying:Bool = false {
        didSet {
            if isModifying {
                displayView.addSubview(execLabel)
                lines[0].leftTitle = "MOD"
                lines[0].leftTitleColor = UIColor.whiteColor()
            } else {
                execLabel.removeFromSuperview()
                lines[0].leftTitle = "ACT"
                lines[0].leftTitleColor = UIColor.cduBlueColor()
            }
        }
    }

    //basic input function for the keybord
    @IBAction func keyboad(sender: UIButton) {
        keySoundPlayer.play()
        if let symbol = sender.currentTitle  {
            if !isDeleting && isTyping {
                if symbol == "+" {
                    if let number = NSNumberFormatter().numberFromString(note)?.doubleValue {
                        if number > 0 {
                            note = "-" + note
                        } else {
                            note = String(note.characters.dropFirst())
                        }
                    } else {
                        note = note + "-"
                    }
                }else {
                    note = note + symbol
                }
            } else {
                input.text = symbol
                isTyping = true
                isDeleting = false
            }
        }
    }
    
    
    @IBAction func clear(sender: UIButton) {
        if !note.isEmpty {
            note = String((input.text!).characters.dropLast())
        }
        keySoundPlayer.play()
    }
    
    @IBAction func deleteButton(sender: UIButton) {
        note = "DELETE"
        isDeleting = true
        keySoundPlayer.play()

    }
    
    
    func clearNote() {
        note = ""
    }
    
    func clearMessage() {
        messageLabel.text = ""
    }
    
    func updateUI(){}
    func updateData() {}
    
    //MARK: - ViewController life cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.hidden = true
        splitViewController?.maximumPrimaryColumnWidth = 1024
        splitViewController?.preferredPrimaryColumnWidthFraction = 0.5
        navigationController?.navigationBarHidden = true
        addSeprator(CGRectMake(0, 510, 203, 3))
        addSeprator(CGRectMake(200, 420, 3, 93))
        addSeprator(CGRectMake(200, 420, 340, 3))
        addNail(CGPointMake(0, 20))
        addNail(CGPointMake(0, 530))
        addNail(CGPointMake(0, 690))
        addNail(CGPointMake(462, 20))
        addNail(CGPointMake(462, 430))
        addNail(CGPointMake(462, 690))
    }
    
    func addSeprator(frame:CGRect) {
        let sepratorView = UIView(frame: frame)
        sepratorView.layer.cornerRadius = 3
        sepratorView.alpha = 0.8
        sepratorView.backgroundColor = UIColor.blackColor()
        view.addSubview(sepratorView)

    }
    
    func addNail(position:CGPoint) {
        var nail = UIImage()
        if position.x == 0 {
            nail = UIImage(named: "螺丝.png")!

        } else {
            nail = UIImage(named: "螺丝R.png")!
        }
        let nailView = UIImageView(frame: CGRectMake(position.x, position.y, 50, 50))
        nailView.image = nail
        view.addSubview(nailView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        input.text = delegate.sharedNote ?? ""
        updateUI()
        updateData()
    }
    
    lazy var keySoundPlayer:AVAudioPlayer = {
        let path = NSBundle.mainBundle().pathForResource("Button", ofType: "WAV")
        let url = NSURL(fileURLWithPath: path!)
        return try! AVAudioPlayer(contentsOfURL:url, fileTypeHint: "WAV")
    }()
    
    struct DefaultConstant {
        static let selectedAttributes = [NSForegroundColorAttributeName:UIColor.greenColor(), NSFontAttributeName:UIFont(name: FontName.Fixedsys, size: 22)!]
        static let cyanSelectedAttributes = [NSForegroundColorAttributeName:UIColor.cyanColor(), NSFontAttributeName:UIFont(name: FontName.Fixedsys, size: 22)!]
    }

}