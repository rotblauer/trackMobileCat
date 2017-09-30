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
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var pointsCountLable: UILabel!
  
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
  
  func addPolyPoints() {
    let tpoints : [TrackPoint] = fetchPointsFromCoreData()!
    var points = [CLLocationCoordinate2D]()
    
    for p in tpoints {
      let coord = CLLocationCoordinate2DMake(CLLocationDegrees(p.lat), CLLocationDegrees(p.long))
      points.append(coord)
    }
  
    let polyline = MKPolyline(coordinates: &points, count: points.count)
    
    mapView.add(polyline)
  }
  
  // MARK: Other mapview functions
  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToUserLocation()
    let c = numberOfCoreDataTrackpoints()
    updatePointsCount(stringer: "\(c)")
    addPolyPoints()
  }
  
  @IBAction func pushPoints(sender: AnyObject) {
    pushLocs()
  }
}

// MARK: - Location Manager Delegate
extension GeotificationsViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    mapView.showsUserLocation = status == .authorizedAlways
  }
}

// MARK: - MapView Delegate
extension GeotificationsViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKCircle {
      let circleRenderer = MKCircleRenderer(overlay: overlay)
      circleRenderer.lineWidth = 1.0
      circleRenderer.strokeColor = .purple
      circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
      return circleRenderer
    }
    if overlay is MKPolyline {
      let polylineView = MKPolylineRenderer(overlay: overlay)
      
      polylineView.lineWidth = CGFloat(0.5)
      polylineView.lineJoin = CGLineJoin.round
      polylineView.lineCap = CGLineCap.round
      polylineView.strokeColor = UIColor.blue
      
      return polylineView
    }
    return MKOverlayRenderer(overlay: overlay)
  }
  
}
