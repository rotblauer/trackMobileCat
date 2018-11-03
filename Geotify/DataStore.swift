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
    Q = Q+1
    updateStats(p:point as! TrackPoint)
    
    do {
      try managedContext.save()
    } catch let error as NSError {
      print("Could not save. \(error), \(error.userInfo)")
    }
  }
}

private func updateStats(p:TrackPoint){
  //      let _uuid = (p?.uuid)!
  let acc = String(format: "%.2f", (p.accuracy))
  let lat = String(format: "%.9f", (p.lat))
  let lon = String(format: "%.9f", (p.long))
  let alt = String(format: "%.9f", (p.altitude))
  let course = String(format: "%.3f", (p.course))
  let speed = String(format: "%.9f", (p.speed))
  let t = p.time
  let currentTripDistance = String(format: "%.4f", (currentTripNotes.currentTripDistance))
  let relativeAltitude = String(format: "%.4f", (currentTripNotes.relativeAltitude))
  let pressure = String(format: "%.4f", (currentTripNotes.pressure))
  
  //      UUID: \(_uuid)\n
  currentStats = "ACC: \(acc)\nLAT: \(lat)\tLON: \(lon)\nALT: \(alt)\nCOURSE: \(course)\nSPEED: \(speed)\nTIME: \(String(describing: t))\nActivity: \(currentTripNotes.activity)\tTrip: \(currentTripNotes.customNote)\nDistance: \(currentTripDistance)\nSteps: \(currentTripNotes.numberOfSteps)\tPressure: \(pressure)\nRAltitude: \(relativeAltitude)\tVERSION: \(version)"
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
