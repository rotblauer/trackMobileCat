//MIT License //Copyright (c) <2016> <ROTBLAUER LLC> // //Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: //
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import CoreLocation
import UIKit
import CoreData
import CoreMotion
import HealthKit
import CoreBluetooth

// mem only

private var firstPoint:CLLocation? = nil;
private var lastPoint:CLLocation? = nil;
var currentTripNotes = Note()
private var customTripNote = ""
private var batteryStatsField = ""
private let activityManager = CMMotionActivityManager()
private let pedometer = CMPedometer()
private let elly=CMAltimeter();// We have an actual altimeter!
private let hk=HKHealthStore();

private let catTracksBeaconUUID = "0A4AE5C6-12D1-48B1-A75D-BF0B8A6B1895"

var beaconRegions:[CLBeaconRegion]=[]
var beaconsRanging:[CLBeacon] = []

var requireWifiForPush:Bool = true;

func getRequireWifi() -> Bool {
  return requireWifiForPush;
}
func setRequireWifi(requireWifi: Bool) {
  requireWifiForPush = requireWifi;
}

private func startTrackingActivityType() {
  activityManager.startActivityUpdates(to: OperationQueue.main) {
    (activity: CMMotionActivity?) in
    
    guard let activity = activity else { return }
    DispatchQueue.main.async {
      if activity.walking {
        currentTripNotes.activity=Activity.Walking
      } else if activity.stationary {
        currentTripNotes.activity=Activity.Stationary
      } else if activity.running {
        currentTripNotes.activity=Activity.Running
      } else if activity.automotive {
        currentTripNotes.activity=Activity.Automotive
      }else if activity.cycling {
        currentTripNotes.activity=Activity.Bike
      }else{
        currentTripNotes.activity=Activity.Unknown
      }
    }
  }
}

private func startTrackingBatteryThings() {
  //    NotificationCenter.default.addObserver(self, selector: func(_ notification:Notification) {
  //      //  UIDevice.version()
  //      //  UIDevice.version()
  //      //  UIDevice.batteryLevelDidChangeNotification
  //      }, name: UIDevice.batteryStateDidChangeNotification, object: nil)
}

private func handleHeartRateSamples(ttype:HKQuantityType, samples:[HKQuantitySample]) {
  if samples.count > 0 {
    
    let sEI = samples.endIndex
    
    // take only last
    let sample = samples[sEI-1]
    
    //  let pp = "heartRate= \(sample.quantity)\nheartRateRaw= \(sample)"
    //  print(pp)
    
    currentTripNotes.heartRate = "\(sample.quantity)"
    currentTripNotes.heartRateRaw = "\(sample)"
  } else {
    setHeartRateNA(note:currentTripNotes)
  }
}

private func startMonitoringHeartRate() {
  // https://www.appcoda.com/healthkit/
  // https://stackoverflow.com/questions/40739920/how-to-get-the-calories-and-heart-rate-from-health-kit-sdk-in-swift
  
  let heartRateTypeIdent = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
  
  var myanchor = HKQueryAnchor.init(fromValue: 0)
  
  guard let startDate = NSCalendar.current.date(byAdding: .second, value: -10, to: (NSDate() as Date), wrappingComponents: true) else {
    fatalError("death in the beginning")
  }
  let endDate = NSCalendar.current.date(byAdding: .year, value: 1, to: (NSDate() as Date), wrappingComponents: true)
  let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
  
  let qq = HKAnchoredObjectQuery(type: heartRateTypeIdent, predicate: predicate, anchor: myanchor, limit: HKObjectQueryNoLimit) {
    (qq, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
    
    guard let samples = samplesOrNil as? [HKQuantitySample] else {
      print("samples nil errrrro")
      setHeartRateNA(note:currentTripNotes)
      fatalError("an error occururred fetching users quantities")
    }
    print("<3 start")
    myanchor = newAnchor!
    handleHeartRateSamples(ttype: heartRateTypeIdent, samples: samples)
  }
  
  // Add update handler to qq query.
  qq.updateHandler = { (query, samplesOrNil, deletedObjectsOrNil, newAnchor, errorOrNil) in
    guard let samples = samplesOrNil as? [HKQuantitySample] else {
      // Handle the error here.
      print("samples nil errrrro")
      setHeartRateNA(note:currentTripNotes)
      fatalError("*** An error occurred during an update: \(errorOrNil!.localizedDescription) ***")
    }
    myanchor = newAnchor!
    //    print("<3 updated")
    handleHeartRateSamples(ttype: heartRateTypeIdent, samples: samples)
  }
  hk.execute(qq)
}

private func startCountingSteps() {
  pedometer.startUpdates(from: Date()) {
    pedometerData, error in
    guard let pedometerData = pedometerData, error == nil else { return }
    
    DispatchQueue.main.async {
      
      //    var current=getStoredTripNotes()
      
      if #available(iOS 10.0, *) {
        if(pedometerData.averageActivePace != nil){
          currentTripNotes.averageActivePace=pedometerData.averageActivePace!
        }
      } else {
        currentTripNotes.averageActivePace=(-1.0)
      }
      if(pedometerData.currentCadence != nil){
        currentTripNotes.currentCadence=pedometerData.currentCadence!
      }
      currentTripNotes.numberOfSteps=pedometerData.numberOfSteps
      if(pedometerData.currentPace != nil){
        currentTripNotes.currentPace=pedometerData.currentPace!
      }
      currentTripNotes.distance=pedometerData.distance!
      if(pedometerData.floorsAscended != nil){
        currentTripNotes.floorsAscended=pedometerData.floorsAscended!
      }
      
      if(pedometerData.floorsDescended != nil){
        currentTripNotes.floorsDescended=pedometerData.floorsDescended!
      }
    }
  }
}


