//
//  TopView.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit

protocol TopViewDelegate: class {
  func topViewDidChangeFlash(title: String)
  func topViewDidToggleCamera()
}

class TopView: UIView {
  
  var currentFlashIndex = 0
  let flashButtonTitles = ["AUTO", "ON", "OFF"]
  
  lazy var flashButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setImage(AssetManager.getImage("AUTO"), forState: .Normal)
    button.setTitle("AUTO", forState: .Normal)
    button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
    button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
    button.contentHorizontalAlignment = .Left
    button.addTarget(self, action: #selector(flashButtonWasTapped(_:)), forControlEvents: .TouchUpInside)
    return button
    }()
  
  lazy var cameraButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setImage(AssetManager.getImage("cameraIcon"), forState: .Normal)
    button.imageView?.contentMode = .Center
    button.addTarget(self, action: #selector(cameraButtonWasTapped(_:)), forControlEvents: .TouchUpInside)
    return button
    }()
  
  weak var delegate: TopViewDelegate?

  // MARK: - Initializers
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    for button in [flashButton, cameraButton] {
      button.layer.shadowColor = UIColor.blackColor().CGColor
      button.layer.shadowOpacity = 0.5
      button.layer.shadowOffset = CGSize(width: 0, height: 1)
      button.layer.shadowRadius = 1
      button.translatesAutoresizingMaskIntoConstraints = false
      addSubview(button)
    }
    
    
    
//    backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    
    setupConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Layout
  
  func setupConstraints() {
    
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Left,
      relatedBy: .Equal, toItem: self, attribute: .Left,
      multiplier: 1, constant: 11))
    
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))
    
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 55))
    
    addConstraint(NSLayoutConstraint(item: cameraButton, attribute: .Right,
      relatedBy: .Equal, toItem: self, attribute: .Right,
      multiplier: 1, constant: 7))
    
    addConstraint(NSLayoutConstraint(item: cameraButton, attribute: .CenterY,
      relatedBy: .Equal, toItem: self, attribute: .CenterY,
      multiplier: 1, constant: 0))
    
    addConstraint(NSLayoutConstraint(item: cameraButton, attribute: .Width,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 55))
    
    addConstraint(NSLayoutConstraint(item: cameraButton, attribute: .Height,
      relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute,
      multiplier: 1, constant: 55))
    
  }
  
  // MARK: - Actions
  
  func flashButtonWasTapped(sender: UIButton) {
    
    currentFlashIndex += 1
    currentFlashIndex = currentFlashIndex % flashButtonTitles.count
    
    switch currentFlashIndex {
    case 1:
      sender.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.45, alpha: 1), forState: .Normal)
      sender.setTitleColor(UIColor(red: 0.52, green: 0.52, blue: 0.24, alpha: 1), forState: .Highlighted)
    default:
      sender.setTitleColor(UIColor.whiteColor(), forState: .Normal)
      sender.setTitleColor(UIColor.whiteColor(), forState: .Highlighted)
    }
    
    let newTitle = flashButtonTitles[currentFlashIndex]
    
    sender.setImage(AssetManager.getImage(newTitle), forState: .Normal)
    sender.setTitle(newTitle, forState: .Normal)
    
    delegate?.topViewDidChangeFlash(newTitle)
  }

  func cameraButtonWasTapped(sender: UIButton) {
    delegate?.topViewDidToggleCamera()
  }
  
}
