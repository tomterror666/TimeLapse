//
//  TimeLapseFotoGenerator.swift
//  TimeLapse
//
//  Created by Andre Heß on 19/05/15.
//  Copyright (c) 2015 Andre Heß. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol TimeLapseFotoGeneratorDelegate {
	 func timeLapseFotoGeneratorHasFinishedSuccessful(generator:TimeLapseFotoGenerator)
	optional func timeLapseFotoGeneratorHasFinishedByError(generator:TimeLapseFotoGenerator, error:NSError)
}

class TimeLapseFotoGenerator: NSObject {
	let baseViewController:UIViewController?
	var delegate:TimeLapseFotoGeneratorDelegate?
	var endlessRecording:Bool = true
	var numberOfImages:UInt32 = 0
	var generatorTimer:NSTimer!
	var imageCounter:UInt32 = 0
	let dataHandler:DataHandler = DataHandler.sharedDataHandler
	
	init(viewController:UIViewController, delegate:TimeLapseFotoGeneratorDelegate) {
		self.delegate = delegate
		self.baseViewController = viewController
	
		super.init()
		self.generatorTimer = self.createNewTimer(5.0)
		self.dataHandler.clearDataDirectory()
	}
	
	func startTimeLapsing() {
		self.endlessRecording = true
		self.imageCounter = 0
		self.dataHandler.clearDataDirectory()
		self.addTimerToRunloop()
	}
	
	func startTimeLapsing(numberOfImages:UInt32) {
		self.endlessRecording = false
		self.numberOfImages = numberOfImages
		self.imageCounter = 0
		self.dataHandler.clearDataDirectory()
		self.addTimerToRunloop()
	}
	
	func stopTimeLapsing() {
		self.generatorTimer.invalidate()
		self.generatorTimer = self.createNewTimer(5.0)
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
		device.lockForConfiguration(error)
		if (device.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus)) {
			device.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
		}
		if (device.smoothAutoFocusSupported) {
			device.smoothAutoFocusEnabled = true
		}
		if (device.lowLightBoostSupported) {
			device.automaticallyEnablesLowLightBoostWhenAvailable = true
		}
		device.whiteBalanceMode = AVCaptureWhiteBalanceMode.ContinuousAutoWhiteBalance
		device.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
		device.unlockForConfiguration()
		let input:AVCaptureDeviceInput = AVCaptureDeviceInput.deviceInputWithDevice(device, error:error) as! AVCaptureDeviceInput
		session.addInput(input)
		
		let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
		//stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
		stillImageOutput.outputSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
		stillImageOutput.highResolutionStillImageOutputEnabled = true
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
			self.dataHandler.storeData(imageData, withName: "timeLapsImage_\(self.imageCounter).jpg")
			let formatter:NSDateFormatter = NSDateFormatter()
			formatter.dateStyle = NSDateFormatterStyle.ShortStyle
			formatter.timeStyle = NSDateFormatterStyle.LongStyle
			println("finished to generate image now: \(formatter.stringFromDate(NSDate()))")
			session.stopRunning()
		})
	}
	
	func imageDataFromSampleBuffer(sampleBuffer:CMSampleBuffer) -> NSData {
		let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
		if (imageBuffer == nil) {
			return AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
		} else {
			CVPixelBufferLockBaseAddress(imageBuffer, 0)
			let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
			let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
			let width = CVPixelBufferGetWidth(imageBuffer)
			let height = CVPixelBufferGetHeight(imageBuffer)
			let context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, CGColorSpaceCreateDeviceRGB(), CGBitmapInfo.ByteOrder32Little | CGBitmapInfo(CGImageAlphaInfo.PremultipliedFirst.rawValue))
			let imageRef = CGBitmapContextCreateImage(context)
			
			let resultCtx = CGBitmapContextCreate(nil, height, width, 8, height * 4, CGColorSpaceCreateDeviceRGB(), CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue))
			CGContextRotateCTM(resultCtx, CGFloat(-M_2_PI))
			CGContextDrawImage(resultCtx, CGRectMake(/*CGFloat((height-width)/2+height)*/0, /*CGFloat((width-height)/2)*/0, CGFloat(width), CGFloat(height)), imageRef)
//			CGContextRotateCTM(resultCtx, CGFloat(-M_2_PI))
						
			return UIImageJPEGRepresentation(UIImage(CGImage: CGBitmapContextCreateImage(resultCtx)), 0.8)
		}
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
	
	func getCurrentImage() {
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
