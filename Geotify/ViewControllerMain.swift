/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import MapKit
import CoreLocation
import CoreData

struct PreferencesKeys {
  static let savedItems = "savedItems"
}
var P = 0;
var Q = 0;
var currentStats="Locking location";
let version = catVersion()

class MainViewController: UIViewController {
  
  @IBOutlet weak var pointsCountLable: UILabel!
  @IBOutlet weak var pushPointsButton: UIBarButtonItem!
  @IBOutlet weak var lastPointLabel: UILabel!
  @IBOutlet weak var tripTimeSince: UILabel!
  @IBOutlet weak var tripDistLabel: UILabel!
  
  override func didMove(toParent parent: UIViewController?) {
    super.willMove(toParent: parent)
    if parent is SettingsViewController {
      print("twas settingsvc")
    } else if parent is MainViewController {
      print("twas mainvc")
    }
    if parent != nil { // idk
      print("did move to cattracks main view")
      updatePointDisplay()
    } else {
      print("main view parent")
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
      (_:Timer)->Void in
      self.updatePointDisplay();
    }
  }
  
  func updatePointsCount(stringer : String) {
    pointsCountLable.text = stringer
  }
  
  func updateLastPoint(stringer : String) {
    lastPointLabel.text = stringer
  }
  
  func updatePointDisplay() {
    updatePointsCount(stringer: "P:\(P)Q:\(Q)")
    updateLastPoint(stringer: currentStats)
  }
  
  @IBAction func swiper(_ sender: UISwipeGestureRecognizer) {
    updatePointDisplay()
  }
  
  @IBAction func pushPoints(_ sender: Any) {
    print("time to push")
    updatePointDisplay()
    pushLocs(force:true,pushToken: pushToken)
  }
}
