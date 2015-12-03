//
//  OneChannelPoster.swift
//  OneChannel
//
//  Created by Doug Williams on 12/3/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import Foundation

public class OneChannelPoster: NSObject {
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    public func send(text: String, callback: ((success: Bool, error: NSError?)->())) {
        guard Settings.slackIsConfigured else {
            callback(success: false, error: Error.ConfigureSlack.error)
            return
        }
        if text.isEmpty {
            callback(success: false, error: Error.MissingText.error)
        }
        guard let payload = createPayload(text) else {
            callback(success: false, error: Error.MissingParameter.error)
            return
        }
        
        // create the request
        let request = NSMutableURLRequest(URL: NSURL(string: Settings.slackWebhookURL!)!)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(payload, options: NSJSONWritingOptions())
            request.HTTPBody = json
        } catch {
            callback(success: false, error: Error.JsonError.error)
            return
        }
        request.HTTPMethod = "POST"
        
        // send the request
        let task = session.dataTaskWithRequest(request) { data, response, error in
            dispatch_async(dispatch_get_main_queue(), {
                // look at the response
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // get the response string back which is returned as the body of the response
                        guard let data = data else {
                            callback(success: false, error: Error.SlackError.error("We didn't hear anything back from Slack."))
                            return
                        }
                        guard let responseString = NSString(data: data, encoding:NSUTF8StringEncoding) as? String else {
                            callback(success: false, error: Error.SlackError.error("We didn't understand what we heard back from Slack."))
                            return
                        }
                        // inspect the response
                        if let res = SlackResponse(rawValue: responseString) {
                            switch res {
                            case .Success:
                                callback(success: true, error: nil)
                                return
                            case .ChannelNotFound, .NotInChannel, .ChannelArchived:
                                Settings.resetSlackSettings()
                                callback(success: false, error: Error.SlackError.error("Slack is reporting that your channel is not found or that you are no longer a member of the channel. Reconfigure Add to Slack in Settings. 🤕"))
                                return
                            case .NotAuthed, .InvalidAuth, .AccountInactive, .BadToken:
                                Settings.resetSlackSettings()
                                callback(success: false, error: Error.SlackError.error("Slack is reporting an authentication error. Go to Settings and reconfigure Add to Slack. 🤒"))
                                return
                            case .NoText, .TextTooLong:
                                callback(success: false, error: Error.SlackError.error("Slack says your message is too short or (more likely) too long. 🙃"))
                                return
                            case .RateLimited:
                                callback(success: false, error: Error.SlackError.error("Enhance your chill. Slack is rate limiting us. 😕"))
                                return
                            }
                        }
                        callback(success: false, error: Error.SlackError.error("We didn't understand what we heard back from Slack. 😾"))
                        return
                    } else {
                        callback(success: false, error: Error.HTTPError.error("There was one of those problems the Internet has sometimes with error code \(httpResponse.statusCode) 💀"))
                        return
                    }
                } else {
                    print(error)
                    callback(success: false, error: Error.NoResponse.error)
                    return
                }
            })
        }
        task.resume()
    }
    
    private func createPayload(text: String) -> [String:String]? {
        if text.isEmpty {
            return [String:String]?()
        }
        if !Settings.slackIsConfigured {
            return [String:String]?()
        }
        var payload = [String:String]()
        payload[SlackPayloadKey.Text.rawValue] = text
        payload[SlackPayloadKey.Token.rawValue] = Settings.slackAccessToken!
        payload[SlackPayloadKey.Icon_Emoji.rawValue] = DefaultIconEmoji
        payload[SlackPayloadKey.Channel.rawValue] = Settings.slackChannel!
        payload[SlackPayloadKey.Parse.rawValue] = "full"
        return payload
    }
    
}