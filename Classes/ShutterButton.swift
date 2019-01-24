//
//  ShutterButton.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit

class ShutterButton: UIButton {
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    func setupButton() {
        backgroundColor = UIColor.white
        layer.cornerRadius = 58 / 2
        addTarget(self, action: #selector(shutterButtonWasTapped(_:)), for: .touchUpInside)
        addTarget(self, action: #selector(shutterButtonDidHighlight(_:)), for: .touchDown)
    }
    
    // MARK: - Actions
    
    @objc func shutterButtonWasTapped(_ sender: UIButton) {
        backgroundColor = UIColor.white
    }
    
    @objc func shutterButtonDidHighlight(_ sender: UIButton) {
        backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1)
    }
    
}
