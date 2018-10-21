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

var uuid:String = "unset"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let locationManager = CLLocationManager()
  //declare this property where it won't go out of scope relative to your listener


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()

    locationManager.desiredAccuracy = kCLLocationAccuracyBest // kCLLocationAccuracyBest
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.pausesLocationUpdatesAutomatically = false

    locationManager.startUpdatingLocation()
    locationManager.startMonitoringSignificantLocationChanges()
    locationManager.activityType = CLActivityType.fitness

    //TODO sliders and such for distance filter, or convert to once per minute type thing

    // application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
    UIDevice.current.isBatteryMonitoringEnabled = true
    uuid = (UIDevice.current.identifierForVendor?.uuidString)!
    UIApplication.shared.cancelAllLocalNotifications()

    startUpdatingActivity()
    return true
  }
}


let updateAccuracySettingsEvery:int_fast64_t = 10;
let mayAttemptPushEvery:int_fast64_t = 100;
var lastAttemptUpdateAccuracySettings:int_fast64_t = 0;
var lastAttemptPushEvery:int_fast64_t = 0;

extension AppDelegate: CLLocationManagerDelegate {

  // Runs when the location is updated
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    if (amDeleting) {
      print("Location changed but delete in progress. Returning.")
      return
    }
    // TODO: use me to update UI
//    savePointToCoreData(manager: manager)
    savePointsToCoreData(locations: locations)
    let data = numberAndLastOfCoreDataTrackpoints()
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.activityType = CLActivityType.fitness

    // every 100||n
    if (data.count < 1000) { return; }
    lastAttemptPushEvery = lastAttemptPushEvery.advanced(by: locations.count);
    if (lastAttemptPushEvery < mayAttemptPushEvery) {
      return;
    }
    lastAttemptPushEvery = 0;

    if (true) {
      print("Have wifi and will push \(data.count) points.")
      pushLocs() // to the cloud
    } else {
      print("Have not got wifi or only a few points. Have \(data.count) points stockpiled.")
    }
  }
}

class DataController: NSObject {
  var managedObjectContext: NSManagedObjectContext

  override init() {
    // This resource is the same name as your xcdatamodeld contained in your project.
    guard let modelURL = Bundle.main.url(forResource: "TrackPoint", withExtension:"momd") else {
      fatalError("Error loading model from bundle")
    }
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Error initializing mom from: \(modelURL)")
    }
    let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
    self.managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    self.managedObjectContext.persistentStoreCoordinator = psc

    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let docURL = urls[urls.endIndex-1]
    /* The directory the application uses to store the Core Data store file.
     This code uses a file named "DataModel.sqlite" in the application's documents directory.
     */
    let storeURL = docURL.appendingPathComponent("TrackPoint.sqlite")
    do {
      try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
    } catch {
      fatalError("Error migrating store: \(error)")
    }

  }
}
