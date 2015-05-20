//
//  SlidingImagesHandler.swift
//  TimeLapse
//
//  Created by Andre Heß on 20/05/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

import UIKit

let imageWidth:CGFloat = 200.0
let imageHeight:CGFloat = 300.0

class SlidingImagesHandler: NSObject {
	
	let baseScrollView:UIScrollView!
	let dataSource:NSArray!
	
	init(baseScrollView:UIScrollView, imageNames:[String]) {
		self.baseScrollView = baseScrollView
		self.dataSource = imageNames
	}
	
	func addImages() {
		let dataSourceCount:CGFloat = CGFloat(self.dataSource.count)
		self.baseScrollView.contentSize = CGSizeMake(self.baseScrollView.frame.size.width * dataSourceCount, self.baseScrollView.frame.size.height)
		self.dataSource.enumerateObjectsUsingBlock { (object:AnyObject!, index:Int, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
			let x = CGFloat(index) * self.baseScrollView.frame.size.width + (self.baseScrollView.frame.size.width - imageWidth) / 2
			let y = (self.baseScrollView.frame.size.height - imageHeight) / 2
			self.baseScrollView.addSubview(self.getImageViewForImage(self.getImage(object as! String), rect:CGRectMake(x, y, imageWidth, imageHeight)))
		}
	}
	
	func getImage(fullImageFileName:String) -> UIImage {
		let result = UIImage(contentsOfFile: fullImageFileName)!
		return result
	}
	
	func getImageViewForImage(image:UIImage, rect:CGRect) -> UIImageView {
		let result = UIImageView(image:image)
		result.frame = rect
		result.contentMode = UIViewContentMode.ScaleAspectFit
		return result
	}
}
