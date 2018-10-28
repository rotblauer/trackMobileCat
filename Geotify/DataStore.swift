//
//  DataStore.swift
//  Geotify
//
//  Created by Kitty on 10/28/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import UIKit

// get all trackpoints from data store
func fetchPointsFromCoreData() -> [TrackPoint]? {
  let moc = DataController().managedObjectContext
  let pointsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
  
  do {
    let fetchedPoints = try moc.fetch(pointsFetch) as! [TrackPoint]
    return fetchedPoints
  } catch {
    print("Failed to fetch employees: \(error)")
    return []
  }
}

// save a single Trackpoint from location
func savePointToCoreData(manager: CLLocationManager) -> TrackPoint? {
  if (amPushing) {
    postponedPoints.append(manager.location!)
    return nil;
  }
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

var postponedPoints:[CLLocation] = [];

// save multiple Trackpoints
func savePointsToCoreData(locations: [CLLocation]) -> Bool {
  if (amPushing) {
    postponedPoints.append(contentsOf: locations);
    return true;
  }
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

var amDeleting : BooleanLiteralType = false
func getAmDeleting() -> BooleanLiteralType {
  return amDeleting
}
func clearTrackPointsCD() {
  print("Even deleting")
  amDeleting = true
  let moc = DataController().managedObjectContext
  
  // Create Fetch Request
  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
  
  // Create Batch Delete Request
  let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
  
  do {
    try moc.execute(batchDeleteRequest)
    try moc.save()
  } catch {
    // Error Handling
  }
  amDeleting = false
}

func numberAndLastOfCoreDataTrackpoints() -> (count: int_fast64_t, lastPoint: TrackPoint?) {
  var i : int_fast64_t = 0
  var lastP : TrackPoint? = nil
  let moc = DataController().managedObjectContext
  let pointsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
  pointsFetch.includesPropertyValues = false
  do {
    let fetchedPoints = try moc.fetch(pointsFetch) as! [TrackPoint]
    i = Int64(fetchedPoints.count)
    if i > 0 {
      lastP = fetchedPoints.last // thinkin tis last not first nor middle child
    }
  } catch {
    print("Failed to fetch employees \(error)")
  }
  return (i, lastP)
}
