//
//  LocationManager.swift
//  Geotify
//
//  Created by isaac on 12/22/18.
//  Copyright © 2018 Rotblauer. All rights reserved.
//

import Foundation
import CoreLocation

func locationManagerSetMode(manager: CLLocationManager, mode: String) {
  if(mode=="fly"){
    print("updating to fly mode")
    locationManagerFly(manager: manager)
  }else if (mode == "lite") {
    print("updating to lite mode")
    locationManagerLite(manager: manager)
  }else{
    print("setting to regular mode")
    locationManagerFull(manager: manager)
  }
  print("@locationManager.desiredAccuracy=\(manager.desiredAccuracy)")
  print("@locationManager.distanceFilter=\(manager.distanceFilter)")
  print("@locationManager.auto_pause=\(manager.pausesLocationUpdatesAutomatically)")
  print("@locationManager.background_allowed=\(manager.allowsBackgroundLocationUpdates)")
}

func locationManagerFly(manager: CLLocationManager) {
  pushAtCount=60*60*12
  manager.desiredAccuracy=5000
  manager.activityType = CLActivityType.airborne
}

func locationManagerLite(manager: CLLocationManager) {
  pushAtCount=60*60
  manager.pausesLocationUpdatesAutomatically = true
  manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
  manager.distanceFilter = 10
  manager.activityType = CLActivityType.other

  // https://developer.apple.com/documentation/corelocationgetting_the_user_s_location/
  manager.stopUpdatingLocation()
  manager.startMonitoringSignificantLocationChanges()

  // https://developer.apple.com/documentation/corelocationgetting_the_user_s_location/
  manager.stopUpdatingLocation()
  manager.startMonitoringSignificantLocationChanges()
}

func locationManagerFull(manager: CLLocationManager) {
  pushAtCount=60*2
  manager.pausesLocationUpdatesAutomatically = false
  
  // The default value of this property is CLActivityType.other. Note that when the value of activityType is CLActivityType.fitness, indoor positioning is disabled.
  // https://developer.apple.com/documentation/corelocation/cllocationmanager/1620567-activitytype
  manager.activityType = CLActivityType.other
  
  // https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_standard_location_service
  manager.desiredAccuracy = kCLLocationAccuracyBest
  manager.distanceFilter = kCLDistanceFilterNone
  manager.stopMonitoringSignificantLocationChanges()
  manager.startUpdatingLocation()
}
