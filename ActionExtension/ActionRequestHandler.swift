//
//  ActionRequestHandler.swift
//  ActionExtension
//
//  Created by Doug Williams on 12/3/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import UIKit
import MobileCoreServices
import OneChannelKit
import Crashlytics

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?
    let poster = OneChannelPoster()
    
    func beginRequestWithExtensionContext(context: NSExtensionContext) {
        // log
        Answers.logCustomEventWithName("Action Extension - Opened", customAttributes: [:])
        self.extensionContext = context
        self.poster.delegate = self
        poster.postWithExtensionContext(context)
    }
}

extension ActionRequestHandler: OneChannelPosterAppExtensionDelegate {
    func postDidFailWithError(error: NSError) {
        Answers.logCustomEventWithName("Action Extension - Send Failed", customAttributes: ["error":error.localizedDescription])
        // ignore the error for now
        print("ActionRequestHandler had trouble posting an item: error \(error)")
        postDidFinish()
    }
    func postDidFinish() {
        Answers.logCustomEventWithName("Action Extension - Send Success", customAttributes: [:])
        self.extensionContext?.completeRequestReturningItems([], completionHandler:nil)
        self.extensionContext = nil
    }
}