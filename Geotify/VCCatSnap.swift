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
  
  func startSnapping() {
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = .camera;
      imagePicker.allowsEditing = false
      self.present(imagePicker, animated: true, completion: nil)
    }
  }
  
  @IBAction func didTap(_ sender: UITapGestureRecognizer) {
    startSnapping()
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
    currentTripNotes.imgB64 = ""
    
    trackSnapButtonButton.isHidden = true
    saveSnapButton.isHidden = false
    resetSnapButton.isHidden = false
  }
  
  @IBAction func openCameraButton(_ sender: UIButton, forEvent event: UIEvent) {
    startSnapping()
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
    imagePicked.image = image.fixedOrientation()
    takeSnapButton.isHidden = true
    trackSnapButtonButton.isHidden = false
    resetSnapButton.isHidden = false
    dismiss(animated:true, completion: nil)
  }
}

// https://gist.github.com/schickling/b5d86cb070130f80bb40#gistcomment-2393934
extension UIImage {
  
  func fixedOrientation() -> UIImage? {
    
    guard imageOrientation != UIImage.Orientation.up else {
      //This is default orientation, don't need to do anything
      return self.copy() as? UIImage
    }
    
    guard let cgImage = self.cgImage else {
      //CGImage is not available
      return nil
    }
    
    guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
      return nil //Not able to create CGContext
    }
    
    var transform: CGAffineTransform = CGAffineTransform.identity
    
    switch imageOrientation {
    case .down, .downMirrored:
      transform = transform.translatedBy(x: size.width, y: size.height)
      transform = transform.rotated(by: CGFloat.pi)
      break
    case .left, .leftMirrored:
      transform = transform.translatedBy(x: size.width, y: 0)
      transform = transform.rotated(by: CGFloat.pi / 2.0)
      break
    case .right, .rightMirrored:
      transform = transform.translatedBy(x: 0, y: size.height)
      transform = transform.rotated(by: CGFloat.pi / -2.0)
      break
    case .up, .upMirrored:
      break
    }
    
    //Flip image one more time if needed to, this is to prevent flipped image
    switch imageOrientation {
    case .upMirrored, .downMirrored:
      transform.translatedBy(x: size.width, y: 0)
      transform.scaledBy(x: -1, y: 1)
      break
    case .leftMirrored, .rightMirrored:
      transform.translatedBy(x: size.height, y: 0)
      transform.scaledBy(x: -1, y: 1)
    case .up, .down, .left, .right:
      break
    }
    
    ctx.concatenate(transform)
    
    switch imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
    default:
      ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
      break
    }
    
    guard let newCGImage = ctx.makeImage() else { return nil }
    return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
  }
}
