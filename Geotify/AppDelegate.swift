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
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.distanceFilter = 5.0; //5 meters move per update

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

extension AppDelegate: CLLocationManagerDelegate {

  // Runs when the location is updated
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    NSLog("HFID")


    // https://github.com/varshylmobile/LocationManager/blob/master/LocationManager.swift
    let arrayOfLocation = locations as NSArray
    let location = arrayOfLocation.lastObject as! CLLocation
    let coordLatLon = location.coordinate

    latitude  = coordLatLon.latitude
    longitude = coordLatLon.longitude

    // latitudeAsString  = coordLatLon.latitude.description
    // longitudeAsString = coordLatLon.longitude.description

    // http://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift
    // json in body here
    // good old rayban https://www.raywenderlich.com/120442/swift-json-tutorial
    // and http://stackoverflow.com/questions/29512839/create-json-in-swift
    let json: [String: AnyObject] = [
      "name": "kitty",
      "lat": latitude,
      "long": longitude
      //andmoar

      // "altitude":
      // "transfer": [
      //   "startDate": "10/04/2015 12:45",
      //   "endDate": "10/04/2015 16:00"
      // ],
      // "custom": savedData

    ]

    let jsonData = try? JSONSerialization.data(withJSONObject: json)

    // create post request
    let url = URL(string: "http://cattrack-155019.appspot.com/populate/")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // http://stackoverflow.com/questions/39929513/http-post-request-with-json
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

    // insert json data to the request
    request.httpBody = jsonData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJSON = responseJSON as? [String: Any] {
            print(responseJSON)
        }
    }


    // ------

    //but this has caps where others don't. don't trust it so much.
    // // http://stackoverflow.com/questions/24566180/how-to-post-a-json-with-new-apple-swift-language
    // // // create the request & response
    // var request = NSMutableURLRequest(URL: NSURL(string: "http://requestb.in/1ema2pl1"), cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
    // var response: NSURLResponse?
    // var error: NSError?

    // // create some JSON data and configure the request
    // let jsonString = "json=[{\"str\":\"Hello\",\"num\":1},{\"str\":\"Goodbye\",\"num\":99}]"
    // request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
    // request.HTTPMethod = "POST"
    // request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // // send the request
    // NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)

    // // look at the response
    // if let httpResponse = response as? NSHTTPURLResponse {
    //     println("HTTP response: \(httpResponse.statusCode)")
    // } else {
    //     println("No HTTP response")
    // }
    // //
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
