//MIT License //Copyright (c) <2016> <ROTBLAUER LLC> // //Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: //
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
}
