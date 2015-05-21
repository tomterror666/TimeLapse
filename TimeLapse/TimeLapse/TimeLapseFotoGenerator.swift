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
	var previewView:UIView?
	var session:AVCaptureSession?
	var device:AVCaptureDevice?
	var input:AVCaptureDeviceInput?
	
	init(viewController:UIViewController, withPreviewView previewView:UIView?, withDelegate delegate:TimeLapseFotoGeneratorDelegate) {
		self.delegate = delegate
		self.baseViewController = viewController
		
		super.init()
		
		self.session = AVCaptureSession()
		self.configureCaptureSession()
		self.previewView = previewView
		self.configurePreviewView()
		self.device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
		self.input = AVCaptureDeviceInput.deviceInputWithDevice(self.device, error:nil) as? AVCaptureDeviceInput
		self.configureCaptureDevice()
		
		self.generatorTimer = self.createNewTimer(5.0)
		self.dataHandler.clearDataDirectory()
	}
	
	func startTimeLapsing() {
		self.endlessRecording = true
		self.imageCounter = 0
		self.dataHandler.clearDataDirectory()
		self.addTimerToRunloop()
		self.session!.startRunning()
	}
	
	func startTimeLapsingWithNumberOfImages(numberOfImages:UInt32) {
		self.endlessRecording = false
		self.numberOfImages = numberOfImages
		self.imageCounter = 0
		self.dataHandler.clearDataDirectory()
		self.addTimerToRunloop()
		self.session!.startRunning()
	}
	
	func stopTimeLapsing() {
		self.generatorTimer.invalidate()
		self.generatorTimer = self.createNewTimer(5.0)
		self.delegate?.timeLapseFotoGeneratorHasFinishedSuccessful(self)
		self.session!.stopRunning()
	}
	
	func configureCaptureSession() {
		self.session!.sessionPreset = AVCaptureSessionPresetHigh
	}
	
	func configurePreviewView() {
		if (self.previewView != nil) {
			let previewLayer:AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer.layerWithSession(session) as! AVCaptureVideoPreviewLayer
			previewLayer.frame = self.previewView!.bounds
			self.previewView?.layer.addSublayer(previewLayer)
		}
	}
	
	func resetPreviewView() {
		if (self.previewView != nil) {
			for layer:CALayer in self.previewView?.layer.sublayers as! [CALayer] {
				if (layer.isKindOfClass(AVCaptureVideoPreviewLayer)) {
					layer.removeFromSuperlayer()
					break
				}
			}
		}
	}
	
	func configureCaptureDevice() {
		let error:NSErrorPointer = nil
		self.device!.lockForConfiguration(error)
		if (self.device!.isFocusModeSupported(AVCaptureFocusMode.ContinuousAutoFocus)) {
			self.device!.focusMode = AVCaptureFocusMode.ContinuousAutoFocus
		}
		if (self.device!.smoothAutoFocusSupported) {
			self.device!.smoothAutoFocusEnabled = true
		}
		if (self.device!.lowLightBoostSupported) {
			self.device!.automaticallyEnablesLowLightBoostWhenAvailable = true
		}
		self.device!.whiteBalanceMode = AVCaptureWhiteBalanceMode.ContinuousAutoWhiteBalance
		self.device!.exposureMode = AVCaptureExposureMode.ContinuousAutoExposure
		self.device!.unlockForConfiguration()
		self.session!.addInput(self.input)
		
	}
	
	/*
		// MARK: - image getting
	*/
	
	func getImage() {
		let stillImageOutput:AVCaptureStillImageOutput = AVCaptureStillImageOutput()
		stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
		//stillImageOutput.outputSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
		stillImageOutput.highResolutionStillImageOutputEnabled = true
		self.session!.addOutput(stillImageOutput)
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
		
		stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (imageSampleBuffer:CMSampleBuffer!, error:NSError!) -> Void in
			let imageData:NSData = self.imageDataFromSampleBuffer(imageSampleBuffer)
			self.dataHandler.storeData(imageData, withName: "timeLapsImage_\(self.imageCounter).jpg")
			let formatter:NSDateFormatter = NSDateFormatter()
			formatter.dateStyle = NSDateFormatterStyle.ShortStyle
			formatter.timeStyle = NSDateFormatterStyle.LongStyle
			println("finished to generate image now: \(formatter.stringFromDate(NSDate()))")
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
