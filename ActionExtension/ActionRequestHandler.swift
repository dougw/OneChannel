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

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?
    let poster = OneChannelPoster()
    
    func beginRequestWithExtensionContext(context: NSExtensionContext) {
        self.extensionContext = context
        self.poster.delegate = self
        poster.postWithExtensionContext(context)
    }
}

extension ActionRequestHandler: OneChannelPosterAppExtensionDelegate {
    func postDidFailWithError(error: NSError) {
        // ignore the error for now
        print("ActionRequestHandler had trouble posting an item: error \(error)")
        postDidFinish()
    }
    func postDidFinish() {
        self.extensionContext?.completeRequestReturningItems([], completionHandler:nil)
        self.extensionContext = nil
    }
}