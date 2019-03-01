//MIT License //Copyright (c) <2016> <ROTBLAUER LLC> // //Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: //
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreLocation
import CoreData
import UIKit

var lastTP:TrackPoint!

func save(manager: CLLocationManager){
  var locs:[CLLocation]=[]
  locs.append(CLLocation(latitude: CLLocationManager().location!.coordinate.latitude, longitude: CLLocationManager().location!.coordinate.longitude))

  savePointsToCoreData(locations: locs)
}

func savePointsToCoreData(locations: [CLLocation]) {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }

  let managedContext = appDelegate.persistentContainer.viewContext
  let entity = NSEntityDescription.entity(forEntityName: "TrackPoint", in: managedContext)!
  locations.forEach { p in
    let point = NSManagedObject(entity: entity, insertInto: managedContext)
    point.setValue(uuid, forKey: "uuid");  //set all your values..
    point.setValue(UIDevice.current.name, forKey: "name");
    let lat = p.coordinate.latitude;
    let lng = p.coordinate.longitude;
    point.setValue(lat, forKey: "lat");
    point.setValue(lng, forKey: "long");
    point.setValue(p.horizontalAccuracy, forKey: "accuracy");
    point.setValue(p.verticalAccuracy, forKey: "vAccuracy");
    point.setValue(p.altitude, forKey: "altitude");
    point.setValue(p.speed, forKey: "speed");
    point.setValue(p.course, forKey: "course");
    point.setValue(p.timestamp.iso8601, forKey: "time"); //leave ios for now
    point.setValue(getCurrentTripNoteString(), forKey: "notes");
    manageTripVals(lat: lat, lng: lng)
    Q = Q+1
    updatePrintableStats(p:point as! TrackPoint)
    
    do {
      try managedContext.save()
      //      print("saved new points")
      lastTP = point as? TrackPoint
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}

func updatePrintableStats(p:TrackPoint){
  let acc = String(format: "%.2f", (p.accuracy))
  let vacc = String(format: "%.2f", (p.vAccuracy))
  let lat = String(format: "%.5f", (p.lat))
  let lon = String(format: "%.5f", (p.long))
  let alt = String(format: "%.1f", (p.altitude))
  let speed = String(format: "%.2f", (p.speed))
  let ti = p.time?.dateFromISO8601?.timeIntervalSinceNow
  var tt = "n/a"
  if ti != nil {
    tt =  stringFromTimeInterval(interval: ti!) as String
  }
  var dd = currentTripNotes.distance
  if dd.decimalValue <= 0 {
    dd = 0
  }
  let currentTripDistance = String(format: "%.1f", (currentTripNotes.distance))
  let relativeAltitude = String(format: "%.1f", (currentTripNotes.relativeAltitude))
  let pressure = String(format: "%.4f", (currentTripNotes.pressure))
  var beacsRangs:[String] = []
  for beac in beaconsRanging {
    beacsRangs.append("\(beaconProximityString(prox: beac.proximity)):\(beac.major).\(beac.minor)")
  }

  currentStats = """
  ACC.H: \(acc), ACC.V: \(vacc), SPEED: \(speed)
  LAT: \(lat), LON: \(lon)
  ALT: \(alt), PRESSURE: \(pressure)
  TIME SINCE LAST POINT: \(tt)
  ---
  LOC.desired_acc: \(locMan.desiredAccuracy), LOC.distance_filter: \(locMan.distanceFilter)
  LOC.autopause: \(locMan.pausesLocationUpdatesAutomatically), LOC.background_allowed: \(locMan.allowsBackgroundLocationUpdates)
  Q.pushEvery: \(AppSettings.pushAtCount) points
  ---
  Activity: \(currentTripNotes.activity), HeartRate: \(currentTripNotes.heartRate)
  Distance: \(currentTripDistance), Steps: \(currentTripNotes.numberOfSteps)
  Floors(U/D): \(currentTripNotes.floorsAscended)/\(currentTripNotes.floorsDescended), RelAltitude: \(relativeAltitude) meters
  ---
  WLAN: \(currentTripNotes.networkInfo?.ssid ?? "")
  BEAC.me: \(uuidN1).\(uuidN2), BEAC.catfriends: \(beacsRangs)
  ---
  VERSION: \(version)
  """
}

func getTrackPointsStoredCount(context: NSManagedObjectContext) -> Int {
  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TrackPoint")
  do {
    let pc = try context.count(for: fetchRequest) as Int
    return pc
  } catch let err as NSError {
    print("could not count track points \(err)")
    return -1
  }
}

// get all trackpoints from data store
func fetchPointsFromCoreData(context:NSManagedObjectContext, limit:Int) -> [TrackPoint]? {
  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TrackPoint")
  if limit > 0 {
      fetchRequest.fetchLimit = limit
  }

  do {
    let fetchedPoints = try context.fetch(fetchRequest) as! [TrackPoint]
    return fetchedPoints
  } catch let error as NSError {
    print("Could not fetch. \(error), \(error.userInfo)")
    return []
  }
}

func clearTrackPointsCD(toDelete: [TrackPoint],currentContext:NSManagedObjectContext) {
  print("attempting delete")

  for p in toDelete {
    delete(trackPoint: p, context:currentContext)
    P=P+1
  }
}

func delete(trackPoint : TrackPoint,context:NSManagedObjectContext){
  context.delete(trackPoint)
}