private func startMonitoringElevation(){
  elly.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler: { (altitudeData:CMAltitudeData?, error:Error?) in
    currentTripNotes.relativeAltitude = altitudeData!.relativeAltitude.doubleValue    // Relative altitude in meters
    currentTripNotes.pressure = altitudeData!.pressure.doubleValue            // Pressure in kilopascals
  })
}

func startUpdatingHeartRate() {
  startMonitoringHeartRate()
}

// TODO toggle for each for battery what not
func startUpdatingActivity() {
  if CMMotionActivityManager.isActivityAvailable() {
    print("activity: ok")
    startTrackingActivityType()
  }
  
  if CMPedometer.isStepCountingAvailable() {
    print("pedometer: ok")
    startCountingSteps()
  }
  
  if CMAltimeter.isRelativeAltitudeAvailable(){
    print("relative altitude: ok")
    startMonitoringElevation()
  }
  print("started activity updates")
}

func updateNetworkConfiguration() {
  if AppSettings.networkInformationEnabled {
      currentTripNotes.networkInfo = getNetworkInfo()
  }
}

func loadSavedSettingsExternalFromDelegate() {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  let managedContext = appDelegate.persistentContainer.viewContext
  loadSavedSettings(context:managedContext)
}

func saveSettingsExternalFromDelegate() {
  guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
    print("non-delegate")
    return
  }
  let managedContext = appDelegate.persistentContainer.viewContext
  saveSettings(managedContext:managedContext)
}

func startUpdatingNetworkInformation() {
  if (AppSettings.networkInformationEnabled) {
      updateNetworkConfiguration()
      DispatchQueue.main.asyncAfter(deadline: .now() + 60*5) {
        startUpdatingActivity()
      }
  }
}

func knownBeaconRegion(br: CLBeaconRegion) -> Int {
  for (i, b) in beaconRegions.enumerated() {
    if matchBeaconRegions(b1: b, b2: br) {
      return i
    }
  }
  return -1
}

func handleDidEnterBeaconRegion(locman: CLLocationManager, region: CLBeaconRegion) {
  // Never dupe beacon regions. This whole array thing in case there are ever more kinds of beacon regioning, eg. diff region UUIDs
  if knownBeaconRegion(br: region) >= 0 {
    return
  }
  beaconRegions.append(region)
  locman.startRangingBeacons(in: region)
  print("added beacon region: id: \(region.proximityUUID) M.m: \(region.major ?? -1).\(region.minor ?? -1)")
}

func matchBeaconRegions(b1: CLBeaconRegion, b2: CLBeaconRegion) -> Bool {
  return b1 == b2 || b1.major == b2.major && b1.minor == b2.minor
}

func matchBeacons(b1: CLBeacon, b2: CLBeacon) -> Bool {
  return b1 == b2 || b1.major == b2.major && b1.minor == b2.minor
}

func handleDidExitBeaconRegion(locman: CLLocationManager, region: CLBeaconRegion) {
  let i = knownBeaconRegion(br: region)
  // Always keep
  if i >= 0 && beaconRegions.count > 1 {
    locman.stopRangingBeacons(in: region)
    beaconRegions.remove(at: i)
    print("removed beacon region: id: \(region.proximityUUID) M.m: \(region.major ?? -1).\(region.minor ?? -1)")
  }
}

func startBeaconMonitoringIfEnabled(locman: CLLocationManager) {
  if AppSettings.beaconMonitoringEnabled && CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
    // Match all beacons with the specified UUID
    
    let proximityUUID = UUID(uuidString: catTracksBeaconUUID)
    let beaconID = "com.rotblauer.Beaconing"
    
    // Create the region and begin monitoring it.
    let region = CLBeaconRegion(proximityUUID: proximityUUID!, identifier: beaconID)
    region.notifyOnEntry = true
    region.notifyOnExit = true
    locman.startMonitoring(for: region)
    print("monitoring beacons: ok")
  } else {
    print("monitoring beacons: no")
    stopBeaconingService(locman: locman)
  }
}

