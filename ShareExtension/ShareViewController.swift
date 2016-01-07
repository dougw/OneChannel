//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Doug Williams on 12/3/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import UIKit
import Social
import OneChannelKit
import Crashlytics

class ShareViewController: SLComposeServiceViewController {
    
    let poster = OneChannelPoster()
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        // log
        Answers.logCustomEventWithName("Share Extension - Opened", customAttributes: [:])
        poster.delegate = self
    }

    override func isContentValid() -> Bool {
        return true
    }

    override func didSelectPost() {
        poster.postWithExtensionContext(extensionContext!, contentText: self.contentText)
    }
    
    override func configurationItems() -> [AnyObject]! {
        return []
    }
}

extension ShareViewController: OneChannelPosterAppExtensionDelegate {
    func postDidFailWithError(error: NSError) {
        poster.displayAlert(self, error: error)
        // log
        Answers.logCustomEventWithName("Share Extension - Send Failed", customAttributes: ["error":error.localizedDescription])
    }
    func postDidFinish() {
        // log
        Answers.logCustomEventWithName("Share Extension - Send Success", customAttributes: [:])
        self.extensionContext?.completeRequestReturningItems([], completionHandler:nil)
    }
}