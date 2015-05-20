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

class ViewController: UIViewController, TimeLapseFotoGeneratorDelegate {

	@IBOutlet weak var durationLabel: UILabel!
	@IBOutlet weak var startStopButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var imageScrollView: UIScrollView!
	@IBOutlet weak var imageProgress: UIProgressView!
	@IBOutlet weak var prevButton: UIButton!
	@IBOutlet weak var nextButton: UIButton!
	
	var fotoGenerator:TimeLapseFotoGenerator!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.fotoGenerator = TimeLapseFotoGenerator(delegate: self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		ViewConfiguration.configureLabelWithFontAndTitle(self.durationLabel, font: RunningText17, title: "")
		ViewConfiguration.configureButtonWithFontAndTitle(self.startStopButton, font: RunningTextBold19, title: "Start")
		ViewConfiguration.configureButtonWithFontAndTitle(self.playButton, font: RunningTextBold19, title: "Play")
		ViewConfiguration.configureButtonWithFontAndTitle(self.prevButton, font: RunningTextLight15, title: "Previous")
		ViewConfiguration.configureButtonWithFontAndTitle(self.nextButton, font: RunningTextLight15, title: "Next")
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	/*
	// MARK: - button handling
	*/
	
	@IBAction func startStopButtonTouched(startStopButton: UIButton) {
		if (startStopButton.tag == stopButtonTag) {
			startStopButton.setTitle("Start", forState:UIControlState.Normal)
			startStopButton.tag = startButtonTag
			fotoGenerator.stopTimeLapsing()
		} else {
			startStopButton.setTitle("Stop", forState:UIControlState.Normal)
			startStopButton.tag = stopButtonTag
			fotoGenerator.startTimeLapsing()
		}
		
		
	}
	
	@IBAction func playButtonTouched(AnyObject) {
		
	}
	
	@IBAction func prevButtonTouched(AnyObject) {
		
	}
	
	@IBAction func nextButtonTouched(AnyObject) {
		
	}
	
}