func createBeaconRegion() -> CLBeaconRegion? {
  let proximityUUID = UUID(uuidString: catTracksBeaconUUID)
  let major : CLBeaconMajorValue = CLBeaconMinorValue(uuidN1) // device uuid hash
  let minor : CLBeaconMinorValue = CLBeaconMinorValue(uuidN2) // device uuid hash
  let beaconID = "com.rotblauer.Beaconing"
  
  return CLBeaconRegion(proximityUUID: proximityUUID!,
                        major: major, minor: minor, identifier: beaconID)
}

func advertiseDevice(btman: CBPeripheralManager, region : CLBeaconRegion) -> Bool {
  if btman.state == .poweredOn {
    let peripheralData = region.peripheralData(withMeasuredPower: nil)
    btman.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
    return true
  }
  return false
}

func startBeaconAdvertisingIfEnabled(btman: CBPeripheralManager) {
  if AppSettings.beaconAdvertisingEnabled {
    let region = createBeaconRegion()!
    let ok = advertiseDevice(btman: btman, region: region)
    print("advertising beacon: ok:\(ok) -> id: \(region.proximityUUID) M.m: \(region.major ?? -1).\(region.minor ?? -1)")
  } else {
    print("advertising beacon: off")
    btman.stopAdvertising()
  }
}

func stopBeaconingService(locman: CLLocationManager) {
  for r in beaconRegions {
    locman.stopMonitoring(for: r)
    locman.stopRangingBeacons(in: r)
  }
  beaconRegions = []
  beaconsRanging = []
}

func knownBeacon(bb: CLBeacon) -> Int {
  for (i, b) in beaconsRanging.enumerated() {
    if matchBeacons(b1: b, b2: bb) {
      return i
    }
  }
  return -1
}

func setRangedBeacon(beacon: CLBeacon) {
  let i = knownBeacon(bb: beacon)
  if i >= 0 {
    let kb = beaconsRanging[i]
    if kb.proximity != beacon.proximity {
      beaconsRanging.remove(at: i)
      beaconsRanging.append(beacon)
    }
    return
  }
  beaconsRanging.append(beacon)
}

func removeRangedBeacon(beacon: CLBeacon) {
  let i = knownBeacon(bb: beacon)
  if i >= 0 {
    beaconsRanging.remove(at: i)
    print("removed beacon: id: \(beacon.proximityUUID) M.m: \(beacon.major ).\(beacon.minor )")
  }
}

func addVisit(visit:CLVisit,place:String){
  let v = Visit.init(fromVisit: visit, placeAt: place)
  save(manager: locMan)
  currentTripNotes.currentVisit=v
  
  // update network whenever visit happens... or ~a little~ 6 minutes later, b/c it takes a hot minute to politey steal the coffeeshop's password
  DispatchQueue.main.asyncAfter(deadline: .now() + 60*6) {
      updateNetworkConfiguration()
  }
  
  save(manager: locMan)
  currentTripNotes.currentVisit=nil
}

func setCurrentTripNotes(s: String) {
  save(manager: locMan)
  
  locationManagerSetMode(manager: locMan, mode: s)
  
  //  savePointToCoreData(manager: CLLocationManager())
  currentTripNotes = Note()
  currentTripNotes.customNote=s
  startUpdatingActivity()//reset ped etc
  
  //TODO store actual currentTripNotes
  customTripNote = s
  
  save(manager: locMan)
  //  savePointToCoreData(manager: CLLocationManager())
}

func getStoredCustomTripNotes() -> String {
  return customTripNote
}

func getCurrentTripNoteString() -> String {
  currentTripNotes.customNote=getStoredCustomTripNotes();
  return getStringNote(n:currentTripNotes) ;
}
func getCurrentTripDistance() -> (traveled:Double, fromStart:Double) {
  return (currentTripNotes.currentTripDistance, currentTripNotes.currentTripDistanceFromStart);
}
func getCurrentTripTime() -> TimeInterval {
  return currentTripNotes.currentTripStart.timeIntervalSinceNow;
}
func getCurrentTripCustomNote() -> String {
  return currentTripNotes.customNote
}


func manageTripVals(lat:CLLocationDegrees, lng:CLLocationDegrees) {
  if (currentTripNotes.customNote != "") {
    if (lastPoint == nil) {
      currentTripNotes.currentTripStart = Date();
      lastPoint = CLLocation(latitude: lat, longitude: lng);
      firstPoint = lastPoint;
    } else {
      let curPoint = CLLocation(latitude: lat, longitude: lng);
      // increment
      currentTripNotes.currentTripDistance = currentTripNotes.currentTripDistance + (lastPoint?.distance(from: curPoint))!;
      // overall
      currentTripNotes.currentTripDistanceFromStart = (firstPoint?.distance(from: curPoint))!;
      
      lastPoint = curPoint; // update
    }
  } else {
    if (currentTripNotes.currentTripDistance != 0 || lastPoint != nil) {
      lastPoint = nil;
      currentTripNotes.currentTripDistance = 0;
      currentTripNotes.currentTripDistanceFromStart = 0;
      currentTripNotes.currentTripStart = Date();
    }
  }
}
