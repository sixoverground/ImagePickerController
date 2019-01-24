//
//  GalleryViewController.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit
import Photos

class GalleryViewController: UIViewController {
    
    let CellIdentifier = "GalleryCollectionViewCell"
    
    lazy var collectionView: UICollectionView = { [unowned self] in
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsMultipleSelection = true
        
        return collectionView
        }()
    
    lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        layout.sectionInset = UIEdgeInsets.zero
        return layout
        }()
    
    lazy var assets = [PHAsset]()
    
    var collectionSize: CGSize?
    
    // MARK: - Initializers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        for attribute: NSLayoutConstraint.Attribute in [.left, .top, .right, .bottom] {
            view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: attribute, relatedBy: .equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
        }
        
        subscribe()
        
        fetchAssets()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionSize = CGSize(width: view.frame.height, height: view.frame.height)
        collectionView.reloadData()
    }
    
    // MARK: - Layout
    
    func updateFrames() {
        //    view.setNeedsLayout()
        //    collectionView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        //    collectionSize = CGSize(width: view.frame.height, height: view.frame.height)
        //    collectionView.reloadData()
    }
    
    // MARK: - Notifications
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(selectedAssetDidChange(_:)), name: NSNotification.Name(rawValue: ImagePickerModel.Notifications.selectedAssetDidChange), object: nil)
    }
    
    @objc func selectedAssetDidChange(_ notification: NSNotification) {
        if let asset = ImagePickerModel.sharedInstance.selectedAsset {
            if let index = assets.firstIndex(of: asset) {
                let indexPath = NSIndexPath(row: index, section: 0)
                collectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: [])
            }
        }
    }
    
    // MARK: - Assets
    
    func fetchAssets(completion: (() -> Void)? = nil) {
        ImagePickerModel.fetch { (assets) in
            self.assets.removeAll()
            self.assets.append(contentsOf: assets)
            self.collectionView.reloadData()
            completion?()
        }
    }
    
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath) as? GalleryCollectionViewCell else { return UICollectionViewCell() }
        
        let asset = assets[indexPath.row]
        
        var assetSize = CGSize(width: 160, height: 240)
        if let collectionSize = collectionSize {
            assetSize = collectionSize
        }
        
        ImagePickerModel.resolveAsset(asset: asset, size: assetSize) { (image) in
            if let image = image {
                cell.configureCell(image: image)
            }
        }
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("did select")
        //    guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? GalleryCollectionViewCell else { return }
        
        if let indexPaths = collectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                collectionView.deselectItem(at: indexPath, animated: true)
            }
        }
        collectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: [])
        
        let asset = assets[indexPath.row]
        
        ImagePickerModel.resolveAsset(asset: asset) { (image) in
            guard let _ = image else { return }
            
            ImagePickerModel.sharedInstance.selectedAsset = asset
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("did deselect")
        ImagePickerModel.sharedInstance.selectedAsset = nil
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let collectionSize = collectionSize else { return .zero }
        return collectionSize
    }
}
