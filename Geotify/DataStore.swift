//MIT License //Copyright (c) <2016> <ROTBLAUER LLC> // //Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: //
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreLocation
import CoreData
import UIKit


func save(manager: CLLocationManager){
  var locs:[CLLocation]=[]
  locs.append(CLLocation(latitude: CLLocationManager().location!.coordinate.latitude, longitude: CLLocationManager().location!.coordinate.longitude))

  saveAll(locations: locs)
}

func saveAll(locations: [CLLocation]) {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
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
    point.setValue(p.altitude, forKey: "altitude");
    point.setValue(p.speed, forKey: "speed");
    point.setValue(p.course, forKey: "course");
    point.setValue(p.timestamp.iso8601, forKey: "time"); //leave ios for now
    point.setValue(getCurrentTripNoteString(), forKey: "notes");
    manageTripVals(lat: lat, lng: lng)
    Q = Q+1
    updateStats(p:point as! TrackPoint)
//    print("save")

    do {
      try managedContext.save()
      //      print("saved new points")
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}

private func updateStats(p:TrackPoint){
  //      let _uuid = (p?.uuid)!
  let acc = String(format: "%.2f", (p.accuracy))
  let lat = String(format: "%.5f", (p.lat))
  let lon = String(format: "%.5f", (p.long))
  let alt = String(format: "%.2f", (p.altitude))
  let speed = String(format: "%.2f", (p.speed))
  let t = p.time
  let currentTripDistance = String(format: "%.2f", (currentTripNotes.currentTripDistance))
  let relativeAltitude = String(format: "%.2f", (currentTripNotes.relativeAltitude))
  let pressure = String(format: "%.4f", (currentTripNotes.pressure))
  
  //      UUID: \(_uuid)\n
  currentStats = """
  ACC: \(acc) SPEED: \(speed)
  LAT: \(lat) LON: \(lon)
  ALT: \(alt) Pressure: \(pressure)
  TIME: \(String(describing: t))
  Activity: \(currentTripNotes.activity) Trip: \(currentTripNotes.customNote)
  Distance: \(currentTripDistance) Steps: \(currentTripNotes.numberOfSteps)
  Floors(U/D): \(currentTripNotes.floorsAscended)/\(currentTripNotes.floorsDescended) RAltitude: \(relativeAltitude)
  HR: \(currentTripNotes.heartRate) VERSION: \(version)
  loc.desired_acc: \(locMan.desiredAccuracy) loc.distance_filter \(locMan.distanceFilter)
  loc.autopause \(locMan.pausesLocationUpdatesAutomatically) loc.background_allowed \(locMan.allowsBackgroundLocationUpdates)
  """
}

// get all trackpoints from data store
func fetchPointsFromCoreData(context:NSManagedObjectContext) -> [TrackPoint]? {
  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TrackPoint")

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
