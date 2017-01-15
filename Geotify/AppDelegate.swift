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
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let locationManager = CLLocationManager()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.startUpdatingLocation()
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = 50.0; //meters move per update

    application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
    UIApplication.shared.cancelAllLocalNotifications()
    return true
  }
  
  func handleEvent(forRegion region: CLRegion!) {
    // Show an alert if application is active
    if UIApplication.shared.applicationState == .active {
      guard let message = note(fromRegionIdentifier: region.identifier) else { return }
      window?.rootViewController?.showAlert(withTitle: nil, message: message)
    } else {
      // Otherwise present a local notification
      let notification = UILocalNotification()
      notification.alertBody = note(fromRegionIdentifier: region.identifier)
      notification.soundName = "Default"
      UIApplication.shared.presentLocalNotificationNow(notification)
    }
  }
  
  func note(fromRegionIdentifier identifier: String) -> String? {
    let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
    let geotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Geotification }
    let index = geotifications?.index { $0?.identifier == identifier }
    return index != nil ? geotifications?[index!]?.note : nil
  }
  
}
extension Date {
  static let iso8601Formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
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


extension AppDelegate: CLLocationManagerDelegate {
  
  // Runs when the location is updated
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print(manager.location!.coordinate.latitude)
    print( manager.location!.coordinate.longitude)
    print(manager.location!.speed)
    print(manager.location!.altitude)
    print(manager.location!.course)
    print(UIDevice.current.name)
    
    let json = NSMutableDictionary()
    json.setValue(UIDevice.current.name, forKey: "name"); //set all your values..
    json.setValue(manager.location!.coordinate.latitude, forKey: "lat");
    json.setValue(manager.location!.coordinate.longitude, forKey: "long");
    json.setValue(manager.location!.horizontalAccuracy, forKey: "accuracy");
    json.setValue(manager.location!.altitude, forKey: "elevation");
    json.setValue(manager.location!.speed, forKey: "speed");
    json.setValue(manager.location!.course, forKey: "heading");
    json.setValue(Date().iso8601 , forKey: "time");

    var request = URLRequest(url: URL(string: "http://localhost:8080/populate/")!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try! JSONSerialization.data(withJSONObject: json, options: [])
    //http://highaltitudehacks.com/2016/06/23/ios-application-security-part-46-app-transport-security/
    
    URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
      if error != nil {
        print(error ?? "NONE")
      } else {
        do {
          guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else { return }
          
          guard let errors = json?["errors"] as? [[String: Any]] else { return }
          if errors.count > 0 {
            print(errors)
            return
          } else {
          }
        }
      }
    }).resume()
    
//    {"name":"","lat":52.472254,"long":13.398756,"accuracy":0,"elevation":0,"speed":0,"tilt":0,"heading":0,"heartrate":0,"time":"2017-01-15T14:05:00.367100976-06:00","notes":""}
//    
    //TODO update distance filter proportional to speed
    
//    LongitudeGPS = String(format: "%.10f", manager.location!.coordinate.longitude)
//    speedGPS = String(format: "%.3f", manager.location!.speed)
//    Altitude = String(format: "%.3f", manager.location!.altitude)
//    Course = String(format: "%.3f", manager.location!.course)
  
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleEvent(forRegion: region)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
      handleEvent(forRegion: region)
    }
  }
}

