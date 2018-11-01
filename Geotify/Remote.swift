//
//  Remote.swift push data to remote
//  Geotify
//
//  Created by Kitty on 10/28/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//


import Foundation
import CoreData 
import UIKit

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

func pushLocs(force:Bool) {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  

  
  let managedContext = appDelegate.persistentContainer.viewContext
    if let points = fetchPointsFromCoreData(){
    if points.count == 0 {
      print("No points to push, returning.")
      return
    }
//      let data = numberAndLastOfCoreDataTrackpoints()
      //
//      print("Points" )
      if (!force && points.count < pushAtCount) { return; }
      print("preparing push")
//      lastAttemptPushEvery = lastAttemptPushEvery.advanced(by: 1);
//      if (lastAttemptPushEvery < mayAttemptPushEvery) {
//        return;
//      }
//      lastAttemptPushEvery = 0;
      
    print(points.count)
    let json = buildJsonPosterFromTrackpoints(trackpoints: points)
    
    var request = URLRequest(url: URL(string: "http://track.areteh.co:3001/populate/")!)// will up date to cat scratcher main
    
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try! JSONSerialization.data(withJSONObject: json as Any, options: [])

    URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
      if error != nil {
        print(error ?? "NONE")
        return //giveup. we'll getemnextime
      } else {
        print("Boldy deleting.")
        clearTrackPointsCD(toDelete: points,currentContext: managedContext)
      }
    }).resume()
  }
}

