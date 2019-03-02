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
  var pushAtCount:Int64 = 100
  var healthKitEnabled:Bool = true
  var batteryMonitoringEnabled:Bool = true
  var beaconMonitoringEnabled:Bool = true
  var beaconAdvertisingEnabled:Bool = true
  var networkInformationEnabled:Bool = true
  var locationManagerSettings:LocationManagerSettings = LocationManagerSettings();
  
  func flyMode() -> Settings {
    self.pushAtCount = 60*60*24 // ~24 hours
    self.networkInformationEnabled = false
    
    self.beaconMonitoringEnabled = false
    self.beaconAdvertisingEnabled = false
    self.locationManagerSettings.locationManagerService = LocationManagerService.Standard
    self.locationManagerSettings.backgroundUpdates = true
    self.locationManagerSettings.autoPause = false
    self.locationManagerSettings.desiredAccuracy = 5000
    self.locationManagerSettings.distanceFilter = 500
    self.locationManagerSettings.activityType = LocationManagerActivityType.Other
    
    return self
  }
  
  func liteMode() -> Settings {
    self.pushAtCount = 60*10 // ~10 min
    self.networkInformationEnabled = true
    
    // distanceFilter=~500 is baked in to LocationManagerService.SignficantChange, which is overkill for the intentions of this feature
    // adhoc testing shows that da=30/df=5 is sufficient to reduce battery usage significantly (eg. 60-80%battery/night -> 10%/night and 100% bats/8hrs -> 60%bats/24hrs (granted a frequently stationary lifestyle)
    self.beaconMonitoringEnabled = false
    self.beaconAdvertisingEnabled = false
    self.locationManagerSettings.locationManagerService = LocationManagerService.Standard
    self.locationManagerSettings.backgroundUpdates = true
    self.locationManagerSettings.autoPause = true
    self.locationManagerSettings.desiredAccuracy = 50
    self.locationManagerSettings.distanceFilter = 5 // tracking at least movements to the kitchen once in a while
    self.locationManagerSettings.activityType = LocationManagerActivityType.Other
    
    return self
  }
  
  func fullMode() -> Settings {
    self.pushAtCount = 60*2 // ~2 minutes
    self.networkInformationEnabled = true
    
    self.beaconMonitoringEnabled = true
    self.beaconAdvertisingEnabled = true
    self.locationManagerSettings.locationManagerService = LocationManagerService.Standard
    self.locationManagerSettings.backgroundUpdates = true
    self.locationManagerSettings.autoPause = false
    self.locationManagerSettings.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManagerSettings.distanceFilter = kCLDistanceFilterNone
    self.locationManagerSettings.activityType = LocationManagerActivityType.Other
    
    return self
  }
}
