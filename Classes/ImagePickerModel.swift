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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Notifications.selectedAssetDidChange), object: self)
        }
    }
    
    public static func fetch(completion: @escaping (_ assets: [PHAsset]) -> Void) {
        
        let fetchOptions = PHFetchOptions()
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        var fetchResult: PHFetchResult<AnyObject>?
        
        guard authorizationStatus == .authorized else { return }
        
        if fetchResult == nil {
            fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) as? PHFetchResult<AnyObject>
        }
        
        if fetchResult?.count ?? 0 > 0 {
            var assets = [PHAsset]()
            fetchResult?.enumerateObjects({ (object, index, stop) in
                if let asset = object as? PHAsset {
                    assets.insert(asset, at: 0)
                }
            })
            DispatchQueue.main.async {
                completion(assets)
            }
        }
    }
    
    public static func resolveAsset(asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
            if let info = info, info["PHImageFileUTIKey"] == nil {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }
    }
    
    public static func resolveAssets(assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { (image, info) in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
    
}
