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
import CoreData
import Intents
import UserNotifications
import HealthKit

var uuid:String = "unset"
var pushToken:String = "unset"
var locMan : CLLocationManager = CLLocationManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let locationManager = CLLocationManager()
  let center = UNUserNotificationCenter.current()
  let nsnotifc = UNUserNotificationCenter.current()
  static let geoCoder = CLGeocoder()
  let hkds = HKHealthStore()
  
  fileprivate func setupLocationManager() -> CLLocationManager {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManagerInstallSettings(manager: locationManager, settings: AppSettings.locationManagerSettings)
    print("location activated")
    return locationManager
  }
  
  fileprivate func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      (granted, error) in
      print("Permission granted: \(granted)")
      
    }
  }
  
  private func authorizeHealthKit() {
    if (!AppSettings.healthKitEnabled) {
      print("health kit disabled")
      return
    }
    HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
      guard authorized else {
        let baseMessage = "HealthKit authorization failed"
        if let error = error {
          print("\(baseMessage). Reason: \(error.localizedDescription)")
        } else {
          print(baseMessage)
        }
        return
      }
      startUpdatingHeartRate()
      print("HealthKit things possibly authorized")
    }
  }
  
  fileprivate func setupBatteryMonitoring() {
    if (AppSettings.batteryMonitoringEnabled) {
        UIDevice.current.isBatteryMonitoringEnabled = true
    }
  }
  
  fileprivate func setupAlertsAuthorization() {
    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    }
  }
  
  fileprivate func startLog() {
    var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let fileName = "\(Date()).log"
    let logFilePath = (documentsDirectory as NSString).appendingPathComponent(fileName)
    freopen(logFilePath.cString(using: String.Encoding.ascii)!, "a+", stderr)
    print("started log")
  }
  
  fileprivate func handleLaunchOptions(launchOpts: [UIApplication.LaunchOptionsKey : Any]?) {
    func launchedWithLocation(key: UIApplication.LaunchOptionsKey, value: Any) -> Bool {
      if (key == UIApplication.LaunchOptionsKey.location && (value as! Bool) == true) {
        return true
      }
      return false
    }
    if (launchOpts?.contains(where: launchedWithLocation) ?? false) {
      print("launched because of location update")
    } else {
      print("launched for cat reasons")
    }
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    startLog()
    
    handleLaunchOptions(launchOpts: launchOptions)
    
    // Set global instances.
    locMan = setupLocationManager()
    uuid = (UIDevice.current.identifierForVendor?.uuidString)!
    print("uuid: \(uuid)")
    
    // Requests, authorizations, and startups.
    setupAlertsAuthorization()
    setupBatteryMonitoring()
    authorizeHealthKit()
    startUpdatingActivity()
    registerForPushNotifications()
    updateNetworkConfiguration()
    UIApplication.shared.registerForRemoteNotifications() // https://www.raywenderlich.com/584-push-notifications-tutorial-getting-started
    
    return true
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data -> String in
      return String(format: "%02.2hhx", data)
    }
    
    let token = tokenParts.joined()
    print("Device Token: \(token)")
    pushToken="\(token)"
  }
  
  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register: \(error)")
  }
  
  
  //  stores trackpoints
  lazy var persistentContainer:   NSPersistentContainer = {
    let container = NSPersistentContainer(name: "TrackPoint")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    })
    
    return container
  }()
}

extension AppDelegate: CLLocationManagerDelegate {
  
  
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    // create CLLocation from the coordinates of CLVisit
    let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
    
    // Get location description
    AppDelegate.geoCoder.reverseGeocodeLocation(clLocation) { placemarks, _ in
      if let place = placemarks?.first {
        let description = "\(place)"
        
        self.newVisitReceived(visit, description: description)
      }
    }
  }
  
  // Runs when a new visit is detected
  func newVisitReceived(_ visit: CLVisit, description: String) {
    addVisit(visit: visit, place: description)
    
    let content = UNMutableNotificationContent()
    content.title = "New Visit 📌"
    content.body = description
    content.sound = UNNotificationSound.default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(identifier: "Cat visit", content: content, trigger: trigger)
    
    center.add(request, withCompletionHandler: nil)
  }
  
  
  // Runs when the location is updated
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    saveAll(locations: locations)
    pushLocs(force: false, pushToken: pushToken)
  }
}
