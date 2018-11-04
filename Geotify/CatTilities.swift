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
  save(manager: CLLocationManager())
  currentTripNotes.currentVisit=v
  save(manager: CLLocationManager())
  currentTripNotes.currentVisit=nil
}


func setCurrentTripNotes(s: String) {
  
  save(manager: CLLocationManager())
  
  //  savePointToCoreData(manager: CLLocationManager())
  currentTripNotes = Note()
  currentTripNotes.customNote=s
  startUpdatingActivity()//reset ped etc
  //TODO store actual currentTripNotes
  customTripNote = s
  
  save(manager: CLLocationManager())
  //  savePointToCoreData(manager: CLLocationManager())
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

