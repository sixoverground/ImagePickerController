//
//  CameraViewController.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol CameraViewDelegate: class {
  func setFlashButtonHidden(hidden: Bool)
}

class CameraViewController: UIViewController {
  
  lazy var capturedImageView: UIView = { [unowned self] in
    let view = UIView()
    view.backgroundColor = UIColor.blackColor()
    view.alpha = 0
    return view
    }()

  let captureSession = AVCaptureSession()
  var devices = AVCaptureDevice.devices()
  var captureDevice: AVCaptureDevice? {
    didSet {
      if let myDevice = captureDevice {
        print("HAS FLASH: \(myDevice.hasFlash)")
        delegate?.setFlashButtonHidden(!myDevice.hasFlash)
      } else {
        delegate?.setFlashButtonHidden(false)
      }
    }
  }
  var capturedDevices: NSMutableArray?
  var previewLayer: AVCaptureVideoPreviewLayer?
  var stillImageOutput: AVCaptureStillImageOutput?
  
  weak var delegate: CameraViewDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    
    initializeCamera()
        
    view.backgroundColor = UIColor.blackColor()
    previewLayer?.backgroundColor = UIColor.blackColor().CGColor
    
    view.addSubview(capturedImageView)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
    
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    fixOrientation()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    previewLayer?.position = CGPoint(x: CGRectGetMidX(view.layer.bounds), y: CGRectGetMidY(view.layer.bounds))
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    
//    previewLayer?.frame.size = size
    
//    let totalSize: CGSize = UIScreen.mainScreen().bounds.size
//    //    previewLayer.frame = view.layer.frame
//    previewLayer?.frame = CGRect(x: 0, y: -(totalSize.height - view.frame.size.height)/2, width: totalSize.width, height: totalSize.height)
//    print("preview layer frame: \(previewLayer?.frame)")
    
