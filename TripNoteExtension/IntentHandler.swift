//
//  IntentHandler.swift
//  TripNoteExtension
//
//  Created by Kitty on 4/28/18.
//  Copyright © 2018 Ken Toh. All rights reserved.
//

import Intents


// As an example, this class is set up to handle Message intents.
// You will want to replace this or add other intents as appropriate.
// The intents you wish to handle must be declared in the extension's Info.plist.

// You can test your example integration by saying things to Siri like:
// "Send a message using <myApp>"
// "<myApp> John saying hello"
// "Search for messages in <myApp>"

class IntentHandler: INExtension {

  override func handler(for intent: INIntent) -> Any {
//    print(intent)
    return self
  }
  
}
  
  extension IntentHandler: INCreateNoteIntentHandling {
    
    public func handle(intent: INCreateNoteIntent, completion: @escaping (INCreateNoteIntentResponse) -> Swift.Void) {
//      let context = DatabaseHelper.shared.persistentContainer.viewContext
//      let newNote = Note(context: context)
    print(intent.title?.spokenPhrase)
       print(intent.content?.description)
      
      // Save the context.
//      do {
//        try context.save()
        print("trying to fhandle")
//      Geotify().
      
//       setCurrentTripNotes 
//     cat.setCurrentTripNotes(s: intent.content!)
      
        let response = INCreateNoteIntentResponse(code: INCreateNoteIntentResponseCode.success, userActivity: nil)
        response.createdNote = INNote(title: INSpeakableString.init(spokenPhrase: "HI"), contents:  [intent.content!], groupName: nil, createdDateComponents: nil, modifiedDateComponents: nil, identifier: nil)
//        response.createdNote
        print("finishing")
        completion(response)
//      } catch {
//
//        completion(INCreateNoteIntentResponse(code: INCreateNoteIntentResponseCode.failure, userActivity: nil))
//      }
    }
    
    public func confirm(intent: INCreateNoteIntent, completion: @escaping (INCreateNoteIntentResponse) -> Swift.Void) {
      completion(INCreateNoteIntentResponse(code: INCreateNoteIntentResponseCode.ready, userActivity: nil))
    }
    
    public func resolveTitle(forCreateNote intent: INCreateNoteIntent, with completion: @escaping (INStringResolutionResult) -> Swift.Void) {
      let result: INStringResolutionResult
      
      if let title = intent.title?.spokenPhrase, title.count > 0 {
//        result = INStringResolutionResult.success(with: title)
      } else {
      }
      print("resolve title")
      result = INStringResolutionResult.success(with: "TRACKS")

      
      completion(result)
    }
    
    
    public func resolveContent(for intent: INCreateNoteIntent, with completion: @escaping (INNoteContentResolutionResult) -> Swift.Void) {
      let result: INNoteContentResolutionResult
      print("check content")
      if let content = intent.content {
         print(content)
        result = INNoteContentResolutionResult.success(with: content)
      } else {
        print("needs content")

        result = INNoteContentResolutionResult.needsValue()
      }
      
      completion(result)
    }
    
    
    public func resolveGroupName(for intent: INCreateNoteIntent, with completion: @escaping (INSpeakableStringResolutionResult) -> Swift.Void) {
      completion(INSpeakableStringResolutionResult.notRequired())
    }
}
  
  
  
