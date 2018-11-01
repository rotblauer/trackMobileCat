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
    
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}

// get all trackpoints from data store
func fetchPointsFromCoreData() -> [TrackPoint]? {
  print("fetching data")
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    return []
  }
  
  let managedContext = appDelegate.persistentContainer.viewContext
  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TrackPoint")
  
  do {
      let fetchedPoints = try managedContext.fetch(fetchRequest) as! [TrackPoint]
    return fetchedPoints
  } catch let error as NSError {
    print("Could not fetch. \(error), \(error.userInfo)")
    return []
  }
}

func clearTrackPointsCD(toDelete: [TrackPoint],currentContext:NSManagedObjectContext) {
  for p in toDelete {
    delete(trackPoint: p, context:currentContext)
    P=P+1
  }
  do {
    try currentContext.save()
  } catch {
    print(error)
  }
}

func delete(trackPoint : TrackPoint,context:NSManagedObjectContext){
  print("attempting delete")
    context.delete(trackPoint)
}

func numberAndLastOfCoreDataTrackpoints() -> (count: int_fast64_t, lastPoint: TrackPoint?) {
  var i : int_fast64_t = 0
  var lastP : TrackPoint? = nil
  if let fetchedPoints = fetchPointsFromCoreData(){
    i = Int64(fetchedPoints.count)
    if i > 0 {
      lastP = fetchedPoints.last // thinkin tis last not first nor middle child
    }
  }
  return (i, lastP)
}
