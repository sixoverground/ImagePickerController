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
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.white.cgColor
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
        
        for attribute: NSLayoutConstraint.Attribute in [.left, .top, .right, .bottom] {
            addConstraint(NSLayoutConstraint(item: imageView, attribute: attribute, relatedBy: .equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Notifications
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(selectedAssetDidChange(_:)), name: NSNotification.Name(rawValue: ImagePickerModel.Notifications.selectedAssetDidChange), object: nil)
    }
    
    @objc func selectedAssetDidChange(_ notification: NSNotification) {
        if let sender = notification.object as? ImagePickerModel {
            if let asset = sender.selectedAsset {
                renderViews(asset: asset)
            } else {
                self.imageView.image = nil
                self.imageView.alpha = 0
            }
        }
    }
    
    // MARK: - Helpers
    
    func renderViews(asset: PHAsset) {
        ImagePickerModel.resolveAsset(asset: asset, size: CGSize(width: 58, height: 58)) { (image) in
            self.imageView.image = image
            self.imageView.alpha = 1
        }
    }
    
}
