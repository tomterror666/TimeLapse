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
		self.fotoGenerator = TimeLapseFotoGenerator(viewController: self, delegate: self)
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
	
	func enableHiddenViews(enabled:Bool) {
		self.imageScrollView.hidden = !enabled
	}
	
	/*
	// MARK: - button handling
	*/
	
	@IBAction func startStopButtonTouched(startStopButton: UIButton) {
		if (startStopButton.tag == stopButtonTag) {
			self.setStartStatusToButton()
			fotoGenerator.stopTimeLapsing()
		} else {
			self.setStopStatusToButton()
			self.enableHiddenViews(false)
			fotoGenerator.startTimeLapsing()
		}
		
		
	}
	
	@IBAction func playButtonTouched(AnyObject) {
		
	}
	
	@IBAction func prevButtonTouched(AnyObject) {
		
	}
	
	@IBAction func nextButtonTouched(AnyObject) {
		
	}
	
	func setStartStatusToButton() {
		startStopButton.setTitle("Start", forState:UIControlState.Normal)
		startStopButton.tag = startButtonTag
	}
	
	func setStopStatusToButton() {
		startStopButton.setTitle("Stop", forState:UIControlState.Normal)
		startStopButton.tag = stopButtonTag
	}
	
	/*
		// MARK: - timelapsegeneratordelegate implementation
	*/
	
	func timeLapseFotoGeneratorHasFinishedSuccessful(generator: TimeLapseFotoGenerator) {
		if (self.startStopButton.tag == stopButtonTag) {
			self.setStartStatusToButton()
		}
		let dataHandler:DataHandler = DataHandler.sharedDataHandler
		let imageContent = dataHandler.getContentOfDataDirectory()
		let imageHandler = SlidingImagesHandler(baseScrollView: self.imageScrollView, imageNames:imageContent as! [String])
		imageHandler.reset()
		imageHandler.addImages()
		self.enableHiddenViews(true)
	}
	
	func timeLapseFotoGeneratorHasFinishedByError(generator: TimeLapseFotoGenerator, error: NSError) {
		
	}
	
}

