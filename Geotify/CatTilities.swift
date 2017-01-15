//MIT License
//Copyright (c) <2016> <ROTBLAUER LLC>
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.



//
//  CatTilities.swift
//  

import Foundation
import CoreLocation
import UIKit


func pushLoc(manager: CLLocationManager) {
  
  
  let json = NSMutableDictionary()
  json.setValue(UIDevice.current.name, forKey: "name"); //set all your values..
  json.setValue(manager.location!.coordinate.latitude, forKey: "lat");
  json.setValue(manager.location!.coordinate.longitude, forKey: "long");
  json.setValue(manager.location!.horizontalAccuracy, forKey: "accuracy");
  json.setValue(manager.location!.altitude, forKey: "elevation");
  json.setValue(manager.location!.speed, forKey: "speed");
  json.setValue(manager.location!.course, forKey: "heading");
  json.setValue(Date().iso8601 , forKey: "time"); //get in golang time mod
  
  var request = URLRequest(url: URL(string: "http://cattrack-155019.appspot.com/populate/")!)// will up date to cat scratcher main
  request.httpMethod = "POST"
  request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  request.addValue("application/json", forHTTPHeaderField: "Accept")
  request.httpBody = try! JSONSerialization.data(withJSONObject: json, options: [])
  // had to open up the security cleareance to get it to clear customs
  //http://highaltitudehacks.com/2016/06/23/ios-application-security-part-46-app-transport-security/
  
  // needs this, kinda maybe?
  URLSession.shared.dataTask(with:request, completionHandler: {(data, response, error) in
    if error != nil {
      print(error ?? "NONE")
    } else {
      do {
        guard let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else { return }
        
        guard let errors = json?["errors"] as? [[String: Any]] else { return }
        if errors.count > 0 {
          print(errors)
          return
        } else {
        }
      }
    }
  }).resume()
  
}


extension Date {
  static let iso8601Formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX" //cute time format
    return formatter
  }()
  var iso8601: String {
    return Date.iso8601Formatter.string(from: self)
  }
}

extension String {
  var dateFromISO8601: Date? {
    return Date.iso8601Formatter.date(from: self)
  }
}


//
//
//    // https://github.com/varshylmobile/LocationManager/blob/master/LocationManager.swift
//    let arrayOfLocation = locations as NSArray
//    let location = arrayOfLocation.lastObject as! CLLocation
//    let coordLatLon = location.coordinate
//
//    let latitude  = coordLatLon.latitude
//    let longitude = coordLatLon.longitude
//
//    // latitudeAsString  = coordLatLon.latitude.description
//    // longitudeAsString = coordLatLon.longitude.description
//
//    // http://stackoverflow.com/questions/31937686/how-to-make-http-post-request-with-json-body-in-swift
//    // json in body here
//    // good old rayban https://www.raywenderlich.com/120442/swift-json-tutorial
//    // and http://stackoverflow.com/questions/29512839/create-json-in-swift
//    let json: [String: AnyObject] = [
//      "name": "kitty" as AnyObject,
//      "lat": latitude as AnyObject,
//      "long": longitude as AnyObject
//      //andmoar
//
//      // "altitude":
//      // "transfer": [
//      //   "startDate": "10/04/2015 12:45",
//      //   "endDate": "10/04/2015 16:00"
//      // ],
//      // "custom": savedData
//
//    ]
//
//    let jsonData = try? JSONSerialization.data(withJSONObject: json)
//
//    // create post request
//    let url = URL(string: "http://cattrack-155019.appspot.com/populate/")!
//    var request = URLRequest(url: url)
//    request.httpMethod = "POST"
//    // http://stackoverflow.com/questions/39929513/http-post-request-with-json
//    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
//
//    // insert json data to the request
//    request.httpBody = jsonData
//
//    _ = URLSession.shared.dataTask(with: request) { data, response, error in
//        guard let data = data, error == nil else {
//            print(error?.localizedDescription ?? "No data")
//            return
//        }
//        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
//        if let responseJSON = responseJSON as? [String: Any] {
//            print(responseJSON)
//        }
//    }


// ------

//but this has caps where others don't. don't trust it so much.
// // http://stackoverflow.com/questions/24566180/how-to-post-a-json-with-new-apple-swift-language
// // // create the request & response
// var request = NSMutableURLRequest(URL: NSURL(string: "http://requestb.in/1ema2pl1"), cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 5)
// var response: NSURLResponse?
// var error: NSError?

// // create some JSON data and configure the request
// let jsonString = "json=[{\"str\":\"Hello\",\"num\":1},{\"str\":\"Goodbye\",\"num\":99}]"
// request.HTTPBody = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
// request.HTTPMethod = "POST"
// request.setValue("application/json", forHTTPHeaderField: "Content-Type")

// // send the request
// NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)

// // look at the response
// if let httpResponse = response as? NSHTTPURLResponse {
//     println("HTTP response: \(httpResponse.statusCode)")
// } else {
//     println("No HTTP response")
// }
// //
