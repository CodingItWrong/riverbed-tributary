//
//  ShareViewController.swift
//  HydrantShare
//
//  Created by Josh Justice on 11/20/17.
//  Copyright © 2017 NeedBee. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func didSelectPost() {
        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
        let urlString = "http://localhost:3000/webhooks/hydrant"
        let url = URL(string: urlString)!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        let bodyDict = ["message": "hello, world!"]
        let bodyData = try! JSONSerialization.data(withJSONObject: bodyDict, options: [])
        request.httpMethod = "POST";
        request.httpBody = bodyData;

        let task = session.dataTask(with: request)
        task.resume()
    
        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
