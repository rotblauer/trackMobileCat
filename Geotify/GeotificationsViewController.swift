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

struct PreferencesKeys {
  static let savedItems = "savedItems"
}

class GeotificationsViewController: UIViewController {


    @IBAction func setFieldPremade(_ sender: UIButton) {
        setCurrentTripNotes(s: sender.currentTitle!)
        setNoteField.text = getStoredCustomTripNotes();
        updatePointDisplay();
    }
    @IBOutlet weak var setNoteField: UITextField!
    @IBAction func doneField(_ sender: Any) {
        setCurrentTripNotes(s: (sender as! UITextField).text!)
        (sender as! UITextField).resignFirstResponder()
        updatePointDisplay();
    }
    func doStopTrip() {
        setCurrentTripNotes(s: "");
        setNoteField.text = getStoredCustomTripNotes();
        updatePointDisplay();
    }
    @IBAction func stopTrip(_ sender: Any) {
        if (getStoredCustomTripNotes() != "") {
            // create the alert
            let alert = UIAlertController(title: "UIAlertController", message: "Be sure you want to finish this trip.", preferredStyle: UIAlertController.Style.alert)

            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Do Stop", style: UIAlertAction.Style.default, handler: { action in
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

    var locationManager = CLLocationManager()

  override func viewDidLoad() {
    super.viewDidLoad()
 
  }

  func updatePointsCount(stringer : String) {
    pointsCountLable.text = stringer
  }

  func updateLastPoint(stringer : String) {
    lastPointLabel.text = stringer
  }
    // https://stackoverflow.com/questions/28872450/conversion-from-nstimeinterval-to-hour-minutes-seconds-milliseconds-in-swift#28872601
    func stringFromTimeInterval(interval: TimeInterval) -> NSString {

        let ti = NSInteger(-interval) // neg cuz backwards

        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)

        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
    }


  func updatePointDisplay() {
    let data = numberAndLastOfCoreDataTrackpoints()
    updatePointsCount(stringer: "\(data.count)")
    var ps : String = ""
    if data.count > 0 && data.lastPoint !== nil {
      let p = data.lastPoint
//      let _uuid = (p?.uuid)!
      let acc = String(format: "%.2f", (p?.accuracy)!)
      let lat = String(format: "%.9f", (p?.lat)!)
      let lon = String(format: "%.9f", (p?.long)!)
      let alt = String(format: "%.9f", (p?.altitude)!)
      let course = String(format: "%.3f", (p?.course)!)
      let speed = String(format: "%.9f", (p?.speed)!)
      let t = p?.time
      let currentTripDistance = String(format: "%.4f", (currentTripNotes.currentTripDistance))
      let relativeAltitude = String(format: "%.4f", (currentTripNotes.relativeAltitude))
      let pressure = String(format: "%.4f", (currentTripNotes.pressure))

//      UUID: \(_uuid)\n
      ps = "ACC: \(acc)\nLAT: \(lat)\tLON: \(lon)\nALT: \(alt)\nCOURSE: \(course)\nSPEED: \(speed)\nTIME: \(String(describing: t))\nActivity: \(currentTripNotes.activity)\tTrip: \(currentTripNotes.customNote)\nDistance: \(currentTripDistance)\nSteps: \(currentTripNotes.numberOfSteps)\tPressure: \(pressure)\nRAltitude: \(relativeAltitude)\tVERSION: V.carve"
    } else {
      ps = "No points yet."
    }
    updateLastPoint(stringer: ps)

    if (getStoredCustomTripNotes() != "") {
        tripTimeSince.text = stringFromTimeInterval(interval: getCurrentTripTime()) as String;

      let d = getCurrentTripDistance()
      let curdist = d.traveled;
      let curdistFromStart = d.fromStart;
        let meters = String(format: "%.2fme", curdist)
        let miles = String(format: "%.2fmi", curdist/1609)

      let metersFStart = String(format: "%.2fme", curdistFromStart)
      let milesFStart = String(format: "%.2fmi", curdistFromStart/1609)
        tripDistLabel.text = "o:\(meters), \(miles)\nfs:\(metersFStart), \(milesFStart)"

    } else {
        tripTimeSince.text = "";
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
    }

  @IBAction func pushPoints(_ sender: Any) {
    pushLocs()
  }

  @IBAction func switchRequireWifi(_ sender: UISwitch) {
    setRequireWifi(requireWifi: !getRequireWifi())
    sender.setOn(!getRequireWifi(), animated: true) // truthy?
  }
}

// MARK: - Location Manager Delegate
extension GeotificationsViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
  }
}
