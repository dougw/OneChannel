//
//  Utils.swift
//  ToMeFromMe
//
//  Created by Doug Williams on 11/4/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import UIKit

class Utils {

    class func displayAlert(viewController: UIViewController, title: String, message: String? = nil, success: (() -> ())! = nil, cancel: (() -> ())! = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        // add an optional cancel prompt
        if cancel != nil {
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
                if cancel != nil {
                    cancel()
                }
            })
            alert.addAction(cancelAction)
        }
        
        // add the OK prompt
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { action in
            if success != nil {
                success()
            }
        })
        alert.addAction(okAction)
        
        // ensure we're on the main thread since we touch the UI
        dispatch_async(dispatch_get_main_queue(), {
            viewController.presentViewController(alert, animated: true, completion: nil)
        })
    }

}