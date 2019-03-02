//MIT License //Copyright (c) <2016> <ROTBLAUER LLC> // //Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: //
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreData
import UIKit

var pushAtCount=1000;

// send a TrackPoint model -> plain json dict
private func objectifyTrackpoint(trackpoint: TrackPoint,pushToken:String) -> NSMutableDictionary? {
  let dict = NSMutableDictionary()
  dict.setValue(trackpoint.uuid, forKey: "uuid");
  dict.setValue(pushToken, forKey: "pushToken");
  dict.setValue(version, forKey: "version");
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

private func buildJsonPosterFromTrackpoints(trackpoints: [TrackPoint],pushToken:String) -> NSMutableArray? {
  
  let points: NSMutableArray = []
  
  for point in trackpoints {
    let jo = objectifyTrackpoint(trackpoint: point,pushToken:pushToken)
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

private var attemptingPush=false
private var success=false

func pushLocs(force:Bool,pushToken:String) {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  if attemptingPush {
    print("in attempt")
    return
  }
  let apiCOToken="thecattokenthatunlockstheworldtrackyourcats"
  
  let managedContext = appDelegate.persistentContainer.viewContext
  let pc = getTrackPointsStoredCount(context: managedContext)
  Q = pc
  if pc == 0 {
    print("No points to push, returning.")
    return
  }
  if (!force && pc % Int(AppSettings.pushAtCount)>0) { return; }
  
  var pushLim = 5000
  if Int(AppSettings.pushAtCount)*2 > pushLim {
    pushLim = Int(AppSettings.pushAtCount)*2
  }
  if pushLim > 10000 {
    pushLim = 10000
  }
  if pushLim > pc {
    pushLim = pc
  }
  
  if let points = fetchPointsFromCoreData(context: managedContext, limit: pushLim){ // note, out of ass
    print("preparing push for num points:\(pc)")
    let json = buildJsonPosterFromTrackpoints(trackpoints: points, pushToken:pushToken)
    
    var request = URLRequest(url:buildURL())// will up date to cat scratcher main
    
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")
    request.addValue(apiCOToken, forHTTPHeaderField: "AuthorizationOfCats")
//    print(request.allHTTPHeaderFields!)
    
    request.httpBody = try! JSONSerialization.data(withJSONObject: json as Any, options: [])
    attemptingPush=true
    URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
      
      if error != nil {
        print(error ?? "NONE")
        attemptingPush=false
        return //giveup. we'll getemnextime
      } else {
//        Q=0
        print("success push, updating push attempt")
        success=true
        attemptingPush=false
      }
    }).resume()
    while(attemptingPush){
      sleep(1)
      print("attempt")
    }
    if(success){
      clearTrackPointsCD(toDelete: points,currentContext: managedContext)

      do {
        try managedContext.save()
      } catch {
        print(error)
        return
      }
      
      Q = Q - pushLim
    }
    success=false
  }
  
  print("Moving on with push attempt \(attemptingPush)")
}
