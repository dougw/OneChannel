//
//  Settings.swift
//  ToMeFromMe
//
//  Created by Doug Williams on 11/4/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import Foundation

//
//  Settings.swift
//  Copper
//  This class manages
//
//  Created by Doug Williams on 4/19/15.
//  Copyright (c) 2015 Doug Williams. All rights reserved.
//

import UIKit

public class Settings {
    
    enum Key: String {
        case SlackAccessToken = "slack_access_token"
        case SlackChannel = "slack_channel"
        case SlackTeamName = "slack_team_name"
        case SlackWebhookURL = "slack_webhook_url"
    }
    
    public class var slackAccessToken: String? {
        get {
            return Settings.getString(.SlackAccessToken)
        } set {
            if newValue == nil {
                Settings.deleteString(.SlackAccessToken)
            } else {
                Settings.setString(.SlackAccessToken, value: newValue!)
            }
        }
    }
    
    public class var slackChannel: String? {
        get {
        return Settings.getString(.SlackChannel)
        } set {
            if newValue == nil {
                Settings.deleteString(.SlackChannel)
            } else {
                Settings.setString(.SlackChannel, value: newValue!)
            }
        }
    }
    
    public class var slackTeamName: String? {
        get {
        return Settings.getString(.SlackTeamName)
        } set {
            if newValue == nil {
                Settings.deleteString(.SlackTeamName)
            } else {
                Settings.setString(.SlackTeamName, value: newValue!)
            }
        }
    }
    
    
    public class var slackWebhookURL: String? {
        get {
        return Settings.getString(.SlackWebhookURL)
        } set {
            if newValue == nil {
                Settings.deleteString(.SlackWebhookURL)
            } else {
                Settings.setString(.SlackWebhookURL, value: newValue!)
            }
        }
    }
    
    public class var slackIsConfigured: Bool {
        return slackAccessToken != nil && slackChannel != nil && slackTeamName != nil && slackWebhookURL != nil
    }
    
    public class func resetSlackSettings() {
        self.slackAccessToken = nil
        self.slackChannel = nil
        self.slackTeamName = nil
        self.slackWebhookURL = nil
    }
    
    // MARK: - Implementation methods
    
    static var defaults: NSUserDefaults {
        if let d = NSUserDefaults(suiteName: "group.com.withcopper.OneChannel") {
            return d
        } else {
            return NSUserDefaults.standardUserDefaults()
        }
    }

    class func getBool(key: Key) -> Bool {
        return defaults.boolForKey(key.rawValue)
    }
    
    class func setBool(key: Key, value: Bool) {
       defaults.setBool(value, forKey: key.rawValue)
    }
    
    class func getInt(key: Key) -> Int {
        return defaults.integerForKey(key.rawValue)
    }
    
    class func setInt(key: Key, value: Int) {
        defaults.setInteger(value, forKey: key.rawValue)
    }
    
    class func deleteInt(key: Key) {
       defaults.removeObjectForKey(key.rawValue)
    }
    
    // include the user id optionally to create a custom string to by scoped to this userid
    class func getString(key: Key, userId: String! = nil) -> String? {
        var key = key.rawValue
        if userId != nil {
            key += "_\(userId)"
        }
        return defaults.stringForKey(key) as String?
    }
    
    class func setString(key: Key, value: String, userId: String! = nil) {
        var key = key.rawValue
        if userId != nil {
            key += "_\(userId)"
        }
        defaults.setObject(value, forKey: key)
    }
    
    class func deleteString(key: Key, userId: String! = nil) {
        var key = key.rawValue
        if userId != nil {
            key += "_\(userId)"
        }
        defaults.removeObjectForKey(key)
    }
    
    public class func resetSettings(userId: String! = nil) {
        for key in defaults.dictionaryRepresentation().keys {
            defaults.removeObjectForKey(key)
        }
    }
}