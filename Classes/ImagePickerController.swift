//
//  ImagePickerController.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit
import Photos

public protocol ImagePickerControllerDelegate: class {
    func imagePicker(picker: ImagePickerController, didFinishPickingImages images: [UIImage])
    func imagePickerDidCancel(picker: ImagePickerController)
}

public class ImagePickerController: UIViewController {
    
    lazy var galleryViewController: GalleryViewController = {
        let galleryViewController = GalleryViewController()
        return galleryViewController
    }()
    
    lazy var bottomView: BottomView = { [unowned self] in
        let view = BottomView()
        view.delegate = self
        return view
        }()
    
    lazy var topView: TopView = { [unowned self] in
        let view = TopView()
        view.delegate = self
        return view
        }()
    
    lazy var cameraViewController: CameraViewController = {
        let cameraViewController = CameraViewController()
        cameraViewController.delegate = self
        return cameraViewController
    }()
    
    public weak var delegate: ImagePickerControllerDelegate?
    //  public var asset: PHAsset?
    var totalSize: CGSize { return UIScreen.main.bounds.size }
    var galleryHeight:CGFloat!
    var galleryHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        ImagePickerModel.sharedInstance.selectedAsset = nil
        
        for subview in [cameraViewController.view, galleryViewController.view, bottomView, topView] {
            if let subview = subview {
                view.addSubview(subview)
                subview.translatesAutoresizingMaskIntoConstraints = false
            }
        }
        
        view.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
        
        galleryHeight = (view.bounds.size.width - 6) / 4
        setupConstraints()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        galleryHeight = (view.bounds.size.width - 6) / 4
        galleryHeightConstraint.constant = galleryHeight
        
        galleryViewController.updateFrames()
        checkStatus()
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Constraints
    
    func setupConstraints() {
        
        for attribute: NSLayoutAttribute in [.left, .top, .width] {
            view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
        }
        
        view.addConstraint(NSLayoutConstraint(item: topView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44))
        
        //    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .Bottom, relatedBy: .Equal, toItem: cameraViewController.view, attribute: .Top, multiplier: 1, constant: 0))
        
        for attribute: NSLayoutAttribute in [.left, .top, .width] {
            view.addConstraint(NSLayoutConstraint(item: cameraViewController.view, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
        }
        
        view.addConstraint(NSLayoutConstraint(item: cameraViewController.view, attribute: .bottom, relatedBy: .equal, toItem: galleryViewController.view, attribute: .top, multiplier: 1, constant: 0))
        
        for attribute: NSLayoutAttribute in [.left, .width] {
            view.addConstraint(NSLayoutConstraint(item: galleryViewController.view, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
        }
        
        galleryHeightConstraint = NSLayoutConstraint(item: galleryViewController.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: galleryHeight)
        view.addConstraint(galleryHeightConstraint)
        
        view.addConstraint(NSLayoutConstraint(item: galleryViewController.view, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 0))
        
        for attribute: NSLayoutAttribute in [.bottom, .left, .width] {
            view.addConstraint(NSLayoutConstraint(item: bottomView, attribute: attribute,
                                                  relatedBy: .equal, toItem: view, attribute: attribute,
                                                  multiplier: 1, constant: 0))
        }
        
        view.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .height,
                                              relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                              multiplier: 1, constant: 100))
        
    }
    
    // MARK: - Permissions
    
    func checkStatus() {
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        guard currentStatus != .authorized else { return }
        
        if currentStatus == .notDetermined {
            setEnabled(enabled: false)
        }
        
        PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
            DispatchQueue.main.async {
                if authorizationStatus == .denied {
                    self.presentPermissionAlert()
                } else if authorizationStatus == .authorized {
                    self.permissionGranted()
                }
            }
        }
    }
    
    func presentPermissionAlert() {
        let alertController = UIAlertController(title: "Permission Denied", message: "Please allow the application to access your photo library.", preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
                DispatchQueue.main.async {
                    UIApplication.shared.openURL(settingsURL as URL)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func permissionGranted() {
        cameraViewController.initializeCamera()
        galleryViewController.fetchAssets()
        setEnabled(enabled: true)
    }
    
    func setEnabled(enabled: Bool) {
        print("set enabled: \(enabled)")
        galleryViewController.view.alpha = enabled ? 1 : 0
    }
    
    // MARK: - Helpers
    
    fileprivate func takePicture() {
        // camera take picture
        cameraViewController.takePicture {
            if self.galleryViewController.collectionSize == nil { return }
            
            self.galleryViewController.fetchAssets(completion: {
                guard let asset = self.galleryViewController.assets.first else { return }
                ImagePickerModel.sharedInstance.selectedAsset = asset
                //        self.bottomView.doneButton.setTitle("Done", forState: .Normal)
            })
            
        }
    }
    
    
}

// MARK: - BottomViewDelegate

extension ImagePickerController: BottomViewDelegate {
    
    func bottomViewDidTakePicture() {
        takePicture()
    }
    
    func bottomViewDidCancel() {
        dismiss(animated: true, completion: nil)
        delegate?.imagePickerDidCancel(picker: self)
    }
    
    func bottomViewDidFinish() {
        print("bottom view did finish")
        
        if let asset = ImagePickerModel.sharedInstance.selectedAsset {
            let images = ImagePickerModel.resolveAssets(assets: [asset])
            self.delegate?.imagePicker(picker: self, didFinishPickingImages: images)
        }
        dismiss(animated: true, completion: nil)
        
    }
    
}

// MARK: - TopViewDelegate

extension ImagePickerController: TopViewDelegate {
    
    func topViewDidChangeFlash(title: String) {
        cameraViewController.changeFlash(title: title)
    }
    
    func topViewDidToggleCamera() {
        cameraViewController.flipCamera()
    }
    
}

// MARK: - CameraViewDelegate

extension ImagePickerController: CameraViewDelegate {
    
    func setFlashButtonHidden(hidden: Bool) {
        topView.flashButton.isHidden = hidden
    }
    
}