//  override func handler(for intent: INIntent) -> Any {
//    print("SFHSD")
//
//    return self
//  }
//
//  public func resolveTitle(forCreateNote intent: INCreateNoteIntent, with completion: @escaping (INStringResolutionResult) -> Swift.Void) {
////    let result: INStringResolutionResult
////
////    if let title = intent.title, title.count > 0 {
////    } else {
////      result = INStringResolutionResult.needsValue()
//
////    }
//    print( intent.title)
//   let result = INStringResolutionResult.success(with: "HI")
//
//    completion(result)
//  }
//
//  public func resolveContent(for intent: INCreateNoteIntent, with completion: @escaping (INNoteContentResolutionResult) -> Swift.Void) {
//    let result: INNoteContentResolutionResult
//
//    if let content = intent.content {
//      result = INNoteContentResolutionResult.success(with: content)
//    } else {
//      result = INNoteContentResolutionResult.notRequired()
//    }
//
//    completion(result)
//  }
//
//
//  public func confirm(intent: INCreateNoteIntent, completion: @escaping (INCreateNoteIntentResponse) -> Swift.Void) {
//    completion(INCreateNoteIntentResponse(code: INCreateNoteIntentResponseCode.ready, userActivity: nil))
//  }
//  public func resolveGroupName(for intent: INCreateNoteIntent, with completion: @escaping (INSpeakableStringResolutionResult) -> Swift.Void) {
//    print("SFHSD")
//
//    completion(INSpeakableStringResolutionResult.unsupported())
//  }
//
//  public func handle(intent: INCreateNoteIntent, completion: @escaping (INCreateNoteIntentResponse) -> Swift.Void) {
//    // Step 1
////    let context = DatabaseHelper.shared.persistentContainer.viewContext
//    // Step 2
////    let newNote = Note(context: context)
//    print(intent.title!)
////    print(intent.content!.description!)
//
//    // Save the context.
//    do {
//      // Step 3
////      try context.save()
//
//      // Step 4
//      let response = INCreateNoteIntentResponse(code: INCreateNoteIntentResponseCode.success, userActivity: nil)
//      // Step 5
//      response.createdNote = INNote(title: intent.title!, contents: [], groupName: nil, createdDateComponents: nil, modifiedDateComponents: nil, identifier: nil)
//
//      // Step 6
//      completion(response)
//    } catch {
//      // Step 7
//      completion(INCreateNoteIntentResponse(code: INCreateNoteIntentResponseCode.failure, userActivity: nil))
//    }
//  }
  
  
//  override func handler(for intent: INIntent) -> Any? {
//    print("got intent")
//    if intent is INRequestRideIntent {
//      return TripNoteHandler()
////      https://developer.apple.com/documentation/sirikit/increatenoteintenthandling
//    }
//    if intent is INCreateNoteIntent {
//
//      return TripNoteHandler()
//      //      https://developer.apple.com/documentation/sirikit/increatenoteintenthandling
//    }
//    return .none
//  }
//
//  func handle(intent: INCreateNoteIntent, completion: @escaping (INCreateNoteIntentResponse) -> Void) {
//    // Implement your application logic to set the message attribute here.
//    print(intent.content ?? "NO note")
//    let response = INCreateNoteIntentResponse(
//      code: .success,
//      userActivity: .none)
//    completion(response)
//  }
//
//    // MARK: - INSendMessageIntentHandling
//
//    // Implement resolution methods to provide additional information about your intent (optional).
//    func resolveRecipients(for intent: INSendMessageIntent, with completion: @escaping ([INPersonResolutionResult]) -> Void) {
//        if let recipients = intent.recipients {
//
//            // If no recipients were provided we'll need to prompt for a value.
//            if recipients.count == 0 {
//                completion([INPersonResolutionResult.needsValue()])
//                return
//            }
//
//            var resolutionResults = [INPersonResolutionResult]()
//            for recipient in recipients {
//                let matchingContacts = [recipient] // Implement your contact matching logic here to create an array of matching contacts
//                switch matchingContacts.count {
//                case 2  ... Int.max:
//                    // We need Siri's help to ask user to pick one from the matches.
//                    resolutionResults += [INPersonResolutionResult.disambiguation(with: matchingContacts)]
//
//                case 1:
//                    // We have exactly one matching contact
//                    resolutionResults += [INPersonResolutionResult.success(with: recipient)]
//
//                case 0:
//                    // We have no contacts matching the description provided
//                    resolutionResults += [INPersonResolutionResult.unsupported()]
//
//                default:
//                    break
//
//                }
//            }
//            completion(resolutionResults)
//        }
//    }
//
//    func resolveContent(for intent: INSendMessageIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
//        if let text = intent.content, !text.isEmpty {
//            completion(INStringResolutionResult.success(with: text))
//        } else {
//            completion(INStringResolutionResult.needsValue())
//        }
//    }
//
//    // Once resolution is completed, perform validation on the intent and provide confirmation (optional).
//
//    func confirm(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
//        // Verify user is authenticated and your app is ready to send a message.
//
//        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
//        let response = INSendMessageIntentResponse(code: .ready, userActivity: userActivity)
//        completion(response)
//    }
//
//    // Handle the completed intent (required).
//
//    func handle(intent: INSendMessageIntent, completion: @escaping (INSendMessageIntentResponse) -> Void) {
//        // Implement your application logic to send a message here.
//
//        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSendMessageIntent.self))
//        let response = INSendMessageIntentResponse(code: .success, userActivity: userActivity)
//        completion(response)
//    }
//
//    // Implement handlers for each intent you wish to handle.  As an example for messages, you may wish to also handle searchForMessages and setMessageAttributes.
//
//    // MARK: - INSearchForMessagesIntentHandling
//
//    func handle(intent: INSearchForMessagesIntent, completion: @escaping (INSearchForMessagesIntentResponse) -> Void) {
//        // Implement your application logic to find a message that matches the information in the intent.
//
//        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSearchForMessagesIntent.self))
//        let response = INSearchForMessagesIntentResponse(code: .success, userActivity: userActivity)
//        // Initialize with found message's attributes
//        response.messages = [INMessage(
//            identifier: "identifier",
//            content: "I am so excited about SiriKit!",
//            dateSent: Date(),
//            sender: INPerson(personHandle: INPersonHandle(value: "sarah@example.com", type: .emailAddress), nameComponents: nil, displayName: "Sarah", image: nil,  contactIdentifier: nil, customIdentifier: nil),
//            recipients: [INPerson(personHandle: INPersonHandle(value: "+1-415-555-5555", type: .phoneNumber), nameComponents: nil, displayName: "John", image: nil,  contactIdentifier: nil, customIdentifier: nil)]
//            )]
//        completion(response)
//    }
//
//    // MARK: - INSetMessageAttributeIntentHandling
//
//    func handle(intent: INSetMessageAttributeIntent, completion: @escaping (INSetMessageAttributeIntentResponse) -> Void) {
//        // Implement your application logic to set the message attribute here.
//
//        let userActivity = NSUserActivity(activityType: NSStringFromClass(INSetMessageAttributeIntent.self))
//        let response = INSetMessageAttributeIntentResponse(code: .success, userActivity: userActivity)
//        completion(response)
//    }
//}

