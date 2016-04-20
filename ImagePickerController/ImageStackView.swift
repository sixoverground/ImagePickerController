//
//  ImageStackView.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/20/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit
import Photos

class ImageStackView: UIView {

  lazy var imageView: UIImageView = {
    let view = UIImageView()
    view.layer.cornerRadius = 3
    view.contentMode = .ScaleAspectFill
    view.clipsToBounds = true
    view.layer.borderColor = UIColor.whiteColor().CGColor
    view.layer.borderWidth = 1
    view.alpha = 0
    return view
  }()
  
  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    subscribe()
    
    addSubview(imageView)
    
//    imageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    
    for attribute: NSLayoutAttribute in [.Left, .Top, .Right, .Bottom] {
      addConstraint(NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Notifications
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func subscribe() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(selectedAssetDidChange(_:)), name: ImagePickerModel.Notifications.selectedAssetDidChange, object: nil)
  }
  
  func selectedAssetDidChange(notification: NSNotification) {
    if let sender = notification.object as? ImagePickerModel {
      if let asset = sender.selectedAsset {
        renderViews(asset)
      } else {
        self.imageView.image = nil
        self.imageView.alpha = 0
      }
    }
  }

  // MARK: - Helpers
  
  func renderViews(asset: PHAsset) {
    ImagePickerModel.resolveAsset(asset, size: CGSize(width: 58, height: 58)) { (image) in
      self.imageView.image = image
      self.imageView.alpha = 1
    }
  }
  
}
