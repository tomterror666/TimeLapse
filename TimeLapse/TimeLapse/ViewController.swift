//
//  ViewController.swift
//  TimeLapse
//
//  Created by Andre Heß on 18/05/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

import UIKit

let startButtonTag = 1111
let stopButtonTag = 9999

class ViewController: UIViewController {

	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var imageScrollView: UIScrollView!
	@IBOutlet weak var imageProgress: UIProgressView!
	@IBOutlet weak var prevButton: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/*
	// MARK: - button handling
	*/
	
	@IBAction func startStopButtonTouched(startStopButton: UIButton) {
		startStopButton.setTitle(startStopButton.tag == stopButtonTag ? "Start" : "Stop", forState:UIControlState.Normal)
		startStopButton.tag = startStopButton.tag == stopButtonTag ? startButtonTag : stopButtonTag
	}
	
	@IBAction func playButtonTouched(AnyObject) {
		
	}
	
	@IBAction func prevButtonTouched(AnyObject) {
		
	}
	
	@IBAction func nextButtonTouched(AnyObject) {
		
	}
	
}

