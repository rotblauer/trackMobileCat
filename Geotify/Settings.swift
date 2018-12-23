//
//  Settings.swift
//  Geotify
//
//  Created by isaac on 12/22/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import CoreLocation

// Global instance.
var AppSettings:Settings = Settings()

class Settings {
  var pushAtCount:Int = 100
  var healthKitEnabled:Bool = true
  var batteryMonitoringEnabled:Bool = true
  var beaconMonitoringEnabled:Bool = true
  var beaconAdvertisingEnabled:Bool = true
  var networkInformationEnabled:Bool = true
  var locationManagerSettings:LocationManagerSettings = LocationManagerSettings();
  
  func flyMode() -> Settings {
    self.pushAtCount = 60*60*24 // ~24 hours
    self.networkInformationEnabled = false
    
    self.beaconMonitoringEnabled = true
    self.beaconAdvertisingEnabled = true
    self.locationManagerSettings.backgroundUpdates = true
    self.locationManagerSettings.autoPause = false
    self.locationManagerSettings.desiredAccuracy = 5000
    self.locationManagerSettings.distanceFilter = 500
    self.locationManagerSettings.activityType = LocationManagerActivityType.Airborne
    
    return self
  }
  
  func liteMode() -> Settings {
    self.pushAtCount = 60*60 // ~1 hour
    self.networkInformationEnabled = true
    
    self.beaconMonitoringEnabled = false
    self.beaconAdvertisingEnabled = false
    self.locationManagerSettings.backgroundUpdates = true
    self.locationManagerSettings.autoPause = true
    self.locationManagerSettings.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    self.locationManagerSettings.distanceFilter = 10 // because 500 is limit is baked in to the SignficantChange monitoring
    self.locationManagerSettings.activityType = LocationManagerActivityType.Other
    
    return self
  }
  
  func fullMode() -> Settings {
    self.pushAtCount = 60*2 // ~2 minutes
    self.networkInformationEnabled = true
    
    self.beaconMonitoringEnabled = true
    self.beaconAdvertisingEnabled = true
    self.locationManagerSettings.backgroundUpdates = true
    self.locationManagerSettings.autoPause = false
    self.locationManagerSettings.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManagerSettings.distanceFilter = kCLDistanceFilterNone
    self.locationManagerSettings.activityType = LocationManagerActivityType.Other
    
    return self
  }
}
