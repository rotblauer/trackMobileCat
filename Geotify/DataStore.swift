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
func savePointToCoreData(manager: CLLocationManager)  {
  var locs:[CLLocation]=[]
  
  locs.append(CLLocation(latitude: manager.location!.coordinate.latitude, longitude: manager.location!.coordinate.longitude))
  savePointsToCoreData(locations: locs)
}

// save multiple Trackpoints
func savePointsToCoreData(locations: [CLLocation]) -> Bool {
//  let moc = DataController().managedObjectContext
  print("attempt save")
  DataController().persistentContainer.performBackgroundTask { (context) in
    // Iterates the array
    locations.forEach { p in
      // Creates a new entry inside the context `context` and assign the array element `name` to the dog's name
      let point = TrackPoint(context: context)
      
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
      
    }
    print("saving")
    do {
      // Saves the entries created in the `forEach`
      try context.save()
    } catch {
      fatalError("Failure to save context: \(error)")
    }
    
   
    
  }
//  //  print("saving n points", locations.count)
//  for p in locations {
//    let point = NSEntityDescription.insertNewObject(forEntityName: "TrackPoint", into: moc) as! TrackPoint
//
//    point.setValue(uuid, forKey: "uuid");  //set all your values..
//    point.setValue(UIDevice.current.name, forKey: "name");
//    let lat = p.coordinate.latitude;
//    let lng = p.coordinate.longitude;
//    point.setValue(lat, forKey: "lat");
//    point.setValue(lng, forKey: "long");
//    point.setValue(p.horizontalAccuracy, forKey: "accuracy");
//    point.setValue(p.altitude, forKey: "altitude");
//    point.setValue(p.speed, forKey: "speed");
//    point.setValue(p.course, forKey: "course");
//    point.setValue(p.timestamp.iso8601, forKey: "time"); //leave ios for now
//    point.setValue(getCurrentTripNoteString(), forKey: "notes");
////    print(point.objectID)
//    //saver
//    do {
//      try moc.save()
//    } catch {
//      fatalError("Failure to save context: \(error)")
//    }
//  }
  
  return true
}

func getCurrentFetch() -> NSFetchRequest<NSFetchRequestResult>{
  return NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
}

// get all trackpoints from data store
func fetchPointsFromCoreData(toFetch: NSFetchRequest<NSFetchRequestResult>) -> [TrackPoint]? {
  let privateManagedObjectContext = DataController().persistentContainer.viewContext
//  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
//  let moc = DataController().managedObjectContext
  print("fetching data")
  do {
    let fetchedPoints = try privateManagedObjectContext.fetch(getCurrentFetch()) as! [TrackPoint]
    return fetchedPoints
  } catch {
    print("Failed to fetch employees: \(error)")
    return []
  }
}

func clearTrackPointsCD(toDelete: [TrackPoint]) {
//https://cocoacasts.com/more-fetching-and-deleting-managed-objects-with-core-data
//  let moc = DataController().managedObjectContext
//  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
//  let f etchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
////
//  var delIDs: [NSManagedObjectID] = []
//  for p in toDelete {
//    print(p.objectID)
//    delIDs.append(p.objectID)
//
//  }
////  NSbat
////  let batchDeleteRequest = NSBatchDeleteRequest(objectIDs: delIDs)
//
////  var delIDs=[NSManagedObjectID]
////  let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
////  do {
////        try moc.execute(batchDeleteRequest)
////        try moc.save()
////      } catch {
////        // Error Handling
////        print("ERROR")
////      }
//////
////  print("HI")
//  for p in toDelete {
//    delIDs.append(p.objectID)
////  if let anyItem = p as? NSManagedObject {
//    moc.delete(p as NSManagedObject)
//    do {
//   try moc.save()
//    print("delete")
//   } catch {
//    print("delete np")
//
//            // Error Handling
//          }

//  }
//  moc.processPendingChanges()

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
