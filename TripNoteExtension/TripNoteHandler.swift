//
//  TripNoteHandler.swift
//  TripNoteExtension
//
//  Created by Kitty on 4/28/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Foundation
import Intents

class TripNoteHandler:
NSObject, INCreateNoteIntentHandling {
  func handle(intent: INCreateNoteIntent,
              completion: @escaping (INCreateNoteIntentResponse) -> Void) {
    print(intent.content ?? "NO note")
    let response = INCreateNoteIntentResponse(
      code: .failure,
      userActivity: .none)
    completion(response)
  }

}
