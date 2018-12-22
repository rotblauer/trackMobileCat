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
  if (mode=="fly") {
    print("updating to fly mode")
    locationManagerFly(manager: manager)
  } else if (mode == "lite") {
    print("updating to lite mode")
    locationManagerLite(manager: manager)
  } else {
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
  
  if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
    // The service is not available.
    print(":( significant change monitoring not available")
    return
  }
  
  manager.pausesLocationUpdatesAutomatically = true
  manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
  manager.distanceFilter = 500
  manager.activityType = CLActivityType.other

  // https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_significant-change_location_service
  manager.stopUpdatingLocation()
  // The significant-change location service offers a more power-friendly alternative for apps that need location data but do not need frequent updates or the precision of GPS. The service relies on lower-power alternatives (such as Wi-Fi and cellular information) to determine the user’s location. It then delivers location updates to your app only when the user’s position changes by a significant amount, such as 500 meters or more.
  manager.startMonitoringSignificantLocationChanges()
}

func locationManagerFull(manager: CLLocationManager) {
  pushAtCount=60*2
  
  // Do not start services that aren't available.
  if !CLLocationManager.locationServicesEnabled() {
    // Location services is not available.
        print(":( location updates not available")
    return
  }
  
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
