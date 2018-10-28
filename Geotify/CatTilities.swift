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
import CoreMotion

// mem only

private var firstPoint:CLLocation? = nil;
private var lastPoint:CLLocation? = nil;
var currentTripNotes = Note()
private var customTripNote = ""
private let activityManager = CMMotionActivityManager()
private let pedometer = CMPedometer()
private let elly=CMAltimeter();// We have an actual altimeter!

var requireWifiForPush:Bool = true;

func getRequireWifi() -> Bool {
  return requireWifiForPush;
}
func setRequireWifi(requireWifi: Bool) {
  requireWifiForPush = requireWifi;
}

private func startTrackingActivityType() {
  activityManager.startActivityUpdates(to: OperationQueue.main) {
   (activity: CMMotionActivity?) in

    guard let activity = activity else { return }
    DispatchQueue.main.async {
      if activity.walking {
        currentTripNotes.activity=Activity.Walking
      } else if activity.stationary {
        currentTripNotes.activity=Activity.Stationary
      } else if activity.running {
        currentTripNotes.activity=Activity.Running
      } else if activity.automotive {
       currentTripNotes.activity=Activity.Automotive
      }else if activity.cycling {
      currentTripNotes.activity=Activity.Bike
      }else{
       currentTripNotes.activity=Activity.Unknown
      }
    }
  }
}


private func startCountingSteps() {
  pedometer.startUpdates(from: Date()) {
   pedometerData, error in
    guard let pedometerData = pedometerData, error == nil else { return }

    DispatchQueue.main.async {

//    var current=getStoredTripNotes()

      if #available(iOS 10.0, *) {
        if(pedometerData.averageActivePace != nil){
        currentTripNotes.averageActivePace=pedometerData.averageActivePace!
        }
      } else {
       currentTripNotes.averageActivePace=(-1.0)
      }
      if(pedometerData.currentCadence != nil){
      currentTripNotes.currentCadence=pedometerData.currentCadence!
      }
      currentTripNotes.numberOfSteps=pedometerData.numberOfSteps
      if(pedometerData.currentPace != nil){
      currentTripNotes.currentPace=pedometerData.currentPace!
      }
      currentTripNotes.distance=pedometerData.distance!
      if(pedometerData.floorsAscended != nil){
        currentTripNotes.floorsAscended=pedometerData.floorsAscended!
      }

      if(pedometerData.floorsDescended != nil){
        currentTripNotes.floorsDescended=pedometerData.floorsDescended!
      }
    }
  }
}


private func startMonitoringElevation(){
  elly.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (altitudeData:CMAltitudeData?, error:Error?) in
    currentTripNotes.relativeAltitude = altitudeData!.relativeAltitude.doubleValue    // Relative altitude in meters
    currentTripNotes.pressure = altitudeData!.pressure.doubleValue            // Pressure in kilopascals
  })
}
// TODO toggle for each for battery what not
 func startUpdatingActivity() {
  if CMMotionActivityManager.isActivityAvailable() {
    startTrackingActivityType()
  }

  if CMPedometer.isStepCountingAvailable() {
    startCountingSteps()
  }

  if CMAltimeter.isRelativeAltitudeAvailable(){
    startMonitoringElevation()
  }
}

func addVisit(visit:CLVisit,place:String){
  let v = Visit.init(fromVisit: visit, placeAt: place)
  savePointToCoreData(manager: CLLocationManager())
  currentTripNotes.currentVisit=v
  savePointToCoreData(manager: CLLocationManager())
  currentTripNotes.currentVisit=nil
}


func setCurrentTripNotes(s: String) {
  savePointToCoreData(manager: CLLocationManager())
   currentTripNotes = Note()
   currentTripNotes.customNote=s
  startUpdatingActivity()//reset ped etc
  //TODO store actual currentTripNotes
  customTripNote = s
  savePointToCoreData(manager: CLLocationManager())
}

func getStoredCustomTripNotes() -> String {
return customTripNote
}

 func getCurrentTripNoteString() -> String {
 currentTripNotes.customNote=getStoredCustomTripNotes();
 return getStringNote(n:currentTripNotes) ;
}
 func getCurrentTripDistance() -> (traveled:Double, fromStart:Double) {
  return (currentTripNotes.currentTripDistance, currentTripNotes.currentTripDistanceFromStart);
}
 func getCurrentTripTime() -> TimeInterval {
  return currentTripNotes.currentTripStart.timeIntervalSinceNow;
}

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





func manageTripVals(lat:CLLocationDegrees, lng:CLLocationDegrees) {
  if (currentTripNotes.customNote != "") {
    if (lastPoint == nil) {
      currentTripNotes.currentTripStart = Date();
      lastPoint = CLLocation(latitude: lat, longitude: lng);
      firstPoint = lastPoint;
    } else {
      let curPoint = CLLocation(latitude: lat, longitude: lng);
      // increment
      currentTripNotes.currentTripDistance = currentTripNotes.currentTripDistance + (lastPoint?.distance(from: curPoint))!;
      // overall
      currentTripNotes.currentTripDistanceFromStart = (firstPoint?.distance(from: curPoint))!;

      lastPoint = curPoint; // update
    }
  } else {
    if (currentTripNotes.currentTripDistance != 0 || lastPoint != nil) {
      lastPoint = nil;
      currentTripNotes.currentTripDistance = 0;
      currentTripNotes.currentTripDistanceFromStart = 0;
      currentTripNotes.currentTripStart = Date();
    }
  }

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
