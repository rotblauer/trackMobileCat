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
import CoreBluetooth

var uuid:String = "unset"
var uuidN:UInt = 0 //
var pushToken:String = "unset"
var locMan : CLLocationManager = CLLocationManager()
var btMan : CBPeripheralManager = CBPeripheralManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let locationManager = CLLocationManager()
//  let btManager = CBPeripheralManager(delegate: AppDelegate, queue: nil)!
  let btManager = CBPeripheralManager()
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
  
  fileprivate func setupBluetoothManager() -> CBPeripheralManager {
    let btAuthStatus = CBPeripheralManager.authorizationStatus()
//    if btAuthStatus != .authorized {
//      print(":( bluetooth manager not authorized")
//      return btManager
//    }
    var s:String = ""
    switch btAuthStatus {
    case .authorized:
      s = "authorized"
    case .denied:
      s = "denied"
    case .notDetermined:
      s = "not determined"
    case .restricted:
      s = "restricted"
    }
    print("btman: \(s)")
    return btManager
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
  
  fileprivate func assignUUIDs() {
    uuid = (UIDevice.current.identifierForVendor?.uuidString)!
    print("uuid: \(uuid)")
    
    uuidN = UInt((UIDevice.current.identifierForVendor?.hashValue)!)
    print("uuidN: \(uuidN)")
  }
  
  fileprivate func startBeaconingServices() {
    startBeaconMonitoringIfEnabled(locman: locMan)
    startBeaconAdvertisingIfEnabled(btman: btMan)
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    startLog()
    
    handleLaunchOptions(launchOpts: launchOptions)
    
    // Set global instances.
    locMan = setupLocationManager()
    btMan = setupBluetoothManager()
    assignUUIDs()
    
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
    
    var isArrival:Bool // departureSinceArrival is either too-big or impossibly-before
    let departureSinceArrival = visit.departureDate.timeIntervalSince(visit.arrivalDate)
    isArrival = departureSinceArrival > 60*60*24*365 || departureSinceArrival < 0
    
    let content = UNMutableNotificationContent()
    if isArrival {
        content.title = "New Arrival 📌"
    } else {
        content.title = "New Visit 📌"
    }
    
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
  
  // Runs when a region is entered
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLBeaconRegion {
      // Start ranging only if the feature is available.
      // FIXME: maybe don't care about ranging availability; might be just enough to know they're there
      if CLLocationManager.isRangingAvailable() {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        
        // Store the beacon so that ranging can be stopped on demand.
        handleBeaconDidEnterRegion(region: (region as! CLBeaconRegion))
      }
    }
  }
  
  // Runs when a region is exited
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLBeaconRegion {
      // Stop ranging only if the feature is available.
      if CLLocationManager.isRangingAvailable() {
        handleBeaconDidExitRegion(locman: locMan, region: region as! CLBeaconRegion)
      }
    }
  }
  
  // Acting on the nearest beacon
  func locationManager(_ manager: CLLocationManager,
                       didRangeBeacons beacons: [CLBeacon],
                       in region: CLBeaconRegion) {
    // TODO: collect all beacons, not just closest
    if beacons.count > 0 {
      let nearestBeacon = beacons.first!
      let major = CLBeaconMajorValue(truncating: nearestBeacon.major)
      let minor = CLBeaconMinorValue(truncating: nearestBeacon.minor)
      
      print("did range nearest beacon: [\(nearestBeacon.proximity)] \(major).\(minor)")
      
//      switch nearestBeacon.proximity {
//      case .near, .immediate:
//        // Display information about the relevant exhibit.
//        displayInformationAboutExhibit(major: major, minor: minor)
//        break
//      case .far:
//      case .unknown:
//      default:
//        // Dismiss exhibit information, if it is displayed.
//        dismissExhibit(major: major, minor: minor)
//        break
//      }
    }
  }

}
