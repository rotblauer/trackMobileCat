//
//  DataStoreLM.swift
//  Geotify
//
//  Created by isaac on 12/23/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import CoreData
import UIKit

func rmLM() {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  let managedContext = appDelegate.persistentContainer.viewContext
  
  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "LMEnt")
  let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
  do {
    try managedContext.execute(deleteRequest)
    try managedContext.save()
    print("rm'ed existing lm")
  } catch let error as NSError {
    print("could not delete all old lms: \(error), \(error.userInfo)")
    return
  }
}

func saveLM() {
  
  rmLM()
  
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  let managedContext = appDelegate.persistentContainer.viewContext
  
  let entity = NSEntityDescription.entity(forEntityName: "LMEnt", in: managedContext)
  if entity == nil {
    print("nil LM entity")
    return
  }
  
  var service = "Standard"
  if AppSettings.locationManagerSettings.locationManagerService == LocationManagerService.SignificantChange {
    service = "SignficantChange"
  }
  
  var activity:String
  switch AppSettings.locationManagerSettings.activityType {
  case LocationManagerActivityType.Other:
    activity = "Other"
    break
  case LocationManagerActivityType.OtherNavigation:
    activity = "OtherNavigation"
    break
  case LocationManagerActivityType.AutomotiveNavigation:
    activity = "AutomotiveNavigation"
    break
  case LocationManagerActivityType.Airborne:
    activity = "Airborne"
    break
  case LocationManagerActivityType.Fitness:
    activity = "Fitness"
    break
  }
  
  let settingsO = NSManagedObject(entity: entity!, insertInto: managedContext)
  settingsO.setValue(activity, forKey: "lmActivityType")
  settingsO.setValue(service, forKey: "lmServiceType")
  settingsO.setValue(AppSettings.locationManagerSettings.autoPause, forKey: "lmAutoPause")
  settingsO.setValue(AppSettings.locationManagerSettings.backgroundUpdates, forKey: "lmBackgroundUpdates")
  settingsO.setValue(AppSettings.locationManagerSettings.locationManagerVisitsServiceEnabled, forKey: "lmVisitsEnabled")
  settingsO.setValue(AppSettings.locationManagerSettings.desiredAccuracy, forKey: "lmDesiredAccuracy")
  settingsO.setValue(AppSettings.locationManagerSettings.distanceFilter, forKey: "lmDistanceFilter")
  
  do {
    try managedContext.save()
    print("saved LM")
  } catch let error as NSError {
    print("Could not save LM. \(error), \(error.userInfo)")
  }
}

func loadLM() {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    return
  }
  let context = appDelegate.persistentContainer.viewContext
  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "LMEnt")
  do {
    let loadedSettings = try context.fetch(fetchRequest)
    for data in loadedSettings {
      
      var service = LocationManagerService.Standard
      if data.value(forKey: "lmServiceType") as! String == "SignificantChange" {
        service = LocationManagerService.SignificantChange
      }
      AppSettings.locationManagerSettings.locationManagerService = service
      
      var activity:LocationManagerActivityType
      switch AppSettings.locationManagerSettings.activityType {
      case LocationManagerActivityType.Other:
        activity = LocationManagerActivityType.Other
        break
      case LocationManagerActivityType.OtherNavigation:
        activity = LocationManagerActivityType.OtherNavigation
        break
      case LocationManagerActivityType.AutomotiveNavigation:
        activity = LocationManagerActivityType.AutomotiveNavigation
        break
      case LocationManagerActivityType.Airborne:
        activity = LocationManagerActivityType.Airborne
        break
      case LocationManagerActivityType.Fitness:
        activity = LocationManagerActivityType.Fitness
        break
      }
      AppSettings.locationManagerSettings.activityType = activity
      
      AppSettings.locationManagerSettings.backgroundUpdates = (data.value(forKey: "lmBackgroundUpdates") as! NSNumber != 0)
      AppSettings.locationManagerSettings.locationManagerVisitsServiceEnabled = (data.value(forKey: "lmVisitsEnabled") as! NSNumber != 0)
      AppSettings.locationManagerSettings.desiredAccuracy = data.value(forKey: "lmDesiredAccuracy") as! Double
      AppSettings.locationManagerSettings.distanceFilter = data.value(forKey: "lmDistanceFilter") as! Double
      
    }
  } catch let error as NSError {
    print("Could not fetch. \(error), \(error.userInfo)")
    return
  }
}
