//
//  TimeLapseFotoGenerator.swift
//  TimeLapse
//
//  Created by Andre Heß on 19/05/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

import UIKit

protocol TimeLapseFotoGeneratorDelegate {
	
}

class TimeLapseFotoGenerator: NSObject {
	var delegate:TimeLapseFotoGeneratorDelegate
	init(delegate:TimeLapseFotoGeneratorDelegate) {
		self.delegate = delegate
	}
	
	func startTimeLapsing() {
		
	}
	
	func stopTimeLapsing() {
		
	}
}
