//
//  DataStoreSettings.swift
//  Geotify
//
//  Created by isaac on 12/23/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import CoreData
import UIKit

func rmSettings() {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  let managedContext = appDelegate.persistentContainer.viewContext
  
  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SettingsEnt")
  let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
  do {
    try managedContext.execute(deleteRequest)
    try managedContext.save()
    print("rm'ed existing settings")
  } catch let error as NSError {
    print("could not delete all old settings: \(error), \(error.userInfo)")
    return
  }
}

func saveSettings() {

  rmSettings()
  
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  let managedContext = appDelegate.persistentContainer.viewContext

  let entity = NSEntityDescription.entity(forEntityName: "SettingsEnt", in: managedContext)
  if entity == nil {
      print("nil Settings entity")
      return
  }
  
  let settingsO = NSManagedObject(entity: entity!, insertInto: managedContext)
  settingsO.setValue(AppSettings.pushAtCount, forKey: "pushAtCount")
  settingsO.setValue(AppSettings.batteryMonitoringEnabled, forKey: "batteryMonitoringEnabled")
  settingsO.setValue(AppSettings.beaconAdvertisingEnabled, forKey: "beaconAdvertisingEnabled")
  settingsO.setValue(AppSettings.beaconMonitoringEnabled, forKey: "beaconMonitoringEnabled")
  settingsO.setValue(AppSettings.healthKitEnabled, forKey: "healthKitEnabled")
  settingsO.setValue(AppSettings.networkInformationEnabled, forKey: "networkInformationEnabled")
  
  do {
    try managedContext.save()
          print("saved settings")
  } catch let error as NSError {
    print("Could not save settings. \(error), \(error.userInfo)")
  }
}

func loadSavedSettings() {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    return
  }
  let context = appDelegate.persistentContainer.viewContext
  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SettingsEnt")
  do {
    let loadedSettings = try context.fetch(fetchRequest)
    for data in loadedSettings {
      AppSettings.pushAtCount = data.value(forKey: "pushAtCount") as! Int64
      AppSettings.batteryMonitoringEnabled = (data.value(forKey: "batteryMonitoringEnabled") as! NSNumber != 0)
      AppSettings.beaconAdvertisingEnabled = (data.value(forKey: "beaconAdvertisingEnabled") as! NSNumber != 0)
      AppSettings.beaconMonitoringEnabled = (data.value(forKey: "beaconMonitoringEnabled") as! NSNumber != 0)
      AppSettings.healthKitEnabled = (data.value(forKey: "healthKitEnabled") as! NSNumber != 0)
      AppSettings.networkInformationEnabled = (data.value(forKey: "networkInformationEnabled") as! NSNumber != 0)
    }
  } catch let error as NSError {
    print("Could not fetch. \(error), \(error.userInfo)")
    return
  }
}
