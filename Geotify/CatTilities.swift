//MIT License //Copyright (c) <2016> <ROTBLAUER LLC> // //Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: //
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



//
//  CatTilities.swift
//  

import Foundation
import CoreLocation
import UIKit
import CoreData

var currentTripStart:NSDate = NSDate();
var currentTripDistance:Double = 0;
var currentTripDistanceFromStart:Double = 0;
var currentTripNotes = "";
var firstPoint:CLLocation? = nil;
var lastPoint:CLLocation? = nil;

func setCurrentTripNotes(s: String) {
  currentTripNotes = s;
  savePointToCoreData(manager: CLLocationManager())
}
func getCurrentTripNotes() -> String {
  return currentTripNotes;
}
func getCurrentTripDistance() -> (traveled:Double, fromStart:Double) {
  return (currentTripDistance, currentTripDistanceFromStart);
}
func getCurrentTripTime() -> TimeInterval {
  return currentTripStart.timeIntervalSinceNow;
}

// send a TrackPoint model -> plain json dict
func objectifyTrackpoint(trackpoint: TrackPoint) -> NSMutableDictionary? {
  let dict = NSMutableDictionary()
  dict.setValue(trackpoint.name, forKey: "name"); //set all your values..
  dict.setValue(trackpoint.lat, forKey: "lat");
  dict.setValue(trackpoint.long, forKey: "long");
  dict.setValue(trackpoint.accuracy, forKey: "accuracy");
  dict.setValue(trackpoint.altitude, forKey: "elevation");
  dict.setValue(trackpoint.speed, forKey: "speed");
  dict.setValue(trackpoint.course, forKey: "heading");
  dict.setValue(trackpoint.time, forKey: "time"); //get in golang time mod
  dict.setValue(trackpoint.notes, forKey: "notes");
  return dict
}


// {trackpoint json} -> [{trackpoints json}]
func buildJsonPosterFromTrackpoints(trackpoints: [TrackPoint]) -> NSMutableArray? {
  
  let points: NSMutableArray = []
  
  for point in trackpoints {
    let jo = objectifyTrackpoint(trackpoint: point)
    points.add(jo as AnyObject)
  }
  
  return points
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

func manageTripVals(lat:CLLocationDegrees, lng:CLLocationDegrees) {
  if (currentTripNotes != "") {
    if (lastPoint == nil) {
      currentTripStart = NSDate();
      lastPoint = CLLocation(latitude: lat, longitude: lng);
      firstPoint = lastPoint;
    } else {
      let curPoint = CLLocation(latitude: lat, longitude: lng);
      // increment
      currentTripDistance = currentTripDistance + (lastPoint?.distance(from: curPoint))!;
      // overall
      currentTripDistanceFromStart = (firstPoint?.distance(from: curPoint))!;
      
      lastPoint = curPoint; // update
    }
  } else {
    if (currentTripDistance != 0 || lastPoint != nil) {
      lastPoint = nil;
      currentTripDistance = 0;
      currentTripDistanceFromStart = 0;
      currentTripStart = NSDate();
    }
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
  
  point.setValue(UIDevice.current.name, forKey: "name"); //set all your values..
  let lat = manager.location!.coordinate.latitude;
  let lng = manager.location!.coordinate.longitude;
  point.setValue(lat, forKey: "lat");
  point.setValue(lng, forKey: "long");
  point.setValue(manager.location!.horizontalAccuracy, forKey: "accuracy");
  point.setValue(manager.location!.altitude, forKey: "altitude");
  point.setValue(manager.location!.speed, forKey: "speed");
  point.setValue(manager.location!.course, forKey: "course");
  point.setValue(Date().iso8601, forKey: "time"); //leave ios for now
  point.setValue(getCurrentTripNotes(), forKey: "notes");
  
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
    
    point.setValue(UIDevice.current.name, forKey: "name"); //set all your values..
    let lat = p.coordinate.latitude;
    let lng = p.coordinate.longitude;
    point.setValue(lat, forKey: "lat");
    point.setValue(lng, forKey: "long");
    point.setValue(p.horizontalAccuracy, forKey: "accuracy");
    point.setValue(p.altitude, forKey: "altitude");
    point.setValue(p.speed, forKey: "speed");
    point.setValue(p.course, forKey: "course");
    point.setValue(p.timestamp.iso8601, forKey: "time"); //leave ios for now
    point.setValue(getCurrentTripNotes(), forKey: "notes");
    
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

// send POST request with array of json pointies
var amPushing = false
func getAmPushing() -> Bool {
  return amPushing
}
func pushLocs() {
  if (amPushing) { return } //catch de dupes

  // Catch no or unavailable points.
  let points = fetchPointsFromCoreData()!
  if points.count == 0 {
    print("No points to push, returning.")
    return
  }
  
  amPushing = true
  let json = buildJsonPosterFromTrackpoints(trackpoints: points)
  
  var request = URLRequest(url: URL(string: "http://track.areteh.co:3001/populate/")!)// will up date to cat scratcher main

  request.httpMethod = "POST"
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  request.addValue("application/json", forHTTPHeaderField: "Accept")
  request.httpBody = try! JSONSerialization.data(withJSONObject: json as Any, options: [])
  // had to open up the security cleareance to get it to clear customs
  //http://highaltitudehacks.com/2016/06/23/ios-application-security-part-46-app-transport-security/
  
  // needs this, kinda maybe?
  URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
    amPushing = false // ja
    if (postponedPoints.count > 0) {
      if (savePointsToCoreData(locations: postponedPoints)) {
        postponedPoints.removeAll();
      }
    }
    if error != nil {
      print(error ?? "NONE")
      return //giveup. we'll getemnextime
    } else {
      print("Boldy deleting.")
      clearTrackPointsCD()
      do {
        guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else { return }
        
        guard let errors = json?["errors"] as? [[String: Any]] else { return }
        if errors.count > 0 {
          print(errors)
          return
        } else {
          // was success
          // delete local corestore points
          //ornot
          print("Successfully posted points. Will delete the stockpile now.")
          clearTrackPointsCD()
        }
      }
    }
    
  }).resume()
}
