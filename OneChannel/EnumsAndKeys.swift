//
//  EnumsAndKeys.swift
//  OneChannel
//
//  Created by Doug Williams on 12/3/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import Foundation

let DefaultIconEmoji = ":facepunch:"

enum SlackPayloadKey: String {
    case Text = "text"
    case Token = "token"
    case Username = "username"
    case Icon_Emoji = "icon_emoji"
    case Channel = "channel"
    case Parse = "parse"
}

enum SlackResponse: String {
    case Success = "ok"
    case ChannelNotFound = "channel_not_found"
    case NotInChannel = "not_in_channel"
    case ChannelArchived = "is_archived"
    case BadToken = "Bad token"
    case NoText = "no_text"
    case TextTooLong = "msg_too_long"
    case RateLimited = "rate_limited"
    case NotAuthed = "not_authed"
    case InvalidAuth = "invalid_auth"
    case AccountInactive = "account_inactive"
}

public enum ActionExtensionKeys: String {
    case PageURL = "pageURL"
    case PageTitle = "pageTitle"
    case SelectedText = "selectedText"
    case PageSource = "pageSource"
}

public enum Error: Int {
    case ConfigureSlack = 0
    case MissingParameter = 1
    case NoResponse = 2
    case HTTPError = 3
    case MissingText = 4
    case OauthError = 5
    case JsonError = 6
    case SlackError = 7
    
    var message: String {
        switch self {
        case .ConfigureSlack:
            return "Add to Slack in OneChannel Settings to send 👊🏽"
        case .MissingParameter:
            return "Hrm, something's wrong. We suggest you reconnect your Slack channel in OneChannel Settings 🤒"
        case .NoResponse:
            return "We didn't hear back from Slack. Is your Internet down? 🤕"
        case .HTTPError:
            return "There was an unexpected Internet HTTP error. 💀"
        case .MissingText:
            return "If a tree falls in the woods and no one is around, does it make a sound? And if you don't give us a message to send, can we really send it? 😘"
        case .OauthError:
            return "We're didn't get permission post on your behalf. 🤔"
        case .JsonError:
            return "We're having a hard time sending that. Try changing your text. We suggest you remove any abnormal characters. 😷"
        case .SlackError:
            return "Slack returned an error saying something is wrong on our side 🐝"
        }
    }
    
    var domain: String {
        return "com.igudo.OneChannel"
    }
    
    var error: NSError {
        return NSError(domain: self.domain, code: self.rawValue, userInfo:[NSLocalizedDescriptionKey: self.message])
    }
    
    func error(message: String) -> NSError {
        return NSError(domain: self.domain, code: self.rawValue, userInfo:[NSLocalizedDescriptionKey: message])
    }
}