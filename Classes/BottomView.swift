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
        shutterButton.addTarget(self, action: #selector(shutterButtonWasTapped(_:)), for: .touchUpInside)
        return shutterButton
        }()
    
    lazy var borderShutterButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 68 / 2
        return view
    }()
    
    public lazy var doneButton: UIButton = { [unowned self] in
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 19)
        button.addTarget(self, action: #selector(doneButtonWasTapped(_:)), for: .touchUpInside)
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
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(selectedAssetDidChange(_:)), name: NSNotification.Name(rawValue: ImagePickerModel.Notifications.selectedAssetDidChange), object: nil)
    }
    
    @objc func selectedAssetDidChange(_ notification: NSNotification) {
        if ImagePickerModel.sharedInstance.selectedAsset == nil {
            doneButton.setTitle("Cancel", for: .normal)
        } else {
            doneButton.setTitle("Done", for: .normal)
        }
    }
    
    // MARK: - Layout
    
    func setupConstraints() {
        for attribute: NSLayoutConstraint.Attribute in [.centerX, .centerY] {
            addConstraint(NSLayoutConstraint(item: shutterButton, attribute: attribute, relatedBy: .equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: borderShutterButtonView, attribute: attribute, relatedBy: .equal, toItem: self, attribute: attribute, multiplier: 1, constant: 0))
        }
        
        for attribute: NSLayoutConstraint.Attribute in [.width, .height] {
            addConstraint(NSLayoutConstraint(item: shutterButton, attribute: attribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 58))
            
            addConstraint(NSLayoutConstraint(item: borderShutterButtonView, attribute: attribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 68))
            
            addConstraint(NSLayoutConstraint(item: imageStackView, attribute: attribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 58))
        }
        
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: imageStackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: -(UIScreen.main.bounds.width - (68 + UIScreen.main.bounds.width)/2)/2))
        
        addConstraint(NSLayoutConstraint(item: imageStackView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: UIScreen.main.bounds.width/4 - 68/3))
        
    }
    
    // MARK: - Actions
    
    @objc func shutterButtonWasTapped(_ sender: ShutterButton) {
        delegate?.bottomViewDidTakePicture()
    }
    
    @objc func doneButtonWasTapped(_ sender: UIButton) {
        if sender.currentTitle == "Cancel" {
            delegate?.bottomViewDidCancel()
        } else {
            delegate?.bottomViewDidFinish()
        }
    }
    
}
