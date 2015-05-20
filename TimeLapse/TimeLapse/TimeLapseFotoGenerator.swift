//
//  TimeLapseFotoGenerator.swift
//  TimeLapse
//
//  Created by Andre Heß on 19/05/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

import UIKit
import AVFoundation

protocol TimeLapseFotoGeneratorDelegate {
	func timeLapseFotoGeneratorHasFinishedSuccessful(generator:TimeLapseFotoGenerator)
	func timeLapseFotoGeneratorHasFinishedByError(generator:TimeLapseFotoGenerator, error:NSError)
}

class TimeLapseFotoGenerator: NSObject {
	let baseViewController:UIViewController?
	var delegate:TimeLapseFotoGeneratorDelegate?
	var endlessRecording:Bool = true
	var numberOfImages:UInt32 = 0
	var generatorTimer:NSTimer!
	var imageCounter:UInt32 = 0
	
	init(viewController:UIViewController, delegate:TimeLapseFotoGeneratorDelegate) {
		self.delegate = delegate
		self.baseViewController = viewController
	
		super.init()
		self.generatorTimer = self.createNewTimer(1.0)
	}
	
	func startTimeLapsing() {
		self.endlessRecording = true
		self.imageCounter = 0
		self.addTimerToRunloop()
	}
	
	func startTimeLapsing(numberOfImages:UInt32) {
		self.endlessRecording = false
		self.numberOfImages = numberOfImages
		self.imageCounter = 0
		self.addTimerToRunloop()
	}
	
	func stopTimeLapsing() {
		self.generatorTimer.invalidate()
		self.generatorTimer = self.createNewTimer(1.0)
		self.delegate?.timeLapseFotoGeneratorHasFinishedSuccessful(self)
	}
	
	/*
		// MARK: - image getting
	*/
	
	func getImage() {
		let session:AVCaptureSession = AVCaptureSession()
		session.sessionPreset = AVCaptureSessionPresetHigh

		let devices:[AVCaptureDevice] = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo) as! [AVCaptureDevice]
		
		for checkedDevice:AVCaptureDevice in devices {
			let formats = checkedDevice.formats
			let activeFormat = checkedDevice.activeFormat
			let uniqueID = checkedDevice.uniqueID
		}
		
		
		let device:AVCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
		let error:NSErrorPointer = nil
		let input:AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error:error) as! AVCaptureDeviceInput
		session.addInput(input)
		
		let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
		stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
		session.addOutput(stillImageOutput)
		var videoConnection:AVCaptureConnection?
		let connections:[AVCaptureConnection] = stillImageOutput.connections as! [AVCaptureConnection]
		for connection:AVCaptureConnection in connections {
			let inputPorts:[AVCaptureInputPort] = connection.inputPorts as! [AVCaptureInputPort]
			for port:AVCaptureInputPort in inputPorts {
				if (port.mediaType == AVMediaTypeVideo) {
					videoConnection = connection
					break
				}
			}
			if (videoConnection != nil) {
				break
			}
		}
		
		session.startRunning()
		
		stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageSampleBuffer:CMSampleBuffer!, error:NSError!) -> Void in
			let imageData:NSData = self.imageDataFromSampleBuffer(imageSampleBuffer)
			let formatter:NSDateFormatter = NSDateFormatter()
			formatter.dateStyle = NSDateFormatterStyle.ShortStyle
			formatter.timeStyle = NSDateFormatterStyle.LongStyle
			println("finished to generate image now: \(formatter.stringFromDate(NSDate()))")
			session.stopRunning()
		})
	}
	
	func imageDataFromSampleBuffer(sampleBuffer:CMSampleBuffer) -> NSData {
		return AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
	}
	
	/*
		// MARK: - timer handling
	*/
	
	func createNewTimer(interval:NSTimeInterval) -> NSTimer {
		return NSTimer(fireDate:NSDate(timeIntervalSinceNow:interval), interval: interval, target: self, selector: Selector("getCurrentImage"), userInfo: nil, repeats: true)
	}
	
	func addTimerToRunloop() {
		NSRunLoop.currentRunLoop().addTimer(self.generatorTimer, forMode: NSDefaultRunLoopMode)
	}
	
	@objc func getCurrentImage() {
		let formatter:NSDateFormatter = NSDateFormatter()
		formatter.dateStyle = NSDateFormatterStyle.ShortStyle
		formatter.timeStyle = NSDateFormatterStyle.LongStyle
		println("begin to generate image now: \(formatter.stringFromDate(NSDate()))")
		self.getImage()
		self.imageCounter++
		if (self.imageCounter == self.numberOfImages) {
			self.stopTimeLapsing()
		}
	}
}
