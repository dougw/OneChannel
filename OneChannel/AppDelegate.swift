//
//  AppDelegate.swift
//  ToMeFromMe
//
//  Created by Doug Williams on 11/4/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import UIKit
import OAuthSwift
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Fabric.with([Crashlytics.self])
        UITextField.appearance().keyboardAppearance = .Dark
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        // look for the url == SlackRedirectURI
        if (url.scheme == "onechannel29") {
            if url.host == "slack" {
                if url.path!.hasPrefix("/callback") {
                    OAuth2Swift.handleOpenURL(url)
                    // Currently broken ... see note in OauthViewController
                    // UIApplication.sharedApplication().keyWindow!.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {

    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {

    }

    func applicationWillTerminate(application: UIApplication) {

    }
}

let SlackToken = "3873983481.15893383671"
let SlackSecret = "9ee94dbb55810d37eb1405cf3449e314"
let SlackRedirectURI = "onechannel29://slack/callback"
let SlackAuthorizeURL = "https://slack.com/oauth/authorize"
let SlackAccessTokenURL = "https://slack.com/api/oauth.access"
let SlackScope = "incoming-webhook"