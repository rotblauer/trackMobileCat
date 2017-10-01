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
  
  @IBOutlet weak var pointsCountLable: UILabel!
  @IBOutlet weak var pushPointsButton: UIBarButtonItem!
    @IBOutlet weak var lastPointLabel: UILabel!
  
    var locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // 1
    locationManager.delegate = self
    // 2
    locationManager.requestAlwaysAuthorization()
  }
  
  func updatePointsCount(stringer : String) {
    pointsCountLable.text = stringer
  }
  
  func updateLastPoint(stringer : String) {
    lastPointLabel.text = stringer
  }

  
  // MARK: Other mapview functions
  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    let data = numberAndLastOfCoreDataTrackpoints()
    updatePointsCount(stringer: "\(data.count)")
    
    if data.lastPoint !== nil {
      let p = data.lastPoint
      let acc = String(format: "%.2f", (p.accuracy))
      let lat = String(format: "%.9f", (p.lat))
      let lon = String(format: "%.9f", (p.long))
      let alt = String(format: "%.9f", (p.altitude))
      let course = String(format: "%.3f", (p.course))
      let speed = String(format: "%.9f", (p.speed))
      let t = p.time
      
      let ps = "ACC: \(acc)\nLAT: \(lat)\n LON: \(lon)\n ALT: \(alt)\n COURSE: \(course)\n SPEED: \(speed)\n TIME: \(t)"
      
      updateLastPoint(stringer: ps)
    }
  }
  
    @IBAction func pushPoints(_ sender: Any) {
      pushLocs()
    }
}

// MARK: - Location Manager Delegate
extension GeotificationsViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//    mapView.showsUserLocation = status == .authorizedAlways
  }
}

