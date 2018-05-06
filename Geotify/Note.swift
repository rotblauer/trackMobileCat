//
//  Note.swift
//  Geotify
//
//  Created by Kitty on 5/6/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation

enum Activity: String {
  case Walking, Stationary, Running,Automotive,Bike,Unknown
}
class Note{
var activity:Activity = Activity.Unknown;
var numberOfSteps:NSNumber = 0;
var averageActivePace:NSNumber = 0;
var currentPace:NSNumber = 0;
var currentCadence:NSNumber = 0;
var distance:NSNumber=0;
var customNote:String="";
  var floorsAscended:NSNumber=0;
  var floorsDescended:NSNumber=0;
}

func objectifyNote(n: Note) -> NSMutableDictionary? {
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

  return dict
}


func getStringNote(n: Note) -> String{
  let json = try! JSONSerialization.data(withJSONObject: objectifyNote(n:n) as Any, options: [])
  return String(data: json, encoding: String.Encoding.utf8)!
//  return("HDS")
}


