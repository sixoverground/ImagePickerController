//
//  AssetManager.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/20/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import Foundation
import UIKit

public class AssetManager {
  
  public static func getImage(name: String) -> UIImage {
    let traitCollection = UITraitCollection(displayScale: 3)
    var bundle = NSBundle(forClass: AssetManager.self)
    
    if let bundlePath = bundle.resourcePath?.stringByAppendingString("/ImagePickerController.bundle"), resourceBundle = NSBundle(path: bundlePath) {
      bundle = resourceBundle
    }
    
    return UIImage(named: name, inBundle: bundle, compatibleWithTraitCollection: traitCollection) ?? UIImage()
  }
  
}
