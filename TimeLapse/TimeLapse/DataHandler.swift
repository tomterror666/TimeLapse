//
//  DataHandler.swift
//  TimeLapse
//
//  Created by Andre Hess on 20.05.15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

import UIKit

class DataHandler: NSObject {
	
	let basePath:String!
	let fileManager:NSFileManager!
	
	static let sharedDataHandler = DataHandler()
	
	override init() {
		basePath = NSTemporaryDirectory() + "/TimeLapse/"
		fileManager = NSFileManager.defaultManager()
		fileManager.createDirectoryAtPath(basePath, withIntermediateDirectories:true, attributes:nil, error:nil)
		super.init()
	}
	
	func storeData(data:NSData, withName:String) {
		fileManager.createFileAtPath(basePath+withName, contents:data, attributes:nil)
	}
	
	func clearDataDirectory() {
		let error:NSErrorPointer = nil
		for fileName in fileManager.contentsOfDirectoryAtPath(basePath!, error:error) as! [String] {
			fileManager.removeItemAtPath(basePath + fileName, error:error)
		}
	}
	
	func getContentOfDataDirectory() -> NSArray {
		let result:NSArray = fileManager.contentsOfDirectoryAtPath(basePath, error:nil)!
		result.enumerateObjectsUsingBlock { (fileName:AnyObject!, index:Int, stop:UnsafeMutablePointer<ObjCBool>) -> Void in
			
		}
		return result
	}
}
