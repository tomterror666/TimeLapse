//
//  ViewConfiguration.swift
//  TimeLapse
//
//  Created by Andre Heß on 19/05/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

let RunningTextFontName = "AvenirNext-Medium"
let RunningTextBoldFontName = "AvenirNext-Bold"
let RunningTextLightFontName = "AvenirNext-UltraLight"

let RunningText11:UIFont! = UIFont(name:RunningTextFontName, size:11)
let RunningText13:UIFont! = UIFont(name:RunningTextFontName, size:13)
let RunningText15:UIFont! = UIFont(name:RunningTextFontName, size:15)
let RunningText17:UIFont! = UIFont(name:RunningTextFontName, size:17)
let RunningText19:UIFont! = UIFont(name:RunningTextFontName, size:19)
let RunningText21:UIFont! = UIFont(name:RunningTextFontName, size:21)
let RunningText23:UIFont! = UIFont(name:RunningTextFontName, size:23)
let RunningText25:UIFont! = UIFont(name:RunningTextFontName, size:25)

let RunningTextBold11:UIFont! = UIFont(name:RunningTextBoldFontName, size:11)
let RunningTextBold13:UIFont! = UIFont(name:RunningTextBoldFontName, size:13)
let RunningTextBold15:UIFont! = UIFont(name:RunningTextBoldFontName, size:15)
let RunningTextBold17:UIFont! = UIFont(name:RunningTextBoldFontName, size:17)
let RunningTextBold19:UIFont! = UIFont(name:RunningTextBoldFontName, size:19)
let RunningTextBold21:UIFont! = UIFont(name:RunningTextBoldFontName, size:21)
let RunningTextBold23:UIFont! = UIFont(name:RunningTextBoldFontName, size:23)
let RunningTextBold25:UIFont! = UIFont(name:RunningTextBoldFontName, size:25)

let RunningTextLight11:UIFont! = UIFont(name:RunningTextLightFontName, size:11)
let RunningTextLight13:UIFont! = UIFont(name:RunningTextLightFontName, size:13)
let RunningTextLight15:UIFont! = UIFont(name:RunningTextLightFontName, size:15)
let RunningTextLight17:UIFont! = UIFont(name:RunningTextLightFontName, size:17)
let RunningTextLight19:UIFont! = UIFont(name:RunningTextLightFontName, size:19)
let RunningTextLight21:UIFont! = UIFont(name:RunningTextLightFontName, size:21)
let RunningTextLight23:UIFont! = UIFont(name:RunningTextLightFontName, size:23)
let RunningTextLight25:UIFont! = UIFont(name:RunningTextLightFontName, size:25)

let ButtonBlue:UIColor = UIColor(red:0.2, green:0.3, blue:0.8, alpha:1.0)

import UIKit

class ViewConfiguration: NSObject {
	static func configureLabelWithFontAndTitle(label:UILabel, font:UIFont, title:String) {
		label.font = font
		label.text = title
		label.textColor = UIColor.lightGrayColor()
		label.backgroundColor = UIColor.clearColor()
	}
	
	static func configureButtonWithFontAndTitle(button:UIButton, font:UIFont, title:String) {
		button.setTitle(title, forState: UIControlState.Normal)
		button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
		button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
		button.setTitleColor(UIColor.grayColor(), forState: UIControlState.Selected)
		button.titleLabel!.font = font
		button.setBackgroundImage(ViewConfiguration.imageWithColor(ButtonBlue), forState: UIControlState.Normal)
		button.layer.cornerRadius = 4
		button.layer.masksToBounds = true
	}
	
	static func imageWithColor(color:UIColor) -> UIImage {
		var data:UnsafeMutablePointer<CUnsignedChar>
		data = UnsafeMutablePointer<CUnsignedChar>.alloc(4)
		
		let context:CGContext = CGBitmapContextCreate(data, 1, 1, 8, 4, CGColorSpaceCreateDeviceRGB()!, CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue))
		CGContextSetFillColorWithColor(context, color.CGColor)
		CGContextFillRect(context, CGRectMake(0, 0, 1, 1))
		
		return UIImage(CGImage:CGBitmapContextCreateImage(context)!)!
	}
}
