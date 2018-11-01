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


var uuid:String = "unset"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  let locationManager = CLLocationManager()
  let center = UNUserNotificationCenter.current()
  static let geoCoder = CLGeocoder()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions:[UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest // kCLLocationAccuracyBest
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
    locationManager.distanceFilter = kCLDistanceFilterNone
    locationManager.startMonitoringVisits()
    locationManager.startUpdatingLocation()
    locationManager.startMonitoringSignificantLocationChanges()
    locationManager.activityType = CLActivityType.fitness
    print("location activated")

    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
    }
    UIDevice.current.isBatteryMonitoringEnabled = true
    uuid = (UIDevice.current.identifierForVendor?.uuidString)!
//    UIApplication.shared.cancelAllLocalNotifications()
//    UserNotifications
    startUpdatingActivity()
    print("started activity")

//    startLog()
    print("started log")
    return true
  }
  lazy var persistentContainer: NSPersistentContainer = {
    // The persistent container for the application. This implementation
    // creates and returns a container, having loaded the store for the
    // application to it. This property is optional since there are legitimate
    // error conditions that could cause the creation of the store to fail.
    let container = NSPersistentContainer(name: "TrackPoint")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate.
        // You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate.
        /// You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
}


let updateAccuracySettingsEvery:int_fast64_t = 10;
let mayAttemptPushEvery:int_fast64_t = 20;
let pushAtCount=3;
var lastAttemptUpdateAccuracySettings:int_fast64_t = 0;
var lastAttemptPushEvery:int_fast64_t = 0;

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
    print("got update")
    saveAll(locations: locations)
    
    pushLocs(force:false)
  }
  
}
  

