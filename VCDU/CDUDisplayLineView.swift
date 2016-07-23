//
//  CDUDisplayLineView.swift
//  VCDU
//
//  Created by LuoHuanyu on 15/3/28.
//  Copyright (c) 2015年 LuoHuanyu. All rights reserved.
//

import UIKit

@IBDesignable
class CDUDisplayLineView: UIView {
    
    //MARK: - Public Attributes
    
    func clear()
    {
        leftTitle = ""
        title = ""
        rightTitle = ""
        leftSubtitle = ""
        subtitle = ""
        rightSubtitle = ""
    }
    
    //using left title as the 1st column when CDU page is a 2 or 3 columns list.
    @IBInspectable var leftTitle:String = "Left Title" {didSet{labelLT.text = leftTitle}}
    @IBInspectable var leftTitleColor: UIColor = UIColor.whiteColor(){didSet{labelLT.textColor = leftTitleColor}}
    @IBInspectable var leftTitleAlignment:Int = 0 {didSet{labelLT.textAlignment = intToAlignment(leftTitleAlignment)}}
    @IBInspectable var leftTitleSize:CGFloat = 20 {didSet{labelLT.font = UIFont(name: FontName.Fixedsys,size: leftTitleSize)}}
    var leftAttributeTitle:NSAttributedString = NSAttributedString(string: "AttributeTitle") {didSet{labelLT.attributedText = leftAttributeTitle}}
    
    //using title as the 2nd column when CDU page is a 3 columns list, or as the main display column when page only have single column.
    @IBInspectable var title:String = "Title"{didSet{labelT.text = title}}
    @IBInspectable var titleColor: UIColor = UIColor.whiteColor(){didSet{labelT.textColor = titleColor}}

    @IBInspectable var titleAlignment:Int = 1 {didSet{labelT.textAlignment = intToAlignment(titleAlignment)}}
    @IBInspectable var titleSize:CGFloat = 20 {didSet{labelT.font = UIFont(name: FontName.Fixedsys,size: titleSize)}}
    var attributeTitle:NSAttributedString = NSAttributedString(string: "AttributeTitle") {didSet{labelT.attributedText = attributeTitle}}

    //using right title as the 2nd column when CDU page is a 2 columns list, or as the 3rd column when page is a 3 columns list
    @IBInspectable var rightTitle:String = "Right Title"{didSet{labelRT.text = rightTitle}}
    @IBInspectable var rightTitleColor: UIColor = UIColor.whiteColor(){didSet{labelRT.textColor = rightTitleColor}}
    @IBInspectable var rightTitleAlignment:Int = 2 {didSet{labelRT.textAlignment = intToAlignment(rightTitleAlignment)}}
    @IBInspectable var rightTitleSize:CGFloat = 20{didSet{labelRT.font = UIFont(name: FontName.Fixedsys,size: rightTitleSize)}}
    var rightAttributeTitle:NSAttributedString = NSAttributedString(string: "AttributeTitle") {didSet{labelRT.attributedText = rightAttributeTitle}}



    
    @IBInspectable var leftSubtitle:String = "Left Subtitle"{didSet{labelLS.text = leftSubtitle}}
    @IBInspectable var leftSubtitleColor: UIColor = UIColor.cduBlueColor(){didSet{labelLS.textColor = leftSubtitleColor}}
    @IBInspectable var leftSubtitleAlignment:Int = 0 {didSet{labelLS.textAlignment = intToAlignment(leftSubtitleAlignment)}}
    @IBInspectable var leftSubtitleSize:CGFloat = 18{didSet{labelLS.font = UIFont(name: FontName.Fixedsys,size: leftSubtitleSize)}}




    @IBInspectable var subtitle:String = "Subtitle"{didSet{labelS.text = subtitle}}
    @IBInspectable var subtitleColor: UIColor = UIColor.cduBlueColor(){didSet{labelS.textColor = subtitleColor}}
    @IBInspectable var subtitleAlignment: Int = 1 {didSet{labelS.textAlignment = intToAlignment(subtitleAlignment)}}
    @IBInspectable var subtitleSize:CGFloat = 18{didSet{labelS.font = UIFont(name: FontName.Fixedsys,size: subtitleSize)}}



    
    
