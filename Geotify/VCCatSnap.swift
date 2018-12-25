//
//  ViewControllerCatSnap.swift
//  Geotify
//
//  Created by isaac on 12/24/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import UIKit
// https://turbofuture.com/cell-phones/Access-Photo-Camera-and-Library-in-Swift
class CatSnapViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    resetVals()
  }
  
  @IBOutlet weak var imagePicked: UIImageView!
  @IBOutlet weak var trackSnapButtonButton: UIButton!
  @IBOutlet weak var takeSnapButton: UIButton!
  @IBOutlet weak var saveSnapButton: UIButton!
  @IBOutlet weak var resetSnapButton: UIButton!
  
  var imgb64:String = ""
  
  func resetVals() {
    imgb64 = ""
    imagePicked.image = nil
    takeSnapButton.isHidden = false
    trackSnapButtonButton.isHidden = true
    saveSnapButton.isHidden = true
    resetSnapButton.isHidden = true
  }
  
  @IBAction func trackSnapButton(_ sender: UIButton, forEvent event: UIEvent) {
    
    print("tracking cat snap")
  
    let imageData = imagePicked.image!.jpegData(compressionQuality: 0.6)
    if imageData == nil {
      print("image data nil")
      return
    }
    imgb64 = (imageData?.base64EncodedString())!
//    let printy = (imageData?.base64EncodedString(options: .lineLength64Characters))!
//    print("printing printy")
//    print("\(printy)")

    currentTripNotes.imgB64 = imgb64
    save(manager:locMan)
    pushLocs(force:true,pushToken: pushToken)
    
    trackSnapButtonButton.isHidden = true
    saveSnapButton.isHidden = false
    resetSnapButton.isHidden = false
  }
  
  @IBAction func openCameraButton(_ sender: UIButton, forEvent event: UIEvent) {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = .camera;
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true, completion: nil)
    }
  }
  @IBAction func saveSnapButtonPushed(_ sender: UIButton, forEvent event: UIEvent) {
    print("save button pushed")
    let imageData = imagePicked.image!.jpegData(compressionQuality: 1)
    if imageData == nil {
      print("image data nil")
      return
    }
    let compressedJPGImage = UIImage(data: imageData!)
    if compressedJPGImage == nil {
      print("compimg nil")
      return
    }
    if imagePicked.image == nil {
      print("nil image")
      return
    }
    UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
    resetVals()
  }
  @IBAction func noSaveSnapButtonPushed(_ sender: UIButton, forEvent event: UIEvent) {
    resetVals()
  }
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
    let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
    imagePicked.image = image
    takeSnapButton.isHidden = true
    trackSnapButtonButton.isHidden = false
    resetSnapButton.isHidden = false
    dismiss(animated:true, completion: nil)
  }
}
