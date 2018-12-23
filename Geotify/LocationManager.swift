//
//  LocationManager.swift
//  Geotify
//
//  Created by isaac on 12/22/18.
//  Copyright © 2018 Rotblauer. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationManagerService: String {
  case SignificantChange, Standard
}

enum LocationManagerActivityType: String {
  case Other, OtherNavigation, AutomitiveNavigation, Fitness, Airborne
}

class LocationManagerSettings {
  var locationManagerService:LocationManagerService = LocationManagerService.Standard
  var locationManagerVisitsServiceEnabled:Bool = true
  var desiredAccuracy:Double = kCLLocationAccuracyBest
  var distanceFilter:Double = kCLDistanceFilterNone
  var autoPause:Bool = false
  var backgroundUpdates:Bool = true
  var activityType:LocationManagerActivityType = LocationManagerActivityType.Other
}

func locationManagerSetMode(manager: CLLocationManager, mode: String) {
  switch mode {
  case "fly":
    print("updating to fly mode")
    _ = AppSettings.flyMode()
    break
  case "lite":
    print("updating to lite mode")
    _ = AppSettings.liteMode()
    break
  case "full", "":
    fallthrough
  default:
    print("setting to regular mode")
    _ = AppSettings.fullMode()
  }
  
  locationManagerInstallSettings(manager: manager, settings: AppSettings.locationManagerSettings)

  print("@locationManager.desiredAccuracy=\(manager.desiredAccuracy)")
  print("@locationManager.distanceFilter=\(manager.distanceFilter)")
  print("@locationManager.auto_pause=\(manager.pausesLocationUpdatesAutomatically)")
  print("@locationManager.background_allowed=\(manager.allowsBackgroundLocationUpdates)")
}

// locationManagerInstallSettings validates and assigns settings to the manager, stopping and starting location updates as needed.
func locationManagerInstallSettings(manager: CLLocationManager, settings: LocationManagerSettings) {
  
  manager.desiredAccuracy = settings.desiredAccuracy
  manager.distanceFilter = settings.distanceFilter
  manager.pausesLocationUpdatesAutomatically = settings.autoPause
  manager.allowsBackgroundLocationUpdates = settings.backgroundUpdates
  
  switch settings.activityType {
  case LocationManagerActivityType.Airborne:
    manager.activityType = CLActivityType.airborne
    break
  case LocationManagerActivityType.Other:
    manager.activityType = CLActivityType.other
    break
  case LocationManagerActivityType.OtherNavigation:
    manager.activityType = CLActivityType.otherNavigation
    break
  case LocationManagerActivityType.Fitness:
    manager.activityType = CLActivityType.fitness
    break
  default:
    print("impossible activity type: \(settings.activityType)")
    return
  }
  
  // Stop both possible location services.
  manager.stopUpdatingLocation()
  manager.stopMonitoringSignificantLocationChanges()
  
  // Validate and start one location service.
  switch settings.locationManagerService {
  case LocationManagerService.Standard:
    if !CLLocationManager.locationServicesEnabled() {
      print(":( location updates not available")
      return
    }
    manager.startUpdatingLocation()
    break
  case LocationManagerService.SignificantChange:
    if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
      print(":( significant change monitoring not available")
      return
    }
    // https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_significant-change_location_service
    // The significant-change location service offers a more power-friendly alternative for apps that need location data but do not need frequent updates or the precision of GPS. The service relies on lower-power alternatives (such as Wi-Fi and cellular information) to determine the user’s location. It then delivers location updates to your app only when the user’s position changes by a significant amount, such as 500 meters or more.
    manager.startMonitoringSignificantLocationChanges()
    break
  }
  
  if !settings.locationManagerVisitsServiceEnabled {
    manager.stopMonitoringVisits()
  } else {
    if CLLocationManager.authorizationStatus() != .authorizedAlways || !CLLocationManager.locationServicesEnabled() {
      print(":( visit monitoring not available")
      return
    }
    manager.startMonitoringVisits()
  }
}
