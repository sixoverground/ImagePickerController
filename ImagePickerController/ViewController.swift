//
//  ViewController.swift
//  ImagePickerController
//
//  Created by Craig Phares on 4/19/16.
//  Copyright © 2016 Six Overground. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet var imageView: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func imageButtonWasTapped(_ sender: AnyObject) {
    showImagePicker()
  }
  
  func showImagePicker() {
    let imagePickerController = ImagePickerController()
    imagePickerController.delegate = self
    present(imagePickerController, animated: true, completion: nil)
  }

}

extension ViewController: ImagePickerControllerDelegate {
  
  func imagePickerDidCancel(picker: ImagePickerController) {
    print("did cancel")
  }
  
  func imagePicker(picker: ImagePickerController, didFinishPickingImages images: [UIImage]) {
    print("did finish picking: \(images)")
    if let image = images.first {
      imageView.image = image
    }
  }
}

