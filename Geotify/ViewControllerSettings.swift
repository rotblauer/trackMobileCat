//
//  SettingsViewController.swift
//  Geotify
//
//  Created by isaac on 12/23/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import UIKit
class SettingsViewController: UIViewController, UITextFieldDelegate {
  
  @IBOutlet var pushAtNTF: UITextField!
  @IBOutlet weak var desiredAccuracyTF: UITextField!
  @IBOutlet weak var distanceFilterTF: UITextField!
  @IBOutlet weak var locationServiceSC: UISegmentedControl!
  @IBOutlet weak var locationBackgroundUpdatesT: UISwitch!
  @IBOutlet weak var locationAutopausesT: UISwitch!
  @IBOutlet weak var settingsWLANEnabledT: UISwitch!
  @IBOutlet weak var settingsHealthKitEnabled: UISwitch!
  @IBOutlet weak var btBeaconAdvertisingT: UISwitch!
  @IBOutlet weak var btBeaconMonitoringT: UISwitch!
  @IBOutlet weak var presetFlyBT: UIButton!
  @IBOutlet weak var presetLiteBT: UIButton!
  @IBOutlet weak var presetFullBT: UIButton!
  @IBOutlet weak var locationActivityTypeSC: UISegmentedControl!
  
  func setDisplayFromSettings() {
    self.pushAtNTF.text = "\(AppSettings.pushAtCount)"
    self.desiredAccuracyTF.text = "\(AppSettings.locationManagerSettings.desiredAccuracy)"
    self.distanceFilterTF.text = "\(AppSettings.locationManagerSettings.distanceFilter)"
    var lsSegIndex = 0
    if AppSettings.locationManagerSettings.locationManagerService == LocationManagerService.SignificantChange {
      lsSegIndex = 1
    }
    self.locationServiceSC.selectedSegmentIndex = lsSegIndex
    self.locationBackgroundUpdatesT.isOn = AppSettings.locationManagerSettings.backgroundUpdates
    self.locationAutopausesT.isOn = AppSettings.locationManagerSettings.autoPause
    self.settingsHealthKitEnabled.isOn = AppSettings.healthKitEnabled
    self.btBeaconAdvertisingT.isOn = AppSettings.beaconAdvertisingEnabled
    self.btBeaconMonitoringT.isOn = AppSettings.beaconMonitoringEnabled
    var activityTypeSegIndex = 0
    switch AppSettings.locationManagerSettings.activityType {
    case LocationManagerActivityType.Other:
      activityTypeSegIndex = 0
      break
    case LocationManagerActivityType.OtherNavigation:
      activityTypeSegIndex = 1
      break
    case LocationManagerActivityType.AutomotiveNavigation:
      activityTypeSegIndex = 2
      break
    case LocationManagerActivityType.Airborne:
      activityTypeSegIndex = 3
      break
    case LocationManagerActivityType.Fitness:
      activityTypeSegIndex = 4
      break
    }
    self.locationActivityTypeSC.selectedSegmentIndex = activityTypeSegIndex
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("settings view loaded")
    self.hideKeyboardWhenTappedAround()
    setDisplayFromSettings()
  }
  override func willMove(toParent parent: UIViewController?) {
    super.willMove(toParent: parent)
    if parent == nil { // idk
      print("moving back to cattracks main view")
      saveSettings()
      saveLM()
      
      startBeaconMonitoringIfEnabled(locman: locMan)
      startBeaconAdvertisingIfEnabled(btman: btPeripheralManager)
      
      updateNetworkConfiguration()
      locationManagerInstallSettings(manager: locMan, settings: AppSettings.locationManagerSettings)
      
    } else {
      print("parent \(String(describing: parent))")
    }
  }
  
  @IBAction func pushAtNTextFieldEditingEnded(_ sender: UITextField, forEvent event: UIEvent) {
      AppSettings.pushAtCount = Int64(sender.text!)!
  }
  @IBAction func desiredAccuracyEditingEnded(_ sender: UITextField, forEvent event: UIEvent) {
      var d = Double(sender.text!)!
      if d == 0 {
        d = -1
      }
      AppSettings.locationManagerSettings.desiredAccuracy = d
  }
  @IBAction func distanceFilterTFEditingEnded(_ sender: UITextField, forEvent event: UIEvent) {
    var d = Double(sender.text!)!
    if d == 0 {
      d = -1
    }
    AppSettings.locationManagerSettings.distanceFilter = d
  }
  @IBAction func locationServiceSCDidChange(_ sender: UISegmentedControl, forEvent event: UIEvent) {
    if sender.selectedSegmentIndex == 0 {
      AppSettings.locationManagerSettings.locationManagerService = LocationManagerService.Standard
    } else {
      AppSettings.locationManagerSettings.locationManagerService = LocationManagerService.SignificantChange
    }
  }
  @IBAction func locationBackgroundUpdatesTChanged(_ sender: UISwitch, forEvent event: UIEvent) {
    AppSettings.locationManagerSettings.backgroundUpdates = sender.isOn
  }
  @IBAction func locationAutopauseTChanged(_ sender: UISwitch, forEvent event: UIEvent) {
    AppSettings.locationManagerSettings.autoPause = sender.isOn
  }
  @IBAction func settingsWLANEnabledTChanged(_ sender: UISwitch) {
    AppSettings.networkInformationEnabled = sender.isOn
  }
  @IBAction func settingsHealthKitEnabledTChanged(_ sender: UISwitch, forEvent event: UIEvent) {
    AppSettings.healthKitEnabled = sender.isOn
  }
  @IBAction func btBeaconAdvertisingTChanged(_ sender: UISwitch, forEvent event: UIEvent) {
    AppSettings.beaconAdvertisingEnabled = sender.isOn
  }
  @IBAction func btBeaconMonitoringTChanged(_ sender: UISwitch, forEvent event: UIEvent) {
    AppSettings.beaconMonitoringEnabled = sender.isOn
  }
  @IBAction func presetFlyBTPushed(_ sender: UIButton, forEvent event: UIEvent) {
    _ = AppSettings.flyMode()
    setDisplayFromSettings()
  }
  @IBAction func presetLiteBTPushed(_ sender: UIButton, forEvent event: UIEvent) {
    _ = AppSettings.liteMode()
    setDisplayFromSettings()
  }
  @IBAction func presetFullBTPushed(_ sender: UIButton, forEvent event: UIEvent) {
    _ = AppSettings.fullMode()
    setDisplayFromSettings()
  }
  @IBAction func locationActivitySCChanged(_ sender: UISegmentedControl, forEvent event: UIEvent) {
    switch sender.selectedSegmentIndex {
    case 0:
      AppSettings.locationManagerSettings.activityType = LocationManagerActivityType.Other
      break
    case 1:
      AppSettings.locationManagerSettings.activityType = LocationManagerActivityType.OtherNavigation
      break
    case 2:
      AppSettings.locationManagerSettings.activityType = LocationManagerActivityType.AutomotiveNavigation
      break
    case 3:
      AppSettings.locationManagerSettings.activityType = LocationManagerActivityType.Airborne
      break
    case 4:
      AppSettings.locationManagerSettings.activityType = LocationManagerActivityType.Fitness
      break
    default:
      print("impossible")
    }
  }
  
}

// Put this piece of code anywhere you like
// https://stackoverflow.com/a/27079103/4401322
extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}
