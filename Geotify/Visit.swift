//
//  Visit.swift
//  Geotify
//
//  Created by Kitty on 10/27/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import CoreLocation

struct Visit{
  var  arrivalDate:Date;
  var  departureDate:Date;
  var  place:String;
  
  init(fromVisit visit: CLVisit, placeAt:String) {
  arrivalDate = visit.arrivalDate
  departureDate = visit.departureDate
  place = placeAt
  }
}

private func objectifyVisit(v: Visit?) -> NSMutableDictionary? {
  let dict = NSMutableDictionary()
  if let it = v?.arrivalDate.iso8601 {
    dict.setValue(it, forKey: "arrivalDate");
  }
  if let it = v?.departureDate.iso8601 {
    dict.setValue(it, forKey: "departureDate");
  }
  if let it = v?.place {
    dict.setValue(it, forKey: "place");
  }
  if dict.count > 0 {
    dict.setValue(true, forKey: "validVisit");
  }else{
    dict.setValue(false, forKey: "validVisit");
  }
  return dict
}


func getStringVisit(v: Visit?) -> String{
  let json = try! JSONSerialization.data(withJSONObject: objectifyVisit(v:v) as Any, options: [])
  return String(data: json, encoding: String.Encoding.utf8)!
  //  return("HDS")
}
