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
import SystemConfiguration

// MARK: Helper Extensions
extension UIViewController {
  func showAlert(withTitle title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

extension MKMapView {
  func zoomToUserLocation() {
    guard let coordinate = userLocation.location?.coordinate else { return }
    let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
    setRegion(region, animated: true)
  }
}

extension Date {
  static let iso8601Formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX" //cute time format
    return formatter
  }()
  var iso8601: String {
    return Date.iso8601Formatter.string(from: self)
  }
}

extension String {
  var dateFromISO8601: Date? {
    return Date.iso8601Formatter.date(from: self)
  }
}


// func isInternetAvailable() -> Bool {
//   var zeroAddress = sockaddr_in()
//   zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
//   zeroAddress.sin_family = sa_family_t(AF_INET)
//   guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
//     $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
//       SCNetworkReachabilityCreateWithAddress(nil, $0)
//     }
//   }) else {
//     return false
//   }
//   var flags: SCNetworkReachabilityFlags = []
//   if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
//     return false
//   }
//   let isReachable = flags.contains(.reachable)
//   let needsConnection = flags.contains(.connectionRequired)
//   return (isReachable && !needsConnection)
// }
