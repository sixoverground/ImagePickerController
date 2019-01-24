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
        view.backgroundColor = UIColor.black
        view.alpha = 0
        return view
        }()
    
    let captureSession = AVCaptureSession()
    var devices = AVCaptureDevice.devices()
    var captureDevice: AVCaptureDevice? {
        didSet {
            if let myDevice = captureDevice {
                print("HAS FLASH: \(myDevice.hasFlash)")
                delegate?.setFlashButtonHidden(hidden: !myDevice.hasFlash)
            } else {
                delegate?.setFlashButtonHidden(hidden: false)
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
        
        view.backgroundColor = UIColor.black
        previewLayer?.backgroundColor = UIColor.black.cgColor
        
        view.addSubview(capturedImageView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        fixOrientation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        previewLayer?.position = CGPoint(x: view.layer.bounds.midX, y: view.layer.bounds.midY)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
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
        
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))
        
        if devices.isEmpty { devices = AVCaptureDevice.devices() }
        
        for device in devices {
            if device.hasMediaType(AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) {
                if authorizationStatus == .authorized {
                    captureDevice = device
                    capturedDevices?.add(device)
                } else if authorizationStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(for: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)), completionHandler: { (granted) in
                        self.handlePermission(granted: granted, device: device)
                    })
                } else {
                    // show no camera
                }
            }
        }
        
        captureDevice = capturedDevices?.firstObject as? AVCaptureDevice
        
        print("capture device: \(String(describing: captureDevice))")
        
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
            captureDeviceInput = AVCaptureDeviceInput(device: captureDevice!)
            captureSession.addInput(captureDeviceInput!)
        } catch {
            print("Failed to capture device")
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        print("load previewLayer: \(previewLayer)")
        self.previewLayer = previewLayer
        previewLayer.autoreverses = true
        previewLayer.videoGravity = AVLayerVideoGravity(rawValue: convertFromAVLayerVideoGravity(AVLayerVideoGravity.resizeAspectFill))
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
        
        previewLayer.position = CGPoint(x: view.layer.bounds.midX, y: view.layer.bounds.midY)
        
        
        view.clipsToBounds = true
        captureSession.startRunning()
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        captureSession.addOutput(stillImageOutput!)
    }
    
    // MARK: - Permissions
    
    func handlePermission(granted: Bool, device: AVCaptureDevice) {
        if granted {
            captureDevice = device
            capturedDevices?.add(device)
            print("granted: \(String(describing: captureDevice))")
        }
    }
    
    // MARK: - Actions
    
    func flipCamera() {
        guard let captureDevice = captureDevice, let currentDeviceInput = captureSession.inputs.first as? AVCaptureDeviceInput, let deviceIndex = capturedDevices?.index(of: captureDevice) else { return }
        
        var newDeviceIndex = 0
        
        if let index = capturedDevices?.count, deviceIndex != index - 1 && deviceIndex < capturedDevices?.count ?? 0 {
            newDeviceIndex = deviceIndex + 1
        }
        
        self.captureDevice = capturedDevices?.object(at: newDeviceIndex) as? AVCaptureDevice
        configureDevice()
        
        guard let _ = self.captureDevice else { return }
        
        self.captureSession.beginConfiguration()
        self.captureSession.removeInput(currentDeviceInput)
        do { try
            self.captureSession.addInput(AVCaptureDeviceInput(device: self.captureDevice!))
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
        
        var flashMode = AVCaptureDevice.FlashMode.auto
        
        switch title {
        case "ON":
            flashMode = .on
        case "OFF":
            flashMode = .off
        default:
            flashMode = .auto
        }
        
        if let device = captureDevice {
            if device.isFlashModeSupported(flashMode) {
                captureDevice?.flashMode = flashMode
            }
        }
        
    }
    
    func takePicture(completion: @escaping () -> ()) {
        capturedImageView.frame = view.bounds
        
        UIView.animate(withDuration: 0.1, animations: {
            self.capturedImageView.alpha = 1
        }) { (finished) in
            UIView.animate(withDuration: 0.1, animations: {
                self.capturedImageView.alpha = 0
            })
        }
        
        let queue = DispatchQueue(label: "session queue")
        
        guard let stillImageOutput = self.stillImageOutput else { return }
        
        queue.async {
            stillImageOutput.captureStillImageAsynchronously(from: stillImageOutput.connection(with: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video)))!, completionHandler: { (buffer, error) in
                guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!) else { return }
                guard let imageFromData = UIImage(data: imageData) else { return }
                PHPhotoLibrary.shared().performChanges({
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: imageFromData)
                    request.creationDate = NSDate() as Date
                }, completionHandler: { (success, error) in
                    DispatchQueue.main.async {
                        completion()
                    }
                })
            })
        }
        
    }
    
    // MARK: - Helpers
    
    @objc func deviceOrientationDidChange(_ notification: NSNotification) {
        print("device orientation did change")
        fixOrientation()
    }
    
    func fixOrientation() {
        guard let stillImageOutput = self.stillImageOutput, let connection = stillImageOutput.connection(with: AVMediaType(rawValue: convertFromAVMediaType(AVMediaType.video))) else { return }
        
        switch UIDevice.current.orientation {
        case .portrait:
            print("change orientation to portrait")
            connection.videoOrientation = .portrait
        case .landscapeLeft:
            print("change orientation to landscape right")
            connection.videoOrientation = .landscapeRight
        case .landscapeRight:
            print("change orientation to landscape left")
            connection.videoOrientation = .landscapeLeft
        case .portraitUpsideDown:
            print("change orientation to upside down")
            connection.videoOrientation = .portraitUpsideDown
        default:
            break
        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMediaType(_ input: AVMediaType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVLayerVideoGravity(_ input: AVLayerVideoGravity) -> String {
	return input.rawValue
}
