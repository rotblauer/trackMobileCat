//
//  Remote.swift push data to remote
//  Geotify
//
//  Created by Kitty on 10/28/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//


import Foundation


// send a TrackPoint model -> plain json dict
private func objectifyTrackpoint(trackpoint: TrackPoint) -> NSMutableDictionary? {
  let dict = NSMutableDictionary()
  dict.setValue(trackpoint.uuid, forKey: "uuid");  //set all your values..
  dict.setValue(trackpoint.name, forKey: "name");
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
private func buildJsonPosterFromTrackpoints(trackpoints: [TrackPoint]) -> NSMutableArray? {
  
  let points: NSMutableArray = []
  
  for point in trackpoints {
    let jo = objectifyTrackpoint(trackpoint: point)
    points.add(jo as AnyObject)
  }
  
  return points
}


// send POST request with array of json pointies
private var amPushing = false
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
    if error != nil {
      print(error ?? "NONE")
      if (postponedPoints.count > 0) {
        if (savePointsToCoreData(locations: postponedPoints)) {
          postponedPoints.removeAll();
        }
      }
      return //giveup. we'll getemnextime
    } else {
      print("Boldy deleting.")
      clearTrackPointsCD()
      if (postponedPoints.count > 0) {
        if (savePointsToCoreData(locations: postponedPoints)) {
          postponedPoints.removeAll();
        }
      }
      //      // this hits 'ret 2' with json == nil
      //      do {
      //        print("doing do")
      //        guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {
      //          print("ret1");
      //          return;
      //        }
      //
      //        guard let errors = json?["errors"] as? [[String: Any]] else { print("ret 2", json.debugDescription); return; }
      //        if errors.count > 0 {
      //          print(errors)
      //          return
      //        } else {
      //          // was success
      //          // delete local corestore points
      //          //ornot
      //          print("Successfully posted points. Will delete the stockpile now.")
      //          clearTrackPointsCD()
      //        }
      //      }
    }
    //  GeotificationsViewController.updatePointDisplay()
    
  }).resume()
}
