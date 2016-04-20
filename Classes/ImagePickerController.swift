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
    return cameraViewController
    }()
  
  public weak var delegate: ImagePickerControllerDelegate?
//  public var asset: PHAsset?
  var totalSize: CGSize { return UIScreen.mainScreen().bounds.size }
  var galleryHeight:CGFloat!
  var galleryHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Lifecycle
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    ImagePickerModel.sharedInstance.selectedAsset = nil
    
    for subview in [cameraViewController.view, galleryViewController.view, bottomView, topView] {
      view.addSubview(subview)
      subview.translatesAutoresizingMaskIntoConstraints = false
    }
    
    view.backgroundColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
    
    galleryHeight = (view.bounds.size.width - 6) / 4
    setupConstraints()
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
  }
  
  public override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    
    galleryHeight = (view.bounds.size.width - 6) / 4
    galleryHeightConstraint.constant = galleryHeight
    
    galleryViewController.updateFrames()
    checkStatus()
  }
  
  public override func prefersStatusBarHidden() -> Bool {
    return true
  }
  
  // MARK: - Constraints
  
  func setupConstraints() {
    
    for attribute: NSLayoutAttribute in [.Left, .Top, .Width] {
      view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
    }

    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 44))
    
//    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .Bottom, relatedBy: .Equal, toItem: cameraViewController.view, attribute: .Top, multiplier: 1, constant: 0))

    for attribute: NSLayoutAttribute in [.Left, .Top, .Width] {
      view.addConstraint(NSLayoutConstraint(item: cameraViewController.view, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
    }
    
    view.addConstraint(NSLayoutConstraint(item: cameraViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: galleryViewController.view, attribute: .Top, multiplier: 1, constant: 0))
    
    for attribute: NSLayoutAttribute in [.Left, .Width] {
      view.addConstraint(NSLayoutConstraint(item: galleryViewController.view, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
    }

    galleryHeightConstraint = NSLayoutConstraint(item: galleryViewController.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: galleryHeight)
    view.addConstraint(galleryHeightConstraint)
    
    view.addConstraint(NSLayoutConstraint(item: galleryViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: bottomView, attribute: .Top, multiplier: 1, constant: 0))

    for attribute: NSLayoutAttribute in [.Bottom, .Left, .Width] {
      view.addConstraint(NSLayoutConstraint(item: bottomView, attribute: attribute,
        relatedBy: .Equal, toItem: view, attribute: attribute,
        multiplier: 1, constant: 0))
    }
    
    view.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 100))
    
  }
  
  // MARK: - Permissions
  
  func checkStatus() {
    let currentStatus = PHPhotoLibrary.authorizationStatus()
    guard currentStatus != .Authorized else { return }
    
    if currentStatus == .NotDetermined {
      setEnabled(false)
    }
    
    PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
      dispatch_async(dispatch_get_main_queue(), { 
        if authorizationStatus == .Denied {
          self.presentPermissionAlert()
        } else if authorizationStatus == .Authorized {
          self.permissionGranted()
        }
      })
    }
  }
  
  func presentPermissionAlert() {
    let alertController = UIAlertController(title: "Permission Denied", message: "Please allow the application to access your photo library.", preferredStyle: .Alert)
    
    let alertAction = UIAlertAction(title: "OK", style: .Default) { (action) in
      if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(settingsURL)
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    alertController.addAction(alertAction)
    alertController.addAction(cancelAction)
    
    presentViewController(alertController, animated: true, completion: nil)
  }
  
  func permissionGranted() {
    galleryViewController.fetchAssets()
    setEnabled(true)
  }
  
  func setEnabled(enabled: Bool) {
    print("set enabled: \(enabled)")
    galleryViewController.view.alpha = enabled ? 1 : 0
  }
  
  // MARK: - Helpers
  
  private func takePicture() {
    // camera take picture
    cameraViewController.takePicture {
      if self.galleryViewController.collectionSize == nil { return }
      
      self.galleryViewController.fetchAssets({ 
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
    dismissViewControllerAnimated(true, completion: nil)
    delegate?.imagePickerDidCancel(self)
  }
  
  func bottomViewDidFinish() {
    print("bottom view did finish")
    
    if let asset = ImagePickerModel.sharedInstance.selectedAsset {
      let images = ImagePickerModel.resolveAssets([asset])
      self.delegate?.imagePicker(self, didFinishPickingImages: images)
    }
    dismissViewControllerAnimated(true, completion: nil)
    
  }
  
}

// MARK: - TopViewDelegate

extension ImagePickerController: TopViewDelegate {
  
  func topViewDidChangeFlash(title: String) {
    cameraViewController.changeFlash(title)
  }
  
  func topViewDidToggleCamera() {
    cameraViewController.flipCamera()
  }

}
