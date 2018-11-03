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


let pushAtCount=100;


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

private func buildJsonPosterFromTrackpoints(trackpoints: [TrackPoint]) -> NSMutableArray? {
  
  let points: NSMutableArray = []
  
  for point in trackpoints {
    let jo = objectifyTrackpoint(trackpoint: point)
    points.add(jo as AnyObject)
  }
  
  return points
}

private func buildURL() -> URL{
  var urlComponents = URLComponents()
  urlComponents.scheme = "http"
  urlComponents.host = "track.areteh.co"
  urlComponents.port = 3001
  urlComponents.path = "/populate/"
  guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
  
  return url
}


private func fetchDoesCallSucceed(session: URLSession,request: URLRequest,completionHandler: @escaping (Bool) -> Void) {
  
  print("fetching success")
  let task = session.dataTask(with: request) {
    (data, response, error) in
    let success = (error == nil)
    print("success = \(success)")
    completionHandler(success)
  }
  task.resume()
}


func pushLocs(force:Bool) {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  
  let managedContext = appDelegate.persistentContainer.viewContext
    if let points = fetchPointsFromCoreData(context: managedContext){
    if points.count == 0 {
      print("No points to push, returning.")
      return
    }
    if (!force && points.count < pushAtCount) { return; }
      print("preparing push for num points:\(points.count)")
    let json = buildJsonPosterFromTrackpoints(trackpoints: points)
    
    var request = URLRequest(url:buildURL())// will up date to cat scratcher main
    
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try! JSONSerialization.data(withJSONObject: json as Any, options: [])
      
      
    print("starting push")

    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
      DispatchQueue.main.async {
        // present alert
     
      fetchDoesCallSucceed(session: session, request: request){
        success in

        if success {
        clearTrackPointsCD(toDelete: points,currentContext: managedContext)
        do {
          try managedContext.save()
        } catch {
          print(error)
        }
        Q=0
      }
         }
        
      }
     print("stoping task")
      
//     sleep(10)
  }
}

