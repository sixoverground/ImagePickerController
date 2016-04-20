//
//  BottomView.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit

protocol BottomViewDelegate: class {
  func bottomViewDidTakePicture()
  func bottomViewDidCancel()
  func bottomViewDidFinish()
}

public class BottomView: UIView {

  lazy var shutterButton: ShutterButton = { [unowned self] in
    let shutterButton = ShutterButton()
    shutterButton.addTarget(self, action: #selector(shutterButtonWasTapped(_:)), forControlEvents: .TouchUpInside)
    return shutterButton
    }()
  
  lazy var borderShutterButtonView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clearColor()
    view.layer.borderColor = UIColor.whiteColor().CGColor
    view.layer.borderWidth = 2
    view.layer.cornerRadius = 68 / 2
    return view
    }()
  
  public lazy var doneButton: UIButton = { [unowned self] in
    let button = UIButton()
    button.setTitle("Cancel", forState: .Normal)
    button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 19)
    button.addTarget(self, action: #selector(doneButtonWasTapped(_:)), forControlEvents: .TouchUpInside)
    return button
    }()
  
  lazy var imageStackView = ImageStackView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
  
  weak var delegate: BottomViewDelegate?

  public override init(frame: CGRect) {
    super.init(frame: frame)
    
    [borderShutterButtonView, shutterButton, doneButton, imageStackView].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    backgroundColor = UIColor(red: 0.15, green: 0.19, blue: 0.24, alpha: 1)
    
    subscribe()
    
    setupConstraints()
  }
  
  required public init?(coder aDecoder: NSCoder) {
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
    if ImagePickerModel.sharedInstance.selectedAsset == nil {
      doneButton.setTitle("Cancel", forState: .Normal)
    } else {
      doneButton.setTitle("Done", forState: .Normal)
    }
  }
  
  // MARK: - Layout
  
  func setupConstraints() {
    for attribute: NSLayoutAttribute in [.CenterX, .CenterY] {
      addConstraint(NSLayoutConstraint(item: shutterButton, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
      
      addConstraint(NSLayoutConstraint(item: borderShutterButtonView, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
    }
    
    for attribute: NSLayoutAttribute in [.Width, .Height] {
      addConstraint(NSLayoutConstraint(item: shutterButton, attribute: attribute, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 58))
      
      addConstraint(NSLayoutConstraint(item: borderShutterButtonView, attribute: attribute, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 68))
      
      addConstraint(NSLayoutConstraint(item: imageStackView, attribute: attribute, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 58))
    }
    
    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
    
    addConstraint(NSLayoutConstraint(item: imageStackView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1, constant: 0))
    
    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: -(UIScreen.mainScreen().bounds.width - (68 + UIScreen.mainScreen().bounds.width)/2)/2))
    
    addConstraint(NSLayoutConstraint(item: imageStackView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: UIScreen.mainScreen().bounds.width/4 - 68/3))
    
  }
  
  // MARK: - Actions
  
  func shutterButtonWasTapped(sender: ShutterButton) {
    delegate?.bottomViewDidTakePicture()
  }
  
  func doneButtonWasTapped(sender: UIButton) {
    if sender.currentTitle == "Cancel" {
      delegate?.bottomViewDidCancel()
    } else {
      delegate?.bottomViewDidFinish()
    }
  }
  
}
