//
//  Battery.swift
//  Geotify
//
//  Created by Ardis on 07.D.18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import UIKit

var batteryLevel: Float {
  return UIDevice.current.batteryLevel
}
var batteryState: UIDevice.BatteryState {
  return UIDevice.current.batteryState
}

struct DeviceBatteryStat{
  
  var status:String;
  var level:Float;
  
  init(lev:Float, stat:UIDevice.BatteryState) {
    switch stat {
    case .unplugged:
      status = "unplugged"
    case .unknown:
      status = "unknown"
    case .charging:
      status = "charging"
    case .full:
      status = "full"
    }
    level = lev
  }
}

private func objectifyBatStat(bs: DeviceBatteryStat?) -> NSMutableDictionary? {
  let dict = NSMutableDictionary()
  dict.setValue(bs?.level, forKey: "level")
  dict.setValue(bs?.status, forKey: "status")
  return dict
}

func getStringBatteryStatus(bs: DeviceBatteryStat?) -> String {
  let json = try! JSONSerialization.data(withJSONObject: objectifyBatStat(bs: bs) as Any, options: [])
  return String(data: json, encoding: String.Encoding.utf8)!
}
