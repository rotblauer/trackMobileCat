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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let locationManager = CLLocationManager()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    locationManager.startUpdatingLocation()
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    locationManager.distanceFilter = 2.0; //meters move per update,
    locationManager.allowsBackgroundLocationUpdates = true
    
    //TODO sliders and such for distance filter, or convert to once per minute type thing
    
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
    
    // to the cloud
    // pushLoc(manager: manager)
    savePointToCoreData(manager: manager)
    let points = fetchPointsFromCoreData()
    //cuz i don't know what .length() is..
    var c = 0
    for _ in points! {
      c += 1
    }
    if c > 100 { //TODO check for wifi
      pushLocs()
    }
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


// class DataController: NSObject {
//   var managedObjectContext: NSManagedObjectContext
//   override init() {
//     // This resource is the same name as your xcdatamodeld contained in your project.
//     guard let modelURL = Bundle.main.url(forResource: "TrackPoint", withExtension:"momd") else {
//       fatalError("Error loading model from bundle")
//     }
//     // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
//     guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
//       fatalError("Error initializing mom from: \(modelURL)")
//     }
//     let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
//     managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//     managedObjectContext.persistentStoreCoordinator = psc
//     //dispatch_async(dispatch_get_global_queue(DispatchQueue.GlobalQueuePriority.background, 0)) {
//       let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//       let docURL = urls[urls.endIndex-1]
//       /* The directory the application uses to store the Core Data store file.
//        This code uses a file named "DataModel.sqlite" in the application's documents directory.
//        */
//       let storeURL = docURL.URLByAppendingPathComponent("TrackPoint.sqlite")
//       do {
//         try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
//       } catch {
//         fatalError("Error migrating store: \(error)")
//       }
//     //}
//   }
// }






