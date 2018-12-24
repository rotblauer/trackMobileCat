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
var uuidN1:UInt16 = 0 //
var uuidN2:UInt16 = 0 //
var pushToken:String = "unset"
var locMan : CLLocationManager = CLLocationManager()
var btCentralMan:CBCentralManager!
var btPeripheralManager: CBPeripheralManager!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let locationManager = CLLocationManager()
//  let btManager = CBPeripheralManager(delegate: AppDelegate, queue: nil)!
  
  let center = UNUserNotificationCenter.current()
  let nsnotifc = UNUserNotificationCenter.current()
  static let geoCoder = CLGeocoder()
  let hkds = HKHealthStore()
  
  fileprivate func setupLocationManager() -> CLLocationManager {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    // TODO load from peristant
    locationManagerInstallSettings(manager: locationManager, settings: AppSettings.locationManagerSettings)
    print("location activated")
    return locationManager
  }
  
  fileprivate func setupBluetoothManager() {
    btPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
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
    
    let uuidHex = uuid.replacingOccurrences(of: "-", with: "")
//    print("uuidHex: \(uuidHex)")
    
    uuidN1 = UInt16(uuidHex.prefix(4).lowercased(), radix: 16)!
    uuidN2 = UInt16(uuidHex.suffix(4).lowercased(), radix: 16)!
    print("uuidN1.2: \(uuidN1).\(uuidN2)")
  }
  
  fileprivate func startBeaconingServices() {
    startBeaconMonitoringIfEnabled(locman: locMan)
    startBeaconAdvertisingIfEnabled(btman: btPeripheralManager)
  }
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    startLog()
    
    handleLaunchOptions(launchOpts: launchOptions)
    
    // Set global instances.
    assignUUIDs()
    loadSavedSettings()
    loadLM()
    
    locMan = setupLocationManager()
    setupBluetoothManager()
    
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
    var container = NSPersistentContainer(name: "CatTracksData")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        print("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
//  //  stores settings
//  lazy var persistentContainer:   NSPersistentContainer = {
//
//    return container
//  }()
}

extension AppDelegate: CBPeripheralManagerDelegate {
  
  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    
    var statusMessage = ""
    
    switch peripheral.state {
    case .poweredOn:
      statusMessage = "Bluetooth Status: Turned On"
      startBeaconingServices()
      break
    case .poweredOff:
//      if isBroadcasting {
//        switchBroadcastingState(self)
//      }
      statusMessage = "Bluetooth Status: Turned Off"
      break
    case .resetting:
      statusMessage = "Bluetooth Status: Resetting"
      break
    case .unauthorized:
      statusMessage = "Bluetooth Status: Not Authorized"
      break
    case .unsupported:
      statusMessage = "Bluetooth Status: Not Supported"
      break
    default:
      statusMessage = "Bluetooth Status: Unknown"
      break
    }
    print("bt peripheral manager state: \(statusMessage)")
  }
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
    savePointsToCoreData(locations: locations)
    pushLocs(force: false, pushToken: pushToken)
  }
  
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    locationManager.requestState(for: region)
  }

  func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    if region is CLBeaconRegion {
      if state == .inside {
        print("inside region")
        handleDidEnterBeaconRegion(locman: locMan, region: region as! CLBeaconRegion)
      } else {
        print("outside beacon region")
        handleDidExitBeaconRegion(locman: locMan, region: region  as! CLBeaconRegion)
      }
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print(error)
  }
  
  func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
    print(error)
  }
  
  // Runs when a region is entered
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLBeaconRegion {
      print("beacon region entered...")
      // Start ranging only if the feature is available.
      // FIXME: maybe don't care about ranging availability; might be just enough to know they're there
      if CLLocationManager.isRangingAvailable() {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        print("ranging available")
        // Store the beacon so that ranging can be stopped on demand.
        handleDidEnterBeaconRegion(locman: locMan, region: (region as! CLBeaconRegion))
      } else {
        print("no ranging available")
        // Store the beacon so that ranging can be stopped on demand.
        handleDidEnterBeaconRegion(locman: locMan, region: (region as! CLBeaconRegion))
      }
    }
  }
  
  // Runs when a region is exited
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLBeaconRegion {
      print("beacon region exited...")
      // Stop ranging only if the feature is available... or whatever
      if CLLocationManager.isRangingAvailable() {
        print("ranging available")
      } else {
        print("no ranging available")
      }
      handleDidExitBeaconRegion(locman: locMan, region: region as! CLBeaconRegion)
    }
  }
  
  // Acting on the nearest beacon
  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    // TODO: collect all beacons, not just closest
    let beaconLen = beacons.count
    var i = 1
    for beacon in beacons {
      
      let major = CLBeaconMajorValue(truncating: beacon.major)
      let minor = CLBeaconMinorValue(truncating: beacon.minor)
      
      print("did range beacon \(i)/\(beaconLen): [\(beaconProximityString(prox: beacon.proximity))] \(major).\(minor)")
      i = i+1
      
      switch beacon.proximity {
      case .near, .immediate, .far:
        setRangedBeacon(beacon: beacon)
        break
      case .unknown:
        fallthrough
      default:
        handleDidExitBeaconRegion(locman: locMan, region: region)
        removeRangedBeacon(beacon: beacon)
        break
      }
    }
  }
}
