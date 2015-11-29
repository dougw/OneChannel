//
//  OauthViewController.swift
//  OneChannel
//
//  Created by Doug Williams on 11/5/15.
//  Copyright © 2015 Doug Williams. All rights reserved.
//

import UIKit
import OAuthSwift

// ====================================================
// NOTE: This is currently not working and therefore unused
// Awaiting a fix from the team that manages OauthSwift
// ====================================================

class WebViewController: OAuthWebViewController {
    var targetURL : NSURL?
    var webView : UIWebView = UIWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.bounds
        webView.autoresizingMask = [.FlexibleHeight, .FlexibleHeight]
        webView.scalesPageToFit = true
        view.addSubview(webView)
        loadAddressURL()
    }
    
    func setUrl(url: NSURL) {
        targetURL = url
    }
    
    func loadAddressURL() {
        if let targetURL = targetURL {
            let req = NSURLRequest(URL: targetURL)
            webView.loadRequest(req)
        }
    }
}