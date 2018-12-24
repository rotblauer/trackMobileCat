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

func saveSettings() {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    return
  }
  
  let managedContext = appDelegate.persistentContainer.viewContext
  let entity = NSEntityDescription.entity(forEntityName: "SettingsEnt", in: managedContext)!
  let settingsO = NSManagedObject(entity: entity, insertInto: managedContext)

  settingsO.setValue(Int64(AppSettings.pushAtCount), forKey: "pushAtCount")
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

func fetchSavedSettings() {
  let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TrackPoint")
  
  do {
    let fetchedPoints = try context.fetch(fetchRequest) as! [TrackPoint]
    return fetchedPoints
  } catch let error as NSError {
    print("Could not fetch. \(error), \(error.userInfo)")
    return []
  }
}
