//
//  ImagePickerModel.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import PhotosUI

public class ImagePickerModel {
  
  static let sharedInstance = ImagePickerModel()
  private init() {}
  
  public struct Notifications {
    public static let selectedAssetDidChange = "selectedAssetDidChange"
  }
  
  private let selectedAssetKey = "selectedAsset"
  
  public var selectedAsset: PHAsset? {
    didSet {
      NSNotificationCenter.defaultCenter().postNotificationName(Notifications.selectedAssetDidChange, object: self, userInfo: nil)
    }
  }

  public static func fetch(completion: (assets: [PHAsset]) -> Void) {
    
    let fetchOptions = PHFetchOptions()
    let authorizationStatus = PHPhotoLibrary.authorizationStatus()
    var fetchResult: PHFetchResult?
    
    guard authorizationStatus == .Authorized else { return }
    
    if fetchResult == nil {
      fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
    }
        
    if fetchResult?.count > 0 {
      var assets = [PHAsset]()
      fetchResult?.enumerateObjectsUsingBlock({ (object, index, stop) in
        if let asset = object as? PHAsset {
          assets.insert(asset, atIndex: 0)
        }
      })
      
      dispatch_async(dispatch_get_main_queue()) {
        completion(assets: assets)
      }
    }
  }
  
  public static func resolveAsset(asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), completion: (image: UIImage?) -> Void) {
    let imageManager = PHImageManager.defaultManager()
    let requestOptions = PHImageRequestOptions()
    
    imageManager.requestImageForAsset(asset, targetSize: size, contentMode: .AspectFill, options: requestOptions) { (image, info) in
      if let info = info where info["PHImageFileUTIKey"] == nil {
        dispatch_async(dispatch_get_main_queue(), { 
          completion(image: image)
        })
      }
    }
  }
  
  public static func resolveAssets(assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
    let imageManager = PHImageManager.defaultManager()
    let requestOptions = PHImageRequestOptions()
    requestOptions.synchronous = true
    
    var images = [UIImage]()
    for asset in assets {
      imageManager.requestImageForAsset(asset, targetSize: size, contentMode: .AspectFill, options: requestOptions) { (image, info) in
        if let image = image {
          images.append(image)
        }
      }
    }
    return images
  }
  
}