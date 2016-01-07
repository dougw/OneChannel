//
//  OneChannelPoster.swift
//  OneChannel
//
//  Created by Doug Williams on 12/3/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import Foundation
import MobileCoreServices

public protocol OneChannelPosterAppExtensionDelegate: class {
    func postDidFailWithError(error: NSError)
    func postDidFinish()
}

public class OneChannelPoster: NSObject {
    
    let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    var alert: UIAlertController?
    
    public var delegate: OneChannelPosterAppExtensionDelegate?
    
    let AlertDelayDefault: Double = 5.0 // default number of seconds to allow the alert to display

    public func postWithExtensionContext(extensionContext: NSExtensionContext, contentText: String! = nil) {
        
        guard let item = extensionContext.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider else {
            delegate?.postDidFailWithError(Error.MissingText.error)
            delegate?.postDidFinish()
            return
        }
        
        // first we see if this is a URL from an Action Extension
        let propertyList = String(kUTTypePropertyList)
        let propertyURL = String(kUTTypeURL)
        let propertyText = String(kUTTypePlainText)
        
        // Action extension: URL type
        if itemProvider.hasItemConformingToTypeIdentifier(propertyList) {
            itemProvider.loadItemForTypeIdentifier(propertyList, options: nil, completionHandler: { (item, error) -> Void in
                let dictionary = item as! NSDictionary
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as! NSDictionary
                    if let urlString = results[ActionExtensionKeys.PageURL.rawValue] as? String,
                        let url = NSURL(string: urlString) {
                            // we ignore contentText with action extensions and build the string ourselves
                            // based on the javascript action
                            // first, add the page title if it exists
                            var text = results[ActionExtensionKeys.PageTitle.rawValue] as? String
                            // next, add a quote/selected text if any is found
                            if let selectedText = results[ActionExtensionKeys.SelectedText.rawValue] as? String where selectedText != "" {
                                if text == nil {
                                    text = "\"\(selectedText)\""
                                } else {
                                    text = "\(text!)\n\"\(selectedText)\""
                                }
                            }
                            let textToPost = self.textToPost(text, textFromAttachment: url.absoluteString)
                            self.post(textToPost, extensionContext: extensionContext)
                    }
                }
            })
        // Share extension: URL type
        } else if itemProvider.hasItemConformingToTypeIdentifier(propertyURL) {
            itemProvider.loadItemForTypeIdentifier(propertyURL, options: nil, completionHandler: { (url, error) -> Void in
                if let shareURL = url as? NSURL {
                    let textToPost = self.textToPost(contentText, textFromAttachment: shareURL.absoluteString)
                    self.post(textToPost, extensionContext: extensionContext)
                }
            })
        // Share extension: Text type
        } else if itemProvider.hasItemConformingToTypeIdentifier(propertyText) {
            itemProvider.loadItemForTypeIdentifier(propertyText, options: nil, completionHandler: { (plainText, error) -> Void in
                if let plainText = plainText as? String {
                    let textToPost = self.textToPost(contentText, textFromAttachment: plainText)
                    self.post(textToPost, extensionContext: extensionContext)
                }
            })
        } else if contentText != nil && !contentText.isEmpty {
            self.post(contentText, extensionContext: extensionContext)
        } else {
            delegate?.postDidFailWithError(Error.MissingText.error)
            delegate?.postDidFinish()
        }

    }
    
    private func textToPost(contentText: String?, textFromAttachment: String! = nil) -> String {
        if contentText == nil || contentText!.isEmpty {
            return textFromAttachment!
        } else {
            return  "\(contentText!)\n\(textFromAttachment!)"
        }
    }
    
    private func post(text: String, extensionContext: NSExtensionContext) {
        print("Posting: \(text)")
        self.send(text, callback: { (success: Bool, error: NSError?) in
            if error != nil {
                self.delegate?.postDidFailWithError(error!)
            } else {
                self.delegate?.postDidFinish()
            }
        })
    }
    
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
        
    public func displayAlert(viewController: UIViewController, error: NSError, withDelay delay: Double! = nil) {
        alert = UIAlertController(title: "OneChannel had a problem sending that", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        viewController.presentViewController(alert!, animated: true, completion: {
            // no op
        })
        let sleep = delay ?? AlertDelayDefault
        NSThread.sleepForTimeInterval(sleep)
        self.alert = nil
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