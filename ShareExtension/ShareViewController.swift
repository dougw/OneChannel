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

class ShareViewController: SLComposeServiceViewController {
    
    let poster = OneChannelPoster()
    var alert: UIAlertController?
    
    override func viewDidLoad() {
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
    }
    func postDidFinish() {
        self.extensionContext?.completeRequestReturningItems([], completionHandler:nil)
    }
}