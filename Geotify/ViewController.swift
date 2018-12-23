/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import CoreLocation
import CoreData

struct PreferencesKeys {
  static let savedItems = "savedItems"
}
var P = 0;
var Q = 0;
var currentStats="Locking location";
let version = catVersion()
//let picker = UIImagePickerController()

//,UIImagePickerControllerDelegate,
//UINavigationControllerDelegate
class GeotificationsViewController: UIViewController {
  //  var trackPoints: [NSManagedObject] = []
  
    @IBOutlet weak var stopButton: UIButton!
  @IBAction func setFieldPremade(_ sender: UIButton) {
    let tt = sender.currentTitle!
    if (tt == getCurrentTripCustomNote()) {
      return // don't restart same trip
    }
    setCurrentTripNotes(s: tt)
//    setNoteField.text = getStoredCustomTripNotes();
    updateNetworkConfiguration()
    updatePointDisplay();
    stopButton?.isHidden = false
  }
//  @IBOutlet weak var setNoteField: UITextField!
  @IBAction func doneField(_ sender: Any) {
    setCurrentTripNotes(s: (sender as! UITextField).text!)
    (sender as! UITextField).resignFirstResponder()
    updatePointDisplay();
  }
  func doStopTrip() {
    setCurrentTripNotes(s: "");
//    setNoteField.text = getStoredCustomTripNotes();
    updateNetworkConfiguration()
    
    updatePointDisplay();
    stopButton?.isHidden = true
  }
  
  @IBAction func stopTrip(_ sender: Any) {
    if (getStoredCustomTripNotes() != "") {
      // create the alert
      let alert = UIAlertController(title: "Stop Trip", message: "Please confirm stopping this trip.", preferredStyle: UIAlertController.Style.alert)
      
      // add the actions (buttons)
      alert.addAction(UIAlertAction(title: "STOP", style: UIAlertAction.Style.default, handler: { action in
        self.doStopTrip();
      }))
      alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { action in
        self.updatePointDisplay();
      }))
      
      // show the alert
      self.present(alert, animated: true, completion: nil)
    } else {
      updatePointDisplay();
    }
  }
  @IBOutlet weak var pointsCountLable: UILabel!
  @IBOutlet weak var pushPointsButton: UIBarButtonItem!
  @IBOutlet weak var lastPointLabel: UILabel!
  @IBOutlet weak var tripTimeSince: UILabel!
  @IBOutlet weak var tripDistLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
      (_:Timer)->Void in
      self.updatePointDisplay();
    }
    
  }
  
  func updatePointsCount(stringer : String) {
    pointsCountLable.text = stringer
  }
  
  func updateLastPoint(stringer : String) {
    lastPointLabel.text = stringer
  }
  func stringFromTimeInterval(interval: TimeInterval) -> NSString {
    
    let ti = NSInteger(-interval) // neg cuz backwards
    
    let seconds = ti % 60
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600)
    
    return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
  }
  
  func updatePointDisplay() {
    updatePointsCount(stringer: "P:\(P)Q:\(Q)")
    updateLastPoint(stringer: currentStats)
    
    if (getStoredCustomTripNotes() != "") {
      tripTimeSince.text = """
      MODE: \(getCurrentTripCustomNote()) TIME: \(stringFromTimeInterval(interval: getCurrentTripTime()) as String)
      """
      
      let d = getCurrentTripDistance()
      let curdist = d.traveled;
      let curdistFromStart = d.fromStart;
      let meters = String(format: "%.2f", curdist)
      let miles = String(format: "%.2f", curdist/1609)
      
      let metersFStart = String(format: "%.2f", curdistFromStart)
      let milesFStart = String(format: "%.2f", curdistFromStart/1609)
      tripDistLabel.text = """
      OVERALL:    \(meters) meters, \(miles) miles
      FROM START: \(metersFStart) meters, \(milesFStart) miles
      """
    }
    else {
      tripTimeSince.text = "MODE: NORMAL";
      tripDistLabel.text = "";
    }
  }
  
  @IBAction func swiper(_ sender: UISwipeGestureRecognizer) {
    updatePointDisplay()
  }
  
  // MARK: Other mapview functions
  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    updatePointDisplay()

  }
  @IBAction func zoomToCurrentLocationButton(_ sender: UIButton) {
    updatePointDisplay()
//    if UIImagePickerController.isSourceTypeAvailable(.camera) {
//      let imagePicker = UIImagePickerController()
//      imagePicker.delegate = self
//      imagePicker.sourceType = .camera;
//      imagePicker.allowsEditing = false
//      self.present(imagePicker, animated: true, completion: nil)
//    }
//    print("hiss")

  }
//  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//    imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
//    print("HI image")
//    picker.dismiss(animated:true,completion:nil)
//  }
  
  
  
  
  @IBAction func pushPoints(_ sender: Any) {
    print("time to push")
    updatePointDisplay()
    pushLocs(force:true,pushToken: pushToken)
  }
}