    @IBInspectable var rightSubtitle:String = "Right Subtitle"{didSet{labelRS.text = rightSubtitle}}
    @IBInspectable var rightSubtitleColor: UIColor = UIColor.cduBlueColor(){didSet{labelRS.textColor = rightSubtitleColor}}
    @IBInspectable var rightSubtitleAlignment:Int = 2 {didSet{labelRS.textAlignment = intToAlignment(rightSubtitleAlignment)}}
    @IBInspectable var rightsubtitleSize:CGFloat = 18{didSet{labelRS.font = UIFont(name: FontName.Fixedsys,size: rightsubtitleSize)}}



    //MARK: Private Impelementation
    
    private lazy var labelLS:UILabel! = { 
        var label = UILabel.cduLabel(CGRectMake(0, 0, self.bounds.width / 2, self.bounds.height / 2), text: self.leftSubtitle, textSize: self.leftSubtitleSize, textAlignment: self.intToAlignment(self.leftSubtitleAlignment), textColor: self.leftSubtitleColor)
        return label
        }()

    private lazy var labelS:UILabel! = { 
        var label = UILabel.cduLabel(CGRectMake(0, 0, self.bounds.width, self.bounds.height / 2), text: self.subtitle, textSize: self.subtitleSize, textAlignment: self.intToAlignment(self.subtitleAlignment), textColor: self.subtitleColor)
        return label

    }()
    
    private lazy var labelRS:UILabel! = { 
        var label = UILabel.cduLabel(CGRectMake(self.bounds.width / 2, 0, self.bounds.width / 2, self.bounds.height / 2), text: self.rightSubtitle, textSize: self.rightsubtitleSize, textAlignment: self.intToAlignment(self.rightSubtitleAlignment), textColor: UIColor.cduBlueColor())
        return label
        }()
    
    private lazy var labelLT: UILabel = { 
        var label = UILabel.cduLabel(CGRectMake(0, self.bounds.height / 2, self.bounds.width / 2, self.bounds.height / 2), text: self.leftTitle, textSize: self.leftTitleSize, textAlignment: self.intToAlignment(self.leftTitleAlignment), textColor: self.leftTitleColor)
        return label
        }()
    private lazy var labelT: UILabel = { 
        var label = UILabel.cduLabel(CGRectMake(0, self.bounds.height / 2, self.bounds.width, self.bounds.height / 2), text: self.title, textSize: self.titleSize, textAlignment: self.intToAlignment(self.titleAlignment), textColor: self.titleColor)
        return label
        }()
    private lazy var labelRT: UILabel = { 
        var label = UILabel.cduLabel(CGRectMake(self.bounds.width / 2, self.bounds.height / 2, self.bounds.width / 2, self.bounds.height / 2), text: self.rightTitle, textSize: self.rightTitleSize, textAlignment: self.intToAlignment(self.rightTitleAlignment), textColor: self.rightTitleColor)
        return label
        }()

    

    
    override func drawRect(rect: CGRect) {
        addSubview(labelRS)
        addSubview(labelS)
        addSubview(labelLS)
        addSubview(labelLT)
        addSubview(labelT)
        addSubview(labelRT)
    }
    
    private func intToAlignment(alignment: Int) -> NSTextAlignment
    {
        switch alignment
        {
        case 0: return NSTextAlignment.Left
        case 1: return NSTextAlignment.Center
        case 2: return NSTextAlignment.Right
        default:break
        }
        return NSTextAlignment.Center
    }
    
}

extension UIColor {
    class func cduBlueColor() -> UIColor {
        //let color = UIColor(red: 44/255, green: 122/255, blue: 246/255, alpha: 1.0)
        let color = UIColor.cyanColor()
        return color
    }
}

private extension UILabel {
    class func cduLabel(frame: CGRect,  text:String, textSize:CGFloat, textAlignment:NSTextAlignment, textColor: UIColor) -> UILabel {
        let label = UILabel(frame: frame)
        label.font = UIFont(name: FontName.Fixedsys, size: textSize)
        label.text = text
        label.textColor = textColor
        label.textAlignment = textAlignment
        return label
    }
}