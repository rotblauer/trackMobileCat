//MIT License //Copyright (c) <2016> <ROTBLAUER LLC> // //Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: //
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


//
//  Note.swift
//  Geotify
//
//  Created by Kitty on 5/6/18.
//

import Foundation

enum Activity: String {
  case Walking, Stationary, Running,Automotive,Bike,Unknown
}

class Note{
var activity:Activity = Activity.Unknown;// Maybe one of the coolest thing,
var numberOfSteps:NSNumber = 0;// only when stepping, pedometer
var averageActivePace:NSNumber = 0;// only when stepping, pedometer
var currentPace:NSNumber = 0;// only when stepping, pedometer
var currentCadence:NSNumber = 0;// only when stepping, pedometer
  var distance:NSNumber=0;//the pedometer distance, does not track other dists like bike :(
  var customNote:String="";//RB
  var floorsAscended:NSNumber=0;// only when stepping, pedometer
  var floorsDescended:NSNumber=0;// only when stepping, pedometer
  var currentTripStart:Date = Date();//RB
  var currentTripDistance:Double = 0; // real distance RB
  var currentTripDistanceFromStart:Double = 0;// real distance RB
  var relativeAltitude:Double = 0;//From the altimeter, an actual altimeter!
  var pressure:Double = 0;//From the altimeter,we get pressure!
  var currentVisit:Visit? = nil;


}

private func objectifyNote(n: Note) -> NSMutableDictionary? {
  let dict = NSMutableDictionary()
  dict.setValue(n.activity.rawValue, forKey: "activity");  //set all your values..
  dict.setValue(n.numberOfSteps, forKey: "numberOfSteps");
  dict.setValue(n.averageActivePace, forKey: "averageActivePace");
  dict.setValue(n.currentPace, forKey: "currentPace");
  dict.setValue(n.currentCadence, forKey: "currentCadence");
  dict.setValue(n.distance, forKey: "distance");
  dict.setValue(n.customNote, forKey: "customNote");
  dict.setValue(n.floorsAscended, forKey: "floorsAscended");
  dict.setValue(n.floorsDescended, forKey: "floorsDescended");
  dict.setValue(n.currentTripStart.iso8601, forKey: "currentTripStart");
  dict.setValue(n.relativeAltitude, forKey: "relativeAltitude");
  dict.setValue(n.pressure, forKey: "pressure");
  dict.setValue(getStringVisit(v:n.currentVisit), forKey: "visit");

  return dict
}


func getStringNote(n: Note) -> String{
  let json = try! JSONSerialization.data(withJSONObject: objectifyNote(n:n) as Any, options: [])
  return String(data: json, encoding: String.Encoding.utf8)!
//  return("HDS")
}


