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
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionViewLayout)
    collectionView.dataSource = self
    collectionView.delegate = self
    
    collectionView.allowsMultipleSelection = true
    
    return collectionView
    }()
  
  lazy var collectionViewLayout: UICollectionViewLayout = { [unowned self] in
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .Horizontal
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2
    layout.sectionInset = UIEdgeInsetsZero
    return layout
    }()
  
  lazy var assets = [PHAsset]()
  
  var collectionSize: CGSize?
  
  // MARK: - Initializers
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.registerClass(GalleryCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
    view.addSubview(collectionView)
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    for attribute: NSLayoutAttribute in [.Left, .Top, .Right, .Bottom] {
      view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1, constant: 0))
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
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  func subscribe() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(selectedAssetDidChange(_:)), name: ImagePickerModel.Notifications.selectedAssetDidChange, object: nil)
  }
  
  func selectedAssetDidChange(notification: NSNotification) {
    if let asset = ImagePickerModel.sharedInstance.selectedAsset {
      if let index = assets.indexOf(asset) {
        let indexPath = NSIndexPath(forRow: index, inSection: 0)
        collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
      }
    }
  }
  
  // MARK: - Assets
  
  func fetchAssets(completion: (() -> Void)? = nil) {
    ImagePickerModel.fetch { (assets) in
      self.assets.removeAll()
      self.assets.appendContentsOf(assets)
      self.collectionView.reloadData()
      completion?()
    }
  }
  
}

// MARK: - UICollectionViewDataSource

extension GalleryViewController: UICollectionViewDataSource {
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return assets.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as? GalleryCollectionViewCell else { return UICollectionViewCell() }
    
    let asset = assets[indexPath.row]
    
    var assetSize = CGSize(width: 160, height: 240)
    if let collectionSize = collectionSize {
      assetSize = collectionSize
    }
    
    ImagePickerModel.resolveAsset(asset, size: assetSize) { (image) in
      if let image = image {
        cell.configureCell(image)
      }
    }
    
    return cell
  }
  
}

// MARK: - UICollectionViewDelegate

extension GalleryViewController: UICollectionViewDelegate {
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    print("did select")
//    guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? GalleryCollectionViewCell else { return }
    
    if let indexPaths = collectionView.indexPathsForSelectedItems() {
      for indexPath in indexPaths {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
      }
    }
    collectionView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
    
    let asset = assets[indexPath.row]
    
    ImagePickerModel.resolveAsset(asset) { (image) in
      guard let _ = image else { return }
      
      ImagePickerModel.sharedInstance.selectedAsset = asset
    }
  }
  
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    print("did deselect")
    ImagePickerModel.sharedInstance.selectedAsset = nil
  }
  
}

// MARK: - UICollectionViewDelegateFlowLayout

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    guard let collectionSize = collectionSize else { return CGSizeZero }
    return collectionSize
  }
}