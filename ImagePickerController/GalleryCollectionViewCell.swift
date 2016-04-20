//
//  GalleryCollectionViewCell.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {
  
  lazy var imageView = UIImageView()
  lazy var selectedView = UIView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
            
    for view in [imageView, selectedView] {
      view.translatesAutoresizingMaskIntoConstraints = false
      contentView.addSubview(view)
    }
    
    imageView.contentMode = .ScaleAspectFill
    imageView.clipsToBounds = true
    
    selectedView.layer.borderColor = UIColor.whiteColor().CGColor
    selectedView.layer.borderWidth = 1
    selectedView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
    selectedView.alpha = 0
    
    setupConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Constraints
  
  func setupConstraints() {
    for attribute: NSLayoutAttribute in [.Width, .Height, .CenterX, .CenterY] {
      addConstraint(NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
      addConstraint(NSLayoutConstraint(item: selectedView, attribute: attribute, relatedBy: .Equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
    }
  }
  
  // MARK: - Configuration
  
  func configureCell(image: UIImage) {
    imageView.image = image
  }
  
  // MARK: - Selected
  
//  override func setSelected(selected: Bool) {
//    super.setSelected(selected)
//    
//    if selected {
//      selectedView.alpha = 1
//    } else {
//      selectedView.alpha = 0
//    }
//  }
  
  override var selected: Bool {
    get {
      return super.selected
    }
    set {
      super.selected = newValue
      if newValue {
        selectedView.alpha = 1
      } else {
        selectedView.alpha = 0
      }
    }
  }
  
}