    fixOrientation()
  }
  
  // MARK: - Initialization
  
  func initializeCamera() {
    print("init camera")
    capturedDevices = NSMutableArray()
    
    let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
    
    if devices.isEmpty { devices = AVCaptureDevice.devices() }
    
    for device in devices {
      if let device = device as? AVCaptureDevice where device.hasMediaType(AVMediaTypeVideo) {
        if authorizationStatus == .Authorized {
          captureDevice = device
          capturedDevices?.addObject(device)
        } else if authorizationStatus == .NotDetermined {
          AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) in
            self.handlePermission(granted, device: device)
          })
        } else {
          // show no camera
        }
      }
    }
    
    captureDevice = capturedDevices?.firstObject as? AVCaptureDevice
    
    print("capture device: \(captureDevice)")
    
    if captureDevice != nil { beginSession() }
  }
  
  func configureDevice() {
    if let device = captureDevice {
      do  {
        try device.lockForConfiguration()
      } catch {
        print("Could not lock configuration")
      }
      device.unlockForConfiguration()
    }
  }
  
  func beginSession() {
    configureDevice()
    guard captureSession.inputs.count == 0 else { return }
    
//    captureSession.sessionPreset = AVCaptureSessionPresetPhoto
    
    let captureDeviceInput: AVCaptureDeviceInput?
    do { try
      captureDeviceInput = AVCaptureDeviceInput(device: captureDevice)
      captureSession.addInput(captureDeviceInput)
    } catch {
      print("Failed to capture device")
    }
    
    guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else { return }
    print("load previewLayer: \(previewLayer)")
    self.previewLayer = previewLayer
    previewLayer.autoreverses = true
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    view.layer.addSublayer(previewLayer)
    
//    let totalBounds = UIScreen.mainScreen().bounds
//    let bounds = view.bounds
    previewLayer.frame = view.layer.frame
//    previewLayer.frame = totalBounds
//    previewLayer.frame = CGRect(x: 0, y: -(totalSize.height - view.frame.size.height)/2, width: totalSize.width, height: totalSize.height)
//    print("preview layer frame: \(previewLayer.frame)")
    
//    let offset = -(totalBounds.size.height - bounds.size.height) / 2
//    previewLayer.position = CGPoint(x: CGRectGetMidX(bounds), y: offset)
//    view.layer.position = CGPoint(x: CGRectGetMidX(bounds), y: offset)
    
    previewLayer.position = CGPoint(x: CGRectGetMidX(view.layer.bounds), y: CGRectGetMidY(view.layer.bounds))
    
    
    view.clipsToBounds = true
    captureSession.startRunning()
    stillImageOutput = AVCaptureStillImageOutput()
    stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
    captureSession.addOutput(stillImageOutput)
  }
  
  // MARK: - Permissions
  
  func handlePermission(granted: Bool, device: AVCaptureDevice) {
    if granted {
      captureDevice = device
      capturedDevices?.addObject(device)
      print("granted: \(captureDevice)")
    }
    
    dispatch_async(dispatch_get_main_queue()) { 
      // show no camera - granted
    }
  }
  
  // MARK: - Actions
  
  func flipCamera() {
    guard let captureDevice = captureDevice, currentDeviceInput = captureSession.inputs.first as? AVCaptureDeviceInput, deviceIndex = capturedDevices?.indexOfObject(captureDevice) else { return }
    
    var newDeviceIndex = 0
    
    if let index = capturedDevices?.count where deviceIndex != index - 1 && deviceIndex < capturedDevices?.count {
      newDeviceIndex = deviceIndex + 1
    }
    
    self.captureDevice = capturedDevices?.objectAtIndex(newDeviceIndex) as? AVCaptureDevice
    configureDevice()
    
    guard let _ = self.captureDevice else { return }
    
    self.captureSession.beginConfiguration()
    self.captureSession.removeInput(currentDeviceInput)
    do { try
      self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice))
    } catch {
      print("There was an error capturing your device.")
    }
    
    self.captureSession.commitConfiguration()
  }
  
  func changeFlash(title: String) {
    guard let _ = captureDevice?.hasFlash else { return }
    
    do {
      try captureDevice?.lockForConfiguration()
    } catch _ {
      print("could not lock device")
    }
    
    var flashMode = AVCaptureFlashMode.Auto
    
    switch title {
    case "ON":
      flashMode = .On
    case "OFF":
      flashMode = .Off
    default:
      flashMode = .Auto
    }
    
    if let device = captureDevice {
      if device.isFlashModeSupported(flashMode) {
        captureDevice?.flashMode = flashMode
      }
    }
    
  }
  
  func takePicture(completion: () -> ()) {
    capturedImageView.frame = view.bounds
    
    UIView.animateWithDuration(0.1, animations: { 
      self.capturedImageView.alpha = 1
      }) { (finished) in
        UIView.animateWithDuration(0.1, animations: { 
          self.capturedImageView.alpha = 0
        })
    }
    
    let queue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    
    guard let stillImageOutput = self.stillImageOutput else { return }
    
    dispatch_async(queue) {
      stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo), completionHandler: { (buffer, error) in
        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
        
        guard let imageFromData = UIImage(data: imageData) else { return }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ 
          let request = PHAssetChangeRequest.creationRequestForAssetFromImage(imageFromData)
          request.creationDate = NSDate()
          }, completionHandler: { (success, error) in
            dispatch_async(dispatch_get_main_queue(), { 
              completion()
            })
        })
      })
    }
    
  }
  
  // MARK: - Helpers
  
  func deviceOrientationDidChange(notification: NSNotification) {
    print("device orientation did change")
    fixOrientation()
  }
  
  func fixOrientation() {
    guard let stillImageOutput = self.stillImageOutput, connection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) else { return }
    
    switch UIDevice.currentDevice().orientation {
    case .Portrait:
      print("change orientation to portrait")
      connection.videoOrientation = .Portrait
    case .LandscapeLeft:
      print("change orientation to landscape right")
      connection.videoOrientation = .LandscapeRight
    case .LandscapeRight:
      print("change orientation to landscape left")
      connection.videoOrientation = .LandscapeLeft
    case .PortraitUpsideDown:
      print("change orientation to upside down")
      connection.videoOrientation = .PortraitUpsideDown
    default:
      break
    }
  }
  
}
