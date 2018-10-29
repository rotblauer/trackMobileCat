//
//  DataStore.swift get, store, delete cats
//  Geotify
//
//  Created by Kitty on 10/28/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import UIKit



// save a single Trackpoint from location
func savePointToCoreData(manager: CLLocationManager) -> TrackPoint? {
  let moc = DataController().managedObjectContext
  let point = NSEntityDescription.insertNewObject(forEntityName: "TrackPoint", into: moc) as! TrackPoint
  
  point.setValue(uuid, forKey: "uuid");  //set all your values..
  point.setValue(UIDevice.current.name, forKey: "name");
  let lat = manager.location!.coordinate.latitude;
  let lng = manager.location!.coordinate.longitude;
  point.setValue(lat, forKey: "lat");
  point.setValue(lng, forKey: "long");
  point.setValue(manager.location!.horizontalAccuracy, forKey: "accuracy");
  point.setValue(manager.location!.altitude, forKey: "altitude");
  point.setValue(manager.location!.speed, forKey: "speed");
  point.setValue(manager.location!.course, forKey: "course");
  point.setValue(Date().iso8601, forKey: "time"); //leave ios for now
  point.setValue(getCurrentTripNoteString(), forKey: "notes");
  //saver
  do {
    try moc.save()
  } catch {
    fatalError("Failure to save context: \(error)")
  }
  manageTripVals(lat: lat, lng: lng)
  return point
}

// save multiple Trackpoints
func savePointsToCoreData(locations: [CLLocation]) -> Bool {
  let moc = DataController().managedObjectContext
  //  print("saving n points", locations.count)
  for p in locations {
    let point = NSEntityDescription.insertNewObject(forEntityName: "TrackPoint", into: moc) as! TrackPoint
    
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
    
    //saver
    do {
      try moc.save()
    } catch {
      fatalError("Failure to save context: \(error)")
    }
    manageTripVals(lat: lat, lng: lng)
  }
  
  return true
}

func getCurrentFetch() -> NSFetchRequest<NSFetchRequestResult>{
  return NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
}

// get all trackpoints from data store
func fetchPointsFromCoreData(toFetch: NSFetchRequest<NSFetchRequestResult>) -> [TrackPoint]? {
  let moc = DataController().managedObjectContext
  print("fetching data")
  do {
    let fetchedPoints = try moc.fetch(toFetch) as! [TrackPoint]
    return fetchedPoints
  } catch {
    print("Failed to fetch employees: \(error)")
    return []
  }
}

func clearTrackPointsCD(toDelete: [TrackPoint]) {
//https://cocoacasts.com/more-fetching-and-deleting-managed-objects-with-core-data
  let moc = DataController().managedObjectContext
//  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
//  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
//
//  let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//
  print("HI")
  for p in toDelete {
//  if let anyItem = p as? NSManagedObject {
    moc.delete(p as NSManagedObject)
    do {
   try moc.save()
    print("delete")
   } catch {
    print("delete np")

            // Error Handling
          }

  }

//  }
//    do {
//    try moc.execute(batchDeleteRequest)
//    try moc.save()
//  } catch {
//    // Error Handling
//  }
}

func numberAndLastOfCoreDataTrackpoints() -> (count: int_fast64_t, lastPoint: TrackPoint?) {
  var i : int_fast64_t = 0
  var lastP : TrackPoint? = nil
  if let fetchedPoints = fetchPointsFromCoreData(toFetch: getCurrentFetch()){
    i = Int64(fetchedPoints.count)
    if i > 0 {
      lastP = fetchedPoints.last // thinkin tis last not first nor middle child
    }
  }
  return (i, lastP)
}
