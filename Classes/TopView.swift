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
        button.setImage(AssetManager.getImage(name: "AUTO"), for: .normal)
        button.setTitle("AUTO", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.white, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(flashButtonWasTapped(_:)), for: .touchUpInside)
        return button
        }()
    
    lazy var cameraButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setImage(AssetManager.getImage(name: "cameraIcon"), for: .normal)
        button.imageView?.contentMode = .center
        button.addTarget(self, action: #selector(cameraButtonWasTapped(_:)), for: .touchUpInside)
        return button
        }()
    
    weak var delegate: TopViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        for button in [flashButton, cameraButton] {
            button.layer.shadowColor = UIColor.black.cgColor
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
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .left,
                                         relatedBy: .equal, toItem: self, attribute: .left,
                                         multiplier: 1, constant: 11))
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: flashButton, attribute: .width,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 55))
        
        addConstraint(NSLayoutConstraint(item: cameraButton, attribute: .right,
                                         relatedBy: .equal, toItem: self, attribute: .right,
                                         multiplier: 1, constant: 7))
        
        addConstraint(NSLayoutConstraint(item: cameraButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: cameraButton, attribute: .width,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 55))
        
        addConstraint(NSLayoutConstraint(item: cameraButton, attribute: .height,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 55))
        
    }
    
    // MARK: - Actions
    
    @objc func flashButtonWasTapped(_ sender: UIButton) {
        
        currentFlashIndex += 1
        currentFlashIndex = currentFlashIndex % flashButtonTitles.count
        
        switch currentFlashIndex {
        case 1:
            sender.setTitleColor(UIColor(red: 0.98, green: 0.98, blue: 0.45, alpha: 1), for: .normal)
            sender.setTitleColor(UIColor(red: 0.52, green: 0.52, blue: 0.24, alpha: 1), for: .highlighted)
        default:
            sender.setTitleColor(UIColor.white, for: .normal)
            sender.setTitleColor(UIColor.white, for: .highlighted)
        }
        
        let newTitle = flashButtonTitles[currentFlashIndex]
        
        sender.setImage(AssetManager.getImage(name: newTitle), for: .normal)
        sender.setTitle(newTitle, for: .normal)
        
        delegate?.topViewDidChangeFlash(title: newTitle)
    }
    
    @objc func cameraButtonWasTapped(_ sender: UIButton) {
        delegate?.topViewDidToggleCamera()
    }
    
}
