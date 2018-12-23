//
//  Network.swift
//  Geotify
//
//  Created by isaac on 12/22/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

class NetworkInfo {
  var ssidData:String = ""
  var ssid:String = ""
  var bssid:String = ""
  init(data: String, pssid: String, pbssid: String) {
    ssidData = data
    ssid = pssid
    bssid = pbssid
  }
}

// https://stackoverflow.com/a/49526714/4401322
// https://gist.github.com/werediver/b1d5ed625a3fbf538481e40a71b4d1ac
func getNetworkInfo() -> NetworkInfo? {
  var ssidData: CFData? = nil
  var ssid: CFString = "" as CFString
  var bssid: CFString = "" as CFString
  if let interfaces = CNCopySupportedInterfaces() as NSArray? {
    for interface in interfaces {
      if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
        ssidData = (interfaceInfo[kCNNetworkInfoKeySSIDData] as! CFData)
        ssid = interfaceInfo[kCNNetworkInfoKeySSID] as! CFString
        bssid = interfaceInfo[kCNNetworkInfoKeyBSSID] as! CFString
        break
      }
    }
  }
  if ((ssid as String) == "") {
    return nil
  }
  print("ssid: \(ssid), bssid: \(bssid), ssidData: \(String(describing: ssidData!))")
  return NetworkInfo(data: "\(String(describing: ssidData!))" , pssid: ssid as String, pbssid: bssid as String)
}

private func objectifyNetworkInfo(ni: NetworkInfo?) -> NSMutableDictionary? {
  let dict = NSMutableDictionary()
  dict.setValue(ni?.ssid, forKey: "ssid")
  dict.setValue(ni?.ssidData, forKey: "ssidData")
  dict.setValue(ni?.bssid, forKey: "bssid")
  return dict
}

func getStringNetworkInfo(ni: NetworkInfo?) -> String {
  let json = try! JSONSerialization.data(withJSONObject: objectifyNetworkInfo(ni: ni) as Any, options: [])
  return String(data: json, encoding: String.Encoding.utf8)!
}

