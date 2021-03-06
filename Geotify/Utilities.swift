//MIT License //Copyright (c) <2016> <ROTBLAUER LLC> // //Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: //
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import SystemConfiguration
import CoreLocation

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

func catVersion() -> String {
  let dictionary = Bundle.main.infoDictionary!
  let version = dictionary["CFBundleShortVersionString"] as! String
  return version
}

func beaconProximityString(prox: CLProximity) -> String {
  switch prox {
  case .far:
    return "far"
  case .immediate:
    return "immediate"
  case .near:
    return "near"
  case .unknown:
    return "unknown"
  }
}

func stringFromTimeInterval(interval: TimeInterval) -> NSString {
  
  let ti = NSInteger(-interval) // neg cuz backwards
  
  let seconds = ti % 60
  let minutes = (ti / 60) % 60
  let hours = (ti / 3600)
  
  return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
}
