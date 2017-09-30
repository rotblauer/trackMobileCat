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

func numberOfCoreDataTrackpoints() -> int_fast64_t {
  var i : int_fast64_t = 0
  let moc = DataController().managedObjectContext
  let pointsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
  pointsFetch.includesPropertyValues = false
  do {
    let fetchedPoints = try moc.fetch(pointsFetch) as! [TrackPoint]
    for _ in fetchedPoints {
      i += 1
    }
  } catch {
    fatalError("Failed to fetch employees: \(error)")
  }
  return i
}

// get all trackpoints from data store
func fetchPointsFromCoreData() -> [TrackPoint]? {
  let moc = DataController().managedObjectContext
  let pointsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
  
  do {
    let fetchedPoints = try moc.fetch(pointsFetch) as! [TrackPoint]
    return fetchedPoints
  } catch {
    fatalError("Failed to fetch employees: \(error)")
  }
}

// save a single Trackpoint from location
func savePointToCoreData(manager: CLLocationManager) -> TrackPoint? {
  let moc = DataController().managedObjectContext
  let point = NSEntityDescription.insertNewObject(forEntityName: "TrackPoint", into: moc) as! TrackPoint
  
  point.setValue(UIDevice.current.name, forKey: "name"); //set all your values..
  point.setValue(manager.location!.coordinate.latitude, forKey: "lat");
  point.setValue(manager.location!.coordinate.longitude, forKey: "long");
  point.setValue(manager.location!.horizontalAccuracy, forKey: "accuracy");
  point.setValue(manager.location!.altitude, forKey: "altitude");
  point.setValue(manager.location!.speed, forKey: "speed");
  point.setValue(manager.location!.course, forKey: "course");
  point.setValue(Date().iso8601, forKey: "time"); //leave ios for now
  
  //saver
  do {
    try moc.save()
  } catch {
    fatalError("Failure to save context: \(error)")
  }
  return point
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
func pushLocs() {
  if (amPushing) { return } //catch de dupes
  amPushing = true
  let json = buildJsonPosterFromTrackpoints(trackpoints: fetchPointsFromCoreData()!)
  
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
