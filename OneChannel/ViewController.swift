//
//  ViewController.swift
//  ToMeFromMe
//
//  Created by Doug Williams on 11/4/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import UIKit
import OAuthSwift
import OneChannelKit

class ViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Constants
    let SlackPostMessageURL:String = "https://slack.com/api/chat.postMessage"
    let DefaultHeaderChannelLabelText = "OneChannel"
    let ANIMATION_DURATION:Double = 0.35
    let SPRING_DAMPENING:CGFloat = 0.75
    
    enum Mode {
        case Main
        case Settings
    }
    
    // Main View
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var mainViewCenterYLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendButtonHeightConstraint: NSLayoutConstraint!
    // Header
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerChannelLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    // Settings
    @IBOutlet weak var settingsView: UIView!
    // Add View
    @IBOutlet weak var addToSlackView: UIView!
    @IBOutlet weak var addToSlackButton: UIButton!
    // Configured View
    @IBOutlet weak var configuredSettingsView: UIView!
    @IBOutlet weak var configuredTextView: UITextView!
    @IBOutlet weak var disconnectFromSlackButton: UIButton!

    var keyboardRect: CGRect?
    var sendViewTap: UIGestureRecognizer!
    var mainViewTap: UIGestureRecognizer!
    var wasPosting: Bool = false
    let poster = OneChannelPoster()
    
    var mode: Mode = .Main {
        didSet {
            updateConstraints()
        }
    }
    
    var sendButtonEnabled = true {
        didSet(oldValue) {
            sendViewTap.enabled = sendButtonEnabled
            if oldValue != sendButtonEnabled {
                let buttonBackgroundColor = sendButtonEnabled ? UIColor.sendButtonEnabledColor() : UIColor.sendButtonDisabledColor()
                UIView.animateWithDuration(0.35,
                    animations: {
                        self.sendView.backgroundColor = buttonBackgroundColor
                    }
                )
                updateConstraints()
            }
        }
    }
    
    var channelDisplayString: String {
        guard let channel = Settings.slackChannel else {
            return "OneChannel"
        }
        return channel
    }
    
    
    var mainViewCenterYOffset: CGFloat {
        // we move the main view down respective to the size of the header
        return headerView.frame.height / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Settings View
        addToSlackButton.layer.cornerRadius = 10.0
        configureSettingsView()
        
        // Main View
        textView.delegate = self
        mainViewTap = UITapGestureRecognizer(target: self, action: "mainViewTapped:")
        mainView.addGestureRecognizer(mainViewTap)
        mainViewTap.enabled = false
        sendViewTap = UITapGestureRecognizer(target: self, action: "sendViewTapped:")
        sendView.addGestureRecognizer(sendViewTap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillAppear:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        // set off the chain to hide the send button, set the first responder, and update the constraints
        sendButtonEnabled = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:  UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:  UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillAppear(notification:NSNotification){
        keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        updateConstraints()
    }
    
    func keyboardWillHide(notification:NSNotification) {
        keyboardRect = nil
        updateConstraints()
    }
    
    func updateConstraints() {
        switch mode {
        case .Main:
            // setup gestureRecognizers
            for gestureRecognizer in textView.gestureRecognizers! {
                gestureRecognizer.enabled = true
            }
            textView.becomeFirstResponder()
            mainViewTap.enabled = false
            // reset our wasPosting variable in case this was simply a close
            wasPosting = false
            // determine where we want the lay out to be
            var newBottomLayout:CGFloat = 0.0
            if let keyboardRect = self.keyboardRect {
                newBottomLayout += keyboardRect.size.height
            }
            if !sendButtonEnabled {
                newBottomLayout -= self.sendButtonHeightConstraint.constant
            }
            // affect the change!=
            UIView.animateWithDuration(ANIMATION_DURATION, delay: 0.0, usingSpringWithDamping: SPRING_DAMPENING, initialSpringVelocity: 0.0, options: [],
            animations: {
                    self.mainViewCenterYLayoutConstraint.constant = self.mainViewCenterYOffset
                    self.sendButtonLayoutConstraint.constant = newBottomLayout
                    self.view.layoutIfNeeded()
                }, completion: nil)
        case .Settings:
            // setup gestureRecognizers
            for gestureRecognizer in textView.gestureRecognizers! {
                gestureRecognizer.enabled = false
            }
            configureSettingsView()
            mainViewTap.enabled = true
            // calculate how far to move ... just below Settings
            let settingsRevealHeight = settingsView.frame.height
            // affect the change!
            UIView.animateWithDuration(ANIMATION_DURATION, delay: 0.0, usingSpringWithDamping: SPRING_DAMPENING, initialSpringVelocity: 0.0, options: [],
                animations: {
                    self.mainViewCenterYLayoutConstraint.constant = settingsRevealHeight + self.mainViewCenterYOffset
                    self.view.layoutIfNeeded()
                }, completion: nil)
        }
    }
    
    func toggleSettingsView() {
        mode = mode == .Main ? .Settings : .Main
    }
    
    // MARK: - Main View
    
    func mainViewTapped(sender: UIGestureRecognizer) {
        toggleSettingsView()
    }
    
    // MARK: - Header View
    
    @IBAction func settingsButtonPressed(sender: AnyObject) {
        toggleSettingsView()
    }
    
    // MARK: SettingsView
    
    @IBAction func addToSlackButtonPressed(sender: AnyObject) {
        if Settings.slackIsConfigured {
            Settings.resetSettings()
            configureSettingsView()
        } else {
            handleAddToSlack()
        }
    }

    func configureSettingsView() {
        if Settings.slackIsConfigured {
            headerChannelLabel.text = "\(channelDisplayString)"
            configuredTextView.text = "You are posting to \(channelDisplayString) on team \(Settings.slackTeamName!) on Slack."
            configuredSettingsView.hidden = false
            UIView.animateWithDuration(0.35,
                animations: {
                    self.configuredSettingsView.alpha = 1.0
                    self.addToSlackView.alpha = 0.0
                },
                completion: { finished in
                    self.addToSlackView.hidden = true
                }
            )
        } else {
            addToSlackButton.setTitle("Add to Slack", forState: .Normal)
            headerChannelLabel.text = DefaultHeaderChannelLabelText
            addToSlackView.hidden = false
            UIView.animateWithDuration(0.35,
                animations: {
                    self.configuredSettingsView.alpha = 0.0
                    self.addToSlackView.alpha = 1.0
                },
                completion: { finished in
                    self.configuredSettingsView.hidden = true
                }
            )
        }
    }
    
    @IBAction func feedbackButtonPressed(sender: UIButton) {
        if !UIApplication.sharedApplication().openURL(NSURL(string: "twitter://user?screen_name=withcopper")!) {
            UIApplication.sharedApplication().openURL(NSURL(string: "http://www.twitter.com/withcopper")!)
        }
    }

    // MARK: TextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        sendButtonEnabled = !textView.text.isEmpty
    }
    
    // MARK: - Send activities
    
    func sendViewTapped(sender: UIGestureRecognizer) {
        guard Settings.slackIsConfigured else {
            // Utils.displayAlert(self, title: "Step 1. Add to Slack to connect a channel", message: "(We'll help you do that)\n\nStep 2. Profit.")
            self.wasPosting = true
            self.mode = .Settings
            return
        }
        send()
    }
    
    func send() {
        // clear the text to indicate progress
        let text = textView.text
        self.textView.text = ""
        self.textViewDidChange(self.textView)
        // send it!
        self.activityIndicator.startAnimating()
        poster.send(text, callback: { (success: Bool, error: NSError?) in
            self.activityIndicator.stopAnimating()
            if !success {
                self.textView.text = text
                self.textViewDidChange(self.textView)
                var message = "Error unknown :("
                if let error = error {
                    // if this is one of our errors
                    if let _ = Error(rawValue: error.code) {
                        message = error.localizedDescription
                    }
                }
                Utils.displayAlert(self, title: "Bummer", message: message)
            }
        })
    }
    
    // MARK: - OAuth
    
    func handleAddToSlack(sending: Bool = false) {
        self.activityIndicator.startAnimating()
        addToSlackButton.enabled = false
        let oauthswift = OAuth2Swift(
            consumerKey:    SlackToken,
            consumerSecret: SlackSecret,
            authorizeUrl:   SlackAuthorizeURL,
            accessTokenUrl: SlackAccessTokenURL,
            responseType: "code"
        )
        // currently broken -- see note in OauthViewController
        // when working, this will offer an in-app experience for the oauth dialog
        // which would be niiiiice......
        // oauthswift.authorize_url_handler = WebViewController()
        let state = generateStateWithLength(32) as String
        oauthswift.authorizeWithCallbackURL( NSURL(string: SlackRedirectURI)!, scope: SlackScope, state: state, success: {
            credential, response, parameters in
                self.activityIndicator.stopAnimating()
                Settings.slackAccessToken = credential.oauth_token
                Settings.slackChannel = parameters["incoming_webhook"]!["channel"] as? String
                Settings.slackWebhookURL = parameters["incoming_webhook"]!["url"] as? String
                Settings.slackTeamName = parameters["team_name"] as? String
                self.configureSettingsView()
                if self.wasPosting {
                    self.send()
                }
                // .Main resets wasPosting
                self.mode = .Main
                self.addToSlackButton.enabled = true
            }, failure: { (error: NSError) in
                self.activityIndicator.stopAnimating()
                Settings.resetSettings()
                self.addToSlackButton.enabled = true
                Utils.displayAlert(self, title: "We weren't able to Add OneChannel to Slack 😢")
                print(error)
            }
        )
    }
}
