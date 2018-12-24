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

func settingsRM(managedContext:NSManagedObjectContext) {
  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SettingsEnt")
  let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
  do {
    try managedContext.execute(deleteRequest)
    try managedContext.save()
    print("rm'ed existing settings")
  } catch let error as NSError {
    // TODO: handle the error
    print("could not delete all old settings: \(error), \(error.userInfo)")
    return
  }
}

func saveSettings(managedContext:NSManagedObjectContext) {

  settingsRM(managedContext: managedContext)
  
  let entity = NSEntityDescription.entity(forEntityName: "SettingsEnt", in: managedContext)
  var settingsO:NSManagedObject
  if entity == nil {
    print("nil entityt")
    settingsO = NSEntityDescription.insertNewObject(forEntityName: "SettingsEnt", into: managedContext) as! SettingsEnt
    //    return
  } else {
    print("ok entity")
    settingsO = NSManagedObject(entity: entity!, insertInto: managedContext)
  }

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

func loadSavedSettings(context:NSManagedObjectContext) {
//  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
//    print("h0")
//    return
//  }
  print("h1")
//  let managedContext = appDelegate.persistentContainer.viewContext
  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SettingsEnt")
//  let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SettingsEnt")
  print("h2")
  do {
    let loadedSettings = try context.fetch(fetchRequest)
    print("h3")
    for data in loadedSettings {
      print("h4")
      AppSettings.pushAtCount = data.value(forKey: "pushAtCount") as! Int64
      AppSettings.batteryMonitoringEnabled = (data.value(forKey: "batteryMonitoringEnabled") != nil)
      AppSettings.beaconAdvertisingEnabled = (data.value(forKey: "beaconAdvertisingEnabled") != nil)
      AppSettings.beaconMonitoringEnabled = (data.value(forKey: "beaconMonitoringEnabled") != nil)
      AppSettings.healthKitEnabled = (data.value(forKey: "healthKitEnabled") != nil)
      AppSettings.networkInformationEnabled = (data.value(forKey: "networkInformationEnabled") != nil)
    }
  } catch let error as NSError {
    print("Could not fetch. \(error), \(error.userInfo)")
    return
  }
}